//
//  MGPRemoteAssetViewController.m
//  MGPRemoteAssetController
//
//  Created by Saul Mora on 5/14/11.
//  Copyright 2011 Magical Panda Software LLC. All rights reserved.
//

#import "MGPRemoteAssetViewController.h"
#import "MGPRemoteAssetTableViewCell.h"
#import "MGPRemoteAssetDownloadsController.h"
#import "NSNotification+MGPAssetDownloader.h"

@interface MGPRemoteAssetViewController ()

@property (nonatomic, retain) MGPRemoteAssetDownloadsController *downloadController;
@property (nonatomic, retain) NSMutableDictionary *indexPaths;

@end

@implementation MGPRemoteAssetViewController

@synthesize downloadList = downloadList_;
@synthesize downloadController = downloadController_;
@synthesize indexPaths = indexPaths_;

- (void) dealloc
{
    self.indexPaths = nil;
    self.downloadController = nil;
    self.downloadList = nil;
    [super dealloc];
}

- (void) setupViewController
{
    self.downloadController = [[[MGPRemoteAssetDownloadsController alloc] init] autorelease];    
    self.indexPaths = [NSMutableDictionary dictionary];
}

-(id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) 
    {
        [self setupViewController];
    }
    return self;
}

-(id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self)
    {
        [self setupViewController];
    }
    return self;
}

- (void) registerForNotifications
{
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center addObserver:self
               selector:@selector(downloaderWasAdded:) 
                   name:kMGPRADownloadsControllerDownloadAddedNotification
                 object:self.downloadController];
//    [center addObserver:self
//               selector:@selector(downloaderWasAdded:) 
//                   name:kMGPRADownloadsControllerDownloadResumedNotification 
//                 object:self.downloadController];
    [center addObserver:self 
               selector:@selector(downloaderDidComplete:) 
                   name:kMGPRADownloadsControllerDownloadCompletedNotification 
                 object:self.downloadController];          
}

- (void) removeFromNotifications
{
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center removeObserver:self
                      name:kMGPRADownloadsControllerDownloadAddedNotification
                    object:self.downloadController];
//    [center removeObserver:self
//                      name:kMGPRADownloadsControllerDownloadResumedNotification 
//                    object:self.downloadController];
    [center removeObserver:self
                      name:kMGPRADownloadsControllerDownloadCompletedNotification 
                    object:self.downloadController];
}

- (void) viewDidLoad
{
    [self registerForNotifications];
}

- (void) viewDidUnload
{
    self.downloadList = nil;
    [self removeFromNotifications];
    [super viewDidUnload];
}

- (NSIndexPath *) indexPathForDownloaderInNotification:(NSNotification *)notification
{
    MGPRemoteAssetDownloader *downloader = [notification downloader];
    NSIndexPath *indexPath = [self.indexPaths objectForKey:downloader.URL];
    
    if (indexPath == nil)
    {
        NSUInteger index = [self.downloadController.activeDownloads indexOfObject:downloader];
        indexPath = (index == NSNotFound) ? nil : [NSIndexPath indexPathForRow:index inSection:0];
        [self.indexPaths setObject:indexPath forKey:downloader.URL];
    }
    return indexPath;
}

- (void) downloaderWasAdded:(NSNotification *)notification
{
    NSIndexPath *indexPath = [self indexPathForDownloaderInNotification:notification];
    if (indexPath != nil)
    {
        [self.downloadList beginUpdates];
        [self.downloadList insertRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewScrollPositionBottom];
        [self.downloadList endUpdates];
    }
}

- (void) downloaderDidComplete:(NSNotification *)notification
{
    NSIndexPath *indexPath = [self indexPathForDownloaderInNotification:notification];
    if (indexPath != nil)
    {
        [self.indexPaths removeObjectForKey:[notification downloader].URL];
        [self.downloadList beginUpdates];
        [self.downloadList deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationTop];
        [self.downloadList endUpdates];
    }
}

- (BOOL) shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    return YES;
}

- (MGPRemoteAssetDownloader *) downloaderAtIndexPath:(NSIndexPath *)indexPath
{
    return [self.downloadController.activeDownloads objectAtIndex:indexPath.row];
}

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.downloadController.activeDownloads count];
}

- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    MGPRemoteAssetTableViewCell *cell = [MGPRemoteAssetTableViewCell cellForTableView:tableView
                                                                              fromNib:[MGPRemoteAssetTableViewCell nib]];
    cell.downloader = [self downloaderAtIndexPath:indexPath];
    return cell;
}

- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 130;
}

@end
