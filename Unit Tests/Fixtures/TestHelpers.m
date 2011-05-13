//
//  TestHelpers.m
//  MGPRemoteAssetController
//
//  Created by Saul Mora on 5/12/11.
//  Copyright 2011 Magical Panda Software LLC. All rights reserved.
//

#import "TestHelpers.h"

@implementation TestHelpers

+ (id) dataForFixtureNamed:(NSString *)fixtureName
{
    NSString *path = [[NSBundle mainBundle] pathForResource:[fixtureName stringByDeletingPathExtension]
                                                     ofType:[fixtureName pathExtension]
                                                inDirectory:@"Fixtures"];
    return [[[NSData alloc] initWithContentsOfFile:path] autorelease];
}

+ (NSURL *) fileURLForFixtureNamed:(NSString *)fixtureName
{
    return [[NSBundle mainBundle] URLForResource:[fixtureName stringByDeletingPathExtension]
                                   withExtension:[fixtureName pathExtension]
                                    subdirectory:@"Fixtures"];
}

+ (NSString *) scratchPath
{
    return [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject];
}

@end
