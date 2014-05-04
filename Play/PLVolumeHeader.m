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

#import <SonosKit/SonosController.h>

static const CGFloat kMargin = 16.0;
static const CGFloat kAccessorySize = 44.0;

@implementation PLVolumeHeader {
  UILabel *_title;
  UIImageView *_accessoryView;
  UIView *_seperator;
}

- (instancetype)initWithFrame:(CGRect)frame
{
  if (self = [super initWithFrame:frame]) {
    [self setBackgroundColor:[UIColor whiteColor]];

    _title = [[UILabel alloc] initWithFrame:CGRectMake(kMargin, (CGRectGetHeight(self.bounds)/2)-(kAccessorySize/2), CGRectGetWidth(self.bounds)-(kAccessorySize+kMargin), kAccessorySize)];
    [_title setFont:[UIFont header]];
    [_title setTextColor:[UIColor text]];
    [_title setText:@"Loading"];
    [self addSubview:_title];

    _accessoryView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Chevron"]];
    [_accessoryView setFrame:CGRectMake(CGRectGetWidth(self.bounds)-kAccessorySize, (CGRectGetHeight(self.bounds)/2)-(kAccessorySize/2), kAccessorySize, kAccessorySize)];
    [self addSubview:_accessoryView];

    _seperator = [[UIView alloc] initWithFrame:CGRectMake(kMargin, CGRectGetHeight(self.bounds), CGRectGetWidth(self.bounds), .5)];
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
  }];
}

@end
