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
#import "PLInput.h"
#import "UIColor+Common.h"
#import "UIFont+Common.h"

static const CGFloat kNameVerticalMargin = 12.0;
static const CGFloat kNameHorizontalMargin = 16.0;

@implementation PLVolumeCell {
  PLDial *_volumeDial;
  UILabel *_name;
  SonosController *_sonos;
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
  if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
    _sonos = [SonosController sharedController];

    [self setSelectionStyle:UITableViewCellSelectionStyleNone];

    _volumeDial = [[PLDial alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.bounds), 48)];
    [_volumeDial setMaxValue:100.0];
    [_volumeDial setMinValue:0.0];
    [_volumeDial setValue:10.0];
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
  [_sonos volume:_input level:(int)[dial value] completion:nil];
}

- (void)setInput:(PLInput *)aInput
{
  _input = aInput;

  [_name setText:_input.name];
  [_name sizeToFit];

  [_sonos volume:_input completion:^(NSDictionary *response, NSError *error) {
    NSString *value = response[@"u:GetVolumeResponse"][@"CurrentVolume"][@"text"];
    [_volumeDial setValue:[value floatValue]];
  }];
}

@end
