//
//  NBDirectionGestureRecognizer.m
//  NBKit
//
//  Created by Nathan Borror on 2/19/13.
//  Copyright (c) 2013 Nathan Borror. All rights reserved.
//

#import "NBDirectionGestureRecognizer.h"

static const CGFloat kDirectionPanThreshold = 5;

@implementation NBDirectionGestureRecognizer {
  BOOL _drag;
  int _moveX;
  int _moveY;
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
  [super touchesMoved:touches withEvent:event];

  if (self.state == UIGestureRecognizerStateFailed) {
    return;
  }

  CGPoint nowPoint = [[touches anyObject] locationInView:self.view];
  CGPoint previousPoint = [[touches anyObject] previousLocationInView:self.view];

  _moveX += previousPoint.x - nowPoint.x;
  _moveY += previousPoint.y - nowPoint.y;

  if (!_drag) {
    if (abs(_moveX) > kDirectionPanThreshold) {
      if (_direction == NBDirectionPanGestureRecognizerVertical) {
        self.state = UIGestureRecognizerStateFailed;
      } else {
        _drag = YES;
      }
    } else if (abs(_moveY) > kDirectionPanThreshold) {
      if (_direction == NBDirectionPanGestureRecognizerHorizontal) {
        self.state = UIGestureRecognizerStateFailed;
      } else {
        _drag = YES;
      }
    }
  }
}

- (void)reset
{
  [super reset];
  _drag = NO;
  _moveX = 0;
  _moveY = 0;
}

@end
