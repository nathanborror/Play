//
//  RdioPlaylistViewController.m
//  Play
//
//  Created by Nathan Borror on 7/6/13.
//  Copyright (c) 2013 Nathan Borror. All rights reserved.
//

#import "RdioPlaylistViewController.h"
#import "RdioPlaylist.h"
#import "PLNowPlayingViewController.h"
#import "RdioSongsViewController.h"
#import "RdioSong.h"
#import "RdioAlbum.h"
#import "RdioArtist.h"
#import "PLSongViewController.h"

@interface RdioPlaylistViewController ()
{
  Rdio *rdio;
  UILocalizedIndexedCollation *collation;
  NSMutableArray *playlists;
}
@end

@implementation RdioPlaylistViewController

- (id)init
{
  if (self = [super init]) {
    [self setTitle:@"Playlists"];

    // Now Playing Button
    UIBarButtonItem *nowPlayingButton = [[UIBarButtonItem alloc] initWithTitle:@"Playing" style:UIBarButtonItemStyleDone target:self action:@selector(nowPlaying)];
    [self.navigationItem setRightBarButtonItem:nowPlayingButton];

    playlists = [[NSMutableArray alloc] init];
  }
  return self;
}

- (void)viewDidLoad
{
  [super viewDidLoad];

  if (playlists.count == 0) {
    NSString *key = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFRdioConsumerKey"];
    NSString *secret = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFRdioConsumerSecret"];
    rdio = [[Rdio alloc] initWithConsumerKey:key andSecret:secret delegate:self];
    [rdio authorizeUsingAccessToken:[[NSUserDefaults standardUserDefaults] objectForKey:@"rdioAccessKey"] fromController:self];
  } else {
    //
  }
}

- (void)nowPlaying
{
  PLNowPlayingViewController *viewController = [[PLNowPlayingViewController alloc] init];
  UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:viewController];
  [self.navigationController presentViewController:navController animated:YES completion:nil];
}

- (void)getRdioPlaylists
{
  [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
  [rdio callAPIMethod:@"getPlaylists" withParameters:@{@"extras": @"tracks"} delegate:self];
}

#pragma mark - RdioDelegate

- (void)rdioDidAuthorizeUser:(NSDictionary *)user withAccessToken:(NSString *)accessToken
{
  NSLog(@"Rdio: Authorized User");

  [[NSUserDefaults standardUserDefaults] setObject:accessToken forKey:@"rdioAccessKey"];
  [[NSUserDefaults standardUserDefaults] synchronize];

  if (playlists.count == 0) {
    [self getRdioPlaylists];
  }
}

- (void)rdioAuthorizationFailed:(NSString *)error
{
  NSLog(@"Rdio: authorization failed: %@", error);
}

#pragma mark - RDAPIRequestDelegate

- (void)rdioRequest:(RDAPIRequest *)request didLoadData:(id)data
{
//  NSLog(@"Rdio: request did load: %@", data[@"owned"]);
  for (NSDictionary *playlist in data[@"owned"]) {
    RdioPlaylist *newPlaylist = [[RdioPlaylist alloc] init];
    [newPlaylist setName:playlist[@"name"]];
    [newPlaylist setUrl:playlist[@"url"]];

    NSMutableArray *songs = [[NSMutableArray alloc] init];
    for (NSDictionary *song in playlist[@"tracks"]) {
      RdioArtist *artist = [[RdioArtist alloc] init];
      [artist setKey:song[@"artistKey"]];
      [artist setName:song[@"artist"]];

      RdioAlbum *album = [[RdioAlbum alloc] init];
      [album setKey:song[@"albumKey"]];
      [album setName:song[@"album"]];
      [album setArtist:artist];

      RdioSong *newSong = [[RdioSong alloc] init];
      [newSong setKey:song[@"key"]];
      [newSong setName:song[@"name"]];
      [newSong setAlbumArt:song[@"icon"]];
      [newSong setAlbum:album];
      [songs addObject:newSong];
    }
    [newPlaylist setSongs:songs];
    
    [playlists addObject:newPlaylist];
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
  return playlists.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
  UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"PlaylistCell"];
  if (!cell) {
    cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"PlaylistCell"];
  }
  RdioPlaylist *playlist = (RdioPlaylist *)[playlists objectAtIndex:indexPath.row];
  [cell.textLabel setText:playlist.name];
  return cell;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
  RdioPlaylist *playlist = (RdioPlaylist *)[playlists objectAtIndex:indexPath.row];

  RdioSongsViewController *viewController = [[RdioSongsViewController alloc] initWithSongs:playlist.songs];
  [self.navigationController pushViewController:viewController animated:YES];
}

@end
