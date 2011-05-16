//
//  MGPRemoteAssetControllerAppDelegate.m
//
//  Created by Saul Mora on 5/9/11.
//  Copyright 2011 Magical Panda Software, LLC rights reserved.
//

#import "MGPRemoteAssetControllerAppDelegate.h"

int ddLogLevel = LOG_LEVEL_VERBOSE;

@implementation MGPRemoteAssetControllerAppDelegate

@synthesize window = window_;
@synthesize viewController = viewController_;

- (void)dealloc 
{
    self.window = nil;
    self.viewController = nil;
    [super dealloc];
}

#pragma mark -
#pragma mark Application lifecycle

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [DDLog addLogger:[DDNSLoggerLogger sharedInstance]];
    
    [self.window addSubview:self.viewController.view];
    [self.window makeKeyAndVisible];
    
    return YES;
}

@end