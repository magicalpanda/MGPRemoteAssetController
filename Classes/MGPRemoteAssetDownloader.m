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

void scanContentRange(NSString *contentRange, long long *startOfRange, long long *endOfRange, long long *totalContentLength)
{
    NSScanner *contentRangeScanner = [NSScanner scannerWithString:contentRange];
    [contentRangeScanner scanString:@"bytes" intoString:nil];
    [contentRangeScanner scanLongLong:startOfRange];
    [contentRangeScanner scanString:@"-" intoString:nil];
    [contentRangeScanner scanLongLong:endOfRange];
    [contentRangeScanner scanString:@"/" intoString:nil];
    [contentRangeScanner scanLongLong:totalContentLength];
}

static const NSTimeInterval kMGPRemoteAssetDownloaderDefaultRequestTimeout = 30.;

@interface MGPRemoteAssetDownloader ()

@property (nonatomic, strong) MGPAssetCacheManager *cacheManager;
@property (nonatomic, assign) MGPRemoteAssetDownloaderState status;
@property (nonatomic, retain) NSFileHandle *writeHandle;
@property (nonatomic, retain) NSURLConnection *connection;
@property (nonatomic, assign) NSTimeInterval requestTimeout;
@property (nonatomic, retain) NSURLRequest *request;
@property (nonatomic, copy) NSString *fileName;

@property (nonatomic, assign) NSTimeInterval downloadStartTime;
@property (nonatomic, assign) float downloadProgress;
@property (nonatomic, assign) unsigned long long currentFileSize;
@property (nonatomic, assign) long long expectedFileSize;
@property (nonatomic, readonly) NSString *targetFile;
@property (nonatomic, assign) BOOL serverAllowsResume;

@property (nonatomic, assign) float bandwidth;
@property (nonatomic, assign) unsigned long long bytesRemaining;
@property (nonatomic, assign) NSTimeInterval timeRemaining;
@property (nonatomic, copy, readonly) NSString *fileCacheKey;

- (void) downloadCompleted;

@end

@implementation MGPRemoteAssetDownloader

@synthesize cacheManager = _cacheManager;
@synthesize delegate = delegate_;
@synthesize status = status_;

@synthesize fileCacheKey = fileCacheKey_;
@synthesize timeRemaining = timeRemaining_;
@synthesize bandwidth = bandwidth_;
@synthesize bytesRemaining = bytesRemaining_;

@synthesize downloadStartTime = lastDataReceiveTime_;
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
//@synthesize fileManager = fileManager_;

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
    return [NSString stringWithFormat:@"<%@ [url: %@] [downloadPath: %@] [fileName: %@] [currentFileSize: %u] [cachedFileName: %@] [status: %d]>",
            NSStringFromClass([self class]), self.URL, self.downloadPath, self.fileName, self.currentFileSize, self.fileCacheKey, self.status];
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
        self.cacheManager = [MGPAssetCacheManager defaultCache];
    }
    return self;
}

+ (MGPRemoteAssetDownloader *) downloaderForAssetAtURL:(NSURL *)sourceURL
{
    NSString *defaultDestination = [MGPAssetCacheManager cachePath];
    return [[self alloc] initWithURL:sourceURL destinationPath:defaultDestination];
}

+ (MGPRemoteAssetDownloader *) downloaderForAssetAtURL:(NSURL *)sourceURL toDestinationPath:(NSString *)destinationPath
{
    return [[self alloc] initWithURL:sourceURL destinationPath:destinationPath];
}

+ (NSString *) fileKeyForURL:(NSURL *)url
{
    return [[[url absoluteString] mgp_md5] stringByAppendingPathExtension:[url pathExtension]];
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

- (id) cacheKey
{
    return [[self class] fileKeyForURL:self.URL];
}

- (NSString *) targetFile
{
    return [self.cacheManager cachePathForURL:self.URL];
    //    return [self.downloadPath stringByAppendingPathComponent:[self cacheKey]];
}

- (void) beginDownload
{
    self.status = MGPRemoteAssetDownloaderStateNotStarted;
    
    NSAssert(self.downloadPath, @"downloadPath is not set");
    NSAssert(self.URL, @"URL is not set");
    //    NSAssert(self.fileManager, @"fileManager is not set");
    
    if ([self.cacheManager hasURLBeenCached:self.URL])
    {
        DDLogInfo(@"Returned cached asset for URL: %@", self.URL);
        [self downloadCompleted];
    }
    else 
    {
        [self.cacheManager prepareCacheFileForURL:self.URL];

        [self resume];
    }
}

- (void) connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    self.currentFileSize = [self.cacheManager fileSizeForURL:self.URL];
    
    NSHTTPURLResponse *httpResonse = (NSHTTPURLResponse *)response;
    NSDictionary *headers = [httpResonse allHeaderFields];
    
    self.status = MGPRemoteAssetDownloaderStateDownloading;
    DDLogVerbose(@"Response Headers: %@", headers);
    
    self.expectedFileSize = [httpResonse expectedContentLength];
    self.fileName = [httpResonse suggestedFilename];

    self.serverAllowsResume = [[headers valueForKey:@"Accept-Ranges"] hasSuffix:@"bytes"];
    self.writeHandle = [NSFileHandle fileHandleForWritingAtPath:self.targetFile];

    //parse content range, setup file pointers
    NSString *contentRange = [headers valueForKey:@"Content-Range"];
    if (contentRange && (self.currentFileSize > 0))
    {
        long long startOfRange = NSNotFound, endOfRange = NSNotFound, totalContentLength = NSNotFound;
        scanContentRange(contentRange, &startOfRange, &endOfRange, &totalContentLength);

        [self.writeHandle seekToFileOffset:startOfRange];
    }
    
    self.downloadStartTime = [NSDate timeIntervalSinceReferenceDate];
    
    SEL startNotificationAction = self.currentFileSize == 0 ? @selector(downloader:didBeginDownloadingURL:) : @selector(downloader:didResumeDownloadingURL:);
    
    [self performActionOnDelegate:startNotificationAction withObject:self.URL];
}

