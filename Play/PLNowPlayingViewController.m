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
#import "SonosController.h"
#import "RdioSong.h"

static const CGFloat kProgressPadding = 50.0;

static const CGFloat kControlBarHeight = 128.0;
static const CGFloat kControlBarPadding = 16.0;
static const CGFloat kControlBarPreviousNextPadding = 46.0;
static const CGFloat kControlBarButtonWidth = 44.0;
static const CGFloat kControlBarButtonHeight = kControlBarButtonWidth;
static const CGFloat kControlBarButtonPadding = 20.0;
static const CGFloat kControlBarButtonTopMargin = 56.0;

static const CGFloat kNavigationBarHeight = 80.0;

static const CGFloat kVelocity = 0.1;
static const CGFloat kDamping = 0.6;
#import "PLInputStore.h"
#import "PLInput.h"

static const CGFloat kSongTitleFontSize = 17.0;
static const CGFloat kAlbumTitleFontSize = 15.0;

@interface PLNowPlayingViewController ()
{
  SonosController *_sonos;

  NSDictionary *_group;
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

  UIView *_miniBar;
}
@end

@implementation PLNowPlayingViewController

- (id)initWIthGroup:(NSDictionary *)group
{
  if (self = [super init]) {
    _sonos = [SonosController sharedController];
    _group = group;
  }
  return self;
}

- (void)viewDidLoad
{
  [super viewDidLoad];

  [self setTitle:@"Playing"];
  [self.navigationController.navigationBar setBackgroundImage:[[UIImage alloc] init] forBarMetrics:UIBarMetricsDefault];
  [self.navigationController.navigationBar setShadowImage:[[UIImage alloc] init]];
  [self.navigationController.navigationBar setBarStyle:UIBarStyleBlack];
  [self.navigationController.navigationBar setBarTintColor:[UIColor colorWithRed:1 green:.16 blue:.41 alpha:1]];
  [self.navigationController.navigationBar setTintColor:[UIColor whiteColor]];

  if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {

  } else {
    UIBarButtonItem *speakers = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"PLSpeakers"] style:UIBarButtonItemStylePlain target:self action:@selector(showSpeakers)];
    [self.navigationItem setRightBarButtonItem:speakers];
  }

  _volumeTable = [[UITableView alloc] initWithFrame:CGRectZero];
  [_volumeTable registerClass:[PLVolumeCell class] forCellReuseIdentifier:@"PLVolumeCell"];
  [_volumeTable setDelegate:self];
  [_volumeTable setDataSource:self];
  [_volumeTable setAutoresizingMask:UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight];
  [_volumeTable setRowHeight:80];
  [_volumeTable setSeparatorStyle:UITableViewCellSeparatorStyleNone];
  [_volumeTable setContentInset:UIEdgeInsetsMake(kControlBarHeight, 0, 88, 0)];
  [self.view addSubview:_volumeTable];

  // Control Bar
  _controlBar = [[UIView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.bounds), kControlBarHeight)];
  [_controlBar setBackgroundColor:self.navigationController.navigationBar.barTintColor];
  [_controlBar setAutoresizingMask:UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleTopMargin];
  [_controlBar setUserInteractionEnabled:YES];
  [self.view addSubview:_controlBar];

  _playPauseButton = [[UIButton alloc] initWithFrame:CGRectMake((CGRectGetWidth(_controlBar.bounds)/2)-kControlBarButtonWidth/2, kControlBarButtonTopMargin, kControlBarButtonWidth, kControlBarButtonHeight)];
  [_playPauseButton setAutoresizingMask:UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin];
  [_playPauseButton setBackgroundImage:[UIImage imageNamed:@"ControlPause.png"] forState:UIControlStateNormal];
  [_playPauseButton addTarget:self action:@selector(playPause) forControlEvents:UIControlEventTouchUpInside];
  [_playPauseButton setShowsTouchWhenHighlighted:YES];
  [_controlBar addSubview:_playPauseButton];

  _nextButton = [[UIButton alloc] initWithFrame:CGRectMake(CGRectGetWidth(_controlBar.bounds)-(kControlBarButtonWidth+kControlBarPreviousNextPadding), kControlBarButtonTopMargin, kControlBarButtonWidth, kControlBarButtonHeight)];
  [_nextButton setAutoresizingMask:UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin];
  [_nextButton setBackgroundImage:[UIImage imageNamed:@"ControlNext.png"] forState:UIControlStateNormal];
  [_nextButton addTarget:self action:@selector(next) forControlEvents:UIControlEventTouchUpInside];
  [_nextButton setShowsTouchWhenHighlighted:YES];
  [_controlBar addSubview:_nextButton];

  _previousButton = [[UIButton alloc] initWithFrame:CGRectMake(kControlBarPreviousNextPadding, kControlBarButtonTopMargin, kControlBarButtonWidth, kControlBarButtonHeight)];
  [_previousButton setAutoresizingMask:UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin];
  [_previousButton setBackgroundImage:[UIImage imageNamed:@"ControlPrevious.png"] forState:UIControlStateNormal];
  [_previousButton addTarget:self action:@selector(previous) forControlEvents:UIControlEventTouchUpInside];
  [_previousButton setShowsTouchWhenHighlighted:YES];
  [_controlBar addSubview:_previousButton];
}

- (void)viewDidLayoutSubviews
{
  [super viewDidLayoutSubviews];

  [_volumeTable setFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.frame), CGRectGetHeight(self.view.frame))];
  [_volumeTable.tableHeaderView setFrame:CGRectMake(0, 0, CGRectGetWidth(_volumeTable.frame), kControlBarHeight)];
}

- (void)showSpeakers
{
  UIView *snapshot = [self.view snapshotViewAfterScreenUpdates:YES];
  [_group[@"master"] setNowPlayingSnapshot:snapshot];

  PLSpeakersViewController *viewController = [[PLSpeakersViewController alloc] init];
  [self.navigationController presentViewController:viewController animated:NO completion:nil];
}

- (void)playPause
{
  if (_sonos.isPlaying) {
    [_sonos pause:nil completion:nil];
    [_playPauseButton setBackgroundImage:[UIImage imageNamed:@"ControlPlay.png"] forState:UIControlStateNormal];
  } else {
    [_sonos play:nil uri:nil completion:nil];
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

- (void)setCurrentSong:(PLSong *)song
{
  [_sonos play:nil uri:song.uri completion:nil];
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
  return [_group[@"inputs"] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
  PLVolumeCell *cell = (PLVolumeCell *)[tableView dequeueReusableCellWithIdentifier:@"PLVolumeCell"];
  SonosInput *input = [_group[@"inputs"] objectAtIndex:indexPath.item];
  [cell setInput:input];
  return cell;
}

@end
