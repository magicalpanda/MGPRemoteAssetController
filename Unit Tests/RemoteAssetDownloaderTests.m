//
//  RemoteAssetDownloaderTests.m
//  MGPRemoteAssetController
//
//  Created by Saul Mora on 5/9/11.
//  Copyright 2011 Magical Panda Software LLC. All rights reserved.
//

#import "RemoteAssetDownloaderTests.h"
#import "MGPRemoteAssetDownloader.h"
#import "NSString+MD5.h"

static id mockFileHandle_;

@implementation RemoteAssetDownloaderTests

@synthesize testDownloader = testDownloader_;

+ (id) mockFileHandle
{
    return mockFileHandle_;
}

-(BOOL)shouldRunOnMainThread
{
    return YES;
}

- (void) setUp
{
    self.testDownloader = [[[MGPRemoteAssetDownloader alloc] init] autorelease];
}

- (void) tearDown
{
    self.testDownloader = nil;
    [self deswizzle];
}

- (void) testShouldBeCreated
{
    assertThat(self.testDownloader, is(notNilValue()));
}

- (void) testEquals
{
    NSString *testURL = @"http://www.apple.com";
    MGPRemoteAssetDownloader *firstDownloader = [[[MGPRemoteAssetDownloader alloc] init] autorelease];
    firstDownloader.URL = [NSURL URLWithString:testURL];
    
    MGPRemoteAssetDownloader *secondDownloader = [[[MGPRemoteAssetDownloader alloc] init] autorelease];
    secondDownloader.URL = [NSURL URLWithString:testURL];
    
    assertThat(firstDownloader, isNot(sameInstance(secondDownloader)));
    assertThat(firstDownloader, is(equalTo(secondDownloader)));
}

- (void) testShouldRequireDownloadPath
{
    self.testDownloader.fileManager = [NSFileManager defaultManager];
    self.testDownloader.URL = [NSURL fileURLWithPath:@"~"];
    GHAssertThrowsSpecific([self.testDownloader beginDownload], NSException, nil);
}

- (void) testShouldRequreFileManager
{
    self.testDownloader.downloadPath = @"~";
    self.testDownloader.URL = [NSURL fileURLWithPath:@"~"];
    GHAssertThrowsSpecific([self.testDownloader beginDownload], NSException, nil);
}

- (void) testShouldRequireURL
{
    self.testDownloader.fileManager = [NSFileManager defaultManager];
    self.testDownloader.downloadPath = @"~";
    GHAssertThrowsSpecific([self.testDownloader beginDownload], NSException, nil);
}

- (void) testShouldTriggerFailedDownloadWhenFileIsNotReachable
{
    NSString *downloadPath = [[TestHelpers scratchPath] stringByAppendingPathComponent:@"test.download"];
    self.testDownloader.downloadPath = downloadPath;
    self.testDownloader.fileManager = [OCMockObject niceMockForClass:[NSFileManager class]];
    NSURL *testUrl = [TestHelpers fileURLForFixtureNamed:@"nsbrief_logo.png"];
    self.testDownloader.URL = testUrl;
    
    id downloaderDelegate = [OCMockObject niceMockForProtocol:@protocol(MGPRemoteAssetDownloaderDelegate)];
    [[[downloaderDelegate stub] andReturn:[NSNumber numberWithBool:YES]] respondsToSelector:@selector(downloader:failedToDownloadURL:)];
    [[[downloaderDelegate expect] andReturnValue:[NSNumber numberWithBool:NO]] isURLReachable:testUrl];
    [[downloaderDelegate expect] downloader:self.testDownloader failedToDownloadURL:testUrl];
    self.testDownloader.delegate = downloaderDelegate;
    
    [self.testDownloader beginDownload];
    
    [downloaderDelegate verify];
}

- (void) testShouldDownloadCreateNewFileWhenItDoesNotExist
{
    NSString *downloadPath = [[TestHelpers scratchPath] stringByAppendingPathComponent:@"test.download"];
    NSFileManager *testFileManager = [NSFileManager defaultManager];    
    
    self.testDownloader.downloadPath = downloadPath;
    self.testDownloader.URL = [TestHelpers fileURLForFixtureNamed:@"nsbrief_logo.png"];
    self.testDownloader.fileManager = testFileManager;
    
    
    [self.testDownloader beginDownload];
    id mockResponse = [OCMockObject niceMockForClass:[NSHTTPURLResponse class]];

    [self.testDownloader connection:nil didReceiveResponse:mockResponse];
    
    assertThat(self.testDownloader.writeHandle, is(notNilValue()));
    
    [testFileManager removeItemAtPath:downloadPath error:nil];
}

- (id) fileHandleForWritingAtPath:(NSString *)path
{
    return mockFileHandle_;
}

