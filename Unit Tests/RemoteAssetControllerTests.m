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

- (void) setUp
{
    self.testController = [[[MGPRemoteAssetDownloadsController alloc] init] autorelease];
}

- (void) testShouldBeCreated
{
    assertThat(self.testController, is(notNilValue()));
}

- (void) testShouldStartDownloadURL
{
    GHFail(@"Not Implemented");
}

- (void) testShouldNotStartDownloadIfInProgress
{
    GHFail(@"Not Implemented");
}

- (void) testShouldPauseDownload
{
    GHFail(@"Not Implemented");
}

- (void) testShouldLoadFileIntoMemoryCacheIfLessThan100k
{
    GHFail(@"Not Implemented");
}

- (void) testShouldNotifyWhenDownloadCompletes
{
    GHFail(@"Not Implemented");
    
}

@end
