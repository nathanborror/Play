//
//  PLDialog.m
//  Play
//
//  Created by Nathan Borror on 5/25/13.
//  Copyright (c) 2013 Nathan Borror. All rights reserved.
//

#import "PLDialog.h"
#import "NBAnimationHelper.h"
#import "NBDirectionGestureRecognizer.h"
#import <math.h>

static const CGFloat kDialogWidth = 240.0;
static const CGFloat kDialogHeight = 280.0;
static const CGFloat kDialogTop = 100.0;
static inline double radians(double degrees) {return degrees * M_PI / 180;}

@interface PLDialog ()
{
  CGPoint panCoordBegan;
  CGPoint startCenter;
  CGPoint restCenter;
  CGPoint endCenter;
}
@end

@implementation PLDialog
@synthesize front, back;

- (id)initWithFrame:(CGRect)frame
{
  self = [super initWithFrame:frame];
  if (self) {
    [self setBackgroundColor:[UIColor clearColor]];

    self.front = [[UIView alloc] initWithFrame:CGRectMake((CGRectGetWidth(self.bounds)-kDialogWidth)/2, kDialogTop, kDialogWidth, kDialogHeight)];
    [self.front setBackgroundColor:[UIColor colorWithWhite:0 alpha:1]];
    [self.front.layer setCornerRadius:4];
    [self.front.layer setShadowColor:[UIColor blackColor].CGColor];
    [self.front.layer setShadowOpacity:.6];
    [self.front.layer setShadowRadius:10];
    [self.front.layer setShadowOffset:CGSizeMake(0, 4)];

    [self addSubview:self.front];

    self.back = [[UIView alloc] initWithFrame:CGRectMake((CGRectGetWidth(self.bounds)-kDialogWidth)/2, kDialogTop, kDialogWidth, kDialogHeight)];
    [self.back setBackgroundColor:[UIColor colorWithWhite:.8 alpha:1]];
    [self.back.layer setCornerRadius:4];
    [self.back.layer setShadowColor:[UIColor blackColor].CGColor];
    [self.back.layer setShadowOpacity:.6];
    [self.back.layer setShadowRadius:10];
    [self.back.layer setShadowOffset:CGSizeMake(0, 4)];

    // Assign center points
    startCenter = CGPointMake(self.center.x, -self.center.y);
    restCenter = CGPointMake(self.center.x, self.center.y);
    endCenter = CGPointMake(self.center.x, self.center.y+500);

    [self show];

    NBDirectionGestureRecognizer *flick = [[NBDirectionGestureRecognizer alloc] initWithTarget:self action:@selector(swipe:)];
    [flick setDirection:NBDirectionPanGestureRecognizerVertical];
    [self addGestureRecognizer:flick];
  }
  return self;
}

- (void)layoutSubviews
{
  // Info button
  UIButton *info = [[UIButton alloc] initWithFrame:CGRectMake(CGRectGetWidth(self.front.bounds)-39, -5, 44, 44)];
  [info setImage:[UIImage imageNamed:@"Info"] forState:UIControlStateNormal];
  [info addTarget:self action:@selector(info) forControlEvents:UIControlEventTouchUpInside];
  [info setShowsTouchWhenHighlighted:YES];
  [self.front addSubview:info];

  // Close button
  UIButton *close = [[UIButton alloc] initWithFrame:CGRectMake(CGRectGetWidth(self.front.bounds)-39, -5, 44, 44)];
  [close setImage:[UIImage imageNamed:@"Close"] forState:UIControlStateNormal];
  [close addTarget:self action:@selector(close) forControlEvents:UIControlEventTouchUpInside];
  [close setShowsTouchWhenHighlighted:YES];
  [self.back addSubview:close];
}

- (void)show
{
  // Bounce and rotate in
  [NBAnimationHelper animatePosition:self from:startCenter to:restCenter forKey:@"position" delegate:nil];
  [NBAnimationHelper animateTransform:self
                                     from:CATransform3DRotate(self.layer.transform, radians(20), 0, 0, 1)
                                       to:self.layer.transform
                                   forKey:@"rotate" delegate:nil];
}

- (void)hide
{
  [NBAnimationHelper animatePosition:self from:self.center to:endCenter forKey:@"position" delegate:self];
}

- (void)info
{
  [UIView transitionFromView:self.front toView:self.back duration:.35 options:UIViewAnimationOptionTransitionFlipFromLeft completion:nil];
}

- (void)close
{
  [UIView transitionFromView:self.back toView:self.front duration:.35 options:UIViewAnimationOptionTransitionFlipFromRight completion:nil];
}

#pragma mark - NBDirectionGestureRecognizer

- (void)swipe:(NBDirectionGestureRecognizer *)recognizer
{
  [self.layer removeAllAnimations];

  if (recognizer.state == UIGestureRecognizerStateBegan) {
    panCoordBegan = [recognizer locationInView:self];
  }

  if (recognizer.state == UIGestureRecognizerStateChanged) {
    CGPoint panCoordChange = [recognizer locationInView:self];

    CGFloat deltaY = panCoordChange.y - panCoordBegan.y;
    CGPoint newPoint = CGPointMake(self.center.x, self.center.y + deltaY);

    self.center = newPoint;
  }

  if (recognizer.state == UIGestureRecognizerStateEnded) {
    if (self.center.y > restCenter.y) {
      [self hide];
    } else {
      [NBAnimationHelper animatePosition:self from:self.center to:restCenter forKey:@"position" delegate:nil];
    }
  }
}

#pragma mark - CAAnimation

- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag
{
  [self removeFromSuperview];
}

@end
