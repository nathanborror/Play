//
//  PLAppDelegate.m
//  Play
//
//  Created by Nathan Borror on 12/30/12.
//  Copyright (c) 2012 Nathan Borror. All rights reserved.
//

#import "PLAppDelegate.h"
#import "SonosController.h"
#import "PLInputStore.h"
#import "PLNowPlayingViewController.h"
#import "PLSpeakersViewController.h"
#import "PLNextUpViewController.h"

@implementation PLAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
  _window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
  [_window setTintColor:[UIColor colorWithRed:1 green:.16 blue:.41 alpha:1]];
  [_window setBackgroundColor:[UIColor whiteColor]];

  [[UISlider appearance] setMaximumTrackImage:[UIImage imageNamed:@"PLProgressMax"] forState:UIControlStateNormal];
  [[UISlider appearance] setMinimumTrackImage:[UIImage imageNamed:@"PLProgressMin"] forState:UIControlStateNormal];

  // Find all Sonos speakers before anything else.
  [SonosController discover:^(NSArray *inputs, NSError *error) {
    dispatch_async(dispatch_get_main_queue(), ^{
      NSArray *groupings = [[SonosInputStore sharedStore] allInputsGrouped];

      if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        PLNowPlayingViewController *viewController = [[PLNowPlayingViewController alloc] initWIthGroup:[groupings firstObject]];
        UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:viewController];

        PLSpeakersViewController *speakerViewController = [[PLSpeakersViewController alloc] init];

        NSArray *viewControllers = [NSArray arrayWithObjects:navController, speakerViewController, nil];

        UISplitViewController *splitViewController = [[UISplitViewController alloc] init];
        [splitViewController setViewControllers:viewControllers];
        [splitViewController setDelegate:speakerViewController];

        [self.window setRootViewController:splitViewController];
      } else {
        PLNowPlayingViewController *nowPlaying = [[PLNowPlayingViewController alloc] initWIthGroup:[groupings firstObject]];
        UINavigationController *nowPlayingNavController = [[UINavigationController alloc] initWithRootViewController:nowPlaying];
        [_window setRootViewController:nowPlayingNavController];
      }
    });
  }];

  [_window makeKeyAndVisible];
  return YES;
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
  [[SonosInputStore sharedStore] saveChanges];
}

@end
