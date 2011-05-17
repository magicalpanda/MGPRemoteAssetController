//
//  NSDate+Helpers.m
//  MGPRemoteAssetController
//
//  Created by Saul Mora on 5/16/11.
//  Copyright 2011 Magical Panda Software LLC. All rights reserved.
//

#import "NSDate+Helpers.h"


@implementation NSDate (NSDate_Helpers)

- (BOOL) mgp_isBefore:(NSDate *)other
{
    return [self compare:other] == NSOrderedDescending;
}

- (BOOL) mgp_isAfter:(NSDate *)other
{
    return [self compare:other] == NSOrderedAscending;
}

@end
