//
//  PLAppDelegate.m
//  Play
//
//  Created by Nathan Borror on 12/30/12.
//  Copyright (c) 2012 Nathan Borror. All rights reserved.
//

#import "PLAppDelegate.h"
#import "PLInputsViewController.h"
#import "PLInputStore.h"

@implementation PLAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
  self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];

  PLInputsViewController *viewController = [[PLInputsViewController alloc] init];
  UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:viewController];
  [self.window setRootViewController:navController];

  [[UINavigationBar appearance] setBackgroundImage:[[UIImage imageNamed:@"NavBar"] resizableImageWithCapInsets:UIEdgeInsetsMake(4,4,4,4) resizingMode:UIImageResizingModeStretch] forBarMetrics:UIBarMetricsDefault];

  [[UIBarButtonItem appearance] setBackgroundImage:[[UIImage imageNamed:@"BarButtonItem"] resizableImageWithCapInsets:UIEdgeInsetsMake(4,4,4,4) resizingMode:UIImageResizingModeStretch] forState:UIControlStateNormal barMetrics:UIBarMetricsDefault];

  [[UIBarButtonItem appearance] setBackgroundImage:[[UIImage imageNamed:@"BarButtonItemDone"] resizableImageWithCapInsets:UIEdgeInsetsMake(4,4,4,4) resizingMode:UIImageResizingModeStretch] forState:UIControlStateNormal style:UIBarButtonItemStyleDone barMetrics:UIBarMetricsDefault];

  [[UIBarButtonItem appearance] setBackButtonBackgroundImage:[[UIImage imageNamed:@"BarButtonItemBack"] resizableImageWithCapInsets:UIEdgeInsetsMake(15, 15, 4, 4) resizingMode:UIImageResizingModeStretch] forState:UIControlStateNormal barMetrics:UIBarMetricsDefault];

  [self.window makeKeyAndVisible];
  return YES;
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
  [[PLInputStore sharedStore] saveChanges];
}

@end
