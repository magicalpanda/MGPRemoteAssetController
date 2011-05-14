//
//  MGPRemoteAssetController.h
//  MGPRemoteAssetController
//
//  Created by Saul Mora on 5/12/11.
//  Copyright 2011 Magical Panda Software LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSString * const kMGPRADownloadsControllerDownloadAddedNotification;
extern NSString * const kMGPRADownloadsControllerDownloadRemovedNotifiction;
extern NSString * const kMGPRADownloadsControllerDownloadPausedNotifiction;
extern NSString * const kMGPRADownloadsControllerDownloadResumedNotifiction;
extern NSString * const kMGPRADownloadsControllerDownloadFailedNotifiction;

@interface MGPRemoteAssetDownloadsController : NSObject {
    
}

@property (nonatomic, readonly) NSSet *activeDownloads;

@end
