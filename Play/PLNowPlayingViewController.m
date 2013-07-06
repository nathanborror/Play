//
//  ViewController.m
//  Play
//
//  Created by Nathan Borror on 12/30/12.
//  Copyright (c) 2012 Nathan Borror. All rights reserved.
//

#import "PLNowPlayingViewController.h"
#import "SonosController.h"
#import "PLSong.h"
#import "PLDial.h"
#import "SOAPEnvelope.h"
#import "SonosPositionInfoResponse.h"
#import "SonosInputStore.h"
#import "SonosInput.h"
#import "PLVolumeSlider.h"
#import "UIImage+BlurImage.h"
#import "NBKit/NBDirectionGestureRecognizer.h"

static const CGFloat kProgressPadding = 50.0;

static const CGFloat kControlBarPadding = 20.0;
static const CGFloat kControlBarPreviousNextPadding = 40.0;
static const CGFloat kControlBarButtonWidth = 75.0;
static const CGFloat kControlBarButtonHeight = kControlBarButtonWidth;
static const CGFloat kControlBarButtonPadding = 20.0;

static const CGFloat kControlBarLowered = 384.0;
static const CGFloat kControlBarLoweredCenter = 670.0;
static const CGFloat kControlBarRaised = 64.0;
static const CGFloat kControlBarRaisedCenter = 346.0;

static const CGFloat kNavigationBarHeight = 80.0;

@interface PLNowPlayingViewController ()
{
  SonosController *sonos;

  UIView *controlBar;
  UISlider *volumeSlider;
  UIButton *playPauseButton;
  UIButton *stopButton;
  UIButton *nextButton;
  UIButton *previousButton;
  UIButton *speakersButton;
  UIImageView *album;
  UITableView *songList;
  UIView *tableHeader;
  NSArray *songListData;
  CGPoint panCoordBegan;

  UIDynamicAnimator *animator;
  UIGravityBehavior *gravity;
  UICollisionBehavior *collision;
}
@end

@implementation PLNowPlayingViewController

- (id)init
{
  self = [super init];
  if (self) {
    [self.navigationItem setTitle:@"Now Playing"];
    [self.view setBackgroundColor:[UIColor whiteColor]];

    sonos = [SonosController sharedController];

    UIBarButtonItem *done = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(done)];
    [self.navigationItem setRightBarButtonItem:done];

    // Animations
    animator = [[UIDynamicAnimator alloc] initWithReferenceView:self.view];
  }
  return self;
}

- (id)initWithSong:(PLSong *)song
{
  self = [self init];
  if (self) {
    [self setCurrentSong:song];
  }
  return self;
}

- (id)initWithLineIn:(SonosInput *)input
{
  self = [self init];
  if (self) {
    [sonos lineIn:input completion:nil];
    [album setImage:[UIImage imageNamed:@"LineIn.png"]];
  }
  return self;
}

