//
//  MGPRemoteAssetController.m
//  MGPRemoteAssetController
//
//  Created by Saul Mora on 5/12/11.
//  Copyright 2011 Magical Panda Software LLC. All rights reserved.
//

#import "NPReachability.h"
#import "MGPRemoteAssetDownloadsController.h"
#import "MGPRemoteAssetDownloader.h"
#import "MGPAssetCacheManager.h"
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

//need private download queue

@interface MGPRemoteAssetDownloadsController ()

@property (nonatomic, assign) UIBackgroundTaskIdentifier backgroundTaskId;
@property (nonatomic, retain) NSMutableArray *downloads;
@property (nonatomic, assign) BOOL networkIsReachable;

- (void) reachabilityChanged;

@end

@implementation MGPRemoteAssetDownloadsController

@synthesize networkIsReachable = _networkIsReachable;
@synthesize backgroundTaskId = _backgroundTaskId;
@synthesize activeDownloads = _activeDownloads;
@synthesize downloads = _downloads;
@synthesize fileCache = _fileCache;

- (void) dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NPReachabilityChangedNotification object:nil];
}

- (void) initController
{
    self.fileCache = [MGPAssetCacheManager defaultCache];
    self.downloads = [NSMutableArray array];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(reachabilityChanged) 
                                                 name:NPReachabilityChangedNotification 
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
    return [[self alloc] init];
}

+ (id) sharedController;
{
    static MGPRemoteAssetDownloadsController *controller = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        controller = [self controller];
    });
    return controller;
}

- (void) reachabilityChanged
{
    self.networkIsReachable = [[NPReachability sharedInstance] isCurrentlyReachable];
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
    return self.networkIsReachable;
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
    //    DDLogVerbose(@"Data progress: %@", currentProgress);
}

- (void) downloader:(MGPRemoteAssetDownloader *)downloader failedToDownloadURL:(NSURL *)url
{
    [self downloaderComplete:downloader];
    [self postNotificationName:kMGPRADownloadsControllerDownloadFailedNotification withDownloader:downloader];
}

- (void) downloadAssetAtURL:(NSURL *)url progress:(void(^)(NSDictionary *))progressCallback completion:(void(^)(BOOL))completion;
{
    MGPRemoteAssetDownloader *downloader = [self downloaderForURL:url];
    if (downloader.status != MGPRemoteAssetDownloaderStateDownloading) 
    {
        [downloader beginDownload:progressCallback completion:completion];
    }
}

- (MGPRemoteAssetDownloader *) createDownloaderWithURL:(NSURL *)url;
{
    MGPRemoteAssetDownloader *downloader = [MGPRemoteAssetDownloader downloaderForAssetAtURL:url];

    downloader.delegate = self;
    
    return downloader;
}

- (MGPRemoteAssetDownloader *) downloaderForURL:(NSURL *)url;
{
    if ([self.fileCache hasURLBeenCached:url])
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
