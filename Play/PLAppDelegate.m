//
//  PLAppDelegate.m
//  Play
//
//  Created by Nathan Borror on 12/30/12.
//  Copyright (c) 2012 Nathan Borror. All rights reserved.
//

#import "PLAppDelegate.h"
#import "PLSpeakersViewController.h"
#import "SonosInputStore.h"

@implementation PLAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
  self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
  [self.window setBackgroundColor:[UIColor whiteColor]];

  // UISlider appearance
  [[UISlider appearance] setMaximumTrackImage:[[UIImage imageNamed:@"SliderMaxValue.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(3, 3, 3, 3) resizingMode:UIImageResizingModeStretch] forState:UIControlStateNormal];
  [[UISlider appearance] setMinimumTrackImage:[[UIImage imageNamed:@"SliderMinValue.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(3, 3, 3, 3) resizingMode:UIImageResizingModeStretch] forState:UIControlStateNormal];
  [[UISlider appearance] setThumbImage:[UIImage imageNamed:@"SliderThumb.png"] forState:UIControlStateNormal];
  [[UISlider appearance] setThumbImage:[UIImage imageNamed:@"SliderThumbPressed.png"] forState:UIControlStateHighlighted];

  PLSpeakersViewController *viewController = [[PLSpeakersViewController alloc] init];
  UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:viewController];
  [self.window setRootViewController:navController];

  [self.window makeKeyAndVisible];
  return YES;
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
  [[SonosInputStore sharedStore] saveChanges];
}

@end
