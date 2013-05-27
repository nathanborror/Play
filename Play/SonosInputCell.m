//
//  SonosInputCell.m
//  Play
//
//  Created by Nathan Borror on 4/14/13.
//  Copyright (c) 2013 Nathan Borror. All rights reserved.
//

#import "SonosInputCell.h"
#import "SonosInput.h"
#import "SonosController.h"
#import "SonosTransportInfoResponse.h"
#import "SOAPEnvelope.h"
#import "NBKit/NBAnimationHelper.h"

static const CGFloat kSpeakerStatusMargin = -24.0;

@implementation SonosInputCell
@synthesize input, origin, status;

- (id)initWithInput:(SonosInput *)aInput
{
  self = [super init];
  if (self) {
    [self setFrame:CGRectMake(0, 0, 115, 85)];
    self.input = aInput;
    self.origin = self.center;

    [self setShowsTouchWhenHighlighted:YES];

    // Speaker label
    _label = [[UILabel alloc] initWithFrame:CGRectMake(0, 65, CGRectGetWidth(self.bounds), 20)];
    [_label setText:input.name];
    [_label setTextAlignment:NSTextAlignmentCenter];
    [_label setFont:[UIFont boldSystemFontOfSize:11.0]];
    [_label setTextColor:[UIColor whiteColor]];
    [_label setBackgroundColor:[UIColor clearColor]];
    [self addSubview:_label];

    // Speaker icon
    _speakerIcon = [[UIImageView alloc] initWithImage:input.icon];
    [self addSubview:_speakerIcon];

    // Speaker indicator light
    _indicator = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"SpeakerOn"]];
    [_indicator setFrame:CGRectOffset(_indicator.bounds, CGRectGetWidth(_speakerIcon.bounds)+kSpeakerStatusMargin, CGRectGetHeight(_speakerIcon.bounds)+kSpeakerStatusMargin)];
    [self addSubview:_indicator];

    // Check status every five seconds so we keep the indicator up-to-date
    [NSTimer scheduledTimerWithTimeInterval:5.0 target:self selector:@selector(updateStatus) userInfo:nil repeats:YES];

    // Update status to current state
    [self updateStatus];
  }
  return self;
}

- (void)updateStatus
{
  [[SonosController sharedController] status:self.input completion:^(SOAPEnvelope *envelope, NSError *error) {
    SonosTransportInfoResponse *response = (SonosTransportInfoResponse *)[envelope response];
    SonosInputCellStatus newStatus;
    if ([response.state isEqual:@"PLAYING"]) {
      newStatus = SonosInputCellStatusPlaying;
    } else if ([response.state isEqual:@"PAUSED_PLAYBACK"]) {
      newStatus = SonosInputCellStatusPaused;
    } else {
      newStatus = SonosInputCellStatusStopped;
    }
    if (newStatus != self.status) {
      self.status = newStatus;
      [self refreshIndicator];
    }
  }];
}

- (void)pair:(SonosInput *)master
{
  NSString *uri = [NSString stringWithFormat:@"x-rincon:%@", master.uid];
  [[SonosController sharedController] play:self.input track:uri completion:nil];
  [self updateStatus];
}

- (void)unpair
{
  NSString *uri = [NSString stringWithFormat:@"x-rincon-queue:%@#0", self.input.uid];
  [[SonosController sharedController] play:self.input track:uri completion:nil];
  [self updateStatus];
}

- (void)startDragging
{
  [NBAnimationHelper animatePosition:_label
                                from:CGPointMake(_label.center.x, 65)
                                  to:CGPointMake(_label.center.x, 25)
                              forKey:@"labelAnimation"
                            delegate:nil];
}

- (void)stopDragging
{
  [NBAnimationHelper animatePosition:_label
                                from:CGPointMake(_label.center.x, 25)
                                  to:CGPointMake(_label.center.x, 75)
                              forKey:@"labelAnimation"
                            delegate:nil];
}

- (void)refreshIndicator
{
  switch (self.status) {
    case SonosInputCellStatusStopped:
    case SonosInputCellStatusPaused: {
      [UIView animateWithDuration:.2 animations:^{
        [_indicator setAlpha:0];
      }];
    } break;
    case SonosInputCellStatusPlaying: {
      [_indicator setAlpha:1];

      [NBAnimationHelper animateBounds:_indicator
                                    from:CGRectMake(0, 0, 0, 0)
                                      to:_indicator.bounds
                                  forKey:@"statusAnimation"
                                delegate:nil];
    } break;
  }
}

@end
