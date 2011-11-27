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

@synthesize downloadList = _downloadList;
@synthesize downloadController = _downloadController;
@synthesize indexPaths = _indexPaths;

- (void) setupViewController
{
    self.downloadController = [[MGPRemoteAssetDownloadsController alloc] init];
    self.indexPaths = [NSMutableDictionary dictionary];
}

- (id) initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) 
    {
        [self setupViewController];
    }
    return self;
}

- (id) initWithCoder:(NSCoder *)aDecoder
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

- (IBAction) togglePauseAndResume:(id)sender;
{
//    [self.downloadController pauseAllDownloads];
}

- (NSIndexPath *) indexPathForDownloaderInNotification:(NSNotification *)notification
{
    MGPRemoteAssetDownloader *downloader = [notification downloader];
    NSIndexPath *indexPath = [self.indexPaths objectForKey:downloader.URL];
    
    if (indexPath == nil)
    {
        NSUInteger index = [self.downloadController.allDownloads indexOfObject:downloader];
        indexPath = (index == NSNotFound) ? nil : [NSIndexPath indexPathForRow:index inSection:0];
        if (indexPath)
        {
            [self.indexPaths setObject:indexPath forKey:downloader.URL];
        }
    }
    return indexPath;
}

- (void) downloaderWasAdded:(NSNotification *)notification
{
    NSIndexPath *indexPath = [self indexPathForDownloaderInNotification:notification];
    if (indexPath != nil)
    {
        [self.downloadList beginUpdates];
        [self.downloadList insertRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationBottom];
        [self.downloadList endUpdates];
        
        // Only start if we can see it!
        MGPRemoteAssetDownloader *downloader = [notification downloader];
        [downloader beginDownload]; 
    }
}

- (void) downloaderDidComplete:(NSNotification *)notification
{
    NSIndexPath *indexPath = [self indexPathForDownloaderInNotification:notification];
    if (indexPath != nil)
    {
        MGPRemoteAssetDownloader *downloader = [notification downloader];
        [self.indexPaths removeObjectForKey:downloader.URL];
        
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
    return [self.downloadController.allDownloads objectAtIndex:indexPath.row];
}

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.downloadController.allDownloads count];
}

- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    MGPRemoteAssetTableViewCell *cell = [MGPRemoteAssetTableViewCell cellForTableView:tableView];
    cell.downloader = [self downloaderAtIndexPath:indexPath];
    return cell;
}

- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 130;
}

@end
