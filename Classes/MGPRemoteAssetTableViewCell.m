//
//  MGPRemoteAssetTableViewCell.m
//  MGPRemoteAssetController
//
//  Created by Saul Mora on 5/8/11.
//  Copyright 2011 Magical Panda Software LLC. All rights reserved.
//

#import "MGPRemoteAssetTableViewCell.h"
#import "MGPRemoteAssetDownloader.h"
#import "MGPDownloaderViewController.h"

@interface MGPRemoteAssetTableViewCell ()

@property (nonatomic, retain) MGPDownloaderViewController *downloadViewController;

@end


@implementation MGPRemoteAssetTableViewCell

@synthesize downloader = _downloader;
@synthesize downloadViewController = _downloadViewController;

- (void) initCell
{
    self.downloadViewController = [[MGPDownloaderViewController alloc] init];
    [self.downloadViewController.view setAutoresizingMask:UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth];
    
    [self.contentView addSubview:self.downloadViewController.view];
}

-(id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self initCell];
    }
    return self;
}

-(id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) 
    {
        [self initCell];
    }
    return self;
}

- (void)prepareForReuse
{
    self.selected = NO;
}

- (void) setDownloader:(MGPRemoteAssetDownloader *)downloader
{
    if (downloader == _downloader) return;
    
    self.downloadViewController.downloader = _downloader;
}

@end