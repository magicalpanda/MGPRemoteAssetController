//
//  MGPRemoteAssetViewController+Testing.m
//  MGPRemoteAssetController
//
//  Created by Saul Mora on 5/14/11.
//  Copyright 2011 Magical Panda Software LLC. All rights reserved.
//

#import "MGPRemoteAssetViewController+Testing.h"
#import "MGPRemoteAssetViewController.h"
#import "MGPRemoteAssetDownloadsController.h"

@implementation MGPRemoteAssetViewController (MGPRemoteAssetViewController_Testing)

- (IBAction) beginNextDownload;
{
    NSURL *url = [NSURL URLWithString:@"http://cl.ly/0D3L282D12162B2u0v1H/Magical_Core_Data.key"];
    [self.downloadController downloadAssetAtURL:url];
}

@end