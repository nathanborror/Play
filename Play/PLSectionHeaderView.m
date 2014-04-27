//
//  PLSectionHeaderView.m
//  Play
//
//  Created by Nathan Borror on 10/19/13.
//  Copyright (c) 2013 Nathan Borror. All rights reserved.
//

#import "PLSectionHeaderView.h"
#import "PLNowPlayingViewController.h"
#import "SonosController.h"

static const CGFloat kPadding = 16.0;

@implementation PLSectionHeaderView {
  UILabel *_label;
  UIImageView *_chevron;
  UIView *_divider;
}

- (instancetype)initWithFrame:(CGRect)frame
{
  if (self = [super initWithFrame:frame]) {
    _label = [[UILabel alloc] initWithFrame:CGRectZero];
    [_label setTextColor:[UIColor whiteColor]];
    [self addSubview:_label];

    _chevron = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Chevron"]];
    [self addSubview:_chevron];

    _divider = [[UIView alloc] init];
    [_divider setBackgroundColor:[UIColor whiteColor]];
    [self addSubview:_divider];
  }
  return self;
}

- (void)layoutSubviews
{
  [_label setFrame:CGRectMake(kPadding, 0, CGRectGetWidth(self.frame)-(kPadding*2), CGRectGetHeight(self.frame))];
  [_chevron setFrame:CGRectMake(CGRectGetWidth(self.bounds)-44, 0, 44, 44)];
  [_divider setFrame:CGRectMake(16, CGRectGetHeight(self.bounds)-1, CGRectGetWidth(self.bounds)-16, .5)];
}

- (void)setController:(SonosController *)controller
{
  _controller = controller;

  [_controller getPositionInfo:^(NSDictionary *track, NSDictionary *response, NSError *error) {
    [_label setText:track[@"title"][@"text"]];
  }];
}

@end
