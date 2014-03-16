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
#import "SonosController.h"
#import "PLInputStore.h"
#import "PLInput.h"
#import "UIColor+Common.h"
#import "UIFont+Common.h"
#import "DragDownAnimator.h"

static const CGFloat kMarginLeft = 16.0;

@interface PLNowPlayingViewController ()
{
  SonosController *_sonos;
  NSArray *_groups;
  UITableView *_volumeTable;
}
@end

@implementation PLNowPlayingViewController

- (instancetype)init
{
  if (self = [super init]) {
    _sonos = [SonosController sharedController];
    _groups = [[PLInputStore sharedStore] allInputsGrouped];
  }
  return self;
}

- (void)viewDidLoad
{
  [super viewDidLoad];

  [self.view setBackgroundColor:[UIColor blackColor]];

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
}

- (void)viewDidLayoutSubviews
{
  [super viewDidLayoutSubviews];
  [_volumeTable setFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.frame), CGRectGetHeight(self.view.frame))];
}

- (void)showSpeakers
{
  PLSpeakersViewController *viewController = [[PLSpeakersViewController alloc] init];
  [self.navigationController presentViewController:viewController animated:NO completion:nil];
}

- (void)volume:(UISlider *)sender
{
  [_sonos volume:nil level:(int)[sender value] completion:nil];
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
  return _groups.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
  NSDictionary *group = [_groups objectAtIndex:section];
  return [(NSArray *)group[@"inputs"] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
  NSDictionary *group = [_groups objectAtIndex:indexPath.section];
  PLInput *input = [group[@"inputs"] objectAtIndex:indexPath.item];

  PLVolumeCell *cell = (PLVolumeCell *)[tableView dequeueReusableCellWithIdentifier:@"PLVolumeCell"];
  [cell setInput:input];
  return cell;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
  UIView *sectionHeader = [[UIView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.bounds), 64)];
  [sectionHeader setBackgroundColor:[UIColor colorWithWhite:1 alpha:1]];

  UILabel *title = [[UILabel alloc] initWithFrame:CGRectMake(kMarginLeft, 12, CGRectGetWidth(self.view.bounds)-32, 44)];
  [title setTextColor:[UIColor text]];
  [title setFont:[UIFont header]];
  [title setText:@"Line In"];
  [sectionHeader addSubview:title];

  UIView *separator = [[UIView alloc] initWithFrame:CGRectMake(kMarginLeft, CGRectGetHeight(sectionHeader.bounds), CGRectGetWidth(sectionHeader.bounds), .5)];
  [separator setBackgroundColor:[UIColor borderColor]];
  [sectionHeader addSubview:separator];

  return sectionHeader;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
  return 64;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
  if (scrollView.contentOffset.y < -20.0) {
    PLSpeakersViewController *viewController = [[PLSpeakersViewController alloc] init];
    [viewController setModalPresentationStyle:UIModalPresentationCustom];
    [viewController setTransitioningDelegate:self];
    [self presentViewController:viewController animated:YES completion:nil];
  }
}

#pragma mark - UIViewControllerTransitioningDelegate

- (id<UIViewControllerAnimatedTransitioning>)animationControllerForPresentedController:(UIViewController *)presented presentingController:(UIViewController *)presenting sourceController:(UIViewController *)source
{
  DragDownAnimator *animator = [[DragDownAnimator alloc] init];
  [animator setPresenting:YES];
  return animator;
}

- (id<UIViewControllerAnimatedTransitioning>)animationControllerForDismissedController:(UIViewController *)dismissed
{
  DragDownAnimator *animator = [[DragDownAnimator alloc] init];
  [animator setPresenting:NO];
  return animator;
}

@end
