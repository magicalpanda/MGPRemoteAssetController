//
//  GHTestCase+Swizzle.h
//  MGPRemoteAssetController
//
//  Created by Saul Mora on 5/12/11.
//  Copyright 2011 Magical Panda Software LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <GHUnitIOS/GHUnit.h>

@class GHTestCase;

@interface GHTestCase (Swizzle)

+ (id)sharedMock;
+ (void)setSharedMock:(id)newMock;

- (void)swizzle:(Class)target_class selector:(SEL)selector;
- (void)deswizzle;

@end