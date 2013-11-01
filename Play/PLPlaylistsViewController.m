//
//  PLPlaylistsViewController.m
//  Play
//
//  Created by Nathan Borror on 1/1/13.
//  Copyright (c) 2013 Nathan Borror. All rights reserved.
//

#import "PLPlaylistsViewController.h"
#import "PLSongViewController.h"
#import "NBKit/NBArrayDataSource.h"

@implementation PLPlaylistsViewController {
  UITableView *_playlists;
  NSArray *_playlistsCollection;
  NBArrayDataSource *_datasource;
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

  _datasource = [[NBArrayDataSource alloc] initWithItems:_playlistsCollection cellIdentifier:@"PLPlaylistCell" configureCellBlock:^(UITableViewCell *cell, MPMediaPlaylist *playlist) {
    [cell.textLabel setText:[playlist valueForProperty:MPMediaPlaylistPropertyName]];
  }];

  _playlists = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
  [_playlists setDelegate:self];
  [_playlists setDataSource:_datasource];
  [_playlists registerClass:[UITableViewCell class] forCellReuseIdentifier:@"PLPlaylistCell"];
  [self.view addSubview:_playlists];
}

- (void)viewDidLayoutSubviews
{
  [super viewDidLayoutSubviews];

  [_playlists setFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.bounds), CGRectGetHeight(self.view.bounds))];
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
  MPMediaPlaylist *playlist = [_playlistsCollection objectAtIndex:indexPath.row];
  PLSongViewController *viewController = [[PLSongViewController alloc] initWithSongs:[playlist items]];
  [self.navigationController pushViewController:viewController animated:YES];
}

@end
