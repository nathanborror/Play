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
#import "PLLoadingViewController.h"

@implementation PLAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
  _window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
  [_window setTintColor:[UIColor colorWithRed:1 green:.16 blue:.41 alpha:1]];
  [_window setBackgroundColor:[UIColor whiteColor]];

  PLLoadingViewController *loadingViewController = [[PLLoadingViewController alloc] init];
  [_window setRootViewController:loadingViewController];

  // Find all Sonos speakers before anything else.
  [SonosController discover:^(NSArray *inputs, NSError *error) {
    dispatch_async(dispatch_get_main_queue(), ^{
      [_window.rootViewController removeFromParentViewController];

      if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        PLNowPlayingViewController *viewController = [[PLNowPlayingViewController alloc] init];
        UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:viewController];

        PLSpeakersViewController *speakerViewController = [[PLSpeakersViewController alloc] init];

        NSArray *viewControllers = [NSArray arrayWithObjects:navController, speakerViewController, nil];

        UISplitViewController *splitViewController = [[UISplitViewController alloc] init];
        [splitViewController setViewControllers:viewControllers];
        [splitViewController setDelegate:speakerViewController];

        [splitViewController.view setOpaque:NO];
        [splitViewController.view setBackgroundColor:[UIColor colorWithWhite:.1 alpha:1]];

        [self.window setRootViewController:splitViewController];
      } else {
        PLNowPlayingViewController *nowPlaying = [[PLNowPlayingViewController alloc] init];
        [_window setRootViewController:nowPlaying];
      }
    });
  }];

  [_window makeKeyAndVisible];
  return YES;
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
  [[PLInputStore sharedStore] saveChanges];
}

@end
