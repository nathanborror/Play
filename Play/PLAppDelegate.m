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
#import "PLNextUpViewController.h"

@implementation PLAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
  self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
  [self.window setTintColor:[UIColor colorWithRed:1 green:.16 blue:.41 alpha:1]];

  [[UISlider appearance] setMaximumTrackImage:[UIImage imageNamed:@"PLProgressMax"] forState:UIControlStateNormal];
  [[UISlider appearance] setMinimumTrackImage:[UIImage imageNamed:@"PLProgressMin"] forState:UIControlStateNormal];

  if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
    PLNowPlayingViewController *viewController = [[PLNowPlayingViewController alloc] init];
    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:viewController];

    PLSpeakersViewController *speakerViewController = [[PLSpeakersViewController alloc] init];
    UINavigationController *speakerNavController = [[UINavigationController alloc] initWithRootViewController:speakerViewController];

    NSArray *viewControllers = [NSArray arrayWithObjects:navController, speakerNavController, nil];

    UISplitViewController *splitViewController = [[UISplitViewController alloc] init];
    [splitViewController setViewControllers:viewControllers];
    [splitViewController setDelegate:speakerViewController];

    [self.window setRootViewController:splitViewController];
  } else {
    UITabBarController *tabController = [[UITabBarController alloc] init];

    PLNextUpViewController *nextUp = [[PLNextUpViewController alloc] init];
    UINavigationController *nextUpNavController = [[UINavigationController alloc] initWithRootViewController:nextUp];

    PLSpeakersViewController *speakers = [[PLSpeakersViewController alloc] init];

    PLNowPlayingViewController *nowPlaying = [[PLNowPlayingViewController alloc] init];

    [tabController setViewControllers:@[nowPlaying, speakers, nextUpNavController]];

    [self.window setRootViewController:tabController];
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