- (void)viewDidLoad
{
  [super viewDidLoad];

  // Header
  tableHeader = [[UIView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.bounds), 390)];
  [tableHeader setAutoresizingMask:UIViewAutoresizingFlexibleWidth];

  // Header: Album Art
  album = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 320, 320)];
  [album setAutoresizingMask:UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin];
  [album setImage:[UIImage imageNamed:@"TempAlbum.png"]];
  [tableHeader addSubview:album];

  // Song List
  songList = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.bounds), CGRectGetHeight(self.view.bounds))];
  [songList setAutoresizingMask:UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight];
  [songList setBackgroundColor:[UIColor clearColor]];
  [songList setTableHeaderView:tableHeader];
  [songList setContentInset:UIEdgeInsetsMake(0, 0, 700, 0)];
  [songList setDelegate:self];
  [songList setDataSource:self];
  [self.view addSubview:songList];

  // Control Bar
  controlBar = [[UIView alloc] initWithFrame:CGRectMake(0, kControlBarLowered, CGRectGetWidth(self.view.frame), CGRectGetHeight(self.view.frame))];
  [controlBar setBackgroundColor:[UIColor whiteColor]];
  [controlBar setAutoresizingMask:UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleTopMargin];
  [controlBar setUserInteractionEnabled:YES];

  UIImageView *grip = [[UIImageView alloc] initWithFrame:CGRectMake((CGRectGetWidth(self.view.frame)/2)-17, 6, 35, 3)];
  [grip setImage:[UIImage imageNamed:@"ControlBarGrip"]];
  [grip setAutoresizingMask:UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin];
  [controlBar addSubview:grip];

  playPauseButton = [[UIButton alloc] initWithFrame:CGRectMake((CGRectGetWidth(controlBar.bounds)/2)-kControlBarButtonWidth/2, kControlBarPadding, kControlBarButtonWidth, kControlBarButtonHeight)];
  [playPauseButton setBackgroundImage:[UIImage imageNamed:@"ControlPause.png"] forState:UIControlStateNormal];
  [playPauseButton addTarget:self action:@selector(playPause) forControlEvents:UIControlEventTouchUpInside];
  [playPauseButton setShowsTouchWhenHighlighted:YES];
  [controlBar addSubview:playPauseButton];

  nextButton = [[UIButton alloc] initWithFrame:CGRectMake(CGRectGetWidth(controlBar.bounds)-(kControlBarButtonWidth+kControlBarPreviousNextPadding), kControlBarPadding, kControlBarButtonWidth, kControlBarButtonHeight)];
  [nextButton setBackgroundImage:[UIImage imageNamed:@"ControlNext.png"] forState:UIControlStateNormal];
  [nextButton addTarget:self action:@selector(next) forControlEvents:UIControlEventTouchUpInside];
  [nextButton setShowsTouchWhenHighlighted:YES];
  [controlBar addSubview:nextButton];

  previousButton = [[UIButton alloc] initWithFrame:CGRectMake(kControlBarPreviousNextPadding, kControlBarPadding, kControlBarButtonWidth, kControlBarButtonHeight)];
  [previousButton setBackgroundImage:[UIImage imageNamed:@"ControlPrevious.png"] forState:UIControlStateNormal];
  [previousButton addTarget:self action:@selector(previous) forControlEvents:UIControlEventTouchUpInside];
  [previousButton setShowsTouchWhenHighlighted:YES];
  [controlBar addSubview:previousButton];

  // PLDial
  PLDial *dial = [[PLDial alloc] initWithFrame:CGRectMake(kControlBarButtonPadding, 110, CGRectGetWidth(controlBar.bounds)-(kControlBarButtonPadding*2), 44)];
  [dial setMaxValue:100];
  [dial setMinValue:0];
  [dial setValue:20];
  [controlBar addSubview:dial];

  NSArray *speakers = [[SonosInputStore sharedStore] allInputs];
  for (int i = 0; i < speakers.count; i++) {
    PLVolumeSlider *speakerVolume = [[PLVolumeSlider alloc] initWithFrame:CGRectMake(kControlBarButtonPadding, 205 + (i * 70), CGRectGetWidth(controlBar.bounds)-(kControlBarButtonPadding * 2), 44)];
    [speakerVolume setInput:[speakers objectAtIndex:i]];
    [controlBar addSubview:speakerVolume];
  }

  [self.view addSubview:controlBar];

  // Control Bar pan gesture
  NBDirectionGestureRecognizer *controlPan = [[NBDirectionGestureRecognizer alloc] initWithTarget:self action:@selector(panControlBar:)];
  [controlPan setDirection:NBDirectionPanGestureRecognizerVertical];
  [controlBar addGestureRecognizer:controlPan];
}

- (void)playPause
{
  if (sonos.isPlaying) {
    [sonos pause:nil completion:nil];
    [playPauseButton setBackgroundImage:[UIImage imageNamed:@"ControlPlay.png"] forState:UIControlStateNormal];
  } else {
    [sonos play:nil track:nil completion:nil];
    [playPauseButton setBackgroundImage:[UIImage imageNamed:@"ControlPause.png"] forState:UIControlStateNormal];
  }
}

