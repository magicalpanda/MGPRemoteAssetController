//
//  MGPRemoteAssetTableViewCell.m
//  MGPRemoteAssetController
//
//  Created by Saul Mora on 5/8/11.
//  Copyright 2011 Magical Panda Software LLC. All rights reserved.
//

#import "MGPRemoteAssetTableViewCell.h"
#import "MGPRemoteAssetDownloader.h"

static void const * kMGPRemoteAssetTableViewCellObservingContext = &kMGPRemoteAssetTableViewCellObservingContext;

@implementation MGPRemoteAssetTableViewCell

@synthesize downloader = downloader_;
@synthesize fileName = fileName_;
@synthesize fileSize = fileSize_;
@synthesize url = url_;
@synthesize timeRemaining = timeRemaining_;
@synthesize downloadProgress = downloadProgress_;

- (void) dealloc
{
    self.downloader = nil;
    self.fileName = nil;
    self.fileSize = nil;
    self.url = nil;
    self.timeRemaining = nil;
    self.downloadProgress = nil;
    [super dealloc];
}

- (void) awakeFromNib
{
//    self.fileName.text = nil;
//    self.fileSize.text = nil;
//    self.url.text = nil;
//    self.timeRemaining.text = nil;
    self.downloadProgress.progress = 0;
}

- (void)prepareForReuse
{
    self.selected = NO;
}

- (void) setDownloader:(MGPRemoteAssetDownloader *)downloader
{
    if (downloader == downloader_) return;
    
    [downloader_ removeObserver:self forKeyPath:@"downloadProgress"];
    
    [downloader_ release];
    downloader_ = [downloader retain];
    
    self.fileName.text = nil;
    self.fileSize.text = [NSString stringWithFormat:@"%lld bytes", self.downloader.expectedFileSize];
    self.url.text = [self.downloader.URL absoluteString];
    
    [self.downloader addObserver:self 
                      forKeyPath:@"downloadProgress" 
                         options:NSKeyValueObservingOptionInitial | NSKeyValueObservingOptionNew
                         context:&kMGPRemoteAssetTableViewCellObservingContext];
}

- (void) updateDownloadProgress
{
    self.downloadProgress.progress = self.downloader.downloadProgress;
    self.timeRemaining.text = nil;
}

-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if (context == kMGPRemoteAssetTableViewCellObservingContext) 
    {
        if (object == self.downloader)
        {
            if ([keyPath isEqualToString:@"downloadProgress"])
            {
                [self updateDownloadProgress];
            }
        }
    }
    else
    {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

- (IBAction) pauseDownload
{
    
}

- (IBAction) resumeDownload
{
    
}

@end
