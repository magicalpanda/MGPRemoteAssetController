//
//  MGPRemoteAssetDownloader.m
//  MGPRemoteAssetController
//
//  Created by Saul Mora on 5/9/11.
//  Copyright 2011 Magical Panda Software LLC. All rights reserved.
//

#import "MGPRemoteAssetDownloader.h"
#import "NSString+MD5.h"

NSString * const kMGPDownloaderKey =            @"kMGPDownloaderKey";
NSString * const kMGPTimeRemainingKey =         @"kMGPTimeRemainingKey";
NSString * const kMGPBytesRemainingKey =        @"kMGPBytesRemainingKey";
NSString * const kMGPProgressKey =              @"kMGPProgressKey";
NSString * const kMGPEstimatedBandwidthKey =    @"kMGPEstimatedBandwidthKey";

static const NSTimeInterval kMGPRemoteAssetDownloaderDefaultRequestTimeout = 30.;

@interface MGPRemoteAssetDownloader ()

@property (nonatomic, assign) MGPRemoteAssetDownloaderState status;
@property (nonatomic, retain) NSFileHandle *writeHandle;
@property (nonatomic, retain) NSURLConnection *connection;
@property (nonatomic, assign) NSTimeInterval requestTimeout;
@property (nonatomic, retain) NSURLRequest *request;
@property (nonatomic, copy) NSString *fileName;

@property (nonatomic, assign) NSTimeInterval lastDataReceiveTime;
@property (nonatomic, assign) float downloadProgress;
@property (nonatomic, assign) unsigned long long currentFileSize;
@property (nonatomic, assign) long long expectedFileSize;
@property (nonatomic, readonly) NSString *targetFile;
@property (nonatomic, assign) BOOL serverAllowsResume;

@property (nonatomic, assign) float bandwidth;
@property (nonatomic, assign) unsigned long long bytesRemaining;
@property (nonatomic, assign) NSTimeInterval timeRemaining;
@property (nonatomic, readonly) NSString *fileCacheKey;

@end

@implementation MGPRemoteAssetDownloader

@synthesize delegate = delegate_;
@synthesize status = status_;

@synthesize fileCacheKey = fileCacheKey_;
@synthesize timeRemaining = timeRemaining_;
@synthesize bandwidth = bandwidth_;
@synthesize bytesRemaining = bytesRemaining_;

@synthesize lastDataReceiveTime = lastDataReceiveTime_;
@synthesize serverAllowsResume = serverAllowsResume;
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
        self.status = MGPRemoteAssetDownloaderStateNotStarted;
    }
    return self;
}

- (NSString *) description
{
    return [NSString stringWithFormat:@"<%@ [url: %@] [downloadPath: %@] [fileName: %@] [cachedFileName: %@] [status: %d]>",
            NSStringFromClass([self class]), self.URL, self.downloadPath, self.fileName, self.fileCacheKey, self.status];
}

- (void) performActionOnDelegate:(SEL)selector withObject:(id)parameter
{
    if ([self.delegate respondsToSelector:selector]) 
    {
        [self.delegate performSelector:selector withObject:self withObject:parameter];
    }
}

- (id) initWithURL:(NSURL *)url destinationPath:(NSString *)destinationPath
{
    self = [self init];
    if (self)
    {
        self.URL = url;
        self.downloadPath = destinationPath;
    }
    return self;
}

+ (MGPRemoteAssetDownloader *) downloaderForAssetAtURL:(NSURL *)sourceURL toDestinationPath:(NSString *)destinationPath
{
    return [[[self alloc] initWithURL:sourceURL destinationPath:destinationPath] autorelease];
}

+ (NSString *) fileKeyForURL:(NSURL *)url
{
    return [[url absoluteString] mgp_md5];
}

- (NSUInteger) hash
{
    return [self.URL hash];
}

- (BOOL) isEqual:(id)object
{
    if ([object isKindOfClass:[self class]])
    {
        MGPRemoteAssetDownloader *other = object;
        return [self.URL isEqual:other.URL];
    }
    return NO;
}

- (id) fileCacheKey
{
    return [[self class] fileKeyForURL:self.URL];
}

- (NSString *) targetFile
{
    return [self.downloadPath stringByAppendingPathComponent:[self fileCacheKey]];
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
            DDLogWarn(@"Unable to create cache directory: %@", self.downloadPath);
        }
    }
    
    if (![self.fileManager fileExistsAtPath:self.targetFile])
    {
        if (![self.fileManager createFileAtPath:self.targetFile contents:nil attributes:nil])
        {
            DDLogWarn(@"Unable to create cache download file: %@", self.targetFile);
        }
    }

    NSDictionary *attributes = [self.fileManager attributesOfItemAtPath:self.targetFile error:nil];
    self.currentFileSize = [attributes fileSize];
    
    [self resume];
}

