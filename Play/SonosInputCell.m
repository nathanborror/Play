//
//  SonosInputCell.m
//  Play
//
//  Created by Nathan Borror on 4/14/13.
//  Copyright (c) 2013 Nathan Borror. All rights reserved.
//

#import "SonosInputCell.h"
#import "SonosInput.h"
#import "NBAnimation.h"

@interface SonosInputCell ()
{
  UILabel *title;
  NBAnimation *hideTitleAnimation;
  CGPoint originalPosition;
}
@end

@implementation SonosInputCell
@synthesize input;

- (id)initWithInput:(SonosInput *)aInput
{
  self = [super init];
  if (self) {
    [self setFrame:CGRectMake(0, 0, 115, 85)];
    self.input = aInput;

    title = [[UILabel alloc] initWithFrame:CGRectMake(0, 65, CGRectGetWidth(self.bounds), 20)];
    [title setText:input.name];
    [title setTextAlignment:NSTextAlignmentCenter];
    [title setFont:[UIFont boldSystemFontOfSize:11.0]];
    [title setTextColor:[UIColor whiteColor]];
    [title setBackgroundColor:[UIColor clearColor]];
    [self addSubview:title];

    UIImageView *icon = [[UIImageView alloc] initWithImage:input.icon];
    [self addSubview:icon];

    [self setShowsTouchWhenHighlighted:YES];

    hideTitleAnimation = [NBAnimation animationWithKeyPath:@"position.y"];
    [hideTitleAnimation setDuration:0.7f];
    [hideTitleAnimation setNumberOfBounces:2];
    [hideTitleAnimation setShouldOvershoot:YES];
  }
  return self;
}

- (void)startDragging
{
  id fromValue = [NSNumber numberWithFloat:65];
  id toValue = [NSNumber numberWithFloat:25];

  [hideTitleAnimation setFromValue:fromValue];
  [hideTitleAnimation setToValue:toValue];

  [title.layer addAnimation:hideTitleAnimation forKey:@"hideTitleAnimation"];
  [title.layer setValue:toValue forKeyPath:@"position.y"];
}

- (void)stopDragging
{
  id fromValue = [NSNumber numberWithFloat:25];
  id toValue = [NSNumber numberWithFloat:75];

  [hideTitleAnimation setFromValue:fromValue];
  [hideTitleAnimation setToValue:toValue];

  [title.layer addAnimation:hideTitleAnimation forKey:@"hideTitleAnimation"];
  [title.layer setValue:toValue forKeyPath:@"position.y"];
}

@end
