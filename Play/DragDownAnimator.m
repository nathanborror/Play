//
//  DragDownAnimator.m
//  Play
//
//  Created by Nathan Borror on 2/26/14.
//  Copyright (c) 2014 Nathan Borror. All rights reserved.
//

#import "DragDownAnimator.h"

@implementation DragDownAnimator

- (NSTimeInterval)transitionDuration:(id<UIViewControllerContextTransitioning>)transitionContext
{
  return .4;
}

- (void)animateTransition:(id<UIViewControllerContextTransitioning>)transitionContext
{
  UIViewController *fromViewController = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
  UIViewController *toViewController = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];

  if (_presenting) {
    [transitionContext.containerView addSubview:toViewController.view];
    [transitionContext.containerView addSubview:fromViewController.view];
  } else {
    [toViewController.view setFrame:CGRectOffset(toViewController.view.bounds, 0, CGRectGetHeight(fromViewController.view.bounds)-64)];

    [transitionContext.containerView addSubview:fromViewController.view];
    [transitionContext.containerView addSubview:toViewController.view];
  }

  [UIView animateWithDuration:[self transitionDuration:transitionContext] delay:0 usingSpringWithDamping:.75 initialSpringVelocity:.2 options:UIViewAnimationOptionCurveLinear animations:^{
    if (_presenting) {
      [fromViewController.view setFrame:CGRectOffset(fromViewController.view.bounds, 0, CGRectGetHeight(fromViewController.view.bounds)-64)];
    } else {
      [toViewController.view setFrame:CGRectOffset(toViewController.view.bounds, 0, 0)];
    }
  } completion:^(BOOL finished) {
    if (_presenting) {
      [fromViewController.view removeFromSuperview];
    }
    [transitionContext completeTransition:YES];
  }];
}

@end
