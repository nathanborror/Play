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
#import "NBKit/NBAnimationHelper.h"

static const CGFloat kProgressPadding = 50.0;

static const CGFloat kControlBarPadding = 20.0;
static const CGFloat kControlBarPreviousNextPadding = 40.0;
static const CGFloat kControlBarButtonWidth = 75.0;
static const CGFloat kControlBarButtonHeight = kControlBarButtonWidth;
static const CGFloat kControlBarButtonPadding = 20.0;
static const CGFloat kControlBarRestingYPortrait = 151.0;
static const CGFloat kControlBarRestingYLandscape = 235.0;

static const CGFloat kNavigationBarHeight = 80.0;

@interface PLNowPlayingViewController ()
{
  SonosController *sonos;

  UIImageView *controlBar;
  UISlider *volumeSlider;
  UIButton *playPauseButton;
  UIButton *stopButton;
  UIButton *nextButton;
  UIButton *previousButton;
  UIButton *speakersButton;
  UIImageView *album;

  UIView *trackInfo;
  UILabel *title;
  UILabel *timeTotal;
  UILabel *timeElapsed;
  UISlider *progress;

  UITableView *songList;
  UIView *tableHeader;
  NSArray *songListData;

  CGPoint panCoordBegan;

  UIImageView *navBar;
}
@end

@implementation PLNowPlayingViewController

