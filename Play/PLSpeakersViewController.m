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
#import "UIColor+Common.h"
#import "UIFont+Common.h"

#import <SonosKit/SonosController.h>
#import <SonosKit/SonosControllerStore.h>

#import <DraggableCollectionView/DraggableCollectionViewFlowLayout.h>

static NSString *kInputCell = @"PLInputCell";
static NSString *kSectionHeader = @"PLSectionHeader";

@implementation PLSpeakersViewController {
  NSArray *_data;

  UIScrollView *_scrollView;
  CGPoint _cellPanCoordBegan;
  UICollectionView *_collectionView;
  UIButton *_nowPlayingButton;

  DraggableCollectionViewFlowLayout *_layout;
}

- (void)viewDidLoad
{
  [super viewDidLoad];

  [self setTitle:@"Speakers"];
  [self.view setBackgroundColor:[UIColor blackColor]];

  _layout = [[DraggableCollectionViewFlowLayout alloc] init];
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
  [_collectionView setDraggable:YES];
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

  _data = [[SonosControllerStore sharedStore] data];

  [[SonosControllerStore sharedStore] addObserver:self forKeyPath:@"data" options:NSKeyValueObservingOptionNew context:nil];
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

  if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
    [_nowPlayingButton setAlpha:1];
  }
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

#pragma mark - UICollectionViewDataSource

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
  return _data.count;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
  return [(NSArray *)[_data objectAtIndex:section] count];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
  PLInputCell *cell = (PLInputCell *)[collectionView dequeueReusableCellWithReuseIdentifier:kInputCell forIndexPath:indexPath];
  NSArray *controllers = [_data objectAtIndex:indexPath.section];
  SonosController *controller = (SonosController *)[controllers objectAtIndex:indexPath.item];
  [cell setController:controller];
  return cell;
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
{
  UICollectionReusableView *reusableview;
  NSArray *controllers = [_data objectAtIndex:indexPath.section];
  SonosController *coordinator = [controllers lastObject];

  if ([kind isEqualToString:UICollectionElementKindSectionHeader]) {
    PLSectionHeaderView *header = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:kSectionHeader forIndexPath:indexPath];
    [header setController:coordinator];

    // Add tap gesture
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleSectionTap:)];
    [tap setDelaysTouchesBegan:YES];
    [tap setNumberOfTapsRequired:1];
    [header addGestureRecognizer:tap];

    reusableview = header;
  }

  return reusableview;
}

#pragma mark - UICollectionViewDataSource_Draggable

- (BOOL)collectionView:(LSCollectionViewHelper *)collectionView canMoveItemAtIndexPath:(NSIndexPath *)indexPath
{
  return YES;
}

- (BOOL)collectionView:(UICollectionView *)collectionView canMoveItemAtIndexPath:(NSIndexPath *)indexPath toIndexPath:(NSIndexPath *)toIndexPath
{
  return YES;
}

- (void)collectionView:(UICollectionView *)collectionView moveItemAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
  NSMutableArray *data1 = [_data objectAtIndex:fromIndexPath.section];
  NSMutableArray *data2 = [_data objectAtIndex:toIndexPath.section];
  SonosController *controller = [data1 objectAtIndex:fromIndexPath.item];
  SonosController *coordinator;

  for (SonosController *controller in data2) {
    if ([controller.group isEqualToString:controller.uuid]) {
      coordinator = controller;
      break;
    }
  }

  [[SonosControllerStore sharedStore] pairController:controller with:coordinator];

  [data1 removeObjectAtIndex:fromIndexPath.item];
  [data2 insertObject:controller atIndex:toIndexPath.item];
}

#pragma mark - UICollectionViewDelegate

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
  NSArray *controllers = [_data objectAtIndex:indexPath.section];
  SonosController *controller = (SonosController *)[controllers objectAtIndex:indexPath.item];
  PLLibraryViewController *viewController = [[PLLibraryViewController alloc] initWithController:controller];
  UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:viewController];

  if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
    [navController setModalPresentationStyle:UIModalPresentationFormSheet];
  }

  [self presentViewController:navController animated:YES completion:nil];
}

#pragma mark - KVO

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
  if ([keyPath isEqualToString:@"data"]) {
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
      _data = [[SonosControllerStore sharedStore] data];
      [_collectionView reloadData];
    }];
  }
}

@end
