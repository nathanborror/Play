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
#import "PLSpeakersViewController.h"

@implementation PLAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
  self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];

  [[UISlider appearance] setMaximumTrackImage:[UIImage imageNamed:@"PLProgressMax"] forState:UIControlStateNormal];
  [[UISlider appearance] setMinimumTrackImage:[UIImage imageNamed:@"PLProgressMin"] forState:UIControlStateNormal];

  [self.window setTintColor:[UIColor colorWithRed:.99 green:.29 blue:.44 alpha:1]];

  PLNowPlayingViewController *viewController = [[PLNowPlayingViewController alloc] init];
  UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:viewController];
  [navController.navigationBar setTranslucent:NO];

  if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
    PLSpeakersViewController *speakerViewController = [[PLSpeakersViewController alloc] init];
    UINavigationController *speakerNavController = [[UINavigationController alloc] initWithRootViewController:speakerViewController];

    [viewController setDelegate:speakerViewController];

    NSArray *viewControllers = [NSArray arrayWithObjects:navController, speakerNavController, nil];

    UISplitViewController *splitViewController = [[UISplitViewController alloc] init];
    [splitViewController setViewControllers:viewControllers];
    [splitViewController setDelegate:speakerViewController];

    [self.window setRootViewController:splitViewController];
  } else {
    [self.window setRootViewController:navController];
  }

  [self.window setBackgroundColor:[UIColor whiteColor]];
  [self.window makeKeyAndVisible];
  return YES;
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
  [[SonosInputStore sharedStore] saveChanges];
}

@end
