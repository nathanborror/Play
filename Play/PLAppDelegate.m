//
//  PLAppDelegate.m
//  Play
//
//  Created by Nathan Borror on 12/30/12.
//  Copyright (c) 2012 Nathan Borror. All rights reserved.
//

#import "PLAppDelegate.h"
#import "SonosInputStore.h"
#import "PLNowPlayingViewController.h"

@implementation PLAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
  self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
  [self.window setBackgroundColor:[UIColor whiteColor]];

  [[UISlider appearance] setMaximumTrackImage:[UIImage imageNamed:@"PLProgressMax"] forState:UIControlStateNormal];
  [[UISlider appearance] setMinimumTrackImage:[UIImage imageNamed:@"PLProgressMin"] forState:UIControlStateNormal];

  [self.window setTintColor:[UIColor colorWithRed:.99 green:.29 blue:.44 alpha:1]];

  PLNowPlayingViewController *viewController = [[PLNowPlayingViewController alloc] init];
  UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:viewController];
  [navController.navigationBar setTranslucent:NO];
  [self.window setRootViewController:navController];

  [self.window makeKeyAndVisible];
  return YES;
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
  [[SonosInputStore sharedStore] saveChanges];
}

@end
