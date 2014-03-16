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
#import "PLInputStore.h"
#import "PLInput.h"
#import "SonosController.h"
#import "RdioPlaylistViewController.h"
#import "NBKit/NBArrayDataSource.h"

@implementation PLLibraryViewController {
  UITableView *_libraryTableView;
  NSArray *_sourceList;
  PLInput *_input;
  NBArrayDataSource *_delegate;
}

- (instancetype)initWithInput:(PLInput *)input
{
  if (self = [super init]) {
    if (input) {
      _input = input;
    } else {
      _input = [[PLInputStore sharedStore] master];
    }

    _sourceList = @[
      [[PLSource alloc] initWithName:@"Playlists" selection:nil],
      [[PLSource alloc] initWithName:@"Rdio" selection:^(){
        RdioPlaylistViewController *viewController = [[RdioPlaylistViewController alloc] init];
        [self.navigationController pushViewController:viewController animated:YES];
      }],
      [[PLSource alloc] initWithName:@"Radio Stations" selection:nil],
      [[PLSource alloc] initWithName:@"Line In" selection:^() {
        [[SonosController sharedController] lineIn:_input completion:nil];
        [self dismissViewControllerAnimated:YES completion:nil];
      }]
    ];
  }
  return self;
}

- (void)viewDidLoad
{
  [super viewDidLoad];

  [self setTitle:@"Library"];

  UIBarButtonItem *done = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(done:)];
  [self.navigationItem setRightBarButtonItem:done];

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

- (void)done:(id)sender
{
  [self dismissViewControllerAnimated:YES completion:nil];
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
