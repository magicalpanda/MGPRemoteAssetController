//
//  MGPTableViewCell.h
//  MGPRemoteAssetController
//
//  Created by Saul Mora on 5/9/11.
//  Copyright 2011 Magical Panda Software LLC. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface MGPTableViewCell : UITableViewCell

+ (UINib *) nib;

+ (id) cellForTableView:(UITableView *)tableView fromNib:(UINib *)nib;
+ (id) cellForTableView:(UITableView *)tableView;

@end