- (void) testShouldWriteDataToFileDuringDownload
{
    NSURL *testUrl = [TestHelpers fileURLForFixtureNamed:@"nsbrief_logo.png"];
    NSString *downloadPath = [[TestHelpers scratchPath] stringByAppendingPathComponent:@"test.download"];
    NSString *expectedOutfileFileName = [[[testUrl absoluteString] mgp_md5] stringByAppendingPathExtension:@"png"];
    NSString *expectedOutputFilePath = [downloadPath stringByAppendingPathComponent:expectedOutfileFileName];

    id mockFileManager = [OCMockObject niceMockForClass:[NSFileManager class]];
    [[mockFileManager expect] createFileAtPath:expectedOutputFilePath contents:[OCMArg isNil] attributes:[OCMArg any]];
    
    NSDictionary *fileAttributes = [NSDictionary dictionaryWithObject:[NSNumber numberWithInt:0] forKey:@"NSFileSize"];
    [[[mockFileManager expect] andReturn:fileAttributes] attributesOfItemAtPath:expectedOutputFilePath error:nil];
    
    id mockFileHandler = [OCMockObject mockForClass:[NSFileHandle class]];
    mockFileHandle_ = [mockFileHandler retain];
    [[mockFileHandler expect] writeData:[OCMArg isNotNil]];
    [[mockFileHandler expect] synchronizeFile];
    [[mockFileHandler expect] closeFile];

    [self swizzle:[NSFileHandle class] selector:@selector(fileHandleForWritingAtPath:)];
    
    self.testDownloader.downloadPath = downloadPath;
    self.testDownloader.fileManager = mockFileManager;
    
    self.testDownloader.URL = [TestHelpers fileURLForFixtureNamed:@"nsbrief_logo.png"];    
    
    [self.testDownloader beginDownload];

    id mockResponse = [OCMockObject niceMockForClass:[NSHTTPURLResponse class]];
    NSDictionary *mockHeaders = [NSDictionary dictionaryWithObjectsAndKeys:@"123-", @"Content-Range", @"200", @"Content-Length", @"bytes", @"Accept-Ranges", nil];
    [[[mockResponse expect] andReturn:mockHeaders] allHeaderFields];
    [[[mockResponse expect] andReturnValue:[NSNumber numberWithUnsignedLongLong:200]] expectedContentLength];

    [self.testDownloader connection:nil didReceiveResponse:mockResponse];
    [self.testDownloader connection:nil didReceiveData:[TestHelpers dataForFixtureNamed:@"nsbrief_logo.png"]];
    [self.testDownloader connectionDidFinishLoading:nil];
    
    [mockFileHandler verify];
    [mockFileManager verify];
    [mockFileHandle_ release], mockFileHandle_ = nil;
}

- (void) testShouldResumeWritingDataToEndOfFileAfterInterruption
{
    NSURL *testUrl = [TestHelpers fileURLForFixtureNamed:@"nsbrief_logo.png"];
    NSString *downloadPath = [[TestHelpers scratchPath] stringByAppendingPathComponent:@"test.download"];
    NSString *expectedOutfileFileName = [[[testUrl absoluteString] mgp_md5] stringByAppendingPathExtension:@"png"];
    NSString *expectedOutputFilePath = [downloadPath stringByAppendingPathComponent:expectedOutfileFileName];

    NSDictionary *fileAttributes = [NSDictionary dictionaryWithObject:[NSNumber numberWithInt:123] forKey:@"NSFileSize"];
    
    id mockFileManager = [OCMockObject niceMockForClass:[NSFileManager class]];
    [[[mockFileManager expect] andReturn:fileAttributes] attributesOfItemAtPath:expectedOutputFilePath error:nil];
    [[mockFileManager expect] createFileAtPath:expectedOutputFilePath contents:[OCMArg isNil] attributes:[OCMArg any]];

    
    id mockFileHandler = [OCMockObject mockForClass:[NSFileHandle class]];
    mockFileHandle_ = mockFileHandler;
    [[mockFileHandler expect] seekToFileOffset:123];
    [[mockFileHandler expect] writeData:[OCMArg isNotNil]];
    [[mockFileHandler expect] synchronizeFile];
    [[mockFileHandler expect] closeFile];
    [self swizzle:[NSFileHandle class] selector:@selector(fileHandleForWritingAtPath:)];
    
    self.testDownloader.downloadPath = downloadPath;
    self.testDownloader.fileManager = mockFileManager;

    self.testDownloader.URL = testUrl;
        
    id mockResponse = [OCMockObject niceMockForClass:[NSHTTPURLResponse class]];
    NSDictionary *mockHeaders = [NSDictionary dictionaryWithObjectsAndKeys:@"123-", @"Content-Range", @"200", @"Content-Length", @"bytes", @"Accept-Ranges", nil];
    [[[mockResponse expect] andReturn:mockHeaders] allHeaderFields];
    [[[mockResponse expect] andReturnValue:[NSNumber numberWithUnsignedLongLong:200]] expectedContentLength];

    [self.testDownloader beginDownload];
    [self.testDownloader connection:nil didReceiveResponse:mockResponse];
    [self.testDownloader connection:nil didReceiveData:[TestHelpers dataForFixtureNamed:@"nsbrief_logo.png"]];
    [self.testDownloader connectionDidFinishLoading:nil];
    
    [mockResponse verify];
    [mockFileManager verify];
    [mockFileHandler verify];

    mockFileHandle_ = nil;
}