- (id)init
{
  self = [super init];
  if (self) {
    [self.view setBackgroundColor:[UIColor colorWithRed:.2 green:.2 blue:.2 alpha:1]];
    [self.view setClipsToBounds:YES];

    [self.navigationItem setTitle:@"Now Playing"];

    sonos = [SonosController sharedController];

    // Background
    UIImageView *background = [[UIImageView alloc] initWithFrame:CGRectMake(-100, -100, CGRectGetWidth(self.view.bounds)+200, CGRectGetHeight(self.view.bounds)+200)];
    [background setAutoresizingMask:UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight];
    [self.view addSubview:background];

    // Header
    tableHeader = [[UIView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.bounds), 390)];
    [tableHeader setAutoresizingMask:UIViewAutoresizingFlexibleWidth];

    // Header: Album Art
    album = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 320, 320)];
    [album setAutoresizingMask:UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin];
    [album setImage:[UIImage imageNamed:@"TempAlbum.png"]];
    [album.layer setShadowRadius:5];
    [album.layer setShadowOffset:CGSizeMake(0, 5)];
    [album.layer setShadowOpacity:.5];
    [album.layer setShadowColor:[UIColor blackColor].CGColor];
    [tableHeader addSubview:album];

    // Blurred Background
    [background setImage:[UIImage blurImage:album.image radius:20.0 scale:1.6]];

    // Song List
    songList = [[UITableView alloc] initWithFrame:CGRectMake(0, kNavigationBarHeight, CGRectGetWidth(self.view.bounds), CGRectGetHeight(self.view.bounds))];
    [songList setAutoresizingMask:UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight];
    [songList setBackgroundColor:[UIColor clearColor]];
    [songList setTableHeaderView:tableHeader];
    [songList setContentInset:UIEdgeInsetsMake(0, 0, 700, 0)];
    [songList setDelegate:self];
    [songList setDataSource:self];
    [songList setSeparatorColor:[UIColor colorWithWhite:1 alpha:.3]];
    [songList setScrollIndicatorInsets:UIEdgeInsetsMake(0, 0, 0, -7)];
    [self.view addSubview:songList];

    // ---- Custom Navigation Bar ----

    navBar = [[UIImageView alloc] initWithImage:[[UIImage imageNamed:@"NavBar"] resizableImageWithCapInsets:UIEdgeInsetsMake(4, 4, 4, 4) resizingMode:UIImageResizingModeStretch]];
    [navBar setUserInteractionEnabled:YES];
    [navBar setFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.bounds), kNavigationBarHeight)];
    [navBar.layer setShadowOffset:CGSizeMake(0, 2)];
    [navBar.layer setShadowColor:[UIColor colorWithWhite:.2 alpha:1].CGColor];
    [navBar.layer setShadowRadius:1.0];
    [navBar.layer setShadowOpacity:.3];
    [self.view addSubview:navBar];

    UIButton *done = [[UIButton alloc] initWithFrame:CGRectMake(CGRectGetWidth(navBar.bounds)-55-6, 7, 55, 30)];
    [done addTarget:self action:@selector(done) forControlEvents:UIControlEventTouchUpInside];
    [done setBackgroundImage:[[UIImage imageNamed:@"BarButtonItemDone"] resizableImageWithCapInsets:UIEdgeInsetsMake(4,4,4,4) resizingMode:UIImageResizingModeStretch] forState:UIControlStateNormal];
    [done setTitle:@"Done" forState:UIControlStateNormal];
    [done.titleLabel setFont:[UIFont boldSystemFontOfSize:12]];
    [done.titleLabel setShadowOffset:CGSizeMake(0, -1)];
    [navBar addSubview:done];

    // Track Info
    trackInfo = [[UIView alloc] init];

    title = [[UILabel alloc] initWithFrame:CGRectMake(0, 10, CGRectGetWidth(self.view.bounds), 20)];
    [title setAutoresizingMask:UIViewAutoresizingFlexibleWidth];
    [title setTextColor:[UIColor colorWithWhite:1 alpha:.9]];
    [title setBackgroundColor:[UIColor clearColor]];
    [title setTextAlignment:NSTextAlignmentCenter];
    [title setFont:[UIFont boldSystemFontOfSize:14]];
    [title setText:@"Come Together"];
    [trackInfo addSubview:title];

    // Track Info: Progress Bar
    progress = [[UISlider alloc] initWithFrame:CGRectMake(kProgressPadding, 45, 320 - (kProgressPadding * 2), 20)];
    [progress setAutoresizingMask:UIViewAutoresizingFlexibleWidth];
    [progress setThumbImage:[UIImage imageNamed:@"SliderThumbSmall.png"] forState:UIControlStateNormal];
    [progress setThumbImage:[UIImage imageNamed:@"SliderThumbSmallPressed.png"] forState:UIControlStateHighlighted];
    [trackInfo addSubview:progress];

    // Track Info: Elapsed Time
    timeElapsed = [[UILabel alloc] initWithFrame:CGRectMake(5, 46, 40, 20)];
    [timeElapsed setTextColor:[UIColor colorWithWhite:1 alpha:.9]];
    [timeElapsed setBackgroundColor:[UIColor clearColor]];
    [timeElapsed setTextAlignment:NSTextAlignmentRight];
    [timeElapsed setFont:[UIFont systemFontOfSize:12]];
    [timeElapsed setText:@"02:23"];
    [trackInfo addSubview:timeElapsed];

    // Track Info: Total Time
    timeTotal = [[UILabel alloc] initWithFrame:CGRectMake(278, 46, 40, 20)];
    [timeTotal setAutoresizingMask:UIViewAutoresizingFlexibleLeftMargin];
    [timeTotal setTextColor:[UIColor colorWithWhite:1 alpha:.9]];
    [timeTotal setBackgroundColor:[UIColor clearColor]];
    [timeTotal setTextAlignment:NSTextAlignmentLeft];
    [timeTotal setFont:[UIFont systemFontOfSize:12]];
    [timeTotal setText:@"06:12"];
    [trackInfo addSubview:timeTotal];

    [trackInfo sizeToFit];
    [navBar addSubview:trackInfo];

    // ---- Control Bar ----

    controlBar = [[UIImageView alloc] initWithFrame:CGRectMake(0, CGRectGetHeight(self.view.bounds)-kControlBarRestingYPortrait, CGRectGetWidth(self.view.frame), CGRectGetHeight(self.view.frame))];
    [controlBar setImage:[[UIImage imageNamed:@"ControlBar.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(6, 6, 6, 6) resizingMode:UIImageResizingModeStretch]];
    [controlBar setAutoresizingMask:UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleTopMargin];
    [controlBar setUserInteractionEnabled:YES];
    [controlBar.layer setShadowOffset:CGSizeMake(0, -2)];
    [controlBar.layer setShadowColor:[UIColor colorWithWhite:.2 alpha:1].CGColor];
    [controlBar.layer setShadowRadius:1.0];
    [controlBar.layer setShadowOpacity:.3];

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
      PLVolumeSlider *speakerVolume = [[PLVolumeSlider alloc] initWithFrame:CGRectMake(kControlBarButtonPadding, 185 + (i * 70), CGRectGetWidth(controlBar.bounds)-(kControlBarButtonPadding * 2), 44)];
      [speakerVolume setInput:[speakers objectAtIndex:i]];
      [controlBar addSubview:speakerVolume];
    }

    [self.view addSubview:controlBar];

    // Control Bar pan gesture
    NBDirectionGestureRecognizer *controlPan = [[NBDirectionGestureRecognizer alloc] initWithTarget:self action:@selector(panControlBar:)];
    [controlPan setDirection:NBDirectionPanGestureRecognizerVertical];
    [controlBar addGestureRecognizer:controlPan];
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
    [title setText:[NSString stringWithFormat:@"%@ - Line In", [input name]]];
    [timeElapsed setText:@"00:00"];
    [timeTotal setText:@"00:00"];
  }
  return self;
}

