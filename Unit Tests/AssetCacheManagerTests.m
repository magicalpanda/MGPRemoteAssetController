//
//  AssetFileCacheTests.m
//  MGPRemoteAssetController
//
//  Created by Saul Mora on 5/16/11.
//  Copyright 2011 Magical Panda Software LLC. All rights reserved.
//

#import "AssetCacheManagerTests.h"
#import "MGPAssetCacheManager.h"

@implementation AssetCacheManagerTests

@synthesize testCache;

- (void) setUp
{
    self.testCache = [[[MGPAssetCacheManager alloc] init] autorelease];
}

- (void) tearDown
{
    self.testCache = nil;
}

- (void) testShouldBeCreated
{
    assertThat(self.testCache, is(notNilValue()));
}

- (void) testDefaultCachePath
{
    NSString *cachesPath = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject];
    assertThat([self.testCache cachePath], startsWith(cachesPath));
    assertThat([self.testCache cachePath], endsWith(kMGPFileCacheDefaultCacheFolder));
}

- (void) testShouldRemoveExpiredAssets
{
    ///    [self.testCache]
}

- (void) testShouldRetrieveFileForKey
{
    //    NSObject<MGPFileCacheItem> *mockItem = [OCMockObject mockForProtocol:@protocol(MGPFileCacheItem)];
    //    [[[mockItem expect] andReturn:@"MockedCacheKey"] cacheKey];
    
    
}

- (void) testShouldRetrieveMetadataForKey
{
    GHFail(@"Not Implemented");
}

- (void) testShouldRetrieveFileSizeForKey
{
    GHFail(@"Not Implemented");
}

@end
