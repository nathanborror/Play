//
//  ViewController.m
//  Play
//
//  Created by Nathan Borror on 12/30/12.
//  Copyright (c) 2012 Nathan Borror. All rights reserved.
//

#import "PLNowPlayingViewController.h"
#import "PLLibraryViewController.h"

#import "PLVolumeCell.h"
#import "PLVolumeHeader.h"

#import "UIColor+Common.h"
#import "UIFont+Common.h"

#import <SonosKit/SonosController.h>
#import <SonosKit/SonosControllerStore.h>

@implementation PLNowPlayingViewController {
  NSArray *_data;
  UITableView *_volumeTable;
}

- (instancetype)init
{
  if (self = [super init]) {
    [self setTitle:@"Volume"];
    [self.view setBackgroundColor:[UIColor whiteColor]];
  }
  return self;
}

- (void)viewDidLoad
{
  [super viewDidLoad];

  _volumeTable = [[UITableView alloc] initWithFrame:CGRectZero];
  [_volumeTable registerClass:[PLVolumeCell class] forCellReuseIdentifier:@"PLVolumeCell"];
  [_volumeTable setDelegate:self];
  [_volumeTable setDataSource:self];
  [_volumeTable setRowHeight:96];
  [_volumeTable setSeparatorStyle:UITableViewCellSeparatorStyleNone];
  [_volumeTable setContentInset:UIEdgeInsetsMake(0, 0, 96.0, 0)];
  [self.view addSubview:_volumeTable];

  _data = [[SonosControllerStore sharedStore] data];
  [[SonosControllerStore sharedStore] addObserver:self forKeyPath:@"data" options:NSKeyValueObservingOptionNew context:nil];
}

- (void)viewDidLayoutSubviews
{
  [super viewDidLayoutSubviews];
  [_volumeTable setFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.frame), CGRectGetHeight(self.view.frame))];
}

- (void)viewWillAppear:(BOOL)animated
{
  [super viewWillAppear:animated];
  [self.navigationController setNavigationBarHidden:YES animated:YES];
}

- (void)showLibrary:(PLVolumeHeader *)header
{
  PLLibraryViewController *viewController = [[PLLibraryViewController alloc] initWithController:header.controller];
  [self.navigationController pushViewController:viewController animated:YES];
}

- (UITabBarItem *)tabBarItem
{
  return [[UITabBarItem alloc] initWithTitle:@"Playing" image:[UIImage imageNamed:@"PlayingTab"] selectedImage:[UIImage imageNamed:@"PlayingTabSelected"]];
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
  return _data.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
  NSArray *controllers = [_data objectAtIndex:section];
  return controllers.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
  NSArray *controllers = [_data objectAtIndex:indexPath.section];
  SonosController *controller = [controllers objectAtIndex:indexPath.row];

  PLVolumeCell *cell = (PLVolumeCell *)[tableView dequeueReusableCellWithIdentifier:@"PLVolumeCell"];
  [cell setController:controller];
  return cell;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
  NSArray *controllers = [_data objectAtIndex:section];
  SonosController *coordinator = [controllers lastObject];

  PLVolumeHeader *header = [[PLVolumeHeader alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.bounds), 64)];
  [header setController:coordinator];
  [header addTarget:self action:@selector(showLibrary:) forControlEvents:UIControlEventTouchUpInside];

  return header;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
  return 64;
}

#pragma mark - KVO

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
  if ([keyPath isEqualToString:@"data"]) {
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
      _data = [[SonosControllerStore sharedStore] data];
      [_volumeTable reloadData];
    }];
  }
}

@end
