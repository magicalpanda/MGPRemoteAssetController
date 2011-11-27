//
//  MGPRemoteAssetTableViewCell.h
//  MGPRemoteAssetController
//
//  Created by Saul Mora on 5/8/11.
//  Copyright 2011 Magical Panda Software LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MGPTableViewCell.h"

@class MGPRemoteAssetDownloader;
@class MGPDownloaderViewController;

@interface MGPRemoteAssetTableViewCell : MGPTableViewCell 

@property (nonatomic, retain) MGPRemoteAssetDownloader *downloader;

@end
