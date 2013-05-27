//
//  PLControlMenu.m
//  Play
//
//  Created by Nathan Borror on 5/19/13.
//  Copyright (c) 2013 Nathan Borror. All rights reserved.
//

#import "PLControlMenu.h"
#import "NBKit/NBDirectionGestureRecognizer.h"
#import "NBKit/NBAnimationHelper.h"
#import "PLVolumeSlider.h"
#import "SonosInputStore.h"
#import "SonosController.h"

static const CGFloat kButtonWidth = 75.0;
static const CGFloat kButtonHeight = kButtonWidth;
static const CGFloat kButtonTopMargin = 20.0;
static const CGFloat kPreviousNextPadding = 40.0;

@interface PLControlMenu ()
{
  UIImageView *controlBar;
  UIButton *playPauseButton;
  UIButton *stopButton;
  UIButton *nextButton;
  UIButton *previousButton;

  CGPoint showCenter;
  CGPoint hideCenter;
  CGPoint panCoordBegan;
}
@end

@implementation PLControlMenu

- (id)initWithFrame:(CGRect)frame
{
  self = [super initWithFrame:frame];
  if (self) {
    [self setBackgroundColor:[UIColor clearColor]];

    controlBar = [[UIImageView alloc] initWithFrame:self.bounds];
    [controlBar setImage:[[UIImage imageNamed:@"ControlBar.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(6, 6, 6, 6) resizingMode:UIImageResizingModeStretch]];
    [controlBar setAutoresizingMask:UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight];
    [controlBar setUserInteractionEnabled:YES];
    [controlBar.layer setShadowOffset:CGSizeMake(0, -2)];
    [controlBar.layer setShadowColor:[UIColor colorWithWhite:.2 alpha:1].CGColor];
    [controlBar.layer setShadowRadius:1.0];
    [controlBar.layer setShadowOpacity:.3];

    showCenter = CGPointMake(self.center.x, self.center.y + 44);
    hideCenter = CGPointMake(self.center.x, self.center.y + 515);

    UIImageView *grip = [[UIImageView alloc] initWithFrame:CGRectMake((CGRectGetWidth(self.frame)/2)-17, 8, 35, 3)];
    [grip setImage:[UIImage imageNamed:@"ControlBarGrip"]];
    [grip setAutoresizingMask:UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin];
    [controlBar addSubview:grip];

    playPauseButton = [[UIButton alloc] initWithFrame:CGRectMake((CGRectGetWidth(self.bounds)/2)-kButtonWidth/2, kButtonTopMargin, kButtonWidth, kButtonHeight)];
    [playPauseButton setBackgroundImage:[UIImage imageNamed:@"ControlPause.png"] forState:UIControlStateNormal];
    [playPauseButton addTarget:self action:@selector(playPause) forControlEvents:UIControlEventTouchUpInside];
    [playPauseButton setShowsTouchWhenHighlighted:YES];
    [controlBar addSubview:playPauseButton];

    nextButton = [[UIButton alloc] initWithFrame:CGRectMake(CGRectGetWidth(self.bounds)-(kButtonWidth+kPreviousNextPadding), kButtonTopMargin, kButtonWidth, kButtonHeight)];
    [nextButton setBackgroundImage:[UIImage imageNamed:@"ControlNext.png"] forState:UIControlStateNormal];
    [nextButton addTarget:self action:@selector(next) forControlEvents:UIControlEventTouchUpInside];
    [nextButton setShowsTouchWhenHighlighted:YES];
    [controlBar addSubview:nextButton];

    previousButton = [[UIButton alloc] initWithFrame:CGRectMake(kPreviousNextPadding, kButtonTopMargin, kButtonWidth, kButtonHeight)];
    [previousButton setBackgroundImage:[UIImage imageNamed:@"ControlPrevious.png"] forState:UIControlStateNormal];
    [previousButton addTarget:self action:@selector(previous) forControlEvents:UIControlEventTouchUpInside];
    [previousButton setShowsTouchWhenHighlighted:YES];
    [controlBar addSubview:previousButton];

    // NBDial
    NSArray *speakers = [[SonosInputStore sharedStore] allInputs];
    for (int i = 0; i < speakers.count; i++) {
      PLVolumeSlider *speakerVolume = [[PLVolumeSlider alloc] initWithFrame:CGRectMake(kButtonTopMargin, 140 + (i * 70), CGRectGetWidth(self.bounds)-(kButtonTopMargin * 2), 44)];
      [speakerVolume setInput:[speakers objectAtIndex:i]];
      [controlBar addSubview:speakerVolume];
    }

    [self addSubview:controlBar];

    // Control Bar pan gesture
    NBDirectionGestureRecognizer *controlPan = [[NBDirectionGestureRecognizer alloc] initWithTarget:self action:@selector(panControlBar:)];
    [controlPan setDirection:NBDirectionPanGestureRecognizerVertical];
    [self addGestureRecognizer:controlPan];

    // Hide initially
    [self.layer setPosition:hideCenter];
  }
  return self;
}

- (void)playPause
{
  if ([[SonosController sharedController] isPlaying]) {
    [[SonosController sharedController] pause:nil completion:nil];
    [playPauseButton setBackgroundImage:[UIImage imageNamed:@"ControlPlay.png"] forState:UIControlStateNormal];
  } else {
    [[SonosController sharedController] play:nil track:nil completion:nil];
    [playPauseButton setBackgroundImage:[UIImage imageNamed:@"ControlPause.png"] forState:UIControlStateNormal];
  }
}

- (void)previous
{
  [[SonosController sharedController] previous:nil completion:nil];
}

- (void)next
{
  [[SonosController sharedController] next:nil completion:nil];
}

#pragma mark - NBDirectionGestureRecognizer

- (void)panControlBar:(NBDirectionGestureRecognizer *)recognizer
{
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
    CGPoint velocityPoint = [recognizer velocityInView:self];

    if (velocityPoint.y >= 0) {
      [NBAnimationHelper animatePosition:self from:self.center to:hideCenter forKey:@"bounce" delegate:nil];
    } else {
      [NBAnimationHelper animatePosition:self from:self.center to:showCenter forKey:@"bounce" delegate:nil];
    }
  }
}

@end
