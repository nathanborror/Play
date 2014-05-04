//
//  UIFont+Common.m
//  Play
//
//  Created by Nathan Borror on 2/26/14.
//  Copyright (c) 2014 Nathan Borror. All rights reserved.
//

#import "UIFont+Common.h"

@implementation UIFont (Common)

+ (UIFont *)header
{
  return [UIFont fontWithName:@"HelveticaNeue" size:18.0];
}

+ (UIFont *)subheader
{
  return [UIFont fontWithName:@"HelveticaNeue-Thin" size:14.0];
}

+ (UIFont *)subheaderCoordinator
{
  return [UIFont fontWithName:@"HelveticaNeue" size:14.0];
}

@end
