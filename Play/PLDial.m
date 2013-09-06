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

@interface PLDial ()
{
  CGPoint panCoordBegan;
  UIView *max;
  UIView *min;
  UIImageView *thumb;

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

    max = [[UIView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.bounds), kDialHeight)];
    [max setBackgroundColor:[UIColor colorWithRed:.85 green:.86 blue:.88 alpha:1]];
    [max.layer setCornerRadius:CGRectGetHeight(max.bounds)/2];
    [self addSubview:max];

    min = [[UIView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.bounds), kDialHeight)];
    [min setBackgroundColor:[UIColor blackColor]];
    [min.layer setCornerRadius:CGRectGetHeight(min.bounds)/2];
    [self addSubview:min];

    thumb = [[UIImageView alloc] initWithFrame:CGRectMake(0, -6, 43, 43)];
    [thumb setImage:[UIImage imageNamed:@"PLDialThumb"]];
    [self addSubview:thumb];

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
  self->value = aValue;

  CGPoint newPoint = CGPointMake([self findPosition:aValue], thumb.center.y);

  if (newPoint.x < maxOriginX && newPoint.x > minOriginX) {
    thumb.center = newPoint;
  } else {
    if (newPoint.x > maxOriginX) {
      thumb.center = CGPointMake(maxOriginX, thumb.center.y);
    }
    if (newPoint.x < minOriginX) {
      thumb.center = CGPointMake(minOriginX, thumb.center.y);
    }
  }
  [min setFrame:CGRectMake(0, 0, CGRectGetMaxX(thumb.frame)-10, kDialHeight)];
}

#pragma mark - NBDirectionGestureRecognizer

- (void)panDial:(NBDirectionGestureRecognizer *)recognizer
{
  if (recognizer.state == UIGestureRecognizerStateBegan) {
    panCoordBegan = [recognizer locationInView:thumb];
  }

  if (recognizer.state == UIGestureRecognizerStateChanged) {
    CGPoint panCoordChange = [recognizer locationInView:thumb];
    CGFloat deltaX = panCoordChange.x - panCoordBegan.x;
    CGFloat newX = thumb.center.x + deltaX;

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
