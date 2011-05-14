//
//  MGPRemoteAssetViewController.h
//  MGPRemoteAssetController
//
//  Created by Saul Mora on 5/14/11.
//  Copyright 2011 Magical Panda Software LLC. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface MGPRemoteAssetViewController : UIViewController<UITableViewDelegate, UITableViewDataSource> {}

@property (nonatomic, retain) IBOutlet UITableView *downloadList;


@end