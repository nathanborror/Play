//
//  PLPlaylistsViewController.m
//  Play
//
//  Created by Nathan Borror on 1/1/13.
//  Copyright (c) 2013 Nathan Borror. All rights reserved.
//

#import "PLPlaylistsViewController.h"
#import "PLSongViewController.h"

@implementation PLPlaylistsViewController {
  UITableView *_playlists;
  NSArray *_playlistsCollection;
}

- (id)init
{
  if (self = [super init]) {
    MPMediaQuery *query = [MPMediaQuery playlistsQuery];
    _playlistsCollection = [query collections];
  }
  return self;
}

- (void)viewDidLoad
{
  [super viewDidLoad];

  [self setTitle:@"Playlists"];

  _playlists = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
  [_playlists setDelegate:self];
  [_playlists setDataSource:self];
  [_playlists registerClass:[UITableViewCell class] forCellReuseIdentifier:@"PLPlaylistsTableViewCell"];
  [self.view addSubview:_playlists];
}

- (void)viewDidLayoutSubviews
{
  [super viewDidLayoutSubviews];

  [_playlists setFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.bounds), CGRectGetHeight(self.view.bounds))];
}

#pragma mark - UITableViewController

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
  return [_playlistsCollection count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
  MPMediaPlaylist *playlist = [_playlistsCollection objectAtIndex:indexPath.row];
  UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"PLPlaylistsTableViewCell"];
  [cell.textLabel setText:[playlist valueForProperty:MPMediaPlaylistPropertyName]];
  return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
  MPMediaPlaylist *playlist = [_playlistsCollection objectAtIndex:indexPath.row];
  PLSongViewController *viewController = [[PLSongViewController alloc] initWithSongs:[playlist items]];
  [self.navigationController pushViewController:viewController animated:YES];
}

@end
