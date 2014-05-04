//
//  PLVolumeCell.m
//  Play
//
//  Created by Nathan Borror on 9/4/13.
//  Copyright (c) 2013 Nathan Borror. All rights reserved.
//

#import "PLVolumeCell.h"
#import "PLDial.h"
#import "SonosController.h"
#import "UIColor+Common.h"
#import "UIFont+Common.h"

#import <SonosKit/SonosController.h>

@implementation PLVolumeCell {
  PLDial *_volumeDial;
  UILabel *_name;
  SonosController *_controller;
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
  if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
    [self setSelectionStyle:UITableViewCellSelectionStyleNone];

    _volumeDial = [[PLDial alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.bounds), 48)];
    [_volumeDial setMaxValue:100.0];
    [_volumeDial setMinValue:0.0];
    [_volumeDial setValue:0.0];
    [_volumeDial setTranslatesAutoresizingMaskIntoConstraints:NO];
    [_volumeDial setAutoresizingMask:UIViewAutoresizingFlexibleWidth];
    [_volumeDial addTarget:self action:@selector(changeVolume:) forControlEvents:UIControlEventValueChanged];
    [self addSubview:_volumeDial];

    _name = [[UILabel alloc] init];
    [_name setUserInteractionEnabled:NO];
    [_name setTextColor:[UIColor text]];
    [_name setFont:[UIFont subheader]];
    [_name setBackgroundColor:[UIColor clearColor]];
    [_name setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self addSubview:_name];

    NSDictionary *views = NSDictionaryOfVariableBindings(_name, _volumeDial);
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-[_name]-|" options:0 metrics:nil views:views]];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_volumeDial(>=320)]|" options:0 metrics:nil views:views]];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-[_name]-[_volumeDial(==48)]|" options:0 metrics:nil views:views]];
  }
  return self;
}

- (void)changeVolume:(PLDial *)dial
{
  [_controller setVolume:(int)[dial value] completion:nil];
  
}

- (void)setController:(SonosController *)controller
{
  _controller = controller;

  [_name setText:_controller.name];
  if (_controller.coordinator) {
    [_name setFont:[UIFont subheaderCoordinator]];
  }
  [_name sizeToFit];

#if TARGET_IPHONE_SIMULATOR
  int random = arc4random() % 50;
  [_volumeDial setValue:random];
#else
  [_controller getVolume:^(NSInteger volume, NSDictionary *response, NSError *error) {
    [_volumeDial setValue:volume];
  }];
#endif
}

- (void)prepareForReuse
{
  [_name setFont:[UIFont subheader]];
  [_volumeDial setValue:0.0];
}

@end