- (NSDictionary *) receivedDataSummary:(NSData *)data
{
    NSNumber *progress = [NSNumber numberWithFloat:((float)self.currentFileSize / (float)(self.expectedFileSize ?: MAXFLOAT))];
    NSNumber *bytesRemaining = [NSNumber numberWithFloat:self.expectedFileSize - self.currentFileSize];
    
    NSTimeInterval currentTime = [NSDate timeIntervalSinceReferenceDate];
    NSTimeInterval timeDelta = currentTime - self.downloadStartTime;
    float estimatedBandwidth = (float)self.currentFileSize / (timeDelta ?: MAXFLOAT);
    
    NSNumber *estBandwidth = [NSNumber numberWithFloat:estimatedBandwidth];
    NSNumber *estTimeRemaining = [NSNumber numberWithFloat: (float)(self.expectedFileSize - self.currentFileSize) / estimatedBandwidth];

    NSDictionary *summary = [NSDictionary dictionaryWithObjectsAndKeys:
                             progress, kMGPProgressKey, 
                             bytesRemaining, kMGPBytesRemainingKey, 
                             estTimeRemaining, kMGPTimeRemainingKey,
                             estBandwidth, kMGPEstimatedBandwidthKey,
                             nil];
    
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

- (void) downloadCompleted
{
    self.status = MGPRemoteAssetDownloaderStateComplete;
    [self performActionOnDelegate:@selector(downloader:didCompleteDownloadingURL:) withObject:self.URL];
}

- (void) connectionDidFinishLoading:(NSURLConnection *)connection
{
    self.connection = nil;
    [self.writeHandle closeFile];
    [self downloadCompleted];
}

- (void) connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    [self.writeHandle closeFile];
    self.connection = nil;
    self.status = MGPRemoteAssetDownloaderStateFailed;
}

- (void) cancel
{
    [self.connection cancel];
    self.connection = nil;
    self.status = MGPRemoteAssetDownloaderStateCanceled;
    
    [self performActionOnDelegate:@selector(downloader:didCancelDownloadingURL:) withObject:self.URL];
}

- (void) pause
{
    [self.connection cancel];
    self.connection = nil;
    self.status = MGPRemoteAssetDownloaderStatePaused;
    
    [self performActionOnDelegate:@selector(downloader:didPauseDownloadingURL:) withObject:self.URL];
}

- (BOOL) shouldResumeDownloader
{
    NSInteger nonResumingStates[4] = 
        {MGPRemoteAssetDownloaderStateComplete,
         MGPRemoteAssetDownloaderStateDownloading, 
         MGPRemoteAssetDownloaderStateRequestSent,
         MGPRemoteAssetDownloaderStateCanceled};
    
    BOOL shouldResume = YES;
    for (int i=0; i < 4; i++) 
    {
        shouldResume &= (self.status != nonResumingStates[i]);
    }
    return shouldResume;
}

- (void) resume
{    
    //TODO: do NOT restart downloader if this INSTANCE has completed successfully!
    //make downloader so that it cannot be resumed...downloader must be dealloced to restart

    if (![self shouldResumeDownloader]) return;
    
    //if status != Canclled && != Completed && networkIsConnected
    if ([self.delegate isURLReachable:self.URL])
    {
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:self.URL 
                                                               cachePolicy:NSURLCacheStorageNotAllowed 
                                                           timeoutInterval:self.requestTimeout];
        
        if (self.serverAllowsResume)
        {
            [request addValue:[NSString stringWithFormat:@"bytes=%ull-", self.currentFileSize] forHTTPHeaderField:@"Range"];
        }
        
        self.request = request;
        self.downloadStartTime = [NSDate timeIntervalSinceReferenceDate];
        
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