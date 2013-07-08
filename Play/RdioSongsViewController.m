//
//  RdioSongsViewController.m
//  Play
//
//  Created by Nathan Borror on 7/7/13.
//  Copyright (c) 2013 Nathan Borror. All rights reserved.
//

#import "RdioSongsViewController.h"
#import "PLNowPlayingViewController.h"
#import "RdioSong.h"

@interface RdioSongsViewController ()
{
  NSArray *songs;
}
@end

@implementation RdioSongsViewController

- (id)initWithSongs:(NSArray *)aSongs
{
  if (self = [super init]) {
    [self setTitle:@"Songs"];

    songs = aSongs;

    // Now Playing Button
    UIBarButtonItem *nowPlayingButton = [[UIBarButtonItem alloc] initWithTitle:@"Playing" style:UIBarButtonItemStyleDone target:self action:@selector(nowPlaying)];
    [self.navigationItem setRightBarButtonItem:nowPlayingButton];

    [self.tableView reloadData];
  }
  return self;
}

- (void)nowPlaying
{
  PLNowPlayingViewController *viewController = [[PLNowPlayingViewController alloc] init];
  UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:viewController];
  [self.navigationController presentViewController:navController animated:YES completion:nil];
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
  return songs.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
  UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"PlaylistCell"];
  if (!cell) {
    cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"PlaylistCell"];
  }
  RdioSong *song = (RdioSong *)[songs objectAtIndex:indexPath.row];
  [cell.textLabel setText:song.name];
  return cell;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
  RdioSong *song = (RdioSong *)[songs objectAtIndex:indexPath.row];

  PLNowPlayingViewController *viewController = [[PLNowPlayingViewController alloc] initWithRdioSong:song];
  UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:viewController];
  [self.navigationController presentViewController:navController animated:YES completion:nil];
}

@end