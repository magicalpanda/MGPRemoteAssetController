//
//  NSDate+Helpers.h
//  MGPRemoteAssetController
//
//  Created by Saul Mora on 5/16/11.
//  Copyright 2011 Magical Panda Software LLC. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface NSDate (NSDate_Helpers)

- (BOOL) mgp_isBefore:(NSDate *)other;
- (BOOL) mgp_isAfter:(NSDate *)other;

@end
