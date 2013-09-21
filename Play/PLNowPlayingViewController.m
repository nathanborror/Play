//
//  ViewController.m
//  Play
//
//  Created by Nathan Borror on 12/30/12.
//  Copyright (c) 2012 Nathan Borror. All rights reserved.
//

#import "PLNowPlayingViewController.h"
#import "PLSong.h"
#import "PLDial.h"
#import "PLProgressBar.h"
#import "PLVolumeCell.h"
#import "PLSpeakersViewController.h"
#import "PLNextUpViewController.h"
#import "SOAPEnvelope.h"
#import "SonosController.h"
#import "SonosPositionInfoResponse.h"
#import "SonosInputStore.h"
#import "SonosInput.h"
#import "UIImage+BlurImage.h"
#import "NBKit/NBDirectionGestureRecognizer.h"
#import "PresentSpeakersAnimator.h"
#import "RdioSong.h"

static const CGFloat kProgressPadding = 50.0;

static const CGFloat kControlBarHeight = 250.0;
static const CGFloat kControlBarPadding = 16.0;
static const CGFloat kControlBarPreviousNextPadding = 46.0;
static const CGFloat kControlBarButtonWidth = 65.0;
static const CGFloat kControlBarButtonHeight = kControlBarButtonWidth;
static const CGFloat kControlBarButtonPadding = 20.0;
static const CGFloat kControlBarButtonTopMargin = 132.0;

static const CGFloat kNavigationBarHeight = 80.0;

static const CGFloat kVelocity = 0.1;
static const CGFloat kDamping = 0.6;

static const CGFloat kSongTitleFontSize = 17.0;
static const CGFloat kAlbumTitleFontSize = 15.0;

@interface PLNowPlayingViewController ()
{
  SonosController *_sonos;

  UITableView *_volumeTable;
  UIView *_controlBar;
  UISlider *_volumeSlider;

  UIButton *_playPauseButton;
  UIButton *_stopButton;
  UIButton *_nextButton;
  UIButton *_previousButton;
  UIButton *_speakersButton;

  CGPoint _panCoordBegan;

  NSArray *_songListData;
  NSArray *_speakers;

  UIView *_miniBar;
}
@end

@implementation PLNowPlayingViewController

- (id)init
{
  self = [super init];
  if (self) {
    _sonos = [SonosController sharedController];

    // TODO: This needs to be replace with a discover method
    SonosInputStore *inputStore = [SonosInputStore sharedStore];
    SonosInput *livingRoom = [inputStore addInputWithIP:@"10.0.1.9" name:@"Living Room" uid:@"RINCON_000E58D0540801400" icon:[UIImage imageNamed:@"SonosAmp"]];
    [inputStore addInputWithIP:@"10.0.1.10" name:@"Bedroom" uid:@"RINCON_000E587641F201400" icon:[UIImage imageNamed:@"SonosSpeakerPlay3Light"]];
    [inputStore addInputWithIP:@"10.0.1.11" name:@"Kitchen" uid:@"RINCON_000E587BBA5201400" icon:[UIImage imageNamed:@"SonosSpeakerPlay3Dark"]];

    [inputStore setMaster:livingRoom];
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

- (id)initWithRdioSong:(RdioSong *)song
{
  if (self = [self init]) {
    [_sonos play:nil rdioSong:song completion:nil];
  }
  return self;
}

- (id)initWithLineIn:(SonosInput *)input
{
  if (self = [self init]) {
    [_sonos lineIn:input completion:nil];
  }
  return self;
}

- (void)viewDidLoad
{
  [super viewDidLoad];

  UIBarButtonItem *speakerButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"PLSpeakers"] style:UIBarButtonItemStylePlain target:self action:@selector(showSpeakers)];
  [self.navigationItem setLeftBarButtonItem:speakerButton];

  UIBarButtonItem *queueButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"PLQueue"] style:UIBarButtonItemStylePlain target:self action:@selector(showQueue)];
  [self.navigationItem setRightBarButtonItem:queueButton];

  _volumeTable = [[UITableView alloc] initWithFrame:CGRectZero];
  [_volumeTable registerClass:[PLVolumeCell class] forCellReuseIdentifier:@"PLVolumeCell"];
  [_volumeTable setDelegate:self];
  [_volumeTable setDataSource:self];
  [_volumeTable setAutoresizingMask:UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight];
  [_volumeTable setRowHeight:80];
  [_volumeTable setSeparatorStyle:UITableViewCellSeparatorStyleNone];
  [self.view addSubview:_volumeTable];

  // Control Bar
  _controlBar = [[UIView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.bounds), kControlBarHeight)];
  [_controlBar setBackgroundColor:[UIColor whiteColor]];
  [_controlBar setAutoresizingMask:UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleTopMargin];
  [_controlBar setUserInteractionEnabled:YES];

  _playPauseButton = [[UIButton alloc] initWithFrame:CGRectMake((CGRectGetWidth(_controlBar.bounds)/2)-kControlBarButtonWidth/2, kControlBarButtonTopMargin, kControlBarButtonWidth, kControlBarButtonHeight)];
  [_playPauseButton setBackgroundImage:[UIImage imageNamed:@"ControlPause.png"] forState:UIControlStateNormal];
  [_playPauseButton addTarget:self action:@selector(playPause) forControlEvents:UIControlEventTouchUpInside];
  [_playPauseButton setShowsTouchWhenHighlighted:YES];
  [_controlBar addSubview:_playPauseButton];

  _nextButton = [[UIButton alloc] initWithFrame:CGRectMake(CGRectGetWidth(_controlBar.bounds)-(kControlBarButtonWidth+kControlBarPreviousNextPadding), kControlBarButtonTopMargin, kControlBarButtonWidth, kControlBarButtonHeight)];
  [_nextButton setBackgroundImage:[UIImage imageNamed:@"ControlNext.png"] forState:UIControlStateNormal];
  [_nextButton addTarget:self action:@selector(next) forControlEvents:UIControlEventTouchUpInside];
  [_nextButton setShowsTouchWhenHighlighted:YES];
  [_controlBar addSubview:_nextButton];

  _previousButton = [[UIButton alloc] initWithFrame:CGRectMake(kControlBarPreviousNextPadding, kControlBarButtonTopMargin, kControlBarButtonWidth, kControlBarButtonHeight)];
  [_previousButton setBackgroundImage:[UIImage imageNamed:@"ControlPrevious.png"] forState:UIControlStateNormal];
  [_previousButton addTarget:self action:@selector(previous) forControlEvents:UIControlEventTouchUpInside];
  [_previousButton setShowsTouchWhenHighlighted:YES];
  [_controlBar addSubview:_previousButton];

  // Song Info
  UILabel *songTitle = [[UILabel alloc] init];
  [songTitle setText:@"Come Together"];
  [songTitle setFont:[UIFont boldSystemFontOfSize:kSongTitleFontSize]];
  [songTitle setBackgroundColor:[UIColor clearColor]];
  [songTitle sizeToFit];
  [songTitle setCenter:CGPointMake(CGRectGetWidth(_controlBar.bounds)/2, 42)];
  [_controlBar addSubview:songTitle];

  UILabel *artistTitle = [[UILabel alloc] init];
  [artistTitle setText:@"The Beatles — Abby Road"];
  [artistTitle setFont:[UIFont systemFontOfSize:kAlbumTitleFontSize]];
  [artistTitle setBackgroundColor:[UIColor clearColor]];
  [artistTitle sizeToFit];
  [artistTitle setCenter:CGPointMake(CGRectGetWidth(_controlBar.bounds)/2, songTitle.center.y+24)];
  [_controlBar addSubview:artistTitle];

  PLProgressBar *progress = [[PLProgressBar alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.bounds)-90, 20)];
  [progress setMinimumValue:0];
  [progress setMaximumValue:5.0];
  [progress setValue:1];
  [self.navigationItem setTitleView:progress];

  _speakers = [[SonosInputStore sharedStore] allInputs];

  [_volumeTable setTableHeaderView:_controlBar];
}

