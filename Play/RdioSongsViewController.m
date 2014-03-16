//
//  RdioSongsViewController.m
//  Play
//
//  Created by Nathan Borror on 7/7/13.
//  Copyright (c) 2013 Nathan Borror. All rights reserved.
//

#import "RdioSongsViewController.h"
#import "PLNowPlayingViewController.h"
#import "RdioArtist.h"
#import "RdioAlbum.h"
#import "RdioSong.h"
#import "RdioPlaylist.h"

@interface RdioSongsViewController ()
{
  Rdio *_rdio;
  NSMutableArray *_songs;
  RdioPlaylist *_playlist;
}
@end

@implementation RdioSongsViewController

- (instancetype)initWithPlaylist:(RdioPlaylist *)aPlaylist
{
  if (self = [super init]) {
    _playlist = aPlaylist;
    _songs = [[NSMutableArray alloc] init];

    if (_songs.count == 0) {
      NSString *key = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFRdioConsumerKey"];
      NSString *secret = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFRdioConsumerSecret"];
      _rdio = [[Rdio alloc] initWithConsumerKey:key andSecret:secret delegate:self];
      [_rdio authorizeUsingAccessToken:[[NSUserDefaults standardUserDefaults] objectForKey:@"rdioAccessKey"] fromController:self];
    }
  }
  return self;
}

- (void)viewDidLoad
{
  [super viewDidLoad];

  [self setTitle:@"Songs"];

  UIBarButtonItem *nowPlayingButton = [[UIBarButtonItem alloc] initWithTitle:@"Playing" style:UIBarButtonItemStyleDone target:self action:@selector(nowPlaying)];
  [self.navigationItem setRightBarButtonItem:nowPlayingButton];
}

- (void)nowPlaying
{
  PLNowPlayingViewController *viewController = [[PLNowPlayingViewController alloc] init];
  UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:viewController];
  [self.navigationController presentViewController:navController animated:YES completion:nil];
}

- (void)getRdioSongsForPlaylist
{
  [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
  [_rdio callAPIMethod:@"get" withParameters:@{@"keys":_playlist.key, @"extras": @"tracks"} delegate:self];
}

#pragma mark - RdioDelegate

- (void)rdioDidAuthorizeUser:(NSDictionary *)user withAccessToken:(NSString *)accessToken
{
  NSLog(@"Rdio: Authorized User");

  [[NSUserDefaults standardUserDefaults] setObject:accessToken forKey:@"rdioAccessKey"];
  [[NSUserDefaults standardUserDefaults] synchronize];

  if (_songs.count == 0) {
    [self getRdioSongsForPlaylist];
  }
}

- (void)rdioAuthorizationFailed:(NSString *)error
{
  NSLog(@"Rdio: authorization failed: %@", error);
}

#pragma mark - RDAPIRequestDelegate

- (void)rdioRequest:(RDAPIRequest *)request didLoadData:(id)data
{
//  NSLog(@"Rdio: request did load: %@", data[playlist.key][@"tracks"]);
  for (NSDictionary *track in data[_playlist.key][@"tracks"]) {
    RdioArtist *artist = [[RdioArtist alloc] init];
    [artist setKey:track[@"artistKey"]];
    [artist setName:track[@"artist"]];

    RdioAlbum *album = [[RdioAlbum alloc] init];
    [album setKey:track[@"albumKey"]];
    [album setName:track[@"album"]];
    [album setArtist:artist];

    RdioSong *newSong = [[RdioSong alloc] init];
    [newSong setKey:track[@"key"]];
    [newSong setName:track[@"name"]];
    [newSong setAlbumArt:track[@"icon"]];
    [newSong setAlbum:album];
    [_songs addObject:newSong];
  }
  [self.tableView reloadData];
  [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
}

- (void)rdioRequest:(RDAPIRequest *)request didFailWithError:(NSError *)error
{
  NSLog(@"Rdio: request failed: %@", [error localizedDescription]);
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
  return _songs.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
  UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"PlaylistCell"];
  if (!cell) {
    cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"PlaylistCell"];
  }
  RdioSong *song = (RdioSong *)[_songs objectAtIndex:indexPath.row];
  [cell.textLabel setText:song.name];
  return cell;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
//  RdioSong *song = (RdioSong *)[_songs objectAtIndex:indexPath.row];

//  PLNowPlayingViewController *viewController = [[PLNowPlayingViewController alloc] initWithRdioSong:song];
//  UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:viewController];
//  [self.navigationController presentViewController:navController animated:YES completion:nil];
}

@end