- (void) testShouldSendBeginDownloadNotificationWhenDownloadHasBeginAndDataHasBeenWritten
{
    NSString *downloadPath = [[TestHelpers scratchPath] stringByAppendingPathComponent:@"test.download"];
    self.testDownloader.downloadPath = downloadPath;
    self.testDownloader.fileManager = [OCMockObject niceMockForClass:[NSFileManager class]];
    NSURL *testUrl = [TestHelpers fileURLForFixtureNamed:@"nsbrief_logo.png"];
    self.testDownloader.URL = testUrl;

    id downloaderDelegate = [OCMockObject niceMockForProtocol:@protocol(MGPRemoteAssetDownloaderDelegate)];
    [[[downloaderDelegate stub] andReturn:[NSNumber numberWithBool:YES]] respondsToSelector:@selector(downloader:didBeginDownloadingURL:)];
    [[downloaderDelegate expect] downloader:self.testDownloader didBeginDownloadingURL:testUrl];
    self.testDownloader.delegate = downloaderDelegate;
    
    [self.testDownloader beginDownload];
    [self.testDownloader connection:nil didReceiveResponse:nil];
    
    [downloaderDelegate verify];
}

- (void) testShouldSendProgressCallbacksWhileDownloading
{
    NSString *downloadPath = [[TestHelpers scratchPath] stringByAppendingPathComponent:@"test.download"];
    self.testDownloader.downloadPath = downloadPath;
    self.testDownloader.fileManager = [OCMockObject niceMockForClass:[NSFileManager class]];
    NSURL *testUrl = [TestHelpers fileURLForFixtureNamed:@"nsbrief_logo.png"];
    self.testDownloader.URL = testUrl;
    
    id downloaderDelegate = [OCMockObject niceMockForProtocol:@protocol(MGPRemoteAssetDownloaderDelegate)];
    [[[downloaderDelegate stub] andReturn:[NSNumber numberWithBool:YES]] respondsToSelector:@selector(downloader:didBeginDownloadingURL:)];
    [[[downloaderDelegate stub] andReturn:[NSNumber numberWithBool:YES]] respondsToSelector:@selector(downloader:didCompleteDownloadingURL:)];
    [[[downloaderDelegate stub] andReturn:[NSNumber numberWithBool:YES]] respondsToSelector:@selector(downloader:dataDidProgress:remaining:)];
    [[downloaderDelegate stub] downloader:self.testDownloader didBeginDownloadingURL:testUrl];
    [[downloaderDelegate stub] downloader:self.testDownloader didCompleteDownloadingURL:testUrl];
    [[downloaderDelegate expect] downloader:self.testDownloader dataDidProgress:[OCMArg any]];
    [[downloaderDelegate expect] downloader:self.testDownloader dataDidProgress:[OCMArg any]]; //yeap, twice
    self.testDownloader.delegate = downloaderDelegate;
    
    [self.testDownloader beginDownload];
    [self.testDownloader connection:nil didReceiveResponse:nil];
    [self.testDownloader connection:nil didReceiveData:nil];
    [self.testDownloader connection:nil didReceiveData:nil];
    [self.testDownloader connectionDidFinishLoading:nil];
    
    [downloaderDelegate verify];
}

- (id<MGPRemoteAssetDownloaderDelegate>) mockDownloaderDelegateForUrl:(NSURL *)testUrl
{
    id downloaderDelegate = [OCMockObject niceMockForProtocol:@protocol(MGPRemoteAssetDownloaderDelegate)];
    [[[downloaderDelegate stub] andReturnValue:[NSNumber numberWithBool:YES]] isURLReachable:testUrl];
    
    [[downloaderDelegate stub] downloader:self.testDownloader didBeginDownloadingURL:testUrl];
    [[downloaderDelegate stub] downloader:self.testDownloader dataDidProgress:[OCMArg any]];
    return downloaderDelegate;
}

