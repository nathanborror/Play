//
//  PLAppDelegate.m
//  Play
//
//  Created by Nathan Borror on 12/30/12.
//  Copyright (c) 2012 Nathan Borror. All rights reserved.
//

#import "PLAppDelegate.h"
#import "PLNowPlayingViewController.h"
#import "PLSpeakersViewController.h"
#import "PLSettingsController.h"
#import "UIColor+Common.h"

#import <SonosKit/SonosControllerStore.h>

@implementation PLAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
  _window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
  [_window setTintColor:[UIColor tintColor]];
  [_window setBackgroundColor:[UIColor whiteColor]];

  if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
    PLNowPlayingViewController *nowPlaying = [[PLNowPlayingViewController alloc] init];
    PLSpeakersViewController *speakers = [[PLSpeakersViewController alloc] init];

    NSArray *viewControllers = [NSArray arrayWithObjects:nowPlaying, speakers, nil];
    UISplitViewController *splitViewController = [[UISplitViewController alloc] init];
    [splitViewController setViewControllers:viewControllers];
    [splitViewController setDelegate:speakers];
    [splitViewController.view setOpaque:NO];
    [splitViewController.view setBackgroundColor:[UIColor colorWithWhite:.1 alpha:1]];

    [_window setRootViewController:splitViewController];
  } else {
    UITabBarController *tabController = [[UITabBarController alloc] init];

    PLNowPlayingViewController *playingController = [[PLNowPlayingViewController alloc] init];
    UINavigationController *playingNavController = [[UINavigationController alloc] initWithRootViewController:playingController];

    PLSpeakersViewController *speakerController = [[PLSpeakersViewController alloc] init];
    UINavigationController *speakerNavController = [[UINavigationController alloc] initWithRootViewController:speakerController];

    PLSettingsController *settingsController = [[PLSettingsController alloc] init];
    UINavigationController *settingsNavController = [[UINavigationController alloc] initWithRootViewController:settingsController];

    [tabController setViewControllers:@[playingNavController, speakerNavController, settingsNavController]];

    [_window setRootViewController:tabController];
  }

  [_window makeKeyAndVisible];
  return YES;
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
  [[SonosControllerStore sharedStore] saveChanges];
}

@end
