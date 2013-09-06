//
//  PLLibraryViewController.m
//  Play
//
//  Created by Nathan Borror on 1/1/13.
//  Copyright (c) 2013 Nathan Borror. All rights reserved.
//

#import "PLLibraryViewController.h"
#import "PLNowPlayingViewController.h"
#import "PLSource.h"
#import "PLPlaylistsViewController.h"
#import "PLNowPlayingViewController.h"
#import "SonosInputStore.h"
#import "RdioPlaylistViewController.h"

@implementation PLLibraryViewController {
  UITableView *libraryTableView;
  NSArray *sourceList;
}

- (id)init
{
  if (self = [super init]) {
    sourceList = @[
      [[PLSource alloc] initWithName:@"Playlists" selection:nil],
      [[PLSource alloc] initWithName:@"Rdio" selection:^(){
        RdioPlaylistViewController *viewController = [[RdioPlaylistViewController alloc] init];
        [self.navigationController pushViewController:viewController animated:YES];
      }],
      [[PLSource alloc] initWithName:@"Radio Stations" selection:nil],
      [[PLSource alloc] initWithName:@"Line In" selection:^() {
        PLNowPlayingViewController *viewController = [[PLNowPlayingViewController alloc] initWithLineIn:[[SonosInputStore sharedStore] master]];
        UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:viewController];
        [self.navigationController presentViewController:navController animated:YES completion:nil];
      }]
    ];
  }
  return self;
}

- (void)viewDidLoad
{
  [super viewDidLoad];

  [self setTitle:@"Library"];

  UIBarButtonItem *nowPlayingButton = [[UIBarButtonItem alloc] initWithTitle:@"Playing" style:UIBarButtonItemStyleDone target:self action:@selector(nowPlaying)];
  [self.navigationItem setRightBarButtonItem:nowPlayingButton];

  libraryTableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
  [libraryTableView setDelegate:self];
  [libraryTableView setDataSource:self];
  [libraryTableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"PLLibraryTableViewCell"];
  [self.view addSubview:libraryTableView];
}

- (void)viewDidLayoutSubviews
{
  [super viewDidLayoutSubviews];

  [libraryTableView setFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.bounds), CGRectGetHeight(self.view.bounds))];
}

- (void)nowPlaying
{
  PLNowPlayingViewController *viewController = [[PLNowPlayingViewController alloc] init];
  UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:viewController];
  [self.navigationController presentViewController:navController animated:YES completion:nil];
}

#pragma mark - UITableViewController

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
  return [sourceList count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
  PLSource *source = [sourceList objectAtIndex:indexPath.row];
  UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"PLLibraryTableViewCell"];
  [cell.textLabel setText:source.name];
  return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
  PLSource *source = [sourceList objectAtIndex:indexPath.row];
  if (source.selectionBlock == nil) {
    PLPlaylistsViewController *viewController = [[PLPlaylistsViewController alloc] init];
    [self.navigationController pushViewController:viewController animated:YES];
  } else {
    [source selectionBlock](nil);
  }
}

@end
