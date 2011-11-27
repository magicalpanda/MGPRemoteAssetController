//
//  MGPFileCache.h
//  MGPRemoteAssetController
//
//  Created by Saul Mora on 5/14/11.
//  Copyright 2011 Magical Panda Software LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSString * const kMGPFileCacheDefaultCacheFolder;

@protocol MGPFileCacheItem <NSObject>

- (id) cacheKey;

@end

@interface MGPAssetCacheManager : NSObject

@property (nonatomic, readonly, retain) NSFileManager *fileManager;

+ (NSString *) cachePath;
+ (MGPAssetCacheManager *) defaultCache;

- (void) prepareCacheFileForURL:(NSURL *)url;
- (NSString *)cachePathForURL:(NSURL *)url;

- (unsigned long long) fileSizeForURL:(NSURL *)url;

- (void) flushCache;

- (NSData *) dataForURL:(NSURL *)url;
- (NSInputStream *) dataStreamForURL:(NSURL *)url;

- (BOOL) hasURLBeenCached:(NSURL *)url;

@end