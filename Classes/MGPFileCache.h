//
//  MGPFileCache.h
//  MGPRemoteAssetController
//
//  Created by Saul Mora on 5/14/11.
//  Copyright 2011 Magical Panda Software LLC. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface MGPFileCache : NSObject {}

+ (NSString *) cachePath;
+ (MGPFileCache *) sharedCache;

- (unsigned long long) fileSizeForKey:(id)key;
- (NSDictionary *) metadataForKey:(id)key;

- (void) flushCache;

- (BOOL) setData:(id)data forKey:(id)key;
- (NSData *) dataForKey:(id)key;

@end