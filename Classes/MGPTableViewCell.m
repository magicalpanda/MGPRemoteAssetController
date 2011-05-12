//
//  MGPTableViewCell.m
//  MGPRemoteAssetController
//
//  Created by Saul Mora on 5/9/11.
//  Copyright 2011 Magical Panda Software LLC. All rights reserved.
//

#import "MGPTableViewCell.h"


@implementation MGPTableViewCell

- (NSString *) nibName 
{
    return NSStringFromClass([self class]);
}

- (NSString *) cellIdentifier
{
    return NSStringFromClass([self class]);
}

- (UINib *) nib
{
    NSBundle *bundle = [NSBundle bundleForClass:[self class]];
    UINib *nib = [UINib nibWithNibName:[self nibName] bundle:bundle];
    return nib;
}

- (UITableViewCell *) cellForTableView:(UITableView *)tableView fromNib:(UINib *)nib
{
    NSString *cellIdentifier = [self cellIdentifier];
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if (cell == nil)
    {
        NSArray *views = [nib instantiateWithOwner:self options:nil];
        cell = [views objectAtIndex:0];
    }
    
    return cell;
}

- (UITableViewCell *) cellForTableView:(UITableView *)tableView
{
    NSString *cellIdentifier = [self cellIdentifier];
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil)
    {
        cell = [[[[self class] alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier] autorelease];
    }
    
    return cell;
}

@end
