//
//  RemoteAssetDownloaderTests.m
//  MGPRemoteAssetController
//
//  Created by Saul Mora on 5/9/11.
//  Copyright 2011 Magical Panda Software LLC. All rights reserved.
//

#import "RemoteAssetDownloaderTests.h"


@implementation RemoteAssetDownloaderTests

@synthesize testDownloader = testDownloader_;

- (void) setUp
{
    self.testDownloader = [[[MGPRemoteAssetDownloader alloc] init] autorelease];
}

- (void) tearDown
{
    self.testDownloader = nil;
}

- (void) testShouldBeCreated
{
    assertThat(self.testDownloader, is(notNilValue()));
}

- (void) testShouldRequireDownloadPath
{
//    assertThat(self.testDownloader.URL, is(notNilValue()));
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
//    assertThat(self.testDownloader.fileManager, is(notNilValue()));
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
//    assertThat(nil, is(notNilValue()));
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
    NSString *downloadPath = @"~/Downloads/cache/test.download";
    id mockFileManager = [OCMockObject mockForClass:[NSFileManager class]];
    [[mockFileManager expect] createFileAtPath:downloadPath contents:[OCMArg isNil] attributes:[OCMArg any]];
    [[[mockFileManager stub] fileExistsAtPath:downloadPath] andReturn:[NSNumber numberWithBool:YES]];
    
    MGPRemoteAssetDownloader *testDownloader = [[MGPRemoteAssetDownloader alloc] init];
    
    testDownloader.downloadPath = downloadPath;
    testDownloader.URL = [NSURL URLWithString:@""];
    testDownloader.fileManager = mockFileManager;
    
    
    [testDownloader beginDownload];
    NSURLResponse *testResponse = [[NSURLResponse alloc] initWithURL:nil MIMEType:@"text/html" expectedContentLength:123 textEncodingName:nil];
    [testDownloader connection:nil didReceiveResponse:testResponse];
    
    
    [mockFileManager verify];
}

- (void) testShouldWriteDataToFileDuringDownload
{
    assertThat(nil, is(notNilValue()));
}

- (void) testShouldResumeWritingDataToEndOfFileAfterInterruption
{
    assertThat(nil, is(notNilValue()));
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