- (void)next
{
  [sonos next:nil completion:nil];
}

- (void)previous
{
  [sonos previous:nil completion:nil];
}

- (void)volume:(UISlider *)sender
{
  [sonos volume:nil level:(int)[sender value] completion:nil];
}

- (void)done
{
  [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

- (void)setCurrentSong:(PLSong *)song
{
  [album setImage:song.albumArt];
  NSLog(@"URI: %@", song.uri);
  [sonos play:nil track:song.uri completion:nil];
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
  if (toInterfaceOrientation == UIInterfaceOrientationPortrait) {
    // Portrait
    [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationFade];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    [album setFrame:CGRectMake(30, 90, 260, 260)];
  } else {
    // Landscape
    [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationFade];
    [self.navigationController setNavigationBarHidden:YES animated:YES];
    [album setFrame:CGRectMake(15, 15, 209, 209)];
  }
}

- (void)showSpeakerVolumes
{
  UISnapBehavior *snap = [[UISnapBehavior alloc] initWithItem:controlBar snapToPoint:CGPointMake(controlBar.center.x, kControlBarRaisedCenter)];
  [snap setDamping:.4];
  [animator addBehavior:snap];

  UIDynamicItemBehavior *custom = [[UIDynamicItemBehavior alloc] initWithItems:@[controlBar]];
  [custom setAllowsRotation:NO];
  [animator addBehavior:custom];
}

- (void)hideSpeakerVolumes
{
  UISnapBehavior *snap = [[UISnapBehavior alloc] initWithItem:controlBar snapToPoint:CGPointMake(controlBar.center.x, kControlBarLoweredCenter)];
  [snap setDamping:.4];
  [animator addBehavior:snap];

  UIDynamicItemBehavior *custom = [[UIDynamicItemBehavior alloc] initWithItems:@[controlBar]];
  [custom setAllowsRotation:NO];
  [animator addBehavior:custom];
}

#pragma mark - NBDirectionGestureRecognizer

- (void)panControlBar:(NBDirectionGestureRecognizer *)recognizer
{
  [animator removeAllBehaviors];

  if (recognizer.state == UIGestureRecognizerStateBegan) {
    panCoordBegan = [recognizer locationInView:controlBar];
  }

  if (recognizer.state == UIGestureRecognizerStateChanged) {
    CGPoint panCoordChange = [recognizer locationInView:controlBar];

    CGFloat deltaY = panCoordChange.y - panCoordBegan.y;
    CGPoint newPoint = CGPointMake(controlBar.center.x, controlBar.center.y + deltaY);

    if (newPoint.y > 290.0) {
      controlBar.center = newPoint;
    }
  }

  if (recognizer.state == UIGestureRecognizerStateEnded) {
    CGPoint velocityPoint = [recognizer velocityInView:controlBar];

    if (velocityPoint.y >= 0) {
      [self hideSpeakerVolumes];
    } else {
      [self showSpeakerVolumes];
    }
  }
}

#pragma mark - UITableViewController

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
  return [songListData count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
  PLSong *song = [songListData objectAtIndex:indexPath.row];
  UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"TableViewCell"];
  if (!cell) {
    cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"TableViewCell"];
  }
  [cell.textLabel setFont:[UIFont systemFontOfSize:16]];
  [cell.textLabel setTextColor:[UIColor whiteColor]];
  [cell.textLabel setText:song.title];
  
  if (indexPath.row % 2) {
    [cell.contentView setBackgroundColor:[UIColor colorWithRed:.15 green:.15 blue:.15 alpha:1]];
  } else {
    [cell.contentView setBackgroundColor:[UIColor clearColor]];
  }
  return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
  PLSong *song = [songListData objectAtIndex:indexPath.row];
  [self setCurrentSong:song];
}

@end
