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

- (id) assetForKey:(id)key;
//- (id) expireAssetForKey:(id)key;
- (unsigned long long) fileSizeForKey:(id)key;
- (NSDictionary *) metadataForKey:(id)key;

@end