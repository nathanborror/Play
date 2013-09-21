//
//  PLNextUpViewController.m
//  Play
//
//  Created by Nathan Borror on 9/4/13.
//  Copyright (c) 2013 Nathan Borror. All rights reserved.
//

#import "PLNextUpViewController.h"
#import "PLQueueCell.h"

@implementation PLNextUpViewController {
  UITableView *_queue;
  NSMutableArray *_items;
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
  [self.view setBackgroundColor:[UIColor whiteColor]];

  _queue = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
  [_queue registerClass:[PLQueueCell class] forCellReuseIdentifier:@"PLQueueCell"];
  [_queue setDelegate:self];
  [_queue setDataSource:self];
  [self.view addSubview:_queue];

  UIBarButtonItem *done = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(done)];
  [self.navigationItem setRightBarButtonItem:done];
}

- (void)viewDidLayoutSubviews
{
  [super viewDidLayoutSubviews];

  [_queue setFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.bounds), CGRectGetHeight(self.view.bounds))];
}

- (void)done
{
  [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
  return [_items count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
  PLQueueCell *cell = (PLQueueCell *)[tableView dequeueReusableCellWithIdentifier:@"PLQueueCell"];
  return cell;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{

}

@end
