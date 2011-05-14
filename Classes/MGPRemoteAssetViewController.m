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

@interface MGPRemoteAssetViewController ()

@property (nonatomic, retain) MGPRemoteAssetDownloadsController *downloadController;

@end

@implementation MGPRemoteAssetViewController

@synthesize downloadList = downloadList_;
@synthesize downloadController = downloadController_;

- (void) dealloc
{
    self.downloadController = nil;
    self.downloadList = nil;
    [super dealloc];
}

-(id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) 
    {
        self.downloadController = [[[MGPRemoteAssetDownloadsController alloc] init] autorelease];
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

- (void) downloaderWasAdded:(NSNotification *)notification
{
    //add to bottom of tableview
}

- (void) downloaderDidComplete:(NSNotification *)notification
{
    //find indexpath, remove cell at indexPath
}

- (BOOL) shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    return YES;
}

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.downloadController.activeDownloads count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    MGPRemoteAssetTableViewCell *cell = [MGPRemoteAssetTableViewCell cellForTableView:tableView
                                                                  fromNib:[MGPRemoteAssetTableViewCell nib]];
    return cell;
}

- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 130;
}

@end
