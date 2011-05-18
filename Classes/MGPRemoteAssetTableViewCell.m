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

@synthesize downloader = downloader_;
@synthesize downloadViewController = downloadViewController_;

- (void) dealloc
{
    self.downloadViewController = nil;
    self.downloader = nil;
    [super dealloc];
}

- (void) initCell
{
    self.downloadViewController = [[[MGPDownloaderViewController alloc] init] autorelease];
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
    if (downloader == downloader_) return;
    
    [downloader_ release];
    downloader_ = [downloader retain];
    
    self.downloadViewController.downloader = downloader_;
}

@end