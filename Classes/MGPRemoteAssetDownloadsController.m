//
//  MGPRemoteAssetController.m
//  MGPRemoteAssetController
//
//  Created by Saul Mora on 5/12/11.
//  Copyright 2011 Magical Panda Software LLC. All rights reserved.
//

#import "MGPRemoteAssetDownloadsController.h"
#import "MGPRemoteAssetDownloader.h"
#import "MGPAssetCacheManager.h"
#import "Reachability.h"
#import "NSString+MD5.h"
#import "MGPAssetCacheManager.h"

NSString * const kMGPRADownloadsControllerDownloadAddedNotification = @"kMGPRADownloadsControllerAddedDownloadNotification";
NSString * const kMGPRADownloadsControlelrDownloadStartedNotification = @"kMGPRADownloadsControlelrDownloadStartedNotification";
NSString * const kMGPRADownloadsControllerDownloadRemovedNotification = @"kMGPRADownloadsControllerDownloadRemovedNotification";
NSString * const kMGPRADownloadsControllerDownloadPausedNotification = @"kMGPRADownloadsControllerDownloadPausedNotification";
NSString * const kMGPRADownloadsControllerDownloadResumedNotification = @"kMGPRADownloadsControllerDownloadResumedNotification";
NSString * const kMGPRADownloadsControllerDownloadFailedNotification = @"kMGPRADownloadsControllerDownloadFailedNotification";
NSString * const kMGPRADownloadsControllerDownloadCompletedNotification = @"kMGPRADownloadsControllerDownloadCompletedNotification";
NSString * const kMGPRADownloadsControllerAllDownloadsCompletedNotification = @"kMGPRADownloadsControllerAllDownloadsCompletedNotification";

@interface MGPRemoteAssetDownloadsController ()

@property (nonatomic, assign) UIBackgroundTaskIdentifier backgroundTaskId;
@property (nonatomic, retain) NSMutableArray *downloads;
@property (nonatomic, assign) BOOL networkIsReachable;

- (void) reachabilityChanged;

@end

@implementation MGPRemoteAssetDownloadsController

@synthesize networkIsReachable = networkIsReachable_;
@synthesize backgroundTaskId = backgroundTaskId_;
@synthesize activeDownloads = activeDownloads_;
@synthesize downloads = downloads_;
@synthesize fileCache = fileCache_;

- (void) dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kReachabilityChangedNotification object:nil];
    
    self.fileCache = nil;
    self.downloads = nil;
    [super dealloc];
}

- (void) initController
{
    self.fileCache = [MGPAssetCacheManager defaultCache];
    self.downloads = [NSMutableArray array];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(reachabilityChanged) 
                                                 name:kReachabilityChangedNotification 
                                               object:nil];
    [self reachabilityChanged];
}

- (id) init
{
    self = [super init];
    if (self)
    {
        [self initController];
    }
    return self;
}

+ (id) controller;
{
    return [[[self alloc] init] autorelease];
}

- (void) reachabilityChanged
{
    self.networkIsReachable = [[Reachability reachabilityForInternetConnection] currentReachabilityStatus] != NotReachable;
}

- (NSArray *) allDownloads
{
    return [NSArray arrayWithArray:self.downloads];
}

- (NSArray *) activeDownloads
{
    NSPredicate *activeDownloadQuery = [NSPredicate predicateWithFormat:@"status = %d", MGPRemoteAssetDownloaderStateDownloading];
    return [self.downloads filteredArrayUsingPredicate:activeDownloadQuery];
}

- (BOOL) isURLReachable:(NSURL *)url
{
    Reachability *hostReachability = [Reachability reachabilityWithHostName:[url host]];

    return hostReachability.currentReachabilityStatus != NotReachable;
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
    if ([self.activeDownloads count])
    {
        self.backgroundTaskId = [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:^(void) {
           //what to do when time expired? 
        }];
    }    
    [self pauseAllDownloads];
}

- (void) applicationWillEnterForeground:(NSNotification *)notification
{
    [self resumeAllDownloads];
}

- (void) postNotificationName:(NSString *)notificationName withDownloader:(MGPRemoteAssetDownloader *)downloader;
{
    NSDictionary *userInfo = downloader ? [NSDictionary dictionaryWithObject:downloader forKey:kMGPDownloaderKey] : nil;
    NSNotification *notification = [NSNotification notificationWithName:notificationName 
                                                                 object:self
                                                               userInfo:userInfo];
    
    [[NSNotificationCenter defaultCenter] performSelectorOnMainThread:@selector(postNotification:) withObject:notification waitUntilDone:YES];
}

- (void) downloaderComplete:(MGPRemoteAssetDownloader *)downloader
{
    [self.downloads removeObject:downloader];
//    [self.fileCache setMetadataForKey:[downloader cacheKey]];
    if ([self.downloads count] == 0)
    {
        if (self.backgroundTaskId)
        {
            [[UIApplication sharedApplication] endBackgroundTask:self.backgroundTaskId];
        }
        [self postNotificationName:kMGPRADownloadsControllerAllDownloadsCompletedNotification withDownloader:nil];
    }
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
    [self downloaderComplete:downloader];
    [self postNotificationName:kMGPRADownloadsControllerDownloadCompletedNotification withDownloader:downloader];
}

- (void) downloader:(MGPRemoteAssetDownloader *)downloader dataDidProgress:(NSDictionary *)currentProgress
{
    DDLogVerbose(@"Data progress: %@", currentProgress);
}

- (void) downloader:(MGPRemoteAssetDownloader *)downloader failedToDownloadURL:(NSURL *)url
{
    [self downloaderComplete:downloader];
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

- (MGPRemoteAssetDownloader *) createDownloaderWithURL:(NSURL *)url
{
    MGPRemoteAssetDownloader *downloader = [[MGPRemoteAssetDownloader alloc] initWithURL:url destinationPath:self.fileCache.cachePath];
    
    downloader.fileManager = self.fileCache.fileManager;
    downloader.delegate = self;
    
    return downloader;
}

- (MGPRemoteAssetDownloader *) downloaderForURL:(NSURL *)url;
{
    if ([self.fileCache assetValidForKey:[[url absoluteString] mgp_md5]])
    {
        return nil;
    }
    
    NSUInteger downloaderIndex = [self.downloads indexOfObjectPassingTest:^BOOL(id obj, NSUInteger idx, BOOL *stop) 
    {
        MGPRemoteAssetDownloader *downloader = (MGPRemoteAssetDownloader *)obj;
        return [downloader.URL isEqual:url];
    }];

    MGPRemoteAssetDownloader *downloader = downloaderIndex == NSNotFound ? 
                                            [self createDownloaderWithURL:url] : 
                                            [self.downloads objectAtIndex:downloaderIndex];
    
    if (downloaderIndex == NSNotFound) 
    {
        [self.downloads addObject:downloader];
        [self postNotificationName:kMGPRADownloadsControllerDownloadAddedNotification withDownloader:downloader];
    }
    return downloader;
}

- (void) pauseAllDownloads;
{
    [self.downloads makeObjectsPerformSelector:@selector(pause)];
}

- (void) resumeAllDownloads;
{
    [self.downloads makeObjectsPerformSelector:@selector(resume)];
}

- (void) cancelAllDownloads;
{
    [self.downloads makeObjectsPerformSelector:@selector(cancel)];
}

@end
