//
//  PLInputCell.m
//  Play
//
//  Created by Nathan Borror on 4/14/13.
//  Copyright (c) 2013 Nathan Borror. All rights reserved.
//

#import "PLInputCell.h"
#import "SonosController.h"

@implementation PLInputCell {
  UILabel *_label;
  UIImageView *_indicator;
  UIImageView *_speakerIcon;
}

- (instancetype)initWithFrame:(CGRect)frame
{
  if (self = [super initWithFrame:frame]) {
    _origin = self.center;

    _speakerIcon = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 115, 65)];
    [self addSubview:_speakerIcon];

    _label = [[UILabel alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(_speakerIcon.frame), CGRectGetWidth(self.bounds), 20)];
    [_label setTextAlignment:NSTextAlignmentCenter];
    [_label setFont:[UIFont systemFontOfSize:11.0]];
    [_label setTextColor:[UIColor whiteColor]];
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

- (void)setController:(SonosController *)controller
{
  _controller = controller;

  [_label setText:_controller.name];

  NSString *uuid = _controller.uuid;

  // Determine type of speaker
  NSRegularExpression *regexPlay3 = [NSRegularExpression regularExpressionWithPattern:@"RINCON_000E587" options:0 error:nil];
  NSTextCheckingResult *matchPlay3 = [regexPlay3 firstMatchInString:uuid options:0 range:NSMakeRange(0, uuid.length)];

  NSRegularExpression *regexPlay5 = [NSRegularExpression regularExpressionWithPattern:@"RINCON_000E588" options:0 error:nil];
  NSTextCheckingResult *matchPlay5 = [regexPlay5 firstMatchInString:uuid options:0 range:NSMakeRange(0, uuid.length)];

  NSRegularExpression *regexAmp = [NSRegularExpression regularExpressionWithPattern:@"RINCON_000E58D" options:0 error:nil];
  NSTextCheckingResult *matchAmp = [regexAmp firstMatchInString:uuid options:0 range:NSMakeRange(0, uuid.length)];

  if (matchPlay3) {
    [_speakerIcon setImage:[UIImage imageNamed:@"SonosPlay3"]];
  } else if (matchPlay5) {
    [_speakerIcon setImage:[UIImage imageNamed:@"SonosPlay5"]];
  } else if (matchAmp) {
    [_speakerIcon setImage:[UIImage imageNamed:@"SonosAmp"]];
  }
}

@end
