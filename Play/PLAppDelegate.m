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
    PLNowPlayingViewController *nowPlaying = [[PLNowPlayingViewController alloc] init];
    [_window setRootViewController:nowPlaying];
  }

  [_window makeKeyAndVisible];
  return YES;
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
  [[SonosControllerStore sharedStore] saveChanges];
}

@end
