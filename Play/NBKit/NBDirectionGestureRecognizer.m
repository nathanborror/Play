//
//  NBDirectionGestureRecognizer.m
//  NBKit
//
//  Created by Nathan Borror on 2/19/13.
//  Copyright (c) 2013 Nathan Borror. All rights reserved.
//

#import "NBDirectionGestureRecognizer.h"

const static int kDirectionPanThreshold = 5;

@interface NBDirectionGestureRecognizer ()
{
  BOOL drag;
  int moveX;
  int moveY;
}
@end

@implementation NBDirectionGestureRecognizer
@synthesize direction;

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
  [super touchesMoved:touches withEvent:event];

  if (self.state == UIGestureRecognizerStateFailed) {
    return;
  }

  CGPoint nowPoint = [[touches anyObject] locationInView:self.view];
  CGPoint previousPoint = [[touches anyObject] previousLocationInView:self.view];

  moveX += previousPoint.x - nowPoint.x;
  moveY += previousPoint.y - nowPoint.y;

  if (!drag) {
    if (abs(moveX) > kDirectionPanThreshold) {
      if (direction == NBDirectionPanGestureRecognizerVertical) {
        self.state = UIGestureRecognizerStateFailed;
      } else {
        drag = YES;
      }
    } else if (abs(moveY) > kDirectionPanThreshold) {
      if (direction == NBDirectionPanGestureRecognizerHorizontal) {
        self.state = UIGestureRecognizerStateFailed;
      } else {
        drag = YES;
      }
    }
  }
}

- (void)reset
{
  [super reset];
  drag = NO;
  moveX = 0;
  moveY = 0;
}

@end
