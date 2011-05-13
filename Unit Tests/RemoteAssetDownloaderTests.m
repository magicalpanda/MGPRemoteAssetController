//
//  RemoteAssetDownloaderTests.m
//  MGPRemoteAssetController
//
//  Created by Saul Mora on 5/9/11.
//  Copyright 2011 Magical Panda Software LLC. All rights reserved.
//

#import "RemoteAssetDownloaderTests.h"
//
//@interface RemoteAssetDownloaderTests ()
//
//@property (nonatomic, retain) id mockFileHandler;
//
//@end

static id mockFileHandle_;

@implementation RemoteAssetDownloaderTests

@synthesize testDownloader = testDownloader_;
//@synthesize mockFileHandler = mockFileHandler_;

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
    MGPRemoteAssetDownloader *testDownloader = [[MGPRemoteAssetDownloader alloc] init];
    
    testDownloader.downloadPath = downloadPath;
    testDownloader.URL = [NSURL URLWithString:@""];
    testDownloader.fileManager = testFileManager;
    
    
    [testDownloader beginDownload];
    NSURLResponse *testResponse = [[NSURLResponse alloc] initWithURL:nil MIMEType:@"text/html" expectedContentLength:123 textEncodingName:nil];
    [testDownloader connection:nil didReceiveResponse:testResponse];
    
    assertThat(testDownloader.writeHandle, is(notNilValue()));
    
    [testFileManager removeItemAtPath:downloadPath error:nil];
}

- (id) fileHandleForWritingAtPath:(NSString *)path
{
    return mockFileHandle_;
}

- (void) testShouldWriteDataToFileDuringDownload
{
    NSString *downloadPath = [[TestHelpers scratchPath] stringByAppendingPathComponent:@"test.download"];

    id mockFileManager = [OCMockObject mockForClass:[NSFileManager class]];
    [[[mockFileManager stub] andReturnValue:[NSNumber numberWithBool:NO]] fileExistsAtPath:downloadPath];
    [[mockFileManager expect] createFileAtPath:downloadPath contents:[OCMArg isNil] attributes:[OCMArg any]];
    
    NSDictionary *fileAttributes = [NSDictionary dictionaryWithObject:[NSNumber numberWithInt:0] forKey:@"NSFileSize"];
    [[[mockFileManager expect] andReturn:fileAttributes] attributesOfItemAtPath:downloadPath error:nil];
    
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
    NSString *downloadPath = [[TestHelpers scratchPath] stringByAppendingPathComponent:@"test.download"];
    NSDictionary *fileAttributes = [NSDictionary dictionaryWithObject:[NSNumber numberWithInt:123] forKey:@"NSFileSize"];
    
    id mockFileManager = [OCMockObject mockForClass:[NSFileManager class]];
    [[[mockFileManager stub] andReturnValue:[NSNumber numberWithBool:NO]] fileExistsAtPath:downloadPath];
    [[[mockFileManager expect] andReturn:fileAttributes] attributesOfItemAtPath:downloadPath error:nil];
    [[mockFileManager expect] createFileAtPath:downloadPath contents:[OCMArg isNil] attributes:[OCMArg any]];
    
    id mockFileHandler = [OCMockObject mockForClass:[NSFileHandle class]];
    mockFileHandle_ = mockFileHandler;
    [[mockFileHandler expect] seekToEndOfFile];
    [[mockFileHandler expect] writeData:[OCMArg isNotNil]];
    [[mockFileHandler expect] closeFile];
    [self swizzle:[NSFileHandle class] selector:@selector(fileHandleForWritingAtPath:)];
    
    self.testDownloader.downloadPath = downloadPath;
    self.testDownloader.fileManager = mockFileManager;
    self.testDownloader.URL = [TestHelpers fileURLForFixtureNamed:@"nsbrief_logo.png"];
    
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
    assertThat(nil, is(notNilValue()));
}

- (void) testShouldSendProgressCallbacksWhileDownloading
{
    assertThat(nil, is(notNilValue()));
}

- (void) testShouldSendCompletionNotificationWhenDownloadCompletedSuccessfully
{
    assertThat(nil, is(notNilValue()));   
}

@end
