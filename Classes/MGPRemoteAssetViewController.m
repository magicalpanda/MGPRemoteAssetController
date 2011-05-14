//
//  MGPRemoteAssetViewController.m
//  MGPRemoteAssetController
//
//  Created by Saul Mora on 5/14/11.
//  Copyright 2011 Magical Panda Software LLC. All rights reserved.
//

#import "MGPRemoteAssetViewController.h"


@implementation MGPRemoteAssetViewController

@synthesize downloadList = downloadList_;

- (void) dealloc
{
    self.downloadList = nil;
    [super dealloc];
}


@end
