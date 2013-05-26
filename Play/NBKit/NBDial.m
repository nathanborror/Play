//
//  NBDial.m
//  Play
//
//  Created by Nathan Borror on 4/19/13.
//  Copyright (c) 2013 Nathan Borror. All rights reserved.
//

#import "NBDial.h"
#import "NBDirectionGestureRecognizer.h"

@interface NBDial ()
{
  CGPoint panCoordBegan;
  UIImageView *max;
  UIView *min;

  CGFloat maxOriginX;
  CGFloat minOriginX;
}
@end

@implementation NBDial
@synthesize maxValue, minValue, value;

- (id)initWithFrame:(CGRect)frame
{
  self = [super initWithFrame:frame];
  if (self) {
    [self setClipsToBounds:YES];

    max = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.bounds), 25)];
    [max setImage:[[UIImage imageNamed:@"NBDial"] resizableImageWithCapInsets:UIEdgeInsetsMake(12, 150, 12, 150) resizingMode:UIImageResizingModeStretch]];
    [self addSubview:max];

    min = [[UIView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.bounds), 25)];
    [min setClipsToBounds:YES];
    [self addSubview:min];

    UIView *minNotch = [[UIView alloc] initWithFrame:CGRectMake(CGRectGetWidth(min.bounds)-2, 0, 2, CGRectGetHeight(self.bounds))];
    [minNotch setBackgroundColor:[UIColor colorWithRed:0 green:0 blue:0 alpha:.1]];
    [min addSubview:minNotch];

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
