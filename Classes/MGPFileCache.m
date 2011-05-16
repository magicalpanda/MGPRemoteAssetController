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

- (id) assetForKey:(id)key;
{
    return nil;
}

//- (id) expireAssetForKey:(id)key;
- (unsigned long long) fileSizeForKey:(id)key;
{
    return 0;    
}

- (NSDictionary *) metadataForKey:(id)key;
{
    return nil;
}


@end
