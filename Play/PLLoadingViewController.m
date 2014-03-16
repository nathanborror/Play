//
//  PLLoadingViewController.m
//  Play
//
//  Created by Nathan Borror on 11/30/13.
//  Copyright (c) 2013 Nathan Borror. All rights reserved.
//

#import "PLLoadingViewController.h"
#import "UIColor+Common.h"

@implementation PLLoadingViewController {
  UIImageView *_spinner;
}

- (void)viewDidLoad
{
  [super viewDidLoad];

  [self.view setBackgroundColor:[UIColor blackColor]];

  _spinner = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Loading"]];
  [_spinner setFrame:CGRectMake((CGRectGetWidth(self.view.bounds)/2)-12, (CGRectGetHeight(self.view.bounds)/2)-12, 24, 24)];
  [self.view addSubview:_spinner];
}

- (void)viewDidAppear:(BOOL)animated
{
  [super viewDidAppear:animated];
  [self spin];
}

- (void)spin
{
  [UIView animateWithDuration:.25 delay:0 options:UIViewAnimationOptionCurveLinear animations:^{
    [_spinner setTransform:CGAffineTransformRotate(_spinner.transform, M_PI_2)];
  } completion:^(BOOL finished) {
    if ([self isViewLoaded] && self.view.window) {
      [self spin];
    }
  }];
}

@end
