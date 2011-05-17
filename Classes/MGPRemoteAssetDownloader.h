//
//  MGPRemoteAssetDownloader.h
//  MGPRemoteAssetController
//
//  Created by Saul Mora on 5/9/11.
//  Copyright 2011 Magical Panda Software LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MGPFileCache.h"

extern NSString * const kMGPDownloaderKey;

@class MGPRemoteAssetDownloader;

@protocol MGPRemoteAssetDownloaderDelegate <NSObject>
@required

- (BOOL) isURLReachable:(NSURL *)url;

@optional

- (void) downloader:(MGPRemoteAssetDownloader *)downloader didBeginDownloadingURL:(NSURL *)url;
- (void) downloader:(MGPRemoteAssetDownloader *)downloader didCompleteDownloadingURL:(NSURL *)url;
- (void) downloader:(MGPRemoteAssetDownloader *)downloader didPauseDownloadingURL:(NSURL *)url;
- (void) downloader:(MGPRemoteAssetDownloader *)downloader didResumeDownloadingURL:(NSURL *)url;

- (void) downloader:(MGPRemoteAssetDownloader *)downloader dataDidProgress:(NSNumber *)currentProgress remaining:(NSNumber *)remaining;

- (void) downloader:(MGPRemoteAssetDownloader *)downloader failedToDownloadURL:(NSURL *)url;

@end

@interface MGPRemoteAssetDownloader : NSObject<MGPFileCacheItem> {}

@property (nonatomic, assign) NSObject<MGPRemoteAssetDownloaderDelegate> *delegate;
@property (nonatomic, copy) NSString *downloadPath;
@property (nonatomic, retain) NSURL *URL;
@property (nonatomic, retain) NSFileManager *fileManager;
@property (nonatomic, readonly, retain) NSFileHandle *writeHandle;
@property (nonatomic, readonly, copy) NSString *fileName;

@property (nonatomic, assign, readonly) float downloadProgress;
@property (nonatomic, assign, readonly) unsigned long long currentFileSize;
@property (nonatomic, assign, readonly) long long expectedFileSize;
@property (nonatomic, assign, readonly) float bandwidth;
@property (nonatomic, assign, readonly) unsigned long long bytesRemaining;
@property (nonatomic, assign, readonly) NSTimeInterval timeRemaining;

//estimated download speed
//estimated completion time

- (void) beginDownload;
- (void) pause;
- (void) resume;

@end
