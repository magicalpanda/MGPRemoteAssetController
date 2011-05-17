//
//  MGPFileCache.m
//  MGPRemoteAssetController
//
//  Created by Saul Mora on 5/14/11.
//  Copyright 2011 Magical Panda Software LLC. All rights reserved.
//

#import "MGPFileCache.h"
#import "NSDate+Helpers.h"

@implementation MGPFileCache

+ (NSString *) cachePath;
{
    NSString *subfolder = @"MGPAssetCache";
    return [[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject] stringByAppendingPathComponent:subfolder];
}

+ (MGPFileCache *) sharedCache;
{
    return nil;
}
- (unsigned long long) fileSizeForKey:(id)key;
{
    return 0;
}

- (NSDictionary *) metadataForKey:(id)key;
{
    return  nil;
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

    NSDirectoryEnumerator *enumerator = [fileManager enumeratorAtPath:[[self class] cachePath]];
    NSError *error = nil;
    NSDate *expirationDate;
    for (NSString *fileName in enumerator)
    {
        NSString *filePath = [[[self class] cachePath] stringByAppendingPathComponent:fileName];
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
