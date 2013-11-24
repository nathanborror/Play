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
#import "NBKit/NBArrayDataSource.h"

@implementation PLSongViewController {
  NSArray *_songs;
  UITableView *_songTableView;
  NBArrayDataSource *_datasource;
}

- (id)init
{
  return [self initWithSongs:nil];
}

- (id)initWithSongs:(NSArray *)aSongs
{
  if (self = [super init]) {
    _songs = aSongs;
  }
  return self;
}

- (void)viewDidLoad
{
  [super viewDidLoad];

  _datasource = [[NBArrayDataSource alloc] initWithItems:_songs cellIdentifier:@"PLSongCell" configureCellBlock:^(UITableViewCell *cell, MPMediaItem *item) {
    [cell.textLabel setText:[item valueForProperty:MPMediaItemPropertyTitle]];
    UIImage *albumArt = [[item valueForProperty:MPMediaItemPropertyArtwork] imageWithSize:CGSizeMake(CGRectGetHeight(cell.bounds), CGRectGetHeight(cell.bounds))];
    [cell.imageView setImage:albumArt];
  }];

  _songTableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
  [_songTableView setDelegate:self];
  [_songTableView setDataSource:_datasource];
  [_songTableView setAutoresizesSubviews:YES];
  [_songTableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"PLSongCell"];
  [self.view addSubview:_songTableView];
}

- (void)viewDidLayoutSubviews
{
  [super viewDidLayoutSubviews];

  [_songTableView setFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.bounds), CGRectGetHeight(self.view.bounds))];
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
//  MPMediaItem *item = [_songs objectAtIndex:indexPath.row];
//  MPMediaItemArtwork *artwork = [item valueForProperty:MPMediaItemPropertyArtwork];
//  PLSong *song = [[PLSong alloc] initWithArtist:[item valueForProperty:MPMediaItemPropertyAlbumArtist]
//                                          album:[item valueForProperty:MPMediaItemPropertyArtist]
//                                          title:[item valueForProperty:MPMediaItemPropertyTitle]
//                                            uri:[[item valueForProperty:MPMediaItemPropertyAssetURL] absoluteString]
//                                       albumArt: [artwork imageWithSize:CGSizeMake(320, 320)]
//                                       duration:@"0:00:00"];

//  PLNowPlayingViewController *viewController = [[PLNowPlayingViewController alloc] initWithSong:song];
//  UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:viewController];
//  [self.navigationController presentViewController:navController animated:YES completion:nil];
}

@end
