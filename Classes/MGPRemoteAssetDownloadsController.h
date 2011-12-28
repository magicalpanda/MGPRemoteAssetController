//
//  MGPRemoteAssetController.h
//  MGPRemoteAssetController
//
//  Created by Saul Mora on 5/12/11.
//  Copyright 2011 Magical Panda Software LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MGPRemoteAssetDownloader.h"

@class MGPAssetCacheManager;

extern NSString * const kMGPRADownloadsControllerDownloadAddedNotification;
extern NSString * const kMGPRADownloadsControlelrDownloadStartedNotification;
extern NSString * const kMGPRADownloadsControllerDownloadRemovedNotification;
extern NSString * const kMGPRADownloadsControllerDownloadPausedNotification;
extern NSString * const kMGPRADownloadsControllerDownloadResumedNotification;
extern NSString * const kMGPRADownloadsControllerDownloadFailedNotification;
extern NSString * const kMGPRADownloadsControllerDownloadCompletedNotification;
extern NSString * const kMGPRADownloadsControllerAllDownloadsCompletedNotification;


@interface MGPRemoteAssetDownloadsController : NSObject<MGPRemoteAssetDownloaderDelegate>

@property (nonatomic, strong, readonly) NSArray *allDownloads;
@property (nonatomic, strong, readonly) NSArray *activeDownloads;
@property (nonatomic, strong) MGPAssetCacheManager *fileCache;

- (MGPRemoteAssetDownloader *) downloaderForURL:(NSURL *)url;

- (void) downloadAssetAtURL:(NSURL *)url progress:(void(^)(NSDictionary *))progressCallback completion:(void(^)(BOOL))completion;

+ (id) controller;
+ (id) sharedController;

- (void) pauseAllDownloads;
- (void) resumeAllDownloads;
- (void) cancelAllDownloads;

@end