- (void) testShouldSendCompletionNotificationWhenDownloadCompletedSuccessfully
{
    NSString *downloadPath = [[TestHelpers scratchPath] stringByAppendingPathComponent:@"test.download"];
    self.testDownloader.downloadPath = downloadPath;
    self.testDownloader.fileManager = [OCMockObject niceMockForClass:[NSFileManager class]];
    NSURL *testUrl = [TestHelpers fileURLForFixtureNamed:@"nsbrief_logo.png"];
    self.testDownloader.URL = testUrl;
    

    id downloaderDelegate = [self mockDownloaderDelegateForUrl:testUrl];
    [[downloaderDelegate expect] downloader:self.testDownloader didCompleteDownloadingURL:testUrl];
    self.testDownloader.delegate = downloaderDelegate;
    
    [self.testDownloader beginDownload];
    [self.testDownloader connection:nil didReceiveResponse:nil];
    [self.testDownloader connection:nil didReceiveData:nil];
    [self.testDownloader connectionDidFinishLoading:nil];
    
    [downloaderDelegate verify];
}

- (void) setupDownloadWithValidValues:(MGPRemoteAssetDownloader *)downloader forUrl:(NSURL *)testUrl
{
    NSString *downloadPath = [[TestHelpers scratchPath] stringByAppendingPathComponent:@"test.download"];
    downloader.downloadPath = downloadPath;
    
    testUrl = testUrl ?: [TestHelpers fileURLForFixtureNamed:@"nsbrief_logo.png"];
    downloader.URL = testUrl;

    NSFileManager *fileManager = [OCMockObject niceMockForClass:[NSFileManager class]];
    downloader.fileManager = fileManager;
}

- (void) testShouldSendDownloadResumedCallbackToDelegate
{
    NSURL *testUrl = [TestHelpers fileURLForFixtureNamed:@"nsbrief_logo.png"];
    [self setupDownloadWithValidValues:self.testDownloader forUrl:testUrl];
    
    id mockFileManager = [OCMockObject niceMockForClass:[NSFileManager class]];
    NSDictionary *mockFileAttributes = [NSDictionary dictionaryWithObject:[NSNumber numberWithInt:100] forKey:NSFileSize];
    [[[mockFileManager expect] andReturn:mockFileAttributes] attributesOfItemAtPath:[OCMArg any] error:nil];
    self.testDownloader.fileManager = mockFileManager;
    
    id downloaderDelegate = [self mockDownloaderDelegateForUrl:testUrl];
    [[downloaderDelegate expect] downloader:self.testDownloader didResumeDownloadingURL:testUrl];
    
    self.testDownloader.delegate = downloaderDelegate;
    
    [self.testDownloader beginDownload];
    [self.testDownloader pause];
    [self.testDownloader resume];
    [self.testDownloader connection:nil didReceiveResponse:nil];

    [mockFileManager verify];
    [downloaderDelegate verify];
}

- (void) testShouldNotBeginDownloadAfterStarted
{
    NSURL *testUrl = [TestHelpers fileURLForFixtureNamed:@"nsbrief_logo.png"];
    [self setupDownloadWithValidValues:self.testDownloader forUrl:testUrl];
    
    id downloaderDelegate = [self mockDownloaderDelegateForUrl:testUrl];
    
    self.testDownloader.delegate = downloaderDelegate;
    [self.testDownloader beginDownload];
    [self.testDownloader resume];
    
    assertThatInteger(self.testDownloader.status, is(equalToInteger(MGPRemoteAssetDownloaderStateRequestSent)));
}

- (void) testShouldNotStartDownloadThatHasCanceled
{
    [self setupDownloadWithValidValues:self.testDownloader forUrl:nil];
    
    id downloaderDelegate = [self mockDownloaderDelegateForUrl:nil];
    
    self.testDownloader.delegate = downloaderDelegate;
    [self.testDownloader beginDownload];
    [self.testDownloader cancel];
    [self.testDownloader resume];
    
    assertThatInteger(self.testDownloader.status, is(equalToInteger(MGPRemoteAssetDownloaderStateCanceled)));
}

- (void) testShouldNotResumeDownloadThatHasCompletedSuccessfully
{
    [self setupDownloadWithValidValues:self.testDownloader forUrl:nil];
    
    id downloaderDelegate = [self mockDownloaderDelegateForUrl:nil];
    
    self.testDownloader.delegate = downloaderDelegate;
    [self.testDownloader beginDownload];
    [self.testDownloader connection:nil didReceiveResponse:nil];
    [self.testDownloader connection:nil didReceiveData:nil];
    [self.testDownloader connectionDidFinishLoading:nil];
    [self.testDownloader resume];
    
    assertThatInteger(self.testDownloader.status, is(equalToInteger(MGPRemoteAssetDownloaderStateComplete)));
}

@end
