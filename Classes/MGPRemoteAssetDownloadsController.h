//
//  MGPRemoteAssetController.h
//  MGPRemoteAssetController
//
//  Created by Saul Mora on 5/12/11.
//  Copyright 2011 Magical Panda Software LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

@class MGPRemoteAssetDownloader;

extern NSString * const kMGPRADownloadsControllerDownloadAddedNotification;
extern NSString * const kMGPRADownloadsControlelrDownloadStartedNotification;
extern NSString * const kMGPRADownloadsControllerDownloadRemovedNotifiction;
extern NSString * const kMGPRADownloadsControllerDownloadPausedNotifiction;
extern NSString * const kMGPRADownloadsControllerDownloadResumedNotifiction;
extern NSString * const kMGPRADownloadsControllerDownloadFailedNotifiction;
extern NSString * const kMGPRADownloadsControllerDownloadCompletedNotification;

@interface MGPRemoteAssetDownloadsController : NSObject {
    
}

@property (nonatomic, readonly) NSSet *activeDownloads;

- (MGPRemoteAssetDownloader *) downloadAssetAtURL:(NSURL *)url;
- (MGPRemoteAssetDownloader *) downloadImageAssetAtURL:(NSURL *)url;
- (MGPRemoteAssetDownloader *) downloadAudioAssetAtURL:(NSURL *)url;
- (MGPRemoteAssetDownloader *) downloadVideoAssetAtURL:(NSURL *)url;
- (MGPRemoteAssetDownloader *) downloadCoreDataStoreAssetAtURL:(NSURL *)url;

@end