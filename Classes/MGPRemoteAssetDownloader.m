//
//  MGPRemoteAssetDownloader.m
//  MGPRemoteAssetController
//
//  Created by Saul Mora on 5/9/11.
//  Copyright 2011 Magical Panda Software LLC. All rights reserved.
//

static const NSTimeInterval kMGPRemoteAssetDownloaderDefaultRequestTimeout = 30.;

#import "MGPRemoteAssetDownloader.h"

@interface MGPRemoteAssetDownloader ()

@property (nonatomic, retain) NSFileHandle *writeHandle;
@property (nonatomic, retain) NSURLConnection *connection;
@property (nonatomic, assign) NSTimeInterval requestTimeout;

@property (nonatomic, assign) unsigned long long currentFileSize;
@property (nonatomic, assign) long long expectedFileSize;

@end

@implementation MGPRemoteAssetDownloader

@synthesize currentFileSize = currentFileSize_;
@synthesize expectedFileSize = expectedFileSize_;
@synthesize requestTimeout = requestTimeout_;
@synthesize delegate = delegate_;
@synthesize connection = connection_;
@synthesize writeHandle = writeHandle_;
@synthesize URL = URL_;
@synthesize downloadPath = downloadPath_;
@synthesize fileManager = fileManager_;

- (void) dealloc
{
    self.delegate = nil;
    self.connection = nil;
    self.writeHandle = nil;
    self.URL = nil;
    self.downloadPath = nil;
    self.fileManager = nil;
    [super dealloc];
}

- (id) init
{
    self = [super init];
    if (self)
    {
        self.requestTimeout = kMGPRemoteAssetDownloaderDefaultRequestTimeout;
    }
    return self;
}

- (void) beginDownload
{
    NSAssert(self.downloadPath, @"downloadPath is not set");
    NSAssert(self.URL, @"URL is not set");
    NSAssert(self.fileManager, @"fileManager is not set");
    
    if (![self.fileManager fileExistsAtPath:self.downloadPath])
    {
        [self.fileManager createFileAtPath:self.downloadPath contents:nil attributes:nil];
    }
    
    NSString *expandedPath = [self.downloadPath stringByExpandingTildeInPath];
    self.writeHandle = [NSFileHandle fileHandleForWritingAtPath:expandedPath];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:self.URL cachePolicy:NSURLCacheStorageNotAllowed timeoutInterval:self.requestTimeout];
    
    NSDictionary *attributes = [self.fileManager attributesOfItemAtPath:self.downloadPath error:nil];
    if ([attributes fileSize] > 0)
    {
        [request addValue:[NSString stringWithFormat:@"bytes=%ull-", [attributes fileSize]] forHTTPHeaderField:@"Range"];
        [self.writeHandle seekToEndOfFile];
    }
    self.currentFileSize = [attributes fileSize];

#ifndef __TESTING__
    self.connection = [NSURLConnection connectionWithRequest:request delegate:self];
#endif
}

- (void) connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    if ([self.delegate respondsToSelector:@selector(downloader:didBeginDownloadingURL:)])
    {
        [self.delegate downloader:self didBeginDownloadingURL:self.URL];
    }

    self.expectedFileSize = [response expectedContentLength];
}

- (void) connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    [self.writeHandle writeData:data];
    self.currentFileSize += [data length];
    
    if ([self.delegate respondsToSelector:@selector(downloader:dataDidProgress:remaining:)])
    {
        NSNumber *progress = [NSNumber numberWithFloat:self.currentFileSize / (self.expectedFileSize ?: 1)];
        NSNumber *bytesRemaining = [NSNumber numberWithFloat:self.expectedFileSize - self.currentFileSize];
        [self.delegate downloader:self dataDidProgress:progress remaining:bytesRemaining];
    }
}

- (void) connectionDidFinishLoading:(NSURLConnection *)connection
{
    self.connection = nil;
    [self.writeHandle closeFile];
    
    if ([self.delegate respondsToSelector:@selector(downloader:didCompleteDownloadingURL:)])
    {
        [self.delegate downloader:self didCompleteDownloadingURL:self.URL];
    }
}

- (void) connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    
}

@end
