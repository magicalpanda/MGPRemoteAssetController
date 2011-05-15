//
//  MGPRemoteAssetController.m
//  MGPRemoteAssetController
//
//  Created by Saul Mora on 5/12/11.
//  Copyright 2011 Magical Panda Software LLC. All rights reserved.
//

#import "MGPRemoteAssetDownloadsController.h"

NSString * const kMGPRADownloadsControllerDownloadAddedNotification = @"kMGPRADownloadsControllerAddedDownloadNotification";
NSString * const kMGPRADownloadsControlelrDownloadStartedNotification = @"kMGPRADownloadsControlelrDownloadStartedNotification";
NSString * const kMGPRADownloadsControllerDownloadRemovedNotification = @"kMGPRADownloadsControllerDownloadRemovedNotification";
NSString * const kMGPRADownloadsControllerDownloadPausedNotification = @"kMGPRADownloadsControllerDownloadPausedNotification";
NSString * const kMGPRADownloadsControllerDownloadResumedNotification = @"kMGPRADownloadsControllerDownloadResumedNotification";
NSString * const kMGPRADownloadsControllerDownloadFailedNotification = @"kMGPRADownloadsControllerDownloadFailedNotification";
NSString * const kMGPRADownloadsControllerDownloadCompletedNotification = @"kMGPRADownloadsControllerDownloadCompletedNotification";

@interface MGPRemoteAssetDownloadsController ()

@property (nonatomic, retain) NSMutableSet *downloads;

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
        self.downloads = [NSMutableSet set];
    }
    return self;
}

- (NSSet *) activeDownloads
{
    return [NSSet setWithSet:self.downloads];
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

-(void)downloader:(MGPRemoteAssetDownloader *)downloader didBeginDownloadingURL:(NSURL *)url
{
    [[NSNotificationCenter defaultCenter] postNotificationName:kMGPRADownloadsControlelrDownloadStartedNotification 
                                                        object:self
                                                      userInfo:[NSDictionary dictionaryWithObject:downloader forKey:kMGPDownloaderKey]];
}

- (MGPRemoteAssetDownloader *) downloadAssetAtURL:(NSURL *)url;
{
    MGPRemoteAssetDownloader *downloader = [self downloaderWithURL:url];
    
    if (![self.downloads containsObject:downloader]) 
    {
        [self.downloads addObject:downloader];
        [[NSNotificationCenter defaultCenter] postNotificationName:kMGPRADownloadsControllerDownloadAddedNotification 
                                                            object:self
                                                          userInfo:[NSDictionary dictionaryWithObject:downloader forKey:kMGPDownloaderKey]];
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

@end
