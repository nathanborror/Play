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
  UITableView *queue;
  NSMutableArray *items;
}

- (id)init
{
  if (self = [super init]) {
    [self setTitle:@"Next Up"];
    [self.view setBackgroundColor:[UIColor whiteColor]];

    items = [[NSMutableArray alloc] init];

    queue = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
    [queue registerClass:[PLQueueCell class] forCellReuseIdentifier:@"PLQueueCell"];
    [queue setDelegate:self];
    [queue setDataSource:self];
    [self.view addSubview:queue];
  }
  return self;
}

- (void)viewDidLoad
{
  [super viewDidLoad];

  UIBarButtonItem *done = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(done)];
  [self.navigationItem setRightBarButtonItem:done];
}

- (void)done
{
  [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
  return [items count];
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
