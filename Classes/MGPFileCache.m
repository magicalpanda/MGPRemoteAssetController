//
//  MGPFileCache.m
//  MGPRemoteAssetController
//
//  Created by Saul Mora on 5/14/11.
//  Copyright 2011 Magical Panda Software LLC. All rights reserved.
//

#import <ImageIO/ImageIO.h>
#import "MGPFileCache.h"
#import "NSDate+Helpers.h"

static NSString * kMGPFileCacheDefaultCacheFolder = @"MGPAssetCache";

CGSize sizeForImageAtURL(NSURL *imageFileURL)
{
    CGImageSourceRef imageSource = CGImageSourceCreateWithURL((CFURLRef)imageFileURL, NULL);
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

@interface MGPFileCache ()

@property (nonatomic, retain) NSFileManager *fileManager;

@end

@implementation MGPFileCache

@synthesize fileManager = fileManager_;

- (NSString *) cachePath;
{
    NSString *subfolder = kMGPFileCacheDefaultCacheFolder;
    return [[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject] stringByAppendingPathComponent:subfolder];
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

+ (MGPFileCache *) defaultCache;
{
    static dispatch_once_t pred;
    static MGPFileCache *fileCache = nil;
    
    dispatch_once(&pred, ^{ fileCache = [[self alloc] init]; });
    return fileCache;
}

- (BOOL) assetValidForKey:(id)key;
{
    return NO;
}

- (unsigned long long) fileSizeForKey:(id)key;
{
    return 0;
}

- (NSDictionary *) metadataForKey:(id)key;
{
    return  nil;
}

- (void) setMetadataForKey:(id)key;
{
    
}

- (void) flushCache;
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSError *error = nil;
    
    [fileManager removeItemAtPath:[self cachePath] error:&error];
}

- (void) expireItemsInCache
{
    NSFileManager *fileManager = [NSFileManager defaultManager];

    NSDirectoryEnumerator *enumerator = [fileManager enumeratorAtPath:[self cachePath]];
    NSError *error = nil;
    NSDate *expirationDate;
    for (NSString *fileName in enumerator)
    {
        NSString *filePath = [[self cachePath] stringByAppendingPathComponent:fileName];
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

- (BOOL) setData:(id)data forKey:(id)key;
{
    return NO;
}

- (NSData *) dataForKey:(id)key;
{
    return nil;
}

@end
