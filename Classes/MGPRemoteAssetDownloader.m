//
//  MGPRemoteAssetDownloader.m
//  MGPRemoteAssetController
//
//  Created by Saul Mora on 5/9/11.
//  Copyright 2011 Magical Panda Software LLC. All rights reserved.
//

#import "MGPRemoteAssetDownloader.h"
#import "NSString+MD5.h"

NSString * const kMGPDownloaderKey = @"kMGPDownloaderKey";

static const NSTimeInterval kMGPRemoteAssetDownloaderDefaultRequestTimeout = 30.;

@interface MGPRemoteAssetDownloader ()

@property (nonatomic, retain) NSFileHandle *writeHandle;
@property (nonatomic, retain) NSURLConnection *connection;
@property (nonatomic, assign) NSTimeInterval requestTimeout;
@property (nonatomic, retain) NSURLRequest *request;
@property (nonatomic, copy) NSString *fileName;

@property (nonatomic, assign) float downloadProgress;
@property (nonatomic, assign) unsigned long long currentFileSize;
@property (nonatomic, assign) long long expectedFileSize;
@property (nonatomic, readonly) NSString *targetFile;

- (void) resume;

@end

@implementation MGPRemoteAssetDownloader

@synthesize delegate = delegate_;

@synthesize fileName = fileName_;
@synthesize downloadProgress = downloadProgress_;
@synthesize expectedFileSize = expectedFileSize_;
@synthesize currentFileSize = currentFileSize_;

@synthesize request = request_;
@synthesize requestTimeout = requestTimeout_;
@synthesize connection = connection_;

@synthesize writeHandle = writeHandle_;

@synthesize URL = URL_;
@synthesize downloadPath = downloadPath_;
@synthesize fileManager = fileManager_;

- (void) dealloc
{
    self.fileName = nil;
    self.request = nil;
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

- (NSString *) targetFile
{
    return [self.downloadPath stringByAppendingPathComponent:[[self.URL absoluteString] mgp_md5]];
}

- (void) beginDownload
{
    NSAssert(self.downloadPath, @"downloadPath is not set");
    NSAssert(self.URL, @"URL is not set");
    NSAssert(self.fileManager, @"fileManager is not set");
    

    if (![self.fileManager fileExistsAtPath:self.downloadPath])
    {
        if (![self.fileManager createDirectoryAtPath:self.downloadPath withIntermediateDirectories:YES attributes:nil error:nil])
        {
            NSLog(@"Unable to create cache directory: %@", self.downloadPath);
        }
    }
    
    if (![self.fileManager fileExistsAtPath:self.targetFile])
    {
        if (![self.fileManager createFileAtPath:self.targetFile contents:nil attributes:nil])
        {
            NSLog(@"Unable to create cache download file: %@", self.targetFile);
        }
    }

    NSDictionary *attributes = [self.fileManager attributesOfItemAtPath:self.targetFile error:nil];
    self.currentFileSize = [attributes fileSize];
    
    [self resume];
}

- (void) connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    self.expectedFileSize = [response expectedContentLength];
    self.fileName = [response suggestedFilename];

    self.writeHandle = [NSFileHandle fileHandleForWritingAtPath:self.targetFile];
    
    if (self.currentFileSize > 0)
    {
        [self.writeHandle seekToEndOfFile];
    }
    
    if ([self.delegate respondsToSelector:@selector(downloader:didBeginDownloadingURL:)])
    {
        [self.delegate downloader:self didBeginDownloadingURL:self.URL];
    } 
}

- (void) connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    [self.writeHandle writeData:data];
    
    self.currentFileSize += [data length];
    self.downloadProgress = self.currentFileSize / (self.expectedFileSize ?: 1);
    
    if ([self.delegate respondsToSelector:@selector(downloader:dataDidProgress:remaining:)])
    {
        NSNumber *progress = [NSNumber numberWithFloat:self.downloadProgress];
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
    
    //TODO: do NOT restart downloader if this INSTANCE has completed successfully!
}

- (void) connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    [self.writeHandle closeFile];
    self.connection = nil;
}

- (void) pause
{
    [self.connection cancel];
}

- (void) resume
{
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:self.URL 
                                                           cachePolicy:NSURLCacheStorageNotAllowed 
                                                       timeoutInterval:self.requestTimeout];
    
    if (self.currentFileSize > 0)
    {
        [request addValue:[NSString stringWithFormat:@"bytes=%ull-", self.currentFileSize] forHTTPHeaderField:@"Range"];
    }
    
    self.request = request;
    
#ifndef __TESTING__
    self.connection = [NSURLConnection connectionWithRequest:self.request delegate:self];
    [self.connection scheduleInRunLoop:[NSRunLoop mainRunLoop] forMode:NSDefaultRunLoopMode];
#endif

}

@end