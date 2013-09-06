//
//  PLVolumeCell.m
//  Play
//
//  Created by Nathan Borror on 9/4/13.
//  Copyright (c) 2013 Nathan Borror. All rights reserved.
//

#import "PLVolumeCell.h"
#import "PLDial.h"
#import "SOAPEnvelope.h"
#import "SonosController.h"
#import "SonosInput.h"
#import "SonosVolumeResponse.h"

static const CGFloat kVolumeBarMargin = 16;

@implementation PLVolumeCell {
  PLDial *volumeDial;
  UILabel *name;
  SonosController *sonos;
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
  if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
    sonos = [SonosController sharedController];

    volumeDial = [[PLDial alloc] initWithFrame:CGRectMake(kVolumeBarMargin, 22, CGRectGetWidth(self.bounds)-(kVolumeBarMargin*2), 44)];
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
  [sonos volume:_input level:(int)[slider value] completion:nil];
}

- (void)changeVolume2:(PLDial *)dial
{
  [sonos volume:_input level:(int)[dial value] completion:nil];
}

- (void)setInput:(SonosInput *)aInput
{
  _input = aInput;

  name = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.bounds), 18)];
  [name setUserInteractionEnabled:NO];
  [name setText:_input.name];
  [name setTextAlignment:NSTextAlignmentCenter];
  [name setFont:[UIFont systemFontOfSize:15]];
  [name setBackgroundColor:[UIColor clearColor]];
  [self addSubview:name];

  [sonos volume:_input completion:^(SOAPEnvelope *envelope, NSError *error) {
    SonosVolumeResponse *volume = (SonosVolumeResponse *)[envelope response];
    [volumeDial setValue:[volume.currentVolume floatValue]];
  }];
}

@end
