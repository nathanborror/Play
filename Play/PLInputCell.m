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

@implementation PLInputCell {
  UILabel *_label;
  UIImageView *_indicator;
  UIImageView *_speakerIcon;
}

- (id)initWithFrame:(CGRect)frame
{
  if (self = [super initWithFrame:frame]) {
    _origin = self.center;

    _speakerIcon = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 115, 65)];
    [self addSubview:_speakerIcon];

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
  [_input addObserver:self forKeyPath:@"uri" options:0 context:nil];

  [_speakerIcon setImage:_input.icon];
  [_label setText:_input.name];

  [self refreshStatus];
}

- (void)pair:(SonosInput *)master
{
  NSString *uri = [NSString stringWithFormat:@"x-rincon:%@", master.uid];
  [[SonosController sharedController] play:self.input uri:uri completion:nil];
}

- (void)unpair
{
  NSString *uri = [NSString stringWithFormat:@"x-rincon-queue:%@#0", self.input.uid];
  [[SonosController sharedController] play:self.input uri:uri completion:nil];
}

- (void)refreshStatus
{
  if (_input.status != PLInputStatusSlave) {
    [_label setFont:[UIFont boldSystemFontOfSize:11]];
  } else {
    [_label setFont:[UIFont systemFontOfSize:11]];
  }
}

#pragma mark - KVO

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
  if (object == _input && [keyPath isEqualToString:@"uri"]) {
    [self refreshStatus];
  }
}

@end
