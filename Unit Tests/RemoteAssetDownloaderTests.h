//
//  RemoteAssetDownloaderTests.h
//  MGPRemoteAssetController
//
//  Created by Saul Mora on 5/9/11.
//  Copyright 2011 Magical Panda Software LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <GHUnitIOS/GHUnit.h>
#import "OCMock.h"
#define HC_SHORTHAND
#import <OCHamcrestIOS/OCHamcrestIOS.h>

#import "MGPRemoteAssetDownloader.h"

@interface RemoteAssetDownloaderTests : GHTestCase {
    
}

@property (nonatomic, retain) MGPRemoteAssetDownloader *testDownloader;

@end
