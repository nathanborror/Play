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
#import "SonosResponse.h"
#import "SonosVolumeResponse.h"

@interface PLVolumeSlider ()
{
  UISlider *volumeSlider;
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

    volumeSlider = [[UISlider alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.bounds), 20)];
    [volumeSlider setMaximumValue:100];
    [volumeSlider setMinimumValue:0];
    [volumeSlider setValue:10];
    [volumeSlider addTarget:self action:@selector(changeVolume:) forControlEvents:UIControlEventValueChanged];
    [self addSubview:volumeSlider];
  }
  return self;
}

- (void)changeVolume:(UISlider *)slider
{
  [sonos volume:input level:(int)[slider value] completion:nil];
}

- (void)setInput:(SonosInput *)aInput
{
  input = aInput;

  name = [[UILabel alloc] initWithFrame:CGRectMake(0, CGRectGetMinY(volumeSlider.frame)-25, CGRectGetWidth(self.bounds), 20)];
  [name setUserInteractionEnabled:NO];
  [name setText:self.input.name];
  [name setFont:[UIFont boldSystemFontOfSize:14.0]];
  [name setTextColor:[UIColor colorWithWhite:.27 alpha:1]];
  [name setBackgroundColor:[UIColor clearColor]];
  [name setShadowColor:[UIColor whiteColor]];
  [name setShadowOffset:CGSizeMake(0, 1)];
  [self addSubview:name];

  [sonos volume:input completion:^(SonosResponse *response, NSError *error) {
    SonosVolumeResponse *volume = (SonosVolumeResponse *)[response response];
    [volumeSlider setValue:[volume.currentVolume floatValue]];
  }];
}

@end
