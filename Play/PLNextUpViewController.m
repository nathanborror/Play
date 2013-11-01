//
//  PLNextUpViewController.m
//  Play
//
//  Created by Nathan Borror on 9/4/13.
//  Copyright (c) 2013 Nathan Borror. All rights reserved.
//

#import "PLNextUpViewController.h"
#import "PLQueueCell.h"
#import "NBKit/NBArrayDataSource.h"

@implementation PLNextUpViewController {
  UITableView *_queue;
  NSMutableArray *_items;
  NBArrayDataSource *_datasource;
}

- (id)init
{
  if (self = [super init]) {
    _items = [[NSMutableArray alloc] init];
  }
  return self;
}

- (void)viewDidLoad
{
  [super viewDidLoad];

  [self setTitle:@"Next Up"];

  _datasource = [[NBArrayDataSource alloc] initWithItems:_items cellIdentifier:@"PLQueueCell" configureCellBlock:^(id cell, id item) {
    //
  }];

  _queue = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
  [_queue registerClass:[PLQueueCell class] forCellReuseIdentifier:@"PLQueueCell"];
  [_queue setDelegate:self];
  [_queue setDataSource:_datasource];
  [self.view addSubview:_queue];
}

- (void)viewDidLayoutSubviews
{
  [super viewDidLayoutSubviews];
  [_queue setFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.bounds), CGRectGetHeight(self.view.bounds))];
}

- (UITabBarItem *)tabBarItem
{
  return [[UITabBarItem alloc] initWithTitle:@"Next Up" image:[UIImage imageNamed:@"PLNextUpTab"] selectedImage:[UIImage imageNamed:@"PLNextUpTabSelected"] ];
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{

}

@end
