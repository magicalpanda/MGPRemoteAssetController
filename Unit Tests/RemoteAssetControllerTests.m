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

- (void) tearDown
{
    self.testController = nil;
}

- (MGPRemoteAssetDownloader *) downloaderWithURL:(NSURL *)url
{
    return [OCMockObject niceMockForClass:[MGPRemoteAssetDownloader class]];
}

- (void) testShouldBeCreated
{
    assertThat(self.testController, is(notNilValue()));
}

- (void) testShouldSetupANewDownloader
{
    NSURL *testUrl = [TestHelpers fileURLForFixtureNamed:@"nsbrief_logo.png"];
    
    MGPRemoteAssetDownloader *downloader = [self.testController downloadAssetAtURL:testUrl];
    
    assertThat(downloader, is(notNilValue()));
    assertThat(downloader.fileManager, is(equalTo([NSFileManager defaultManager])));
    assertThat(downloader.URL, is(equalTo(testUrl)));
    assertThat(downloader.downloadPath, is(equalTo([NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject])));
    
    assertThatInteger([self.testController.activeDownloads count], is(equalToInteger(1)));
}

- (void) testShouldNotifyWhenADownloaderIsAddedToController
{
    id mockObserver = [OCMockObject observerMock];
    
    [[NSNotificationCenter defaultCenter] addMockObserver:mockObserver name:kMGPRADownloadsControllerDownloadAddedNotification object:self.testController];
    
    [[mockObserver expect] notificationWithName:kMGPRADownloadsControllerDownloadAddedNotification object:self.testController userInfo:[OCMArg any]];
    
    [self.testController downloadAssetAtURL:[TestHelpers fileURLForFixtureNamed:@"nsbrief_logo.png"]];
    
    [mockObserver verify];
}

- (void) testShouldNotifyWhenADownloaderIsComplete
{
    id mockObserver = [OCMockObject observerMock];
    
    [[NSNotificationCenter defaultCenter] addMockObserver:mockObserver name:kMGPRADownloadsControllerDownloadCompletedNotification object:self.testController];
    
    [[mockObserver expect] notificationWithName:kMGPRADownloadsControllerDownloadCompletedNotification object:self.testController userInfo:[OCMArg any]];
    
    [self.testController downloadAssetAtURL:[TestHelpers fileURLForFixtureNamed:@"nsbrief_logo.png"]];
    
    [mockObserver verify];
}

- (void) testShouldNotAddANewDownloaderForTheSameURL
{
    NSURL *testUrl = [TestHelpers fileURLForFixtureNamed:@"nsbrief_logo.png"];
    MGPRemoteAssetDownloader *firstDownloader = [self.testController downloadAssetAtURL:testUrl];
    MGPRemoteAssetDownloader *secondDownloader = [self.testController downloadAssetAtURL:testUrl];
    
    assertThat(firstDownloader, is(equalTo(secondDownloader)));
}

- (void) testShouldPauseDownloads
{
    GHFail(@"Not Implemented");
}

- (void) testShouldResumeDownloads
{
    GHFail(@"Not Implemented");    
}

@end
