//
//  PLSpeakersViewController.m
//  Play
//
//  Created by Nathan Borror on 1/1/13.
//  Copyright (c) 2013 Nathan Borror. All rights reserved.
//

#import "PLSpeakersViewController.h"
#import "PLLibraryViewController.h"
#import "PLInputCell.h"
#import "PLSectionHeaderView.h"
#import "PLNowPlayingViewController.h"
#import "PLInput.h"
#import "PLInputStore.h"
#import "SonosController.h"
#import "NBReorderableCollectionViewLayout.h"
#import "UIColor+Common.h"
#import "UIFont+Common.h"

static NSString *kInputCell = @"PLInputCell";
static NSString *kSectionHeader = @"PLSectionHeader";

@implementation PLSpeakersViewController {
  UIScrollView *_scrollView;
  CGPoint _cellPanCoordBegan;
  UIView *_paired;
  NSArray *_data;
  UICollectionView *_collectionView;
  NSIndexPath *_selectedSnapshot;
  NSTimer *_transitionTimer;
  UIButton *_nowPlayingButton;

  NBReorderableCollectionViewLayout *_layout;
  BOOL _isExpanded;
}

- (void)viewDidLoad
{
  [super viewDidLoad];

  [self setTitle:@"Speakers"];
  [self.view setBackgroundColor:[UIColor blackColor]];

  NSArray *groupings = [[PLInputStore sharedStore] allInputsGrouped];
  NSMutableArray *data = [NSMutableArray new];
  _isExpanded = YES;

  // Add all master/input sections
  for (NSDictionary *grouping in groupings) {
    [data addObject:grouping];
  }

  _data = data;

  _layout = [[NBReorderableCollectionViewLayout alloc] init];
  [_layout setMinimumLineSpacing:0];
  [_layout setMinimumInteritemSpacing:0];
  [_layout setHeaderReferenceSize:CGSizeMake(CGRectGetWidth(self.view.bounds), 64)];
  [_layout setItemSize:CGSizeMake(160, 100)];

  _collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:_layout];
  [_collectionView setClipsToBounds:NO];
  [_collectionView registerClass:[PLInputCell class] forCellWithReuseIdentifier:kInputCell];
  [_collectionView registerClass:[PLSectionHeaderView class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:kSectionHeader];
  [_collectionView setDelegate:self];
  [_collectionView setDataSource:self];
  [_collectionView setBackgroundColor:[UIColor clearColor]];
  [self.view addSubview:_collectionView];

  _nowPlayingButton = [[UIButton alloc] initWithFrame:CGRectMake(0, CGRectGetHeight(self.view.bounds)-64, CGRectGetWidth(self.view.bounds), 64)];
  [_nowPlayingButton setBackgroundColor:[UIColor whiteColor]];
  [_nowPlayingButton addTarget:self action:@selector(dismiss) forControlEvents:UIControlEventTouchUpInside];
  [_nowPlayingButton setTitleColor:[UIColor text] forState:UIControlStateNormal];
  [_nowPlayingButton setTitle:@"Now Playing" forState:UIControlStateNormal];
  [_nowPlayingButton setContentHorizontalAlignment:UIControlContentHorizontalAlignmentLeft];
  [_nowPlayingButton setTitleEdgeInsets:UIEdgeInsetsMake(0, 16, 0, 0)];
  [_nowPlayingButton.titleLabel setTextAlignment:NSTextAlignmentLeft];
  [_nowPlayingButton.titleLabel setFont:[UIFont header]];
  [_nowPlayingButton setAlpha:0];
  [self.view addSubview:_nowPlayingButton];
}

- (void)handleSectionTap:(UITapGestureRecognizer *)recognizer
{
  PLNowPlayingViewController *viewController = [[PLNowPlayingViewController alloc] init];
  UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:viewController];
  [self presentViewController:navController animated:YES completion:nil];
}

- (void)viewWillLayoutSubviews
{
  [super viewWillLayoutSubviews];
  [_collectionView setFrame:self.view.bounds];
}