- (void) connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    NSHTTPURLResponse *httpResonse = (NSHTTPURLResponse *)response;
    NSDictionary *headers = [httpResonse allHeaderFields];
    
    self.status = MGPRemoteAssetDownloaderStateDownloading;
    DDLogVerbose(@"Response Headers: %@", headers);
    
    self.expectedFileSize = [response expectedContentLength];
    self.fileName = [response suggestedFilename];

    self.serverAllowsResume = [[headers valueForKey:@"Accept-Ranges"] isEqual:@"bytes"];
    self.writeHandle = [NSFileHandle fileHandleForWritingAtPath:self.targetFile];
    
    if (self.currentFileSize >= self.expectedFileSize) 
    {
        self.currentFileSize = 0;
        [self.writeHandle truncateFileAtOffset:0];
    }
    
    //parse content range, setup file pointers
    if (([headers valueForKey:@"Content-Range"]) && (self.currentFileSize > 0))
    {
        [self.writeHandle seekToEndOfFile];
    }

    if (self.currentFileSize == 0)
    {
        [self performActionOnDelegate:@selector(downloader:didBeginDownloadingURL:) withObject:self.URL];
    }
    else
    {
        [self performActionOnDelegate:@selector(downloader:didResumeDownloadingURL:) withObject:self.URL];
    }
}

- (NSDictionary *) receivedDataSummary:(NSData *)data
{
    NSNumber *progress = [NSNumber numberWithFloat:((float)self.currentFileSize / (float)(self.expectedFileSize ?: 1))];
    NSNumber *bytesRemaining = [NSNumber numberWithFloat:self.expectedFileSize - self.currentFileSize];
    
    NSTimeInterval currentTime = [NSDate timeIntervalSinceReferenceDate];
    NSTimeInterval timeDelta = currentTime - self.lastDataReceiveTime;
    float estimatedBandwidth = (float)[data length] / (timeDelta ?: 1);
    
    NSNumber *estBandwidth = [NSNumber numberWithFloat:estimatedBandwidth];
    NSNumber *estTimeRemaining = [NSNumber numberWithFloat: (float)(self.expectedFileSize - self.currentFileSize) / estimatedBandwidth];

    NSDictionary *summary = [NSDictionary dictionaryWithObjectsAndKeys:
                             progress, kMGPProgressKey, 
                             bytesRemaining, kMGPBytesRemainingKey, 
                             estTimeRemaining, kMGPTimeRemainingKey,
                             estBandwidth, kMGPEstimatedBandwidthKey,
                             nil];
    
    self.lastDataReceiveTime = currentTime;
    
    DDLogVerbose(@"Download Status: %@", summary);
    
    return summary;
}

- (void) connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    self.status = MGPRemoteAssetDownloaderStateDownloading;
    [self.writeHandle writeData:data];
    [self.writeHandle synchronizeFile];
    
    self.currentFileSize += [data length];
    
    NSDictionary *summary = [self receivedDataSummary:data];
    self.downloadProgress = [[summary valueForKey:kMGPProgressKey] floatValue];
    self.bytesRemaining = [[summary valueForKey:kMGPBytesRemainingKey] unsignedLongLongValue];
    self.timeRemaining = [[summary valueForKey:kMGPTimeRemainingKey] doubleValue];
    self.bandwidth = [[summary valueForKey:kMGPEstimatedBandwidthKey] floatValue];
    
    [self performActionOnDelegate:@selector(downloader:dataDidProgress:) withObject:summary];
}

- (void) connectionDidFinishLoading:(NSURLConnection *)connection
{
    self.connection = nil;
    [self.writeHandle closeFile];
    
    self.status = MGPRemoteAssetDownloaderStateComplete;
    [self performActionOnDelegate:@selector(downloader:didCompleteDownloadingURL:) withObject:self.URL];
    
    //TODO: do NOT restart downloader if this INSTANCE has completed successfully!
}

- (void) connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    [self.writeHandle closeFile];
    self.connection = nil;
    self.status = MGPRemoteAssetDownloaderStateFailed;
}

- (void) cancel
{
    //make downloader so that it cannot be resumed...downloader must be dealloced to restart
    self.status = MGPRemoteAssetDownloaderStateCanceled;
}

- (void) pause
{
    [self.connection cancel];
    self.connection = nil;
    self.status = MGPRemoteAssetDownloaderStatePaused;
    
    [self performActionOnDelegate:@selector(downloader:didPauseDownloadingURL:) withObject:self.URL];
}

- (void) resume
{
    //if status != Canclled && != Completed && networkIsConnected
    if ([self.delegate isURLReachable:self.URL])
    {
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:self.URL 
                                                               cachePolicy:NSURLCacheStorageNotAllowed 
                                                           timeoutInterval:self.requestTimeout];
        
        [request addValue:[NSString stringWithFormat:@"bytes=%ull-", self.currentFileSize] forHTTPHeaderField:@"Range"];
        
        self.request = request;
        self.lastDataReceiveTime = [NSDate timeIntervalSinceReferenceDate];
        
    #ifndef __TESTING__
        self.connection = [NSURLConnection connectionWithRequest:self.request delegate:self];
        [self.connection scheduleInRunLoop:[NSRunLoop mainRunLoop] forMode:NSDefaultRunLoopMode];
    #endif
        
        self.status = MGPRemoteAssetDownloaderStateRequestSent;
    }
    else
    {
        self.status = MGPRemoteAssetDownloaderStateFailed;
        [self performActionOnDelegate:@selector(downloader:failedToDownloadURL:) withObject:self.URL];
    }
}

@end