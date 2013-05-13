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

#import "NBKit/NBAnimation.h"

static const CGFloat kSpeakerStatusMargin = -24.0;

@interface SonosInputCell ()
{
  UILabel *label;
  UIImageView *indicator;

  NBAnimation *labelAnimation;
  NBAnimation *indicatorAnimation;
}
@end

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
    label = [[UILabel alloc] initWithFrame:CGRectMake(0, 65, CGRectGetWidth(self.bounds), 20)];
    [label setText:input.name];
    [label setTextAlignment:NSTextAlignmentCenter];
    [label setFont:[UIFont boldSystemFontOfSize:11.0]];
    [label setTextColor:[UIColor whiteColor]];
    [label setBackgroundColor:[UIColor clearColor]];
    [self addSubview:label];

    // Label transition animation
    labelAnimation = [NBAnimation animationWithKeyPath:@"position.y"];
    [labelAnimation setDuration:0.9f];
    [labelAnimation setNumberOfBounces:2];
    [labelAnimation setShouldOvershoot:YES];

    // Speaker icon
    UIImageView *icon = [[UIImageView alloc] initWithImage:input.icon];
    [self addSubview:icon];

    // Speaker indicator light
    indicator = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"SpeakerOn"]];
    [indicator setFrame:CGRectOffset(indicator.bounds, CGRectGetWidth(icon.bounds)+kSpeakerStatusMargin, CGRectGetHeight(icon.bounds)+kSpeakerStatusMargin)];
    [self addSubview:indicator];

    // Speaker Indicator animation
    indicatorAnimation = [NBAnimation animationWithKeyPath:@"bounds"];
    [indicatorAnimation setDuration:0.9f];
    [indicatorAnimation setNumberOfBounces:2];
    [indicatorAnimation setShouldOvershoot:YES];

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
    if ([response.state isEqual:@"PLAYING"]) {
      self.status = SonosInputCellStatusPlaying;
    } else if ([response.state isEqual:@"PAUSED_PLAYBACK"]) {
      self.status = SonosInputCellStatusPaused;
    } else if ([response.state isEqual:@"STOPPED"]) {
      self.status = SonosInputCellStatusStopped;
    }
    [self refreshIndicator];
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
  id fromValue = [NSNumber numberWithFloat:65];
  id toValue = [NSNumber numberWithFloat:25];

  [labelAnimation setFromValue:fromValue];
  [labelAnimation setToValue:toValue];

  [label.layer addAnimation:labelAnimation forKey:@"labelAnimation"];
  [label.layer setValue:toValue forKeyPath:@"position.y"];
}

- (void)stopDragging
{
  id fromValue = [NSNumber numberWithFloat:25];
  id toValue = [NSNumber numberWithFloat:75];

  [labelAnimation setFromValue:fromValue];
  [labelAnimation setToValue:toValue];

  [label.layer addAnimation:labelAnimation forKey:@"labelAnimation"];
  [label.layer setValue:toValue forKeyPath:@"position.y"];
}

- (void)refreshIndicator
{
  switch (self.status) {
    case SonosInputCellStatusStopped:
    case SonosInputCellStatusPaused: {
      [UIView animateWithDuration:.2 animations:^{
        [indicator setAlpha:0];
      }];
    } break;
    case SonosInputCellStatusPlaying: {
      [indicator setAlpha:1];

      id fromValue = [NSValue valueWithCGRect:CGRectMake(0, 0, 0, 0)];
      id toValue = [NSValue valueWithCGRect:indicator.bounds];

      [indicatorAnimation setFromValue:fromValue];
      [indicatorAnimation setToValue:toValue];

      [indicator.layer addAnimation:indicatorAnimation forKey:@"statusAnimation"];
      [indicator.layer setValue:toValue forKeyPath:@"bounds"];
    } break;
  }
}

@end
