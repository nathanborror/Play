//
//  PresentSpeakersAnimator.m
//  Play
//
//  Created by Nathan Borror on 9/3/13.
//  Copyright (c) 2013 Nathan Borror. All rights reserved.
//

#import "PresentSpeakersAnimator.h"

@implementation PresentSpeakersAnimator

- (NSTimeInterval)transitionDuration:(id<UIViewControllerContextTransitioning>)transitionContext
{
  return 0.00;
}

- (void)animateTransition:(id<UIViewControllerContextTransitioning>)transitionContext
{
  UIViewController *fromViewController = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
  UIViewController *toViewController = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];

  if (_presenting) {
    [transitionContext.containerView addSubview:toViewController.view];
    [transitionContext.containerView addSubview:fromViewController.view];

    [UIView animateWithDuration:.4 delay:0 options:UIViewAnimationCurveEaseInOut animations:^{
      [fromViewController.view setFrame:CGRectOffset(fromViewController.view.bounds, 0, CGRectGetHeight(fromViewController.view.bounds))];
    } completion:^(BOOL finished) {
      [transitionContext completeTransition:YES];
    }];
  } else {
    [toViewController.view setHidden:YES];
    [transitionContext.containerView addSubview:fromViewController.view];
    [transitionContext.containerView addSubview:toViewController.view];

    [toViewController.view setFrame:CGRectOffset(fromViewController.view.bounds, 0, CGRectGetHeight(fromViewController.view.bounds))];
    [toViewController.view setHidden:NO];

    [UIView animateWithDuration:.4 delay:0 options:UIViewAnimationCurveEaseInOut animations:^{
      [toViewController.view setFrame:CGRectOffset(fromViewController.view.bounds, 0, 0)];
    } completion:^(BOOL finished) {
      [transitionContext completeTransition:YES];
    }];
  }
}

@end
