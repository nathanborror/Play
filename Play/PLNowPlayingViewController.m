//
//  ViewController.m
//  Play
//
//  Created by Nathan Borror on 12/30/12.
//  Copyright (c) 2012 Nathan Borror. All rights reserved.
//

#import "PLNowPlayingViewController.h"
#import "SonosController.h"
#import "PLPrimaryBarButtonItem.h"
#import "PLSong.h"

static float kProgressPadding = 50.0;
static float kControlBarPadding = 5.0;
static float kControlBarHeight = 118.0;
static float kControlBarButtonWidth = 75.0;
static float kControlBarButtonHeight = 75.0;
static float kControlBarButtonPadding = 20.0;

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
  UILabel *track;
  UILabel *timeTotal;
  UILabel *timeElapsed;
  UISlider *progress;
  UITableView *songList;
  UIView *tableHeader;
  NSArray *songListData;
}
@end

@implementation PLNowPlayingViewController

- (id)init
{
  self = [super init];
  if (self) {
    [self.view setBackgroundColor:[UIColor colorWithRed:.2 green:.2 blue:.2 alpha:1]];

    [self.navigationItem setTitle:@"Now Playing"];

    // Done Button
    UIBarButtonItem *doneButton = [[PLPrimaryBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(done)];
    [self.navigationItem setRightBarButtonItem:doneButton];

    sonos = [SonosController sharedController];

    songListData = @[
    [[PLSong alloc] initWithArtist:@"David Guetta"
                             album:@"Nothing But the Beat"
                             title:@"Where Them Girls At"
                               uri:@"http://mobile-iPhone-D8D1CBAC4DA9.x-udn/music/track.adts?id=CCAE56B9C5E54482"
                          albumArt:[UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:@"http://10.0.1.15:3401/music/image?id=897A8C6E30E6FA61"]]]
                          duration:@"0:04:21"],
    [[PLSong alloc] initWithArtist:@"David Guetta"
                             album:@"Nothing But the Beat"
                             title:@"Anxiety"
                               uri:@"http://mobile-iPhone-D8D1CBAC4DA9.x-udn/music/track.adts?id=897A8C6E30E6FA61"
                          albumArt:[UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:@"http://10.0.1.15:3401/music/image?id=897A8C6E30E6FA61"]]]
                          duration:@"0:04:31"],
    [[PLSong alloc] initWithArtist:@"David Guetta"
                             album:@"Nothing But the Beat"
                             title:@"My Heroine"
                               uri:@"http://mobile-iPhone-D8D1CBAC4DA9.x-udn/music/track.adts?id=B36EA2FF78D7BFBA"
                          albumArt:[UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:@"http://10.0.1.15:3401/music/image?id=897A8C6E30E6FA61"]]]
                          duration:@"0:05:04"],
    [[PLSong alloc] initWithArtist:@"David Guetta"
                             album:@"Nothing But the Beat"
                             title:@"Moon As My Witness"
                               uri:@"http://mobile-iPhone-D8D1CBAC4DA9.x-udn/music/track.adts?id=1C7E23B434C39CA6"
                          albumArt:[UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:@"http://10.0.1.15:3401/music/image?id=897A8C6E30E6FA61"]]]
                          duration:@"0:03:45"]
    ];

    // Header
    tableHeader = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 390)];

    // Header: Album Art
    album = [[UIImageView alloc] initWithFrame:CGRectMake(0, 70, 320, 320)];
    [album setImage:[UIImage imageNamed:@"TempAlbum2.png"]];
    [tableHeader addSubview:album];

    // Header: Track Title
    track = [[UILabel alloc] initWithFrame:CGRectMake(0, 10, 320, 20)];
    [track setTextColor:[UIColor colorWithRed:.6 green:.6 blue:.6 alpha:1]];
    [track setBackgroundColor:[UIColor clearColor]];
    [track setTextAlignment:NSTextAlignmentCenter];
    [track setFont:[UIFont systemFontOfSize:14]];
    [track setText:@"Titanium — Nothing But The Beat"];
    [tableHeader addSubview:track];

    // Header: Progress Bar
    progress = [[UISlider alloc] initWithFrame:CGRectMake(kProgressPadding, 35, 320 - (kProgressPadding * 2), 20)];
    [progress setMaximumTrackImage:[[UIImage imageNamed:@"SliderMaxValue.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(3, 3, 3, 3)] forState:UIControlStateNormal];
    [progress setMinimumTrackImage:[[UIImage imageNamed:@"SliderMinValue.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(3, 3, 3, 3)] forState:UIControlStateNormal];
    [progress setThumbImage:[UIImage imageNamed:@"SliderThumbSmall.png"] forState:UIControlStateNormal];
    [progress setThumbImage:[UIImage imageNamed:@"SliderThumbSmallPressed.png"] forState:UIControlStateHighlighted];
    [tableHeader addSubview:progress];

    // Header: Time
    timeElapsed = [[UILabel alloc] initWithFrame:CGRectMake(5, 36, 40, 20)];
    [timeElapsed setTextColor:[UIColor colorWithRed:.6 green:.6 blue:.6 alpha:1]];
    [timeElapsed setBackgroundColor:[UIColor clearColor]];
    [timeElapsed setTextAlignment:NSTextAlignmentRight];
    [timeElapsed setFont:[UIFont systemFontOfSize:12]];
    [timeElapsed setText:@"02:23"];
    [tableHeader addSubview:timeElapsed];

    timeTotal = [[UILabel alloc] initWithFrame:CGRectMake(278, 36, 40, 20)];
    [timeTotal setTextColor:[UIColor colorWithRed:.6 green:.6 blue:.6 alpha:1]];
    [timeTotal setBackgroundColor:[UIColor clearColor]];
    [timeTotal setTextAlignment:NSTextAlignmentLeft];
    [timeTotal setFont:[UIFont systemFontOfSize:12]];
    [timeTotal setText:@"06:12"];
    [tableHeader addSubview:timeTotal];

    // Song List
    songList = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.bounds), 452)];
    [songList setBackgroundColor:[UIColor clearColor]];
    [songList setTableHeaderView:tableHeader];
    [songList setContentInset:UIEdgeInsetsMake(0, 0, 100, 0)];
    [songList setDelegate:self];
    [songList setDataSource:self];
    [songList setSeparatorColor:[UIColor colorWithRed:.3 green:.3 blue:.3 alpha:1]];
    [self.view addSubview:songList];

    // TODO: Figure out why self.view.bounds isn't returning the right
    // height minus the navbar height

    // Control Bar
    controlBar = [[UIImageView alloc] initWithFrame:CGRectMake(0, CGRectGetHeight(self.view.bounds)-kControlBarHeight-44, CGRectGetWidth(self.view.bounds), kControlBarHeight)];
    [controlBar setImage:[UIImage imageNamed:@"ControlBar.png"]];
    [controlBar setUserInteractionEnabled:YES];
    [self.view addSubview:controlBar];

    playPauseButton = [[UIButton alloc] initWithFrame:CGRectMake((CGRectGetWidth(controlBar.bounds)/2)-kControlBarButtonWidth/2, kControlBarPadding, kControlBarButtonWidth, kControlBarButtonHeight)];
    [playPauseButton setBackgroundImage:[UIImage imageNamed:@"ControlPause.png"] forState:UIControlStateNormal];
    [playPauseButton addTarget:self action:@selector(playPause) forControlEvents:UIControlEventTouchUpInside];
    [playPauseButton setShowsTouchWhenHighlighted:YES];
    [controlBar addSubview:playPauseButton];

    nextButton = [[UIButton alloc] initWithFrame:CGRectMake(CGRectGetWidth(controlBar.bounds)-(kControlBarButtonWidth+kControlBarButtonPadding), kControlBarPadding, kControlBarButtonWidth, kControlBarButtonHeight)];
    [nextButton setBackgroundImage:[UIImage imageNamed:@"ControlNext.png"] forState:UIControlStateNormal];
    [nextButton addTarget:sonos action:@selector(next) forControlEvents:UIControlEventTouchUpInside];
    [nextButton setShowsTouchWhenHighlighted:YES];
    [controlBar addSubview:nextButton];

    previousButton = [[UIButton alloc] initWithFrame:CGRectMake(kControlBarButtonPadding, kControlBarPadding, kControlBarButtonWidth, kControlBarButtonHeight)];
    [previousButton setBackgroundImage:[UIImage imageNamed:@"ControlPrevious.png"] forState:UIControlStateNormal];
    [previousButton addTarget:sonos action:@selector(previous) forControlEvents:UIControlEventTouchUpInside];
    [previousButton setShowsTouchWhenHighlighted:YES];
    [controlBar addSubview:previousButton];

    volumeSlider = [[UISlider alloc] initWithFrame:CGRectMake(kControlBarButtonPadding, 80, CGRectGetWidth(controlBar.bounds)-(kControlBarButtonPadding*2), 20)];
    [volumeSlider setMaximumValue:100];
    [volumeSlider setMinimumValue:0];
    [volumeSlider setValue:20];
    [volumeSlider setMaximumTrackImage:[[UIImage imageNamed:@"SliderMaxValue.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(3, 3, 3, 3)] forState:UIControlStateNormal];
    [volumeSlider setMinimumTrackImage:[[UIImage imageNamed:@"SliderMinValue.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(3, 3, 3, 3)] forState:UIControlStateNormal];
    [volumeSlider setThumbImage:[UIImage imageNamed:@"SliderThumb.png"] forState:UIControlStateNormal];
    [volumeSlider setThumbImage:[UIImage imageNamed:@"SliderThumbPressed.png"] forState:UIControlStateHighlighted];
    [volumeSlider addTarget:self action:@selector(volume:) forControlEvents:UIControlEventValueChanged];
    [controlBar addSubview:volumeSlider];

    [speakersButton addTarget:sonos action:@selector(speakerIPs) forControlEvents:UIControlEventTouchUpInside];

//    [sonos trackInfo];
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

- (id)initWithLineIn:(NSString *)uid
{
  self = [self init];
  if (self) {
    [sonos lineIn:uid];
    [album setImage:[UIImage imageNamed:@"LineIn.png"]];
    [track setText:[NSString stringWithFormat:@"%@ - Line In", [[NSUserDefaults standardUserDefaults] objectForKey:@"current_input_name"]]];
    [timeElapsed setText:@"00:00"];
    [timeTotal setText:@"00:00"];
  }
  return self;
}

- (void)playPause
{
  if (sonos.isPlaying) {
    [sonos pause];
    [playPauseButton setBackgroundImage:[UIImage imageNamed:@"ControlPlay.png"] forState:UIControlStateNormal];
  } else {
    [sonos play:nil];
    [playPauseButton setBackgroundImage:[UIImage imageNamed:@"ControlPause.png"] forState:UIControlStateNormal];
  }
}

- (void)volume:(UISlider *)sender
{
  [sonos volume:(int)[sender value]];
}

- (void)done
{
  [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

- (void)setCurrentSong:(PLSong *)song
{

  [track setText:[NSString stringWithFormat:@"%@ - %@", song.title, song.album]];
  [album setImage:song.albumArt];
  [timeTotal setText:song.duration];
  [sonos play:song.uri];
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
