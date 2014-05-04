//
//  PLLibraryViewController.m
//  Play
//
//  Created by Nathan Borror on 1/1/13.
//  Copyright (c) 2013 Nathan Borror. All rights reserved.
//

#import "PLLibraryViewController.h"
#import "PLNowPlayingViewController.h"
#import "PLPlaylistsViewController.h"
#import "PLNowPlayingViewController.h"
#import "NBKit/NBArrayDataSource.h"
#import "PLSource.h"

#import <SonosKit/SonosController.h>

@implementation PLLibraryViewController {
  UITableView *_libraryTableView;
  NSArray *_sourceList;
  SonosController *_controller;
  NBArrayDataSource *_delegate;
}

- (instancetype)initWithController:(SonosController *)controller
{
  if (self = [super init]) {
    _controller = controller;
    _sourceList = @[
      [[PLSource alloc] initWithName:@"Playlists" selection:nil],
      [[PLSource alloc] initWithName:@"Radio Stations" selection:nil],
      [[PLSource alloc] initWithName:@"Line In" selection:nil]
    ];
  }
  return self;
}

- (void)viewDidLoad
{
  [super viewDidLoad];

  [self setTitle:@"Library"];

  _delegate = [[NBArrayDataSource alloc] initWithItems:_sourceList cellIdentifier:@"PLLibraryTableViewCell" configureCellBlock:^(UITableViewCell *cell, PLSource *source) {
    [cell.textLabel setText:source.name];
  }];

  _libraryTableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
  [_libraryTableView setDelegate:self];
  [_libraryTableView setDataSource:_delegate];
  [_libraryTableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"PLLibraryTableViewCell"];
  [self.view addSubview:_libraryTableView];
}

- (void)viewDidLayoutSubviews
{
  [super viewDidLayoutSubviews];

  [_libraryTableView setFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.bounds), CGRectGetHeight(self.view.bounds))];
}

- (void)viewWillAppear:(BOOL)animated
{
  [super viewWillAppear:animated];

  [self.navigationController setNavigationBarHidden:NO animated:YES];
}

#pragma mark - UITableViewDelegate

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
