//
//  PLTextField.m
//  Play
//
//  Created by Nathan Borror on 1/1/13.
//  Copyright (c) 2013 Nathan Borror. All rights reserved.
//

#import "PLTextField.h"
#import <QuartzCore/QuartzCore.h>

@implementation PLTextField

- (id)initWithFrame:(CGRect)frame
{
  self = [super initWithFrame:frame];
  if (self) {
    [self setBackgroundColor:[UIColor whiteColor]];
    [self setFont:[UIFont boldSystemFontOfSize:22]];
    [self setContentVerticalAlignment:UIControlContentVerticalAlignmentCenter];
    [self setClipsToBounds:YES];
    [self.layer setCornerRadius:4];
  }
  return self;
}

- (CGRect)textRectForBounds:(CGRect)bounds
{
  return CGRectInset(bounds, 10, 10);
}

- (CGRect)editingRectForBounds:(CGRect)bounds
{
  return CGRectInset(bounds, 10, 10);
}

@end
