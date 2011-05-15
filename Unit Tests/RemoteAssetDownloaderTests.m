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

- (void) testShouldRequireDownloadPath
{
    @try 
    {
        self.testDownloader.fileManager = [NSFileManager defaultManager];
        self.testDownloader.URL = [NSURL fileURLWithPath:@"~"];
        [self.testDownloader beginDownload];
    }
    @catch (NSException *e) 
    {
        assertThat([e name], is(equalTo(@"NSInternalInconsistencyException")));
        return;
    }
    
    GHFail(@"Should have thrown an exception");
}

- (void) testShouldRequreFileManager
{
    @try 
    {
        self.testDownloader.downloadPath = @"~";
        self.testDownloader.URL = [NSURL fileURLWithPath:@"~"];
        [self.testDownloader beginDownload];
    }
    @catch (NSException *e) 
    {
        assertThat([e name], is(equalTo(@"NSInternalInconsistencyException")));
        return;
    }
    
    GHFail(@"Should have thrown an exception");
}

- (void) testShouldRequireURL
{
    @try 
    {
        self.testDownloader.fileManager = [NSFileManager defaultManager];
        self.testDownloader.downloadPath = @"~";
        [self.testDownloader beginDownload];
    }
    @catch (NSException *e) 
    {
        assertThat([e name], is(equalTo(@"NSInternalInconsistencyException")));
        return;
    }
    
    GHFail(@"Should have thrown an exception");
}

- (void) testShouldDownloadCreateNewFileWhenItDoesNotExist
{
    NSString *downloadPath = [[TestHelpers scratchPath] stringByAppendingPathComponent:@"test.download"];
    NSFileManager *testFileManager = [NSFileManager defaultManager];    
    
    self.testDownloader.downloadPath = downloadPath;
    self.testDownloader.URL = [TestHelpers fileURLForFixtureNamed:@"nsbrief_logo.png"];
    self.testDownloader.fileManager = testFileManager;
    
    
    [self.testDownloader beginDownload];
    NSURLResponse *testResponse = [[NSURLResponse alloc] initWithURL:nil MIMEType:@"text/html" expectedContentLength:123 textEncodingName:nil];
    [self.testDownloader connection:nil didReceiveResponse:testResponse];
    
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
    NSString *expectedOutfileFileName = [[testUrl absoluteString] mgp_md5];
    NSString *expectedOutputFilePath = [downloadPath stringByAppendingPathComponent:expectedOutfileFileName];

    id mockFileManager = [OCMockObject niceMockForClass:[NSFileManager class]];

//    [[[mockFileManager stub] andReturnValue:[NSNumber numberWithBool:NO]] fileExistsAtPath:expectedOutputFilePath];
    [[mockFileManager expect] createFileAtPath:expectedOutputFilePath contents:[OCMArg isNil] attributes:[OCMArg any]];
    
    NSDictionary *fileAttributes = [NSDictionary dictionaryWithObject:[NSNumber numberWithInt:0] forKey:@"NSFileSize"];
    [[[mockFileManager expect] andReturn:fileAttributes] attributesOfItemAtPath:expectedOutputFilePath error:nil];
    
    id mockFileHandler = [OCMockObject mockForClass:[NSFileHandle class]];
    mockFileHandle_ = [mockFileHandler retain];
    [[mockFileHandler expect] writeData:[OCMArg isNotNil]];
    [[mockFileHandler expect] closeFile];

    [self swizzle:[NSFileHandle class] selector:@selector(fileHandleForWritingAtPath:)];
    
    self.testDownloader.downloadPath = downloadPath;
    self.testDownloader.fileManager = mockFileManager;
    
    self.testDownloader.URL = [TestHelpers fileURLForFixtureNamed:@"nsbrief_logo.png"];    
    
    [self.testDownloader beginDownload];
    
    NSURLResponse *testResponse = [[NSURLResponse alloc] initWithURL:nil MIMEType:@"text/html" expectedContentLength:123 textEncodingName:nil];
    [self.testDownloader connection:nil didReceiveResponse:testResponse];
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
    NSString *expectedOutfileFileName = [[testUrl absoluteString] mgp_md5];
    NSString *expectedOutputFilePath = [downloadPath stringByAppendingPathComponent:expectedOutfileFileName];

    NSDictionary *fileAttributes = [NSDictionary dictionaryWithObject:[NSNumber numberWithInt:123] forKey:@"NSFileSize"];
    
    id mockFileManager = [OCMockObject niceMockForClass:[NSFileManager class]];
//    BOOL isDir;
//    [[[mockFileManager stub] andReturnValue:[NSNumber numberWithBool:NO]] fileExistsAtPath:downloadPath isDirectory:nil];
//    [[[mockFileManager stub] andReturnValue:[NSNumber numberWithBool:NO]] fileExistsAtPath:expectedOutputFilePath];
    [[[mockFileManager expect] andReturn:fileAttributes] attributesOfItemAtPath:expectedOutputFilePath error:nil];
    [[mockFileManager expect] createFileAtPath:expectedOutputFilePath contents:[OCMArg isNil] attributes:[OCMArg any]];

    
    id mockFileHandler = [OCMockObject mockForClass:[NSFileHandle class]];
    mockFileHandle_ = mockFileHandler;
    [[mockFileHandler expect] seekToEndOfFile];
    [[mockFileHandler expect] writeData:[OCMArg isNotNil]];
    [[mockFileHandler expect] closeFile];
    [self swizzle:[NSFileHandle class] selector:@selector(fileHandleForWritingAtPath:)];
    
    self.testDownloader.downloadPath = downloadPath;
    self.testDownloader.fileManager = mockFileManager;

    self.testDownloader.URL = testUrl;
        
    [self.testDownloader beginDownload];
    [self.testDownloader connection:nil didReceiveResponse:nil];
    [self.testDownloader connection:nil didReceiveData:[TestHelpers dataForFixtureNamed:@"nsbrief_logo.png"]];
    [self.testDownloader connectionDidFinishLoading:nil];
    
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

    id downloaderDelegate = [OCMockObject mockForProtocol:@protocol(MGPRemoteAssetDownloaderDelegate)];
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
    
    id downloaderDelegate = [OCMockObject mockForProtocol:@protocol(MGPRemoteAssetDownloaderDelegate)];
    [[[downloaderDelegate stub] andReturn:[NSNumber numberWithBool:YES]] respondsToSelector:@selector(downloader:didBeginDownloadingURL:)];
    [[[downloaderDelegate stub] andReturn:[NSNumber numberWithBool:YES]] respondsToSelector:@selector(downloader:didCompleteDownloadingURL:)];
    [[[downloaderDelegate stub] andReturn:[NSNumber numberWithBool:YES]] respondsToSelector:@selector(downloader:dataDidProgress:remaining:)];
    [[downloaderDelegate stub] downloader:self.testDownloader didBeginDownloadingURL:testUrl];
    [[downloaderDelegate stub] downloader:self.testDownloader didCompleteDownloadingURL:testUrl];
    [[downloaderDelegate expect] downloader:self.testDownloader dataDidProgress:[OCMArg any] remaining:[OCMArg any]];
    [[downloaderDelegate expect] downloader:self.testDownloader dataDidProgress:[OCMArg any] remaining:[OCMArg any]]; //yeap, twice
    self.testDownloader.delegate = downloaderDelegate;
    
    [self.testDownloader beginDownload];
    [self.testDownloader connection:nil didReceiveResponse:nil];
    [self.testDownloader connection:nil didReceiveData:nil];
    [self.testDownloader connection:nil didReceiveData:nil];
    [self.testDownloader connectionDidFinishLoading:nil];
    
    [downloaderDelegate verify];
}

