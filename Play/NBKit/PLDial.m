//
//  PLDial.m
//  Play
//
//  Created by Nathan Borror on 4/19/13.
//  Copyright (c) 2013 Nathan Borror. All rights reserved.
//

#import "PLDial.h"
#import "NBDirectionGestureRecognizer.h"

@interface PLDial ()
{
  CGPoint panCoordBegan;
  UIImageView *max;
  UIView *min;

  CGFloat maxOriginX;
  CGFloat minOriginX;
}
@end

@implementation PLDial
@synthesize maxValue, minValue, value;

- (id)initWithFrame:(CGRect)frame
{
  self = [super initWithFrame:frame];
  if (self) {

    max = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.bounds), 31)];
    [max setImage:[[UIImage imageNamed:@"PLDial"] resizableImageWithCapInsets:UIEdgeInsetsMake(16, 16, 16, 16) resizingMode:UIImageResizingModeStretch]];
    [self addSubview:max];

    min = [[UIView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.bounds), 32)];
    [self addSubview:min];

    UIImageView *thumb = [[UIImageView alloc] initWithFrame:CGRectMake(CGRectGetWidth(min.bounds)-21, -6, 43, 43)];
    [thumb setImage:[UIImage imageNamed:@"PLDialThumb"]];
    [min addSubview:thumb];

    NBDirectionGestureRecognizer *pan = [[NBDirectionGestureRecognizer alloc] initWithTarget:self action:@selector(panDial:)];
    [pan setDirection:NBDirectionPanGestureRecognizerHorizontal];
    [self addGestureRecognizer:pan];

    maxOriginX = min.center.x-12;
    minOriginX = -(maxOriginX);
  }
  return self;
}

- (void)setValue:(CGFloat)aValue
{
  self->value = aValue;

  CGPoint newPoint = CGPointMake([self findPosition:aValue], min.center.y);

  if (newPoint.x < maxOriginX && newPoint.x > minOriginX) {
    min.center = newPoint;
  } else {
    if (newPoint.x > maxOriginX) {
      min.center = CGPointMake(maxOriginX, min.center.y);
    }
    if (newPoint.x < minOriginX) {
      min.center = CGPointMake(minOriginX, min.center.y);
    }
  }
}

#pragma mark - NBDirectionGestureRecognizer

- (void)panDial:(NBDirectionGestureRecognizer *)recognizer
{
  if (recognizer.state == UIGestureRecognizerStateBegan) {
    panCoordBegan = [recognizer locationInView:min];
  }

  if (recognizer.state == UIGestureRecognizerStateChanged) {
    CGPoint panCoordChange = [recognizer locationInView:min];
    CGFloat deltaX = panCoordChange.x - panCoordBegan.x;
    CGFloat newX = min.center.x + deltaX;

    // Figure out value
    [self setValue:[self findValue:newX]];
    [super sendActionsForControlEvents:UIControlEventValueChanged];
  }
}

- (CGFloat)findValue:(CGFloat)x
{
  return ((((maxValue - minValue) * (x - minOriginX)) / (maxOriginX - minOriginX)) + minValue);
}

- (CGFloat)findPosition:(CGFloat)x
{
  return ((((maxOriginX - minOriginX) * (x - minValue)) / (maxValue - minValue)) + minOriginX);
}

@end
