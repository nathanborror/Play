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

  // UINavigationBar appearance
  [[UINavigationBar appearance] setBackgroundImage:[[UIImage imageNamed:@"NavBar"] resizableImageWithCapInsets:UIEdgeInsetsMake(4,4,4,4) resizingMode:UIImageResizingModeStretch] forBarMetrics:UIBarMetricsDefault];
  [[UINavigationBar appearance] setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIColor whiteColor], UITextAttributeTextColor, [UIColor blackColor], UITextAttributeTextShadowColor, 0, UITextAttributeTextShadowOffset, nil]];
  [[UINavigationBar appearance] setShadowImage:[[UIImage alloc] init]];

  // UIBarButtonItem appearance
  [[UIBarButtonItem appearance] setBackgroundImage:[[UIImage imageNamed:@"BarButtonItem"] resizableImageWithCapInsets:UIEdgeInsetsMake(4,4,4,4) resizingMode:UIImageResizingModeStretch] forState:UIControlStateNormal barMetrics:UIBarMetricsDefault];
  [[UIBarButtonItem appearance] setBackgroundImage:[[UIImage imageNamed:@"BarButtonItemDone"] resizableImageWithCapInsets:UIEdgeInsetsMake(4,4,4,4) resizingMode:UIImageResizingModeStretch] forState:UIControlStateNormal style:UIBarButtonItemStyleDone barMetrics:UIBarMetricsDefault];

  UIImage *backButtonImage = [[UIImage imageNamed:@"BarButtonItemBackIcon"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 0, 0, 0)];
  [[UIBarButtonItem appearance] setBackButtonBackgroundImage:backButtonImage  forState:UIControlStateNormal barMetrics:UIBarMetricsDefault];
  [[UIBarButtonItem appearance] setBackButtonTitlePositionAdjustment:UIOffsetMake(0, backButtonImage.size.height * 2) forBarMetrics:UIBarMetricsDefault];

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
