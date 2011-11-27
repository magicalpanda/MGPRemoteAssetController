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

@synthesize downloader = _downloader;
@synthesize fileName = _fileName;
@synthesize fileSize = _fileSize;
@synthesize url = _url;
@synthesize timeRemaining = _timeRemaining;
@synthesize downloadProgress = _downloadProgress;
@synthesize bytesDownloaded = _bytesDownloaded;
@synthesize bandwidth = _bandwidth;

- (void) awakeFromNib
{
    self.downloadProgress.progress = 0;
}

- (void) setDownloader:(MGPRemoteAssetDownloader *)downloader
{
    if (downloader == _downloader) return;
    
    [_downloader removeObserver:self forKeyPath:@"downloadProgress"];
        
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
