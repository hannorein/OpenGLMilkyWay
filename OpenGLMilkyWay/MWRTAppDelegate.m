//
//  MWRTAppDelegate.m
//  OpenGLMilkyWay
//
//  Created by Hanno Rein on 12/17/12.
//  Copyright (c) 2012 Hanno Rein. All rights reserved.
//

#import "MWRTAppDelegate.h"

#import "UniverseViewController.h"

@implementation MWRTAppDelegate

- (void)dealloc{
    [_window release];
    [_viewController release];
    [super dealloc];
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions{
    self.window = [[[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]] autorelease];
    // Override point for customization after application launch.

    self.viewController =  [[[UniverseViewController alloc] init] autorelease];
    self.window.rootViewController = self.viewController;
    [self.window makeKeyAndVisible];
    return YES;
}

@end
