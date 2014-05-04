//
//  PLVolumeHeader.m
//  Play
//
//  Created by Nathan Borror on 5/3/14.
//  Copyright (c) 2014 Nathan Borror. All rights reserved.
//

#import "PLVolumeHeader.h"
#import "UIColor+Common.h"
#import "UIFont+Common.h"

#import <Shimmer/FBShimmeringView.h>
#import <SonosKit/SonosController.h>

static const CGFloat kMarginLeft = 16.0;

@implementation PLVolumeHeader {
  UILabel *_title;
  UIImageView *_accessoryView;
  UIView *_seperator;
  FBShimmeringView *_titleShimmer;
}

- (instancetype)initWithFrame:(CGRect)frame
{
  if (self = [super initWithFrame:frame]) {
    [self setBackgroundColor:[UIColor whiteColor]];

    _titleShimmer = [[FBShimmeringView alloc] initWithFrame:CGRectMake(kMarginLeft, 12, CGRectGetWidth(self.bounds)-32, 44)];
    [self addSubview:_titleShimmer];

    _title = [[UILabel alloc] initWithFrame:_titleShimmer.bounds];
    [_title setFont:[UIFont header]];
    [_title setTextColor:[UIColor text]];
    [_title setText:@"Loading"];
    [_titleShimmer setContentView:_title];
    [_titleShimmer setShimmering:YES];

    _accessoryView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Chevron"]];
    [_accessoryView setFrame:CGRectMake(CGRectGetWidth(self.bounds)-44, (CGRectGetHeight(self.bounds)/2)-22, 44, 44)];
    [self addSubview:_accessoryView];

    _seperator = [[UIView alloc] initWithFrame:CGRectMake(kMarginLeft, CGRectGetHeight(self.bounds), CGRectGetWidth(self.bounds), .5)];
    [_seperator setBackgroundColor:[UIColor borderColor]];
    [self addSubview:_seperator];
  }
  return self;
}

- (void)setController:(SonosController *)controller
{
  _controller = controller;

  [_controller getPositionInfo:^(NSDictionary *track, NSDictionary *response, NSError *error) {
    NSString *title = track[@"creator"][@"text"];
    if (!title) title = track[@"title"][@"text"];
    [_title setText:title ? title : @"Line In"];
    [_titleShimmer setShimmering:NO];
  }];
}

@end
