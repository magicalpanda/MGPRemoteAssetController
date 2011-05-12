//
//  MGPRemoteAssetTableViewCell.m
//  MGPRemoteAssetController
//
//  Created by Saul Mora on 5/8/11.
//  Copyright 2011 Magical Panda Software LLC. All rights reserved.
//

#import "MGPRemoteAssetTableViewCell.h"


@implementation MGPRemoteAssetTableViewCell

@synthesize fileName = fileName_;
@synthesize fileSize = fileSize_;
@synthesize url = url_;
@synthesize timeRemaining = timeRemaining_;
@synthesize downloadProgress = downloadProgress_;

- (void) dealloc
{
    self.fileName = nil;
    self.fileSize = nil;
    self.url = nil;
    self.timeRemaining = nil;
    self.downloadProgress = nil;
    [super dealloc];
}

@end
