//
//  MGPDownloaderView.m
//  MGPRemoteAssetController
//
//  Created by Saul Mora on 5/17/11.
//  Copyright 2011 Magical Panda Software LLC. All rights reserved.
//

#import "MGPDownloaderViewController.h"
#import "MGPRemoteAssetDownloader.h"


static void const * kMGPRemoteAssetDownloaderObservingContext = &kMGPRemoteAssetDownloaderObservingContext;


@implementation MGPDownloaderViewController

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
    
    self.fileName = nil;
    self.fileSize = nil;
    self.url = nil;
    self.timeRemaining = nil;
    self.downloadProgress = nil;
    [super dealloc];
}

- (void) awakeFromNib
{
    self.downloadProgress.progress = 0;
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
                         context:&kMGPRemoteAssetDownloaderObservingContext];
}

- (void) observedownloadProgress
{
    self.fileName.text = self.downloader.fileName;
    self.fileSize.text = [NSString stringWithFormat:@"%qi bytes", self.downloader.expectedFileSize];
    self.bytesDownloaded.text = [NSString stringWithFormat:@"%.1qu bytes", self.downloader.currentFileSize];
    self.timeRemaining.text = [NSString stringWithFormat:@"%.1f seconds", self.downloader.timeRemaining];
    self.bandwidth.text = [NSString stringWithFormat:@"%.1f kbps", self.downloader.bandwidth];
    self.downloadProgress.progress = self.downloader.downloadProgress;
}

- (void) observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if (context == kMGPRemoteAssetDownloaderObservingContext && object == self.downloader) 
    {
        SEL selector = NSSelectorFromString([NSString stringWithFormat:@"observe%@", keyPath]);
        [self performSelector:selector];
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