- (void)viewDidLayoutSubviews
{
  [super viewDidLayoutSubviews];

  [_volumeTable setFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.bounds), CGRectGetHeight(self.view.bounds))];
  [_volumeTable.tableHeaderView setFrame:CGRectMake(0, 0, CGRectGetWidth(_volumeTable.bounds), kControlBarHeight)];
}

- (void)playPause
{
  if (_sonos.isPlaying) {
    [_sonos pause:nil completion:nil];
    [_playPauseButton setBackgroundImage:[UIImage imageNamed:@"ControlPlay.png"] forState:UIControlStateNormal];
  } else {
    [_sonos play:nil track:nil completion:nil];
    [_playPauseButton setBackgroundImage:[UIImage imageNamed:@"ControlPause.png"] forState:UIControlStateNormal];
  }
}

- (void)next
{
  [_sonos next:nil completion:nil];
}

- (void)previous
{
  [_sonos previous:nil completion:nil];
}

- (void)volume:(UISlider *)sender
{
  [_sonos volume:nil level:(int)[sender value] completion:nil];
}

- (void)showSpeakers
{
  PLSpeakersViewController *viewController = [[PLSpeakersViewController alloc] init];
  [viewController setModalPresentationStyle:UIModalPresentationCustom];
  [viewController setTransitioningDelegate:self];
  [self.navigationController presentViewController:viewController animated:YES completion:nil];
}

- (void)showQueue
{
  PLNextUpViewController *viewController = [[PLNextUpViewController alloc] init];
  UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:viewController];
  [self.navigationController presentViewController:navController animated:YES completion:nil];
}

- (void)setCurrentSong:(PLSong *)song
{
  [_sonos play:nil track:song.uri completion:nil];
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
  if (toInterfaceOrientation == UIInterfaceOrientationPortrait) {
    // Portrait
    [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationFade];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
  } else {
    // Landscape
    [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationFade];
    [self.navigationController setNavigationBarHidden:YES animated:YES];
  }
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
  return [_speakers count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
  PLVolumeCell *cell = (PLVolumeCell *)[tableView dequeueReusableCellWithIdentifier:@"PLVolumeCell"];
  SonosInput *input = [[SonosInputStore sharedStore] inputAtIndex:indexPath.row];
  [cell setInput:input];
  return cell;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{

}

#pragma mark - UIViewControllerTransitioningDelegate

- (id<UIViewControllerAnimatedTransitioning>)animationControllerForPresentedController:(UIViewController *)presented presentingController:(UIViewController *)presenting sourceController:(UIViewController *)source
{
  PresentSpeakersAnimator *animator = [[PresentSpeakersAnimator alloc] init];
  [animator setPresenting:YES];
  return animator;
}

- (id <UIViewControllerAnimatedTransitioning>)animationControllerForDismissedController:(UIViewController *)dismissed
{
  PresentSpeakersAnimator *animator = [[PresentSpeakersAnimator alloc] init];
  [animator setPresenting:NO];
  return animator;
}

@end
