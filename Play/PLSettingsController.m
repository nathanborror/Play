//
//  PLSettingsController.m
//  Play
//
//  Created by Nathan Borror on 5/3/14.
//  Copyright (c) 2014 Nathan Borror. All rights reserved.
//

#import "PLSettingsController.h"

@implementation PLSettingsController

- (instancetype)init
{
  if (self = [super init]) {
    [self setTitle:@"More"];
  }
  return self;
}

- (UITabBarItem *)tabBarItem
{
  return [[UITabBarItem alloc] initWithTitle:@"More" image:[UIImage imageNamed:@"MoreTab"] selectedImage:[UIImage imageNamed:@"MoreTabSelected"]];
}

@end
