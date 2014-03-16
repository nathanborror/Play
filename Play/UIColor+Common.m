//
//  UIColor+Common.m
//  Play
//
//  Created by Nathan Borror on 2/16/14.
//  Copyright (c) 2014 Nathan Borror. All rights reserved.
//

#import "UIColor+Common.h"

@implementation UIColor (Common)

+ (UIColor *)tintColor
{
  return [UIColor colorWithRed:.18 green:.49 blue:.86 alpha:1];
}

+ (UIColor *)background
{
  return [UIColor whiteColor];
}

+ (UIColor *)text
{
  return [UIColor blackColor];
}

+ (UIColor *)borderColor
{
  return [UIColor colorWithWhite:0 alpha:.1];
}

@end
