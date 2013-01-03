//
//  PLAppDelegate.m
//  Play
//
//  Created by Nathan Borror on 12/30/12.
//  Copyright (c) 2012 Nathan Borror. All rights reserved.
//

#import "PLAppDelegate.h"
#import "PLInputsViewController.h"
#import "PLNavigationController.h"
#import "PLInputStore.h"

@implementation PLAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
  self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];

  PLInputsViewController *viewController = [[PLInputsViewController alloc] init];
  UINavigationController *navController = [[PLNavigationController alloc] initWithRootViewController:viewController];
  [self.window setRootViewController:navController];
  
  [self.window makeKeyAndVisible];
  return YES;
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
  [[PLInputStore sharedStore] saveChanges];
}

@end
