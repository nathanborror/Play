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

@implementation RdioPlaylistViewController {
  Rdio *_rdio;
  UILocalizedIndexedCollation *_collation;
  NSMutableArray *_playlists;
}

- (instancetype)init
{
  if (self = [super init]) {
    _playlists = [[NSMutableArray alloc] init];

    if (_playlists.count == 0) {
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

  [self setTitle:@"Playlists"];

  UIBarButtonItem *nowPlayingButton = [[UIBarButtonItem alloc] initWithTitle:@"Playing" style:UIBarButtonItemStyleDone target:self action:@selector(nowPlaying)];
  [self.navigationItem setRightBarButtonItem:nowPlayingButton];
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
  [_rdio callAPIMethod:@"getPlaylists" withParameters:nil delegate:self];
}

#pragma mark - RdioDelegate

- (void)rdioDidAuthorizeUser:(NSDictionary *)user withAccessToken:(NSString *)accessToken
{
  NSLog(@"Rdio: Authorized User");

  [[NSUserDefaults standardUserDefaults] setObject:accessToken forKey:@"rdioAccessKey"];
  [[NSUserDefaults standardUserDefaults] synchronize];

  if (_playlists.count == 0) {
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
    [newPlaylist setKey:playlist[@"key"]];
    [newPlaylist setName:playlist[@"name"]];
    [newPlaylist setUrl:playlist[@"url"]];
    [_playlists addObject:newPlaylist];
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
  return _playlists.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
  UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"PlaylistCell"];
  if (!cell) {
    cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"PlaylistCell"];
  }
  RdioPlaylist *playlist = (RdioPlaylist *)[_playlists objectAtIndex:indexPath.row];
  [cell.textLabel setText:playlist.name];
  return cell;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
  RdioPlaylist *playlist = (RdioPlaylist *)[_playlists objectAtIndex:indexPath.row];

  RdioSongsViewController *viewController = [[RdioSongsViewController alloc] initWithPlaylist:playlist];
  [self.navigationController pushViewController:viewController animated:YES];
}

@end
