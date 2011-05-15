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

- (NSSet *) activeDownloads
{
    return [NSSet setWithSet:self.downloads];
}

- (MGPRemoteAssetDownloader *) downloadAssetAtURL:(NSURL *)url;
{
    return  nil;
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