- (void) testShouldSendCompletionNotificationWhenDownloadCompletedSuccessfully
{
    NSString *downloadPath = [[TestHelpers scratchPath] stringByAppendingPathComponent:@"test.download"];
    self.testDownloader.downloadPath = downloadPath;
    self.testDownloader.fileManager = [OCMockObject niceMockForClass:[NSFileManager class]];
    NSURL *testUrl = [TestHelpers fileURLForFixtureNamed:@"nsbrief_logo.png"];
    self.testDownloader.URL = testUrl;
    
    id downloaderDelegate = [OCMockObject mockForProtocol:@protocol(MGPRemoteAssetDownloaderDelegate)];
    [[[downloaderDelegate stub] andReturn:[NSNumber numberWithBool:YES]] respondsToSelector:@selector(downloader:didBeginDownloadingURL:)];
    [[[downloaderDelegate stub] andReturn:[NSNumber numberWithBool:YES]] respondsToSelector:@selector(downloader:didCompleteDownloadingURL:)];
    [[[downloaderDelegate stub] andReturn:[NSNumber numberWithBool:YES]] respondsToSelector:@selector(downloader:dataDidProgress:remaining:)];
    [[downloaderDelegate stub] downloader:self.testDownloader didBeginDownloadingURL:testUrl];
    [[downloaderDelegate stub] downloader:self.testDownloader dataDidProgress:[OCMArg any] remaining:[OCMArg any]];
    [[downloaderDelegate expect] downloader:self.testDownloader didCompleteDownloadingURL:testUrl];
    self.testDownloader.delegate = downloaderDelegate;
    
    [self.testDownloader beginDownload];
    [self.testDownloader connection:nil didReceiveResponse:nil];
    [self.testDownloader connection:nil didReceiveData:nil];
    [self.testDownloader connectionDidFinishLoading:nil];
    
    [downloaderDelegate verify];
}

@end
