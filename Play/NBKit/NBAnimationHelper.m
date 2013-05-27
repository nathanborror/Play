//
//  NBAnimationHelper.m
//  Play
//
//  Created by Nathan Borror on 5/26/13.
//  Copyright (c) 2013 Nathan Borror. All rights reserved.
//

#import "NBAnimationHelper.h"
#import "NBAnimation.h"

@implementation NBAnimationHelper

+ (NBAnimation *)animatePosition:(UIView *)view
                   from:(CGPoint)from
                     to:(CGPoint)to
                 forKey:(NSString *)key
               delegate:(id)delegate
{
  NBAnimation *animation = [NBAnimation animationWithKeyPath:@"position"];
  [animation setDuration:0.9f];
  [animation setNumberOfBounces:2];
  [animation setShouldOvershoot:YES];

  if (delegate) {
    [animation setDelegate:delegate];
  }

  id fromValue = [NSValue valueWithCGPoint:from];
  id toValue = [NSValue valueWithCGPoint:to];

  [animation setFromValue:fromValue];
  [animation setToValue:toValue];

  [view.layer addAnimation:animation forKey:key];
  [view.layer setValue:toValue forKeyPath:@"position"];

  return animation;
}

+ (NBAnimation *)animateTransform:(UIView *)view
                    from:(CATransform3D)from
                      to:(CATransform3D)to
                  forKey:(NSString *)key
                delegate:(id)delegate
{
  NBAnimation *animation = [NBAnimation animationWithKeyPath:@"transform"];
  [animation setDuration:0.9f];
  [animation setNumberOfBounces:2];
  [animation setShouldOvershoot:YES];
  [animation setStiffness:NBAnimationStiffnessHeavy];

  if (delegate) {
    [animation setDelegate:delegate];
  }

  id fromValue = [NSValue valueWithCATransform3D:from];
  id toValue = [NSValue valueWithCATransform3D:to];

  [animation setFromValue:fromValue];
  [animation setToValue:toValue];

  [view.layer addAnimation:animation forKey:key];
  [view.layer setValue:toValue forKeyPath:@"transform"];

  return animation;
}

+ (NBAnimation *)animateBounds:(UIView *)view
                             from:(CGRect)from
                               to:(CGRect)to
                           forKey:(NSString *)key
                         delegate:(id)delegate
{
  NBAnimation *animation = [NBAnimation animationWithKeyPath:@"bounds"];
  [animation setDuration:0.9f];
  [animation setNumberOfBounces:2];
  [animation setShouldOvershoot:YES];

  if (delegate) {
    [animation setDelegate:delegate];
  }

  id fromValue = [NSValue valueWithCGRect:from];
  id toValue = [NSValue valueWithCGRect:to];

  [animation setFromValue:fromValue];
  [animation setToValue:toValue];

  [view.layer addAnimation:animation forKey:key];
  [view.layer setValue:toValue forKeyPath:@"bounds"];
  
  return animation;
}

@end
