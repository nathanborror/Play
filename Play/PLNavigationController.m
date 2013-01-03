//
//  PLCustomNavigationController.m
//  Play
//
//  Created by Nathan Borror on 1/1/13.
//  Copyright (c) 2013 Nathan Borror. All rights reserved.
//

#import "PLNavigationController.h"

@implementation PLNavigationController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
  self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
  if (self) {
    // Back Button
    UIImage *backButtonImage = [[UIImage imageNamed:@"CustomBackButtonItem.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(0.0, 14.0, 0.0, 5.0)];
    [[UIBarButtonItem appearance] setBackButtonBackgroundImage:backButtonImage forState:UIControlStateNormal barMetrics:UIBarMetricsDefault];

    // Button Item
    [[UIBarButtonItem appearance] setBackgroundImage:[UIImage imageNamed:@"CustomBarButtonItem.png"] forState:UIControlStateNormal barMetrics:UIBarMetricsDefault];

    // Bar
    [self.navigationBar setBackgroundImage:[UIImage imageNamed:@"NavBar.png"] forBarMetrics:UIBarMetricsDefault];
  }
  return self;
}

@end
