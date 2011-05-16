//
//  NSNotification+MGPAssetDownloader.m
//  MGPRemoteAssetController
//
//  Created by Saul Mora on 5/16/11.
//  Copyright 2011 Magical Panda Software LLC. All rights reserved.
//

#import "NSNotification+MGPAssetDownloader.h"


@implementation NSNotification (NSNotification_MGPAssetDownloader)

- (MGPRemoteAssetDownloader *) downloader;
{
    return [[self userInfo] valueForKey:kMGPDownloaderKey];
}

@end