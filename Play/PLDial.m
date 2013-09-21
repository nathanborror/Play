//
//  PLDial.m
//  Play
//
//  Created by Nathan Borror on 4/19/13.
//  Copyright (c) 2013 Nathan Borror. All rights reserved.
//

#import "PLDial.h"
#import "NBDirectionGestureRecognizer.h"

static const CGFloat kDialHeight = 32;

@implementation PLDial {
  CGPoint _panCoordBegan;
  UIView *_max;
  UIView *_min;
  UIImageView *_thumb;

  CGFloat maxOriginX;
  CGFloat minOriginX;
}

- (id)initWithFrame:(CGRect)frame
{
  if (self = [super initWithFrame:frame]) {
    _max = [[UIView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.bounds), kDialHeight)];
    [_max setBackgroundColor:[UIColor colorWithRed:.85 green:.86 blue:.88 alpha:1]];
    [_max.layer setCornerRadius:CGRectGetHeight(_max.bounds)/2];
    [self addSubview:_max];

    _min = [[UIView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.bounds), kDialHeight)];
    [_min setBackgroundColor:[UIColor blackColor]];
    [_min.layer setCornerRadius:CGRectGetHeight(_min.bounds)/2];
    [self addSubview:_min];

    _thumb = [[UIImageView alloc] initWithFrame:CGRectMake(0, -6, 43, 43)];
    [_thumb setImage:[UIImage imageNamed:@"PLDialThumb"]];
    [self addSubview:_thumb];

    NBDirectionGestureRecognizer *pan = [[NBDirectionGestureRecognizer alloc] initWithTarget:self action:@selector(panDial:)];
    [pan setDirection:NBDirectionPanGestureRecognizerHorizontal];
    [self addGestureRecognizer:pan];

    maxOriginX = CGRectGetWidth(self.bounds)-15;
    minOriginX = 15;
  }
  return self;
}

- (void)setValue:(CGFloat)aValue
{
  _value = aValue;

  CGPoint newPoint = CGPointMake([self findPosition:aValue], _thumb.center.y);

  if (newPoint.x < maxOriginX && newPoint.x > minOriginX) {
    _thumb.center = newPoint;
  } else {
    if (newPoint.x > maxOriginX) {
      _thumb.center = CGPointMake(maxOriginX, _thumb.center.y);
    }
    if (newPoint.x < minOriginX) {
      _thumb.center = CGPointMake(minOriginX, _thumb.center.y);
    }
  }
  [_min setFrame:CGRectMake(0, 0, CGRectGetMaxX(_thumb.frame)-10, kDialHeight)];
}

#pragma mark - NBDirectionGestureRecognizer

- (void)panDial:(NBDirectionGestureRecognizer *)recognizer
{
  if (recognizer.state == UIGestureRecognizerStateBegan) {
    _panCoordBegan = [recognizer locationInView:_thumb];
  }

  if (recognizer.state == UIGestureRecognizerStateChanged) {
    CGPoint panCoordChange = [recognizer locationInView:_thumb];
    CGFloat deltaX = panCoordChange.x - _panCoordBegan.x;
    CGFloat newX = _thumb.center.x + deltaX;

    // Figure out value
    [self setValue:[self findValue:newX]];
    [super sendActionsForControlEvents:UIControlEventValueChanged];
  }
}

- (CGFloat)findValue:(CGFloat)x
{
  return ((((_maxValue - _minValue) * (x - minOriginX)) / (maxOriginX - minOriginX)) + _minValue);
}

- (CGFloat)findPosition:(CGFloat)x
{
  return ((((maxOriginX - minOriginX) * (x - _minValue)) / (_maxValue - _minValue)) + minOriginX);
}

@end