- (void)viewWillAppear:(BOOL)animated
{
  [super viewWillAppear:animated];
  [self.navigationController setNavigationBarHidden:YES];
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
  [title setText:[NSString stringWithFormat:@"%@ - %@", song.title, song.album]];
  [album setImage:song.albumArt];
  [timeTotal setText:song.duration];
  [sonos play:nil track:[song uri] completion:nil];
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
  if (toInterfaceOrientation == UIInterfaceOrientationPortrait) {
    // Portrait
    [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationFade];
    [self.navigationController setNavigationBarHidden:NO animated:YES];

    [controlBar setFrame:CGRectOffset(controlBar.bounds, 0, kControlBarRestingYPortrait)];
    [volumeSlider setFrame:CGRectMake(kControlBarButtonPadding, 80, CGRectGetWidth(controlBar.bounds)-(kControlBarButtonPadding*2), 20)];
    [album setFrame:CGRectMake(30, 90, 260, 260)];
    [trackInfo setFrame:CGRectOffset(trackInfo.bounds, 0, 0)];
  } else {
    // Landscape
    [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationFade];
    [self.navigationController setNavigationBarHidden:YES animated:YES];

    [controlBar setFrame:CGRectOffset(controlBar.bounds, 0, kControlBarRestingYLandscape)];
    [volumeSlider setFrame:CGRectMake(kControlBarButtonPadding+280, 34, 250, 20)];
    [album setFrame:CGRectMake(15, 15, 209, 209)];
    [trackInfo setFrame:CGRectOffset(trackInfo.bounds, CGRectGetWidth(album.bounds)+20, 20)];
  }
}

- (void)showSpeakerVolumes
{
  [NBAnimationHelper animatePosition:controlBar
                                from:controlBar.center
                                  to:CGPointMake(controlBar.center.x, (CGRectGetHeight(controlBar.bounds)/2)+78)
                              forKey:@"bounce"
                            delegate:nil];
}

- (void)hideSpeakerVolumes
{
  [NBAnimationHelper animatePosition:controlBar
                                from:controlBar.center
                                  to:CGPointMake(controlBar.center.x, (CGRectGetHeight(controlBar.bounds)/2)+397)
                              forKey:@"bounce"
                            delegate:nil];
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
