//
//  MGPFileCache.h
//  MGPRemoteAssetController
//
//  Created by Saul Mora on 5/14/11.
//  Copyright 2011 Magical Panda Software LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol MGPFileCacheItem <NSObject>

- (id) fileCacheKey;

@end

@interface MGPFileCache : NSObject {}

@property (nonatomic, readonly, retain) NSFileManager *fileManager;

+ (MGPFileCache *) defaultCache;

- (BOOL) assetValidForKey:(id)key;

- (NSString *) cachePath;
- (unsigned long long) fileSizeForKey:(id)key;
- (NSDictionary *) metadataForKey:(id)key;

- (void) flushCache;

- (BOOL) setData:(id)data forKey:(id)key;
- (NSData *) dataForKey:(id)key;

@end