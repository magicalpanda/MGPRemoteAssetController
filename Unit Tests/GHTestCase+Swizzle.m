//
//  GHTestCase+Swizzle.m
//  MGPRemoteAssetController
//
//  Created by Saul Mora on 5/12/11.
//  Copyright 2011 Magical Panda Software LLC. All rights reserved.
//

#import "GHTestCase+Swizzle.h"

#import <objc/runtime.h>

id sharedMockPointer = nil;

@implementation GHTestCase (Swizzle)

+(id)sharedMock
{
	return sharedMockPointer;
}

+(void)setSharedMock:(id)newMock
{
	sharedMockPointer = newMock;
}

Method originalMethod = nil;
Method swizzleMethod = nil;

- (void)swizzle:(Class)target_class selector:(SEL)selector
{
	originalMethod = class_getClassMethod(target_class, selector);
	swizzleMethod = class_getInstanceMethod([self class], selector);
	method_exchangeImplementations(originalMethod, swizzleMethod);
}

- (void)deswizzle
{
	method_exchangeImplementations(swizzleMethod, originalMethod);
	swizzleMethod = nil;
	originalMethod = nil;
}

@end