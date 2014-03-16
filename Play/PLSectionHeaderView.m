//
//  PLSectionHeaderView.m
//  Play
//
//  Created by Nathan Borror on 10/19/13.
//  Copyright (c) 2013 Nathan Borror. All rights reserved.
//

#import "PLSectionHeaderView.h"
#import "PLNowPlayingViewController.h"

static const CGFloat kPadding = 16.0;

@implementation PLSectionHeaderView {
  UILabel *_label;
}

- (instancetype)initWithFrame:(CGRect)frame
{
  if (self = [super initWithFrame:frame]) {
    _label = [[UILabel alloc] initWithFrame:CGRectZero];
    [_label setTextColor:[UIColor whiteColor]];
    [self addSubview:_label];
  }
  return self;
}

- (void)layoutSubviews
{
  [_label setFrame:CGRectMake(kPadding, 0, CGRectGetWidth(self.frame)-(kPadding*2), CGRectGetHeight(self.frame))];
}

- (void)setTitle:(NSString *)title
{
  _title = title;
  [_label setText:_title];
}

@end
