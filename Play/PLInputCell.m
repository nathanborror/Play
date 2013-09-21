//
//  PLInputCell.m
//  Play
//
//  Created by Nathan Borror on 4/14/13.
//  Copyright (c) 2013 Nathan Borror. All rights reserved.
//

#import "PLInputCell.h"
#import "SonosInput.h"
#import "SonosController.h"
#import "SonosTransportInfoResponse.h"
#import "SOAPEnvelope.h"

@implementation PLInputCell {
  UIDynamicAnimator *_animator;
}

- (id)initWithInput:(SonosInput *)aInput
{
  if (self = [super init]) {
    [self setFrame:CGRectMake(0, 0, 115, 85)];
    self.input = aInput;
    self.origin = self.center;

    _animator = [[UIDynamicAnimator alloc] initWithReferenceView:self];

    // Speaker label
    _label = [[UILabel alloc] initWithFrame:CGRectMake(0, 65, CGRectGetWidth(self.bounds), 20)];
    [_label setText:_input.name];
    [_label setTextAlignment:NSTextAlignmentCenter];
    [_label setFont:[UIFont systemFontOfSize:11.0]];
    [_label setBackgroundColor:[UIColor clearColor]];
    [self addSubview:_label];

    // Speaker icon
    _speakerIcon = [[UIImageView alloc] initWithImage:_input.icon];
    [self addSubview:_speakerIcon];

    // Speaker indicator light
//    _indicator = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"SpeakerOn"]];
//    [_indicator setFrame:CGRectOffset(_indicator.bounds, CGRectGetWidth(_label.bounds)-26, -5)];
//    [_label addSubview:_indicator];

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
    PLInputCellStatus newStatus;
    if ([response.state isEqual:@"PLAYING"]) {
      newStatus = PLInputCellStatusPlaying;
    } else if ([response.state isEqual:@"PAUSED_PLAYBACK"]) {
      newStatus = PLInputCellStatusPaused;
    } else {
      newStatus = PLInputCellStatusStopped;
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
  [_animator removeAllBehaviors];
  UISnapBehavior *snap = [[UISnapBehavior alloc] initWithItem:_label snapToPoint:CGPointMake(_label.center.x, 35)];
  [snap setDamping:.7];
  [_animator addBehavior:snap];
}

- (void)stopDragging
{
  [_animator removeAllBehaviors];
  UISnapBehavior *snap = [[UISnapBehavior alloc] initWithItem:_label snapToPoint:CGPointMake(_label.center.x, 75)];
  [snap setDamping:.7];
  [_animator addBehavior:snap];
}

- (void)refreshIndicator
{
  switch (self.status) {
    case PLInputCellStatusStopped:
    case PLInputCellStatusPaused: {
      [UIView animateWithDuration:.2 animations:^{
        [_indicator setAlpha:0];
      }];
    } break;
    case PLInputCellStatusPlaying: {
      [UIView animateWithDuration:.2 animations:^{
        [_indicator setAlpha:1];
      }];
    } break;
  }
}

@end
