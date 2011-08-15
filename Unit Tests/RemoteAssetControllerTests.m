//
//  RemoteAssetControllerTests.m
//  MGPRemoteAssetController
//
//  Created by Saul Mora on 5/12/11.
//  Copyright 2011 Magical Panda Software LLC. All rights reserved.
//

#import "RemoteAssetControllerTests.h"
#import "MGPRemoteAssetDownloadsController.h"
#import "MGPAssetCacheManager.h"
#import "NSString+MD5.h"

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

+ (NSString *) cachePath
{
    return [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject];
}

- (void) testShouldSetupANewDownloader
{
    NSURL *testUrl = [TestHelpers fileURLForFixtureNamed:@"nsbrief_logo.png"];
    
    id mockFileCache = [OCMockObject niceMockForClass:[MGPAssetCacheManager class]];

    NSString *expectedCachePath = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject];
    [[[mockFileCache expect] andReturn:expectedCachePath] cachePath];
    [[[mockFileCache expect] andReturn:[NSFileManager defaultManager]] fileManager];
    
    self.testController.fileCache = mockFileCache;
    
    MGPRemoteAssetDownloader *downloader = [self.testController downloaderForURL:testUrl];
    
    assertThat(downloader, is(notNilValue()));
    assertThat(downloader.fileManager, is(equalTo([NSFileManager defaultManager])));
    assertThat(downloader.URL, is(equalTo(testUrl)));
    assertThat(downloader.downloadPath, is(equalTo(expectedCachePath)));

    [self.testController resumeAllDownloads];
    
    assertThat(self.testController.allDownloads, hasCountOf(1));
    assertThatInteger(downloader.status, is(equalToInteger(MGPRemoteAssetDownloaderStateRequestSent)));

    [mockFileCache verify];
    
    [self deswizzle];
}

- (void) testShouldNotifyWhenADownloaderIsAddedToController
{
    id mockObserver = [OCMockObject observerMock];
    
    [[NSNotificationCenter defaultCenter] addMockObserver:mockObserver name:kMGPRADownloadsControllerDownloadAddedNotification object:self.testController];
    
    [[mockObserver expect] notificationWithName:kMGPRADownloadsControllerDownloadAddedNotification object:self.testController userInfo:[OCMArg any]];
    
    [self.testController downloaderForURL:[TestHelpers fileURLForFixtureNamed:@"nsbrief_logo.png"]];
    
    [mockObserver verify];
}

- (void) testShouldNotifyWhenADownloaderIsComplete
{
    id mockObserver = [OCMockObject observerMock];
    
    [[NSNotificationCenter defaultCenter] addMockObserver:mockObserver name:kMGPRADownloadsControllerDownloadCompletedNotification object:self.testController];
    
    [[mockObserver expect] notificationWithName:kMGPRADownloadsControllerDownloadCompletedNotification object:self.testController userInfo:[OCMArg any]];
    
    MGPRemoteAssetDownloader *downloader = [self.testController downloaderForURL:[TestHelpers fileURLForFixtureNamed:@"nsbrief_logo.png"]];
    [downloader connectionDidFinishLoading:nil];
    
    assertThatInt([self.testController.activeDownloads count], is(equalToInt(0)));
    
    [mockObserver verify];
}

- (void) testShouldNotifyWhenAllDownloadersHaveCompleted
{
    id mockObserver = [OCMockObject observerMock];
    [[NSNotificationCenter defaultCenter] addMockObserver:mockObserver name:kMGPRADownloadsControllerDownloadCompletedNotification object:self.testController];
    [[NSNotificationCenter defaultCenter] addMockObserver:mockObserver name:kMGPRADownloadsControllerAllDownloadsCompletedNotification object:self.testController];
    
    [[mockObserver expect] notificationWithName:kMGPRADownloadsControllerDownloadCompletedNotification object:self.testController userInfo:[OCMArg any]];
    [[mockObserver expect] notificationWithName:kMGPRADownloadsControllerDownloadCompletedNotification object:self.testController userInfo:[OCMArg any]];
    
    [[mockObserver expect] notificationWithName:kMGPRADownloadsControllerAllDownloadsCompletedNotification object:self.testController userInfo:[OCMArg isNil]];
    
    MGPRemoteAssetDownloader *downloader1 = [self.testController downloaderForURL:[TestHelpers fileURLForFixtureNamed:@"nsbrief_logo.png"]];
    MGPRemoteAssetDownloader *downloader2 = [self.testController downloaderForURL:[TestHelpers fileURLForFixtureNamed:@"NSBrief_5.mp3"]];
    
    [downloader1 connectionDidFinishLoading:nil];
    [downloader2 connectionDidFinishLoading:nil];
    
    assertThatInt([self.testController.activeDownloads count], is(equalToInt(0)));
    
    [mockObserver verify];
}

- (void) testShouldNotAddANewDownloaderForTheSameURL
{
    NSURL *testUrl = [TestHelpers fileURLForFixtureNamed:@"nsbrief_logo.png"];
    MGPRemoteAssetDownloader *firstDownloader = [self.testController downloaderForURL:testUrl];
    MGPRemoteAssetDownloader *secondDownloader = [self.testController downloaderForURL:testUrl];
    
    assertThat(firstDownloader, is(equalTo(secondDownloader)));
}

- (void) testShouldNotDownloadIfAlreadyInCacheAndNotExpired
{
    id mockFileCache = [OCMockObject niceMockForClass:[MGPAssetCacheManager class]];
    NSURL *testUrl = [TestHelpers fileURLForFixtureNamed:@"nsbrief_logo.png"];
    self.testController.fileCache = mockFileCache;
    [[[mockFileCache expect] andReturnValue:[NSNumber numberWithBool:YES]] assetValidForKey:[[testUrl absoluteString] mgp_md5]];
    
    MGPRemoteAssetDownloader *downloader = [self.testController downloaderForURL:testUrl];
    
    assertThat(downloader, is(nilValue()));
    [mockFileCache verify];
}
//
//- (void) testShouldPauseDownloads
//{
//    GHFail(@"Not Implemented");
//}
//
//- (void) testShouldResumeDownloads
//{
//    GHFail(@"Not Implemented");    
//}

@end
