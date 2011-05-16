//
//  MGPRemoteAssetController.m
//  MGPRemoteAssetController
//
//  Created by Saul Mora on 5/12/11.
//  Copyright 2011 Magical Panda Software LLC. All rights reserved.
//

#import "MGPRemoteAssetDownloadsController.h"
#import "Reachability.h"

NSString * const kMGPRADownloadsControllerDownloadAddedNotification = @"kMGPRADownloadsControllerAddedDownloadNotification";
NSString * const kMGPRADownloadsControlelrDownloadStartedNotification = @"kMGPRADownloadsControlelrDownloadStartedNotification";
NSString * const kMGPRADownloadsControllerDownloadRemovedNotification = @"kMGPRADownloadsControllerDownloadRemovedNotification";
NSString * const kMGPRADownloadsControllerDownloadPausedNotification = @"kMGPRADownloadsControllerDownloadPausedNotification";
NSString * const kMGPRADownloadsControllerDownloadResumedNotification = @"kMGPRADownloadsControllerDownloadResumedNotification";
NSString * const kMGPRADownloadsControllerDownloadFailedNotification = @"kMGPRADownloadsControllerDownloadFailedNotification";
NSString * const kMGPRADownloadsControllerDownloadCompletedNotification = @"kMGPRADownloadsControllerDownloadCompletedNotification";

@interface MGPRemoteAssetDownloadsController ()

@property (nonatomic, retain) NSMutableArray *downloads;

@end

@implementation MGPRemoteAssetDownloadsController

@synthesize activeDownloads = activeDownloads_;
@synthesize downloads = downloads_;

- (void) dealloc
{
    self.downloads = nil;
    [super dealloc];
}

- (id) init
{
    self = [super init];
    if (self)
    {
        self.downloads = [NSMutableArray array];
    }
    return self;
}

- (NSArray *) activeDownloads
{
    return [NSArray arrayWithArray:self.downloads];
}

- (BOOL) isURLReachable:(NSURL *)url
{
    Reachability *reachability = [Reachability reachabilityWithHostName:[url host]];
    
    return [reachability currentReachabilityStatus] != NotReachable;
}

- (void) registerForNotifications
{
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center addObserver:self
               selector:@selector(applicationDidEnterBackground:)
                   name:UIApplicationDidEnterBackgroundNotification 
                 object:[UIApplication sharedApplication]];
    [center addObserver:self 
               selector:@selector(applicationWillEnterForeground:) 
                   name:UIApplicationWillEnterForegroundNotification 
                 object:[UIApplication sharedApplication]];
}

- (void) applicationDidEnterBackground:(NSNotification *)notification
{
    [self pauseAllDownloads];
}

- (void) applicationWillEnterForeground:(NSNotification *)notification
{
    [self resumeAllDownloads];
}

- (MGPRemoteAssetDownloader *) downloaderWithURL:(NSURL *)url
{
    MGPRemoteAssetDownloader *downloader = [[MGPRemoteAssetDownloader alloc] init];
    
    NSString *cachePath = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject];
    downloader.downloadPath = cachePath;
    downloader.fileManager = [NSFileManager defaultManager];
    downloader.URL = url;
    downloader.delegate = self;
    
    return downloader;
}

- (void) postNotificationName:(NSString *)notificationName withDownloader:(MGPRemoteAssetDownloader *)downloader;
{
    NSNotification *notification = [NSNotification notificationWithName:notificationName 
                                                                 object:self
                                                               userInfo:[NSDictionary dictionaryWithObject:downloader forKey:kMGPDownloaderKey]];
    
    [[NSNotificationCenter defaultCenter] performSelectorOnMainThread:@selector(postNotification:) withObject:notification waitUntilDone:YES];
}

- (void) downloader:(MGPRemoteAssetDownloader *)downloader didBeginDownloadingURL:(NSURL *)url
{
    [self postNotificationName:kMGPRADownloadsControlelrDownloadStartedNotification withDownloader:downloader];
}

- (void) downloader:(MGPRemoteAssetDownloader *)downloader didResumeDownloadingURL:(NSURL *)url
{
    [self postNotificationName:kMGPRADownloadsControllerDownloadResumedNotification withDownloader:downloader];
}

- (void) downloader:(MGPRemoteAssetDownloader *)downloader didCompleteDownloadingURL:(NSURL *)url
{
    [self.downloads removeObject:downloader];
    [self postNotificationName:kMGPRADownloadsControllerDownloadCompletedNotification withDownloader:downloader];
}

- (void) downloader:(MGPRemoteAssetDownloader *)downloader dataDidProgress:(NSNumber *)currentProgress remaining:(NSNumber *)remaining
{
    DDLogVerbose(@"Data progress: %@", currentProgress);
}

- (void) downloader:(MGPRemoteAssetDownloader *)downloader failedToDownloadURL:(NSURL *)url
{
    [self postNotificationName:kMGPRADownloadsControllerDownloadFailedNotification withDownloader:downloader];
}

- (id) assetForURL:(NSURL *)url
{
    //if in file cache, load into memory, return right away
    return nil;
}

- (void) assetForURL:(NSURL *)url completion:(void(^)(id))callback
{
    // if in file cache load into memory, callback(asset)
    //if not in file cache, download, load into memory, callback(asset)
}

- (MGPRemoteAssetDownloader *) downloadAssetAtURL:(NSURL *)url;
{
    MGPRemoteAssetDownloader *downloader = [self downloaderWithURL:url];
    
    if (![self.downloads containsObject:downloader]) 
    {
        [self.downloads addObject:downloader];
        [self postNotificationName:kMGPRADownloadsControllerDownloadAddedNotification withDownloader:downloader];
        [downloader beginDownload];
    }
    return downloader;
}

- (MGPRemoteAssetDownloader *) downloadImageAssetAtURL:(NSURL *)url;
{
    return  nil;    
}
- (MGPRemoteAssetDownloader *) downloadAudioAssetAtURL:(NSURL *)url;
{
    return  nil;
}
- (MGPRemoteAssetDownloader *) downloadVideoAssetAtURL:(NSURL *)url;
{
    return  nil;
}
- (MGPRemoteAssetDownloader *) downloadCoreDataStoreAssetAtURL:(NSURL *)url;
{
    return  nil;
}

- (void) pauseAllDownloads;
{
//    [self.downloads makeObjectsPerformSelector:@selector(pause)];
}

- (void) resumeAllDownloads;
{
//    [self.downloads makeObjectsPerformSelector:@selector(resume)];
}

- (void) cancelAllDownloads;
{
//    [self.downloads makeObjectsPerformSelector:@selector(cancel)];
}

@end
