//
//  MGPFileCache.m
//  MGPRemoteAssetController
//
//  Created by Saul Mora on 5/14/11.
//  Copyright 2011 Magical Panda Software LLC. All rights reserved.
//

#import "MGPFileCache.h"


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
