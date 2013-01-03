//
//  PLPrimaryBarButtonItem.m
//  Play
//
//  Created by Nathan Borror on 12/31/12.
//  Copyright (c) 2012 Nathan Borror. All rights reserved.
//

#import "PLPrimaryBarButtonItem.h"

@implementation PLPrimaryBarButtonItem

- (id)init
{
  self = [super init];
  if (self) {
    UIImage *buttonImage = [[UIImage imageNamed:@"CustomPrimaryBarButtonItem.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(6, 6, 6, 6)];
    [self setBackgroundImage:buttonImage forState:UIControlStateNormal barMetrics:UIBarMetricsDefault];
  }
  return self;
}

@end
