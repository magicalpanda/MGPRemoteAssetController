//
//  MGPDownloaderView.h
//  MGPRemoteAssetController
//
//  Created by Saul Mora on 5/17/11.
//  Copyright 2011 Magical Panda Software LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MGPRemoteAssetDownloader;

@interface MGPDownloaderViewController : UIViewController {}


@property (nonatomic, retain) MGPRemoteAssetDownloader *downloader;


@property (nonatomic, retain) IBOutlet UILabel *fileName;
@property (nonatomic, retain) IBOutlet UILabel *fileSize;
@property (nonatomic, retain) IBOutlet UILabel *bytesDownloaded;
@property (nonatomic, retain) IBOutlet UILabel *timeRemaining;
@property (nonatomic, retain) IBOutlet UILabel *url;
@property (nonatomic, retain) IBOutlet UILabel *bandwidth;
@property (nonatomic, retain) IBOutlet UIProgressView *downloadProgress;

- (IBAction) pauseDownload:(id)sender;
- (IBAction) resumeDownload:(id)sender;


@end
