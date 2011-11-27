//
//  MGPFileCache.m
//  MGPRemoteAssetController
//
//  Created by Saul Mora on 5/14/11.
//  Copyright 2011 Magical Panda Software LLC. All rights reserved.
//

#import <ImageIO/ImageIO.h>
#import "MGPAssetCacheManager.h"
#import "NSDate+Helpers.h"
#import "NSString+MD5.h"

NSString * const kMGPFileCacheDefaultCacheFolder = @"MGPAssetCache";

CGSize sizeForImageAtURL(NSURL *imageFileURL)
{
    CGImageSourceRef imageSource = CGImageSourceCreateWithURL((__bridge CFURLRef)imageFileURL, NULL);
    if (imageSource == NULL) 
    {
        // Error loading image
        return CGSizeZero;
    }
    
    CGFloat width = 0.0f, height = 0.0f;
    CFDictionaryRef imageProperties = CGImageSourceCopyPropertiesAtIndex(imageSource, 0, NULL);
    if (imageProperties != NULL)
    {
        CFNumberRef widthNum  = CFDictionaryGetValue(imageProperties, kCGImagePropertyPixelWidth);
        if (widthNum != NULL) 
        {
            CFNumberGetValue(widthNum, kCFNumberFloatType, &width);
        }
        
        CFNumberRef heightNum = CFDictionaryGetValue(imageProperties, kCGImagePropertyPixelHeight);
        if (heightNum != NULL) 
        {
            CFNumberGetValue(heightNum, kCFNumberFloatType, &height);
        }
        
        CFRelease(imageProperties);
    }

    return CGSizeMake(width, height);
}

@interface MGPAssetCacheManager ()

@property (nonatomic, retain) NSFileManager *fileManager;
@property (nonatomic, retain) NSCache *memoryCache;

@end

@implementation MGPAssetCacheManager

@synthesize fileManager = fileManager_;
@synthesize memoryCache = memoryCache_;

+ (MGPAssetCacheManager *) defaultCache;
{
    static dispatch_once_t pred;
    static MGPAssetCacheManager *fileCache = nil;
    
    dispatch_once(&pred, ^{ fileCache = [[self alloc] init]; });
    return fileCache;
}

+ (NSString *) cachePath;
{
    NSString *subfolder = kMGPFileCacheDefaultCacheFolder;
    return [[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject] stringByAppendingPathComponent:subfolder];
}

- (NSString *)cachePathForURL:(NSURL *)url
{
    NSString *fileName = [[url absoluteString] mgp_md5];
    NSString *filePath = [[[self class] cachePath] stringByAppendingPathComponent:fileName];
    return filePath;
}

- (void) setupCache
{
    self.fileManager = [NSFileManager defaultManager];
}

-(id)init
{
    self = [super init];
    if (self) 
    {
        [self setupCache];
    }
    return self;
}

- (void) prepareCacheFileForURL:(NSURL *)url;
{
    NSString *cachePath = [[self class] cachePath];
    
    if (![self.fileManager fileExistsAtPath:cachePath])
    {
        if (![self.fileManager createDirectoryAtPath:cachePath withIntermediateDirectories:YES attributes:nil error:nil])
        {
            DDLogWarn(@"Unable to create cache directory: %@", cachePath);
        }
    }

    NSString *filePath = [self cachePathForURL:url];
    if (![self.fileManager fileExistsAtPath:filePath])
    {
        if (![self.fileManager createFileAtPath:filePath contents:nil attributes:nil])
        {
            DDLogWarn(@"Unable to create cache download file: %@", filePath);
        }
    }    
}

- (unsigned long long) fileSizeForURL:(NSURL *)url
{
    NSError *error = nil;
    NSDictionary *fileAttributes = [self.fileManager attributesOfItemAtPath:[self cachePathForURL:url] error:&error];
    return [fileAttributes fileSize];
}

- (void) flushCache;
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSError *error = nil;
    
    [fileManager removeItemAtPath:[[self class] cachePath] error:&error];
}

- (void) expireItemsInCache
{
    NSFileManager *fileManager = [NSFileManager defaultManager];

    NSString *cachePath = [[self class] cachePath];
    NSDirectoryEnumerator *enumerator = [fileManager enumeratorAtPath:cachePath];
    NSError *error = nil;
    NSDate *expirationDate;
    for (NSString *fileName in enumerator)
    {
        NSString *filePath = [cachePath stringByAppendingPathComponent:fileName];
        NSDictionary *attributes = [fileManager attributesOfItemAtPath:filePath error:&error];
        
        if ([[attributes fileModificationDate] mgp_isBefore:expirationDate])
        {
            if (![fileManager removeItemAtPath:filePath error:&error])
            {
                DDLogWarn(@"Could not delete item at path: %@", filePath);
            }
        }
    }
}

- (NSInputStream *) dataStreamForURL:(NSURL *)url;
{
    NSString *filePath = [self cachePathForURL:url];
    return [[NSInputStream alloc] initWithFileAtPath:filePath];
}

- (NSData *) dataForURL:(NSURL *)url;
{
    NSData *fileData = nil;
    if ([self hasURLBeenCached:url])
    {
        fileData = [NSData dataWithContentsOfFile:[self cachePathForURL:url]];
    }

    return fileData;
}

- (BOOL) hasURLBeenCached:(NSURL *)url;
{
    return [self.fileManager fileExistsAtPath:[self cachePathForURL:url]];
}

@end
