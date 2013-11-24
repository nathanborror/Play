//
//  PLGroupHeaderView.m
//  Play
//
//  Created by Nathan Borror on 10/19/13.
//  Copyright (c) 2013 Nathan Borror. All rights reserved.
//

#import "PLGroupHeaderView.h"

@implementation PLGroupHeaderView {
  UIView *_divider;
}

- (id)initWithFrame:(CGRect)frame
{
  if (self = [super initWithFrame:frame]) {
    _title = [[UILabel alloc] initWithFrame:CGRectZero];
    [_title setTextAlignment:NSTextAlignmentCenter];
    [_title setFont:[UIFont systemFontOfSize:12]];
    [_title setTextColor:[UIColor whiteColor]];
    [_title setBackgroundColor:[UIColor clearColor]];
    [self addSubview:_title];

    _divider = [[UIView alloc] initWithFrame:CGRectZero];
    [_divider setBackgroundColor:[UIColor whiteColor]];
    [self addSubview:_divider];
  }
  return self;
}

- (void)layoutSubviews
{
  [_title setFrame:CGRectMake(0, 4, CGRectGetWidth(self.frame), CGRectGetHeight(self.frame))];
  [_divider setFrame:CGRectMake(16, CGRectGetHeight(self.frame)-.5, CGRectGetWidth(self.frame)-16, .5)];
}

@end
