//
//  PLPlaylistsViewController.m
//  Play
//
//  Created by Nathan Borror on 1/1/13.
//  Copyright (c) 2013 Nathan Borror. All rights reserved.
//

#import "PLPlaylistsViewController.h"
#import "PLSongViewController.h"

@interface PLPlaylistsViewController ()
{
  UITableView *playlists;
  NSArray *playlistsCollection;
}
@end

@implementation PLPlaylistsViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
  self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
  if (self) {
    [self.navigationItem setTitle:@"Playlists"];
    
    playlists = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
    [playlists setDelegate:self];
    [playlists setDataSource:self];
    [self.view addSubview:playlists];

    MPMediaQuery *query = [MPMediaQuery playlistsQuery];
    playlistsCollection = [query collections];
  }
  return self;
}

#pragma mark - UITableViewController

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
  return [playlistsCollection count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
  MPMediaPlaylist *playlist = [playlistsCollection objectAtIndex:indexPath.row];
  UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"PLPlaylistsTableViewCell"];
  if (!cell) {
    cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"PLPlaylistsTableViewCell"];
  }
  [cell.textLabel setText:[playlist valueForProperty:MPMediaPlaylistPropertyName]];
  return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
  MPMediaPlaylist *playlist = [playlistsCollection objectAtIndex:indexPath.row];
  PLSongViewController *viewController = [[PLSongViewController alloc] initWithSongs:[playlist items]];
  [self.navigationController pushViewController:viewController animated:YES];
}

@end
