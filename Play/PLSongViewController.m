//
//  PLSongViewController.m
//  Play
//
//  Created by Nathan Borror on 1/1/13.
//  Copyright (c) 2013 Nathan Borror. All rights reserved.
//

#import "PLSongViewController.h"
#import "PLSong.h"
#import "PLNowPlayingViewController.h"

@interface PLSongViewController ()
{
  NSArray *songs;
  UITableView *songTableView;
}
@end

@implementation PLSongViewController

- (id)init
{
  return [self initWithSongs:nil];
}

- (id)initWithSongs:(NSArray *)aSongs
{
  self = [super init];
  if (self) {
    if (aSongs) {
      songs = aSongs;

      songTableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
      [songTableView setDelegate:self];
      [songTableView setDataSource:self];
      [songTableView setAutoresizesSubviews:YES];
      [self.view addSubview:songTableView];
    }
  }
  return self;
}

#pragma mark - UITableViewController

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
  return [songs count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
  MPMediaItem *item = [songs objectAtIndex:indexPath.row];
  UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"PLSongTableViewCell"];
  if (!cell) {
    cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"PLSongTableViewCell"];
  }
  [cell.textLabel setText:[item valueForProperty:MPMediaItemPropertyTitle]];
  UIImage *albumArt = [[item valueForProperty:MPMediaItemPropertyArtwork] imageWithSize:CGSizeMake(CGRectGetHeight(cell.bounds), CGRectGetHeight(cell.bounds))];
  [cell.imageView setImage:albumArt];

  return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
  MPMediaItem *item = [songs objectAtIndex:indexPath.row];
  MPMediaItemArtwork *artwork = [item valueForProperty:MPMediaItemPropertyArtwork];
  PLSong *song = [[PLSong alloc] initWithArtist:[item valueForProperty:MPMediaItemPropertyAlbumArtist]
                                          album:[item valueForProperty:MPMediaItemPropertyArtist]
                                          title:[item valueForProperty:MPMediaItemPropertyTitle]
                                            uri:[[item valueForProperty:MPMediaItemPropertyAssetURL] absoluteString]
                                       albumArt: [artwork imageWithSize:CGSizeMake(320, 320)]
                                       duration:@"0:00:00"];

  PLNowPlayingViewController *viewController = [[PLNowPlayingViewController alloc] initWithSong:song];
  UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:viewController];
  [self.navigationController presentViewController:navController animated:YES completion:nil];
}

@end
