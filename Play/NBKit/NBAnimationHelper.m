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

+ (NBAnimation *)animate:(UIView *)view
                    from:(id)from
                      to:(id)to
                duration:(CGFloat)duration
               stiffness:(NBAnimationStiffness)stiffness
              forKeyPath:(NSString *)keyPath
                  forKey:(NSString *)key
                delegate:(id)delegate
{
  NBAnimation *animation = [NBAnimation animationWithKeyPath:keyPath];
  [animation setDuration:duration];
  [animation setNumberOfBounces:2];
  [animation setShouldOvershoot:YES];

  if (stiffness) {
    [animation setStiffness:stiffness];
  }

  if (delegate) {
    [animation setDelegate:delegate];
  }

  [animation setFromValue:from];
  [animation setToValue:to];

  [view.layer addAnimation:animation forKey:key];
  [view.layer setValue:to forKeyPath:keyPath];

  return animation;
}

+ (NBAnimation *)animatePosition:(UIView *)view from:(CGPoint)from to:(CGPoint)to forKey:(NSString *)key delegate:(id)delegate
{
  return [NBAnimationHelper animate:view
                               from:[NSValue valueWithCGPoint:from]
                                 to:[NSValue valueWithCGPoint:to]
                           duration:0.9
                          stiffness:nil
                         forKeyPath:@"position"
                             forKey:key
                           delegate:delegate];
}

+ (NBAnimation *)animateTransform:(UIView *)view from:(CATransform3D)from to:(CATransform3D)to forKey:(NSString *)key delegate:(id)delegate
{
  return [NBAnimationHelper animate:view
                               from:[NSValue valueWithCATransform3D:from]
                                 to:[NSValue valueWithCATransform3D:to]
                           duration:0.9
                          stiffness:NBAnimationStiffnessHeavy
                         forKeyPath:@"transform"
                             forKey:key
                           delegate:delegate];
}

+ (NBAnimation *)animateBounds:(UIView *)view from:(CGRect)from to:(CGRect)to forKey:(NSString *)key delegate:(id)delegate
{
  return [NBAnimationHelper animate:view
                               from:[NSValue valueWithCGRect:from]
                                 to:[NSValue valueWithCGRect:to]
                           duration:0.9
                          stiffness:nil
                         forKeyPath:@"bounds"
                             forKey:key
                           delegate:delegate];
}

@end
