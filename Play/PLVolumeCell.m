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

static const CGFloat kVolumeBarMargin = 16;

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

    _volumeDial = [[PLDial alloc] initWithFrame:CGRectMake(kVolumeBarMargin, 22, CGRectGetWidth(self.bounds)-(kVolumeBarMargin*2), 44)];
    [_volumeDial setAutoresizingMask:UIViewAutoresizingFlexibleWidth];
    [_volumeDial setMaxValue:100.0];
    [_volumeDial setMinValue:0.0];
    [_volumeDial setValue:10.0];
    [_volumeDial addTarget:self action:@selector(changeVolume2:) forControlEvents:UIControlEventValueChanged];
    [self addSubview:_volumeDial];
  }
  return self;
}

- (void)changeVolume:(UISlider *)slider
{
  [_sonos volume:_input level:(int)[slider value] completion:nil];
}

- (void)changeVolume2:(PLDial *)dial
{
  [_sonos volume:_input level:(int)[dial value] completion:nil];
}

- (void)setInput:(PLInput *)aInput
{
  _input = aInput;

  _name = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.bounds), 18)];
  [_name setAutoresizingMask:UIViewAutoresizingFlexibleWidth];
  [_name setUserInteractionEnabled:NO];
  [_name setText:_input.name];
  [_name setTextAlignment:NSTextAlignmentCenter];
  [_name setFont:[UIFont systemFontOfSize:15]];
  [_name setBackgroundColor:[UIColor clearColor]];
  [self addSubview:_name];

  [_sonos volume:_input completion:^(NSDictionary *response, NSError *error) {
    NSString *value = response[@"u:GetVolumeResponse"][@"CurrentVolume"][@"text"];
    [_volumeDial setValue:[value floatValue]];
  }];
}

@end
