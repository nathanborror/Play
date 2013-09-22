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
  UITableView *_libraryTableView;
  NSArray *_sourceList;
}

- (id)init
{
  if (self = [super init]) {
    _sourceList = @[
      [[PLSource alloc] initWithName:@"Playlists" selection:nil],
      [[PLSource alloc] initWithName:@"Rdio" selection:^(){
        RdioPlaylistViewController *viewController = [[RdioPlaylistViewController alloc] init];
        [self.navigationController pushViewController:viewController animated:YES];
      }],
      [[PLSource alloc] initWithName:@"Radio Stations" selection:nil],
      [[PLSource alloc] initWithName:@"Line In" selection:^() {
        if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
          PLNowPlayingViewController *viewController = [[PLNowPlayingViewController alloc] initWithLineIn:[[SonosInputStore sharedStore] master]];
          UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:viewController];
          [self.navigationController presentViewController:navController animated:YES completion:nil];
        } else {
          [self.navigationController popViewControllerAnimated:YES];
        }
      }]
    ];
  }
  return self;
}

- (void)viewDidLoad
{
  [super viewDidLoad];

  [self setTitle:@"Library"];

  _libraryTableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
  [_libraryTableView setDelegate:self];
  [_libraryTableView setDataSource:self];
  [_libraryTableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"PLLibraryTableViewCell"];
  [self.view addSubview:_libraryTableView];
}

- (void)viewDidLayoutSubviews
{
  [super viewDidLayoutSubviews];

  [_libraryTableView setFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.bounds), CGRectGetHeight(self.view.bounds))];
}

#pragma mark - UITableViewController

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
  return [_sourceList count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
  PLSource *source = [_sourceList objectAtIndex:indexPath.row];
  UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"PLLibraryTableViewCell"];
  [cell.textLabel setText:source.name];
  return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
  PLSource *source = [_sourceList objectAtIndex:indexPath.row];
  if (source.selectionBlock == nil) {
    PLPlaylistsViewController *viewController = [[PLPlaylistsViewController alloc] init];
    [self.navigationController pushViewController:viewController animated:YES];
  } else {
    [source selectionBlock](nil);
  }
}

@end
