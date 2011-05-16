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
@synthesize bytesDownloaded = bytesDownloaded_;
@synthesize bandwidth = bandwidth_;

- (void) dealloc
{
    self.bandwidth = nil;
    self.bytesDownloaded = nil;
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
    
    self.bytesDownloaded.text = @"";
    self.url.text = [self.downloader.URL absoluteString];
    
    [self.downloader addObserver:self 
                      forKeyPath:@"downloadProgress" 
                         options:NSKeyValueObservingOptionInitial | NSKeyValueObservingOptionNew
                         context:&kMGPRemoteAssetTableViewCellObservingContext];
}

- (void) updateDownloadProgress
{
    self.fileName.text = self.downloader.fileName;
    self.fileSize.text = [NSString stringWithFormat:@"%qi bytes", self.downloader.expectedFileSize];
    self.bytesDownloaded.text = [NSString stringWithFormat:@"%qu bytes", self.downloader.currentFileSize];
    self.timeRemaining.text = [NSString stringWithFormat:@"%f seconds", self.downloader.timeRemaining];
    self.bandwidth.text = [NSString stringWithFormat:@"%f kbps", self.downloader.bandwidth];
    self.downloadProgress.progress = self.downloader.downloadProgress;
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

- (void) swapAction:(SEL)newAction forAction:(SEL)oldAction onControl:(UIControl *)control
{
    [control removeTarget:self action:oldAction forControlEvents:UIControlEventAllEvents];
    [control addTarget:self action:newAction forControlEvents:UIControlEventTouchUpInside];
}

- (IBAction) pauseDownload:(id)sender
{
    [self.downloader pause];
    [self swapAction:@selector(resumeDownload:) forAction:@selector(pauseDownload:) onControl:sender];
}

- (IBAction) resumeDownload:(id)sender
{
    [self.downloader resume];
    [self swapAction:@selector(pauseDownload:) forAction:@selector(resumeDownload:) onControl:sender];
}

@end
