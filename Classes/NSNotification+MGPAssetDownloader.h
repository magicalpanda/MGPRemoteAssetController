//
//  NSNotification+MGPAssetDownloader.h
//  MGPRemoteAssetController
//
//  Created by Saul Mora on 5/16/11.
//  Copyright 2011 Magical Panda Software LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MGPRemoteAssetDownloader.h"

@interface NSNotification (NSNotification_MGPAssetDownloader)

- (MGPRemoteAssetDownloader *) downloader;

@end
