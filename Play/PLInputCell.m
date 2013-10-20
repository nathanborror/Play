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

- (id)initWithFrame:(CGRect)frame
{
  if (self = [super initWithFrame:frame]) {
    _origin = self.center;
    _animator = [[UIDynamicAnimator alloc] initWithReferenceView:self];

    [self setBackgroundColor:[UIColor whiteColor]];

    // Speaker icon
    _speakerIcon = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 115, 65)];
    [self addSubview:_speakerIcon];

    // Speaker label
    _label = [[UILabel alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(_speakerIcon.frame), CGRectGetWidth(self.bounds), 20)];
    [_label setTextAlignment:NSTextAlignmentCenter];
    [_label setFont:[UIFont systemFontOfSize:11.0]];
    [_label setBackgroundColor:[UIColor clearColor]];
    [self addSubview:_label];
  }
  return self;
}

- (void)layoutSubviews
{
  [_speakerIcon setCenter:CGPointMake(CGRectGetWidth(self.bounds)/2, (CGRectGetHeight(self.bounds)/2)-10)];
  [_label setFrame:CGRectOffset(_label.bounds, 0, CGRectGetMaxY(_speakerIcon.frame))];
}

- (void)setInput:(SonosInput *)input
{
  _input = input;
  [_speakerIcon setImage:_input.icon];
  [_label setText:_input.name];
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
