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
#import "PLProgressBar.h"
#import "UIImage+BlurImage.h"
#import "NBKit/NBDirectionGestureRecognizer.h"
#import "RdioSong.h"

static const CGFloat kProgressPadding = 50.0;

static const CGFloat kControlBarPadding = 15.0;
static const CGFloat kControlBarPreviousNextPadding = 46.0;
static const CGFloat kControlBarButtonWidth = 65.0;
static const CGFloat kControlBarButtonHeight = kControlBarButtonWidth;
static const CGFloat kControlBarButtonPadding = 20.0;

static const CGFloat kControlBarHeight = 184.0;
static const CGFloat kControlBarLoweredCenter = 668.0;
static const CGFloat kControlBarRaisedCenter = 376.0;

static const CGFloat kNavigationBarHeight = 80.0;

static const CGFloat kVelocity = 0.1;
static const CGFloat kDamping = 0.6;

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
}
@end

@implementation PLNowPlayingViewController

- (id)init
{
  self = [super init];
  if (self) {
    [self.navigationItem setTitle:@"Now Playing"];
    [self.navigationController.navigationBar setTintColor:[UIColor blackColor]];

    [self.view setBackgroundColor:[UIColor blackColor]];

    sonos = [SonosController sharedController];

    UIBarButtonItem *done = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(done)];
    [self.navigationItem setRightBarButtonItem:done];
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
  self = [self init];
  if (self) {
    [sonos play:nil rdioSong:song completion:nil];

    NSURL *url = [NSURL URLWithString:song.albumArt];
    NSData *data = [NSData dataWithContentsOfURL:url];
    UIImage *image = [[UIImage alloc] initWithData:data];
    [album setImage:image];
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

  [self setNeedsStatusBarAppearanceUpdate];

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
  [songList setShowsVerticalScrollIndicator:NO];
  [songList setBackgroundColor:[UIColor clearColor]];
  [songList setTableHeaderView:tableHeader];
  [songList setContentInset:UIEdgeInsetsMake(0, 0, 700, 0)];
  [songList setDelegate:self];
  [songList setDataSource:self];
  [self.view addSubview:songList];

  // Control Bar
  controlBar = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetHeight(self.view.bounds)-kControlBarHeight, CGRectGetWidth(self.view.frame), CGRectGetHeight(self.view.frame))];
  [controlBar setBackgroundColor:[UIColor whiteColor]];
  [controlBar setAutoresizingMask:UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleTopMargin];
  [controlBar setUserInteractionEnabled:YES];

  playPauseButton = [[UIButton alloc] initWithFrame:CGRectMake((CGRectGetWidth(controlBar.bounds)/2)-kControlBarButtonWidth/2, 68, kControlBarButtonWidth, kControlBarButtonHeight)];
  [playPauseButton setBackgroundImage:[UIImage imageNamed:@"ControlPause.png"] forState:UIControlStateNormal];
  [playPauseButton addTarget:self action:@selector(playPause) forControlEvents:UIControlEventTouchUpInside];
  [playPauseButton setShowsTouchWhenHighlighted:YES];
  [controlBar addSubview:playPauseButton];

  nextButton = [[UIButton alloc] initWithFrame:CGRectMake(CGRectGetWidth(controlBar.bounds)-(kControlBarButtonWidth+kControlBarPreviousNextPadding), 68, kControlBarButtonWidth, kControlBarButtonHeight)];
  [nextButton setBackgroundImage:[UIImage imageNamed:@"ControlNext.png"] forState:UIControlStateNormal];
  [nextButton addTarget:self action:@selector(next) forControlEvents:UIControlEventTouchUpInside];
  [nextButton setShowsTouchWhenHighlighted:YES];
  [controlBar addSubview:nextButton];

  previousButton = [[UIButton alloc] initWithFrame:CGRectMake(kControlBarPreviousNextPadding, 68, kControlBarButtonWidth, kControlBarButtonHeight)];
  [previousButton setBackgroundImage:[UIImage imageNamed:@"ControlPrevious.png"] forState:UIControlStateNormal];
  [previousButton addTarget:self action:@selector(previous) forControlEvents:UIControlEventTouchUpInside];
  [previousButton setShowsTouchWhenHighlighted:YES];
  [controlBar addSubview:previousButton];

  // Song info
  UILabel *songTitle = [[UILabel alloc] init];
  [songTitle setText:@"Come Together"];
  [songTitle setFont:[UIFont boldSystemFontOfSize:15]];
  [songTitle setBackgroundColor:[UIColor clearColor]];
  [songTitle sizeToFit];
  [songTitle setCenter:CGPointMake(CGRectGetWidth(controlBar.bounds)/2, 40)];
  [controlBar addSubview:songTitle];

  UILabel *artistTitle = [[UILabel alloc] init];
  [artistTitle setText:@"The Beatles — Abby Road"];
  [artistTitle setFont:[UIFont systemFontOfSize:11]];
  [artistTitle setBackgroundColor:[UIColor clearColor]];
  [artistTitle sizeToFit];
  [artistTitle setCenter:CGPointMake(CGRectGetWidth(controlBar.bounds)/2, 60)];
  [controlBar addSubview:artistTitle];

  PLProgressBar *progress = [[PLProgressBar alloc] initWithFrame:CGRectMake(45, 0, CGRectGetWidth(self.view.bounds)-90, 20)];
  [progress setMinimumValue:0];
  [progress setMaximumValue:5.0];
  [progress setValue:1];
  [controlBar addSubview:progress];

  UILabel *elapsedTime = [[UILabel alloc] init];
  [elapsedTime setText:@"1:34"];
  [elapsedTime setFont:[UIFont systemFontOfSize:10]];
  [elapsedTime setBackgroundColor:[UIColor clearColor]];
  [elapsedTime sizeToFit];
  [elapsedTime setFrame:CGRectOffset(elapsedTime.bounds, 20, 11)];
  [controlBar addSubview:elapsedTime];

  UILabel *totalTime = [[UILabel alloc] init];
  [totalTime setText:@"5:11"];
  [totalTime setFont:[UIFont systemFontOfSize:10]];
  [totalTime setBackgroundColor:[UIColor clearColor]];
  [totalTime sizeToFit];
  [totalTime setFrame:CGRectOffset(totalTime.bounds, CGRectGetWidth(controlBar.bounds)-CGRectGetWidth(totalTime.bounds)-20, 11)];
  [controlBar addSubview:totalTime];

  // PLDial
  PLDial *dial = [[PLDial alloc] initWithFrame:CGRectMake(kControlBarPadding, 153-kControlBarPadding, CGRectGetWidth(controlBar.bounds)-(kControlBarPadding*2), 44)];
  [dial setMaxValue:100];
  [dial setMinValue:0];
  [dial setValue:20];
  [controlBar addSubview:dial];

  NSArray *speakers = [[SonosInputStore sharedStore] allInputs];
  for (int i = 0; i < speakers.count; i++) {
    PLVolumeSlider *speakerVolume = [[PLVolumeSlider alloc] initWithFrame:CGRectMake(kControlBarButtonPadding, 235 + (i * 80), CGRectGetWidth(controlBar.bounds)-(kControlBarButtonPadding * 2), 44)];
    [speakerVolume setInput:[speakers objectAtIndex:i]];
    [controlBar addSubview:speakerVolume];
  }

  [self.view addSubview:controlBar];

  // Control Bar pan gesture
  NBDirectionGestureRecognizer *controlPan = [[NBDirectionGestureRecognizer alloc] initWithTarget:self action:@selector(panControlBar:)];
  [controlPan setDirection:NBDirectionPanGestureRecognizerVertical];
  [controlBar addGestureRecognizer:controlPan];
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
  return UIStatusBarStyleLightContent;
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
  [UIView animateWithDuration:.75 delay:0 usingSpringWithDamping:kDamping initialSpringVelocity:kVelocity options:UIViewAnimationOptionCurveLinear animations:^{
    [controlBar setFrame:CGRectOffset(controlBar.bounds, 0, 90)];
  } completion:nil];
}

- (void)hideSpeakerVolumes
{
  [UIView animateWithDuration:.75 delay:0 usingSpringWithDamping:kDamping initialSpringVelocity:kVelocity options:UIViewAnimationOptionCurveLinear animations:^{
    [controlBar setFrame:CGRectOffset(controlBar.bounds, 0, CGRectGetHeight(self.view.bounds)-kControlBarHeight)];
  } completion:nil];
}

#pragma mark - NBDirectionGestureRecognizer

- (void)panControlBar:(NBDirectionGestureRecognizer *)recognizer
{
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
