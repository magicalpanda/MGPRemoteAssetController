//
//  AssetFileCacheTests.m
//  MGPRemoteAssetController
//
//  Created by Saul Mora on 5/16/11.
//  Copyright 2011 Magical Panda Software LLC. All rights reserved.
//

#import "AssetFileCacheTests.h"
#import "MGPFileCache.h"

@implementation AssetFileCacheTests

@synthesize testCache;

-(void)setUp
{
    self.testCache = [[[MGPFileCache alloc] init] autorelease];
}

-(void)tearDown
{
    self.testCache = nil;
}

- (void) testShouldBeCreated
{
    assertThat(self.testCache, is(notNilValue()));
}

@end
