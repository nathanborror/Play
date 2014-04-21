//
//  ViewController.m
//  Play
//
//  Created by Nathan Borror on 12/30/12.
//  Copyright (c) 2012 Nathan Borror. All rights reserved.
//

#import "PLNowPlayingViewController.h"
#import "PLSpeakersViewController.h"
#import "PLVolumeCell.h"
#import "UIColor+Common.h"
#import "UIFont+Common.h"
#import "DragDownAnimator.h"

#import <SonosKit/SonosController.h>
#import <SonosKit/SonosControllerStore.h>

static const CGFloat kMarginLeft = 16.0;

@implementation PLNowPlayingViewController {
  NSArray *_data;
  UITableView *_volumeTable;
}

- (void)viewDidLoad
{
  [super viewDidLoad];

  if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
    [self.view setBackgroundColor:[UIColor blackColor]];
  } else {
    [self.view setBackgroundColor:[UIColor whiteColor]];
  }

  _volumeTable = [[UITableView alloc] initWithFrame:CGRectZero];
  [_volumeTable registerClass:[PLVolumeCell class] forCellReuseIdentifier:@"PLVolumeCell"];
  [_volumeTable setDelegate:self];
  [_volumeTable setDataSource:self];
  [_volumeTable setBackgroundColor:[UIColor clearColor]];
  [_volumeTable setRowHeight:96];
  [_volumeTable setSeparatorStyle:UITableViewCellSeparatorStyleNone];
  [_volumeTable setContentInset:UIEdgeInsetsMake(0, 0, 0, 0)];
  [self.view addSubview:_volumeTable];

  UIView *footer = [[UIView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.bounds), 128)];
  [footer setBackgroundColor:[UIColor whiteColor]];
  [_volumeTable setTableFooterView:footer];

  _data = [[SonosControllerStore sharedStore] data];
  [[SonosControllerStore sharedStore] addObserver:self forKeyPath:@"allControllers" options:NSKeyValueObservingOptionNew context:nil];
}

- (void)viewDidLayoutSubviews
{
  [super viewDidLayoutSubviews];
  [_volumeTable setFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.frame), CGRectGetHeight(self.view.frame))];
}

- (void)viewDidAppear:(BOOL)animated
{
  [super viewDidAppear:animated];

  NSLog(@"Now playing view did appear");
}

- (void)showBrowser
{
  NSLog(@"browser");
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

  UIView *sectionHeader = [[UIView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.bounds), 64)];
  [sectionHeader setBackgroundColor:[UIColor colorWithWhite:1 alpha:1]];

  UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(kMarginLeft, 12, CGRectGetWidth(self.view.bounds)-32, 44)];
  [titleLabel setTextColor:[UIColor text]];
  [titleLabel setFont:[UIFont header]];
  [titleLabel setText:@"Unknown"];
  [sectionHeader addSubview:titleLabel];

  UIImageView *chevron = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Chevron"]];
  [chevron setFrame:CGRectMake(CGRectGetWidth(sectionHeader.bounds)-44, (CGRectGetHeight(sectionHeader.bounds)/2)-22, 44, 44)];
  [sectionHeader addSubview:chevron];

  UIView *separator = [[UIView alloc] initWithFrame:CGRectMake(kMarginLeft, CGRectGetHeight(sectionHeader.bounds), CGRectGetWidth(sectionHeader.bounds), .5)];
  [separator setBackgroundColor:[UIColor borderColor]];
  [sectionHeader addSubview:separator];

  UIButton *button = [[UIButton alloc] initWithFrame:sectionHeader.bounds];
  [button addTarget:self action:@selector(showBrowser) forControlEvents:UIControlEventTouchUpInside];
  [sectionHeader addSubview:button];

  [coordinator trackInfo:^(NSDictionary *track, NSDictionary *response, NSError *error) {
    [titleLabel setText:track[@"creator"][@"text"] ? track[@"creator"][@"text"] : @"Unknown"];
  }];

  return sectionHeader;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
  return 64;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
  if (scrollView.contentOffset.y < -20.0 && [[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
    PLSpeakersViewController *viewController = [[PLSpeakersViewController alloc] init];
    [viewController setModalPresentationStyle:UIModalPresentationCustom];
    [viewController setTransitioningDelegate:self];
    [self presentViewController:viewController animated:YES completion:nil];
  }
}

#pragma mark - UIViewControllerTransitioningDelegate

- (id<UIViewControllerAnimatedTransitioning>)animationControllerForPresentedController:(UIViewController *)presented presentingController:(UIViewController *)presenting sourceController:(UIViewController *)source
{
  DragDownAnimator *animator = [DragDownAnimator new];
  [animator setPresenting:YES];
  return animator;
}

- (id<UIViewControllerAnimatedTransitioning>)animationControllerForDismissedController:(UIViewController *)dismissed
{
  DragDownAnimator *animator = [DragDownAnimator new];
  [animator setPresenting:NO];
  return animator;
}

#pragma mark - KVO

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
  if ([keyPath isEqualToString:@"allControllers"]) {
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
      _data = [[SonosControllerStore sharedStore] data];
      [_volumeTable reloadData];
    }];
  }
}

@end
