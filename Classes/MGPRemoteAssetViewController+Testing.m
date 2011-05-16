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

static NSMutableArray *urls = nil;

@implementation MGPRemoteAssetViewController (MGPRemoteAssetViewController_Testing)

- (IBAction) beginNextDownload;
{
    if (urls == nil)
    {
        urls = [[NSMutableArray arrayWithObjects:
                            @"http://cl.ly/0D3L282D12162B2u0v1H/Magical_Core_Data.key",
                            @"http://support.apple.com/downloads/DL1379/en_US/iPhoto9.1.3Update.dmg",
                            @"http://support.apple.com/downloads/DL1381/en_US/MacBookProEFIUpdate.dmg",
                            @"http://support.apple.com/downloads/DL1377/en_US/SnowLeopardFontUpdate.dmg",
                            @"http://support.apple.com/downloads/DL1376/en_US/SecUpd2011-002Snow.dmg",
                            nil] retain];
    }
    
    if ([urls count])
    {
        NSString *nextUrl = [urls lastObject];
        [urls removeLastObject];
        
        NSURL *url = [NSURL URLWithString:nextUrl];
        [self.downloadController downloadAssetAtURL:url];
     }
}

@end