//
//  PLVolumeSlider.m
//  Play
//
//  Created by Nathan Borror on 2/19/13.
//  Copyright (c) 2013 Nathan Borror. All rights reserved.
//

#import "PLVolumeSlider.h"
#import "PLDial.h"
#import "SonosInput.h"
#import "SonosController.h"
#import "SOAPEnvelope.h"
#import "SonosVolumeResponse.h"

@interface PLVolumeSlider ()
{
  PLDial *volumeDial;
  UILabel *name;
  SonosController *sonos;
}
@end

@implementation PLVolumeSlider
@synthesize input, hideLabel;

- (id)initWithFrame:(CGRect)frame
{
  self = [super initWithFrame:frame];
  if (self) {
    sonos = [SonosController sharedController];

    self.hideLabel = NO;

    volumeDial = [[PLDial alloc] initWithFrame:CGRectMake(0, 18, CGRectGetWidth(self.bounds), 44)];
    [volumeDial setMaxValue:100.0];
    [volumeDial setMinValue:0.0];
    [volumeDial setValue:10.0];
    [volumeDial addTarget:self action:@selector(changeVolume2:) forControlEvents:UIControlEventValueChanged];
    [self addSubview:volumeDial];
  }
  return self;
}

- (void)changeVolume:(UISlider *)slider
{
  [sonos volume:input level:(int)[slider value] completion:nil];
}

- (void)changeVolume2:(PLDial *)dial
{
  [sonos volume:input level:(int)[dial value] completion:nil];
}

- (void)setInput:(SonosInput *)aInput
{
  input = aInput;

  if (!self.hideLabel) {
    name = [[UILabel alloc] init];
    [name setUserInteractionEnabled:NO];
    [name setText:self.input.name];
    [name setFont:[UIFont systemFontOfSize:15]];
    [name setBackgroundColor:[UIColor clearColor]];
    [name sizeToFit];
    [name setCenter:CGPointMake(CGRectGetWidth(self.bounds)/2, 0)];
    [self addSubview:name];
  }

  [sonos volume:input completion:^(SOAPEnvelope *envelope, NSError *error) {
    SonosVolumeResponse *volume = (SonosVolumeResponse *)[envelope response];
    [volumeDial setValue:[volume.currentVolume floatValue]];
  }];
}

@end
