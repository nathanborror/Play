//
//  PLVolumeSlider.m
//  Play
//
//  Created by Nathan Borror on 2/19/13.
//  Copyright (c) 2013 Nathan Borror. All rights reserved.
//

#import "PLVolumeSlider.h"
#import "SonosInput.h"
#import "SonosController.h"
#import "SOAPEnvelope.h"
#import "SonosVolumeResponse.h"
#import "NBKit/NBDial.h"

@interface PLVolumeSlider ()
{
  NBDial *volumeDial;
  UILabel *name;
  SonosController *sonos;
}
@end

@implementation PLVolumeSlider
@synthesize input;

- (id)initWithFrame:(CGRect)frame
{
  self = [super initWithFrame:frame];
  if (self) {
    sonos = [SonosController sharedController];

    volumeDial = [[NBDial alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.bounds), 44)];
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

- (void)changeVolume2:(NBDial *)dial
{
  [sonos volume:input level:(int)[dial value] completion:nil];
}

- (void)setInput:(SonosInput *)aInput
{
  input = aInput;

  name = [[UILabel alloc] initWithFrame:CGRectMake(0, CGRectGetMinY(volumeDial.frame)-25, CGRectGetWidth(self.bounds), 20)];
  [name setUserInteractionEnabled:NO];
  [name setText:self.input.name];
  [name setFont:[UIFont boldSystemFontOfSize:14.0]];
  [name setTextColor:[UIColor colorWithWhite:.27 alpha:1]];
  [name setBackgroundColor:[UIColor clearColor]];
  [name setShadowColor:[UIColor whiteColor]];
  [name setShadowOffset:CGSizeMake(0, 1)];
  [self addSubview:name];

  [sonos volume:input completion:^(SOAPEnvelope *envelope, NSError *error) {
    SonosVolumeResponse *volume = (SonosVolumeResponse *)[envelope response];
    [volumeDial setValue:[volume.currentVolume floatValue]];
  }];
}

@end
