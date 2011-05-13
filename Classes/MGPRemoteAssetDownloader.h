//
//  MGPRemoteAssetDownloader.h
//  MGPRemoteAssetController
//
//  Created by Saul Mora on 5/9/11.
//  Copyright 2011 Magical Panda Software LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

@class MGPRemoteAssetDownloader;

@protocol MGPRemoteAssetDownloaderDelegate <NSObject>
@optional
- (void) downloader:(MGPRemoteAssetDownloader *)downloader didBeginDownloadingURL:(NSURL *)url;
- (void) downloader:(MGPRemoteAssetDownloader *)downloader didCompleteDownloadingURL:(NSURL *)url;
- (void) downloader:(MGPRemoteAssetDownloader *)downloader dataDidProgress:(NSNumber *)currentProgress remaining:(NSNumber *)remaining;

@end

@interface MGPRemoteAssetDownloader : NSObject {
    
}

@property (nonatomic, assign) id<MGPRemoteAssetDownloaderDelegate> delegate;
@property (nonatomic, copy) NSString *downloadPath;
@property (nonatomic, retain) NSURL *URL;
@property (nonatomic, retain) NSFileManager *fileManager;
@property (nonatomic, readonly, retain) NSFileHandle *writeHandle;

- (void) beginDownload;

@end
