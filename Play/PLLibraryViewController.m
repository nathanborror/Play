//
//  PLLibraryViewController.m
//  Play
//
//  Created by Nathan Borror on 1/1/13.
//  Copyright (c) 2013 Nathan Borror. All rights reserved.
//

#import "PLLibraryViewController.h"
#import "PLPrimaryBarButtonItem.h"
#import "PLNowPlayingViewController.h"
#import "PLNavigationController.h"
#import "PLSource.h"
#import "PLPlaylistsViewController.h"

@interface PLLibraryViewController ()
{
  UITableView *libraryTableView;
  NSArray *sourceList;
}
@end

@implementation PLLibraryViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
  self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
  if (self) {
    [self.navigationItem setTitle:@"Library"];

    // Now Playing Button
    UIBarButtonItem *nowPlayingButton = [[PLPrimaryBarButtonItem alloc] initWithTitle:@"Playing" style:UIBarButtonItemStyleDone target:self action:@selector(nowPlaying)];
    [self.navigationItem setRightBarButtonItem:nowPlayingButton];

    // Table
    libraryTableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
    [libraryTableView setDelegate:self];
    [libraryTableView setDataSource:self];
    [self.view addSubview:libraryTableView];

    // Library Items
    // TODO: Make this dynamic
    sourceList = @[
      [[PLSource alloc] initWithName:@"Playlists"],
      [[PLSource alloc] initWithName:@"Rdio"],
      [[PLSource alloc] initWithName:@"Radio Stations"]
    ];
  }
  return self;
}

- (void)viewDidLoad
{
  [super viewDidLoad];
}

- (void)nowPlaying
{
  PLNowPlayingViewController *viewController = [[PLNowPlayingViewController alloc] init];
  UINavigationController *navController = [[PLNavigationController alloc] initWithRootViewController:viewController];
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
  if (!cell) {
    cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"PLLibraryTableViewCell"];
  }
  [cell.textLabel setText:source.name];
  return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
  PLPlaylistsViewController *viewController = [[PLPlaylistsViewController alloc] init];
  [self.navigationController pushViewController:viewController animated:YES];
}

@end