- (void)viewDidAppear:(BOOL)animated
{
  [super viewDidAppear:animated];

  [_nowPlayingButton setAlpha:1];
}

- (void)dismiss
{
  [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - UISplitViewControllerDelegate

- (BOOL)splitViewController:(UISplitViewController *)svc shouldHideViewController:(UIViewController *)vc inOrientation:(UIInterfaceOrientation)orientation
{
  return NO;
}

#pragma mark - NBReorderableCollectionViewDataSource

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
  return _data.count;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
  NSDictionary *obj = [_data objectAtIndex:section];
  NSArray *inputs = (NSArray *)obj[@"inputs"];
  return inputs.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
  NSDictionary *section = [_data objectAtIndex:indexPath.section];
  PLInputCell *cell = (PLInputCell *)[collectionView dequeueReusableCellWithReuseIdentifier:kInputCell forIndexPath:indexPath];
  PLInput *input = [(NSArray *)section[@"inputs"] objectAtIndex:indexPath.row];
  [cell setInput:input];
  return cell;
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
{
  UICollectionReusableView *reusableview;
  NSDictionary *group = [_data objectAtIndex:indexPath.section];

  if ([kind isEqualToString:UICollectionElementKindSectionHeader]) {
    PLSectionHeaderView *header = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:kSectionHeader forIndexPath:indexPath];
    [header setTitle:@"Unknown"];
    [header setGroup:group];

    PLInput *master = (PLInput *)group[@"master"];

    // Try to get the title of whatever's playing
    [[SonosController sharedController] mediaInfo:master completion:^(NSDictionary *response, NSError *error) {
      if (!error) {
        NSDictionary *info = response[@"u:GetMediaInfoResponse"];
        NSString *title = info[@"CurrentURIMetaData"][@"dc:title"][@"text"];
        if (!title) {
          title = info[@"CurrentURI"][@"text"];
        }
        if (!title) {
          title = @"No Music";
        }
        [header setTitle:title];
      }
    }];

    // Add tap gesture
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleSectionTap:)];
    [tap setDelaysTouchesBegan:YES];
    [tap setNumberOfTapsRequired:1];
    [header addGestureRecognizer:tap];

    reusableview = header;
  }

  return reusableview;
}

- (BOOL)collectionView:(UICollectionView *)collectionView canMoveItemAtIndexPath:(NSIndexPath *)indexPath
{
  return YES;
}

- (BOOL)collectionView:(UICollectionView *)collectionView canMoveItemAtIndexPath:(NSIndexPath *)indexPath toIndexPath:(NSIndexPath *)toIndexPath
{
  return YES;
}

- (void)collectionView:(UICollectionView *)collectionView itemAtIndexPath:(NSIndexPath *)fromIndexPath willMoveToIndexPath:(NSIndexPath *)toIndexPath
{
  NSMutableArray *data1 = [_data objectAtIndex:fromIndexPath.section][@"inputs"];
  NSMutableArray *data2 = [_data objectAtIndex:toIndexPath.section][@"inputs"];

  PLInput *master = [_data objectAtIndex:toIndexPath.section][@"master"];
  PLInput *input = [data1 objectAtIndex:fromIndexPath.item];

  [data1 removeObjectAtIndex:fromIndexPath.item];
  [data2 insertObject:input atIndex:toIndexPath.item];

  [[PLInputStore sharedStore] pairInput:input withInput:master];
}

#pragma mark - UICollectionViewDelegate

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
  NSDictionary *section = [_data objectAtIndex:indexPath.section];
  PLInput *input = [(NSArray *)section[@"inputs"] objectAtIndex:indexPath.row];
  PLLibraryViewController *viewController = [[PLLibraryViewController alloc] initWithInput:input];
  UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:viewController];

  if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
    [navController setModalPresentationStyle:UIModalPresentationFormSheet];
  }

  [self presentViewController:navController animated:YES completion:nil];
}

@end
