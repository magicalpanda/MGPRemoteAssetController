//
//  RemoteAssetControllerTests.m
//  MGPRemoteAssetController
//
//  Created by Saul Mora on 5/12/11.
//  Copyright 2011 Magical Panda Software LLC. All rights reserved.
//

#import "RemoteAssetControllerTests.h"
#import "MGPRemoteAssetDownloadsController.h"

@implementation RemoteAssetControllerTests

@synthesize testController = testController_;

- (void) testShouldBeCreated
{
    assertThat(self.testController, is(notNilValue()));
}

- (void) testShouldStartDownloadURL
{
    
}

- (void) testShouldNotStartDownloadIfInProgress
{
    
}

- (void) testShouldPauseDownload
{
    
}

- (void) testShouldLoadFileIntoMemoryCacheIfLessThan100k
{
    
}

- (void) testShouldNotifyWhenDownloadCompletes
{
    
}

@end
