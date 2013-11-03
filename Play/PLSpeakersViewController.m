//
//  PLSpeakersViewController.m
//  Play
//
//  Created by Nathan Borror on 1/1/13.
//  Copyright (c) 2013 Nathan Borror. All rights reserved.
//

#import "PLSpeakersViewController.h"
#import "PLLibraryViewController.h"
#import "PLAddInputViewController.h"
#import "PLInputCell.h"
#import "PLGroupHeaderView.h"
#import "SonosInput.h"
#import "SonosInputStore.h"
#import "SonosController.h"
#import "NBReorderableCollectionViewLayout.h"

static const CGFloat kInputGridTotalCells = 10;
static const CGFloat kInputGridTotalColumns = 2;
static const CGFloat kSongTitleFontSize = 17.0;
static const CGFloat kMiniBarHeight = 44;

@implementation PLSpeakersViewController {
  UIScrollView *_scrollView;
  CGPoint _cellPanCoordBegan;
  UIView *_paired;
  NSArray *_data;
  UICollectionView *_collectionView;
}

- (id)init
{
  if (self = [super init]) {
    _data = @[
              @{@"title": @"Line In",
                @"inputs": (NSMutableArray *)[[SonosInputStore sharedStore] allInputs]},
              @{@"title": @"Test",
                @"inputs": [[NSMutableArray alloc] init]}
            ];
  }
  return self;
}

- (void)viewDidLoad
{
  [super viewDidLoad];

  [self setTitle:@"Speakers"];

  NBReorderableCollectionViewLayout *layout = [[NBReorderableCollectionViewLayout alloc] init];
  [layout setMinimumLineSpacing:1];
  [layout setMinimumInteritemSpacing:0];
  [layout setHeaderReferenceSize:CGSizeMake(CGRectGetWidth(self.view.bounds), 44)];

  if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
    [layout setItemSize:CGSizeMake(149, 112)];
  } else {
    [layout setItemSize:CGSizeMake(160, 112)];
  }

  _collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 60, CGRectGetWidth(self.view.bounds), CGRectGetWidth(self.view.bounds)) collectionViewLayout:layout];
  [_collectionView setClipsToBounds:NO];
  [_collectionView registerClass:[PLInputCell class] forCellWithReuseIdentifier:@"PLInputCell"];
  [_collectionView registerClass:[PLGroupHeaderView class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"PLGroupHeaderView"];
  [_collectionView setDelegate:self];
  [_collectionView setDataSource:self];
  [_collectionView setAutoresizingMask:UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight];
  [_collectionView setBackgroundColor:[UIColor whiteColor]];
  [self.view addSubview:_collectionView];
}

- (UITabBarItem *)tabBarItem
{
  return [[UITabBarItem alloc] initWithTitle:@"Speakers" image:[UIImage imageNamed:@"PLSpeakersTab"] selectedImage:[UIImage imageNamed:@"PLSpeakersTabSelected"] ];
}

- (void)viewWillLayoutSubviews
{
  [super viewWillLayoutSubviews];
  [_collectionView setFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.frame), CGRectGetHeight(self.view.frame))];
}

- (void)done
{
  [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)addInput
{
  PLAddInputViewController *viewController = [[PLAddInputViewController alloc] init];
  UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:viewController];
  [self.navigationController presentViewController:navigationController animated:YES completion:nil];
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
  NSArray *inputs = (NSArray *)[_data objectAtIndex:section][@"inputs"];
  return inputs.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
  PLInputCell *cell = (PLInputCell *)[collectionView dequeueReusableCellWithReuseIdentifier:@"PLInputCell" forIndexPath:indexPath];
  NSArray *inputs = (NSArray *)[_data objectAtIndex:indexPath.section][@"inputs"];
  SonosInput *input = [inputs objectAtIndex:indexPath.row];
  [cell setInput:input];
  return cell;
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
{
  UICollectionReusableView *supplement;
  NSDictionary *group = [_data objectAtIndex:indexPath.section];

  if ([kind isEqualToString:UICollectionElementKindSectionHeader]) {
    PLGroupHeaderView *header = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"PLGroupHeaderView" forIndexPath:indexPath];
    [header.title setText:group[@"title"]];
    supplement = header;
  }
  return supplement;
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

  NSString *index = [data1 objectAtIndex:fromIndexPath.item];

  [data1 removeObjectAtIndex:fromIndexPath.item];
  [data2 insertObject:index atIndex:toIndexPath.item];
}

#pragma mark - UICollectionViewDelegate

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
  PLInputCell *cell = (PLInputCell *)[collectionView dequeueReusableCellWithReuseIdentifier:@"PLInputCell" forIndexPath:indexPath];
  PLLibraryViewController *viewController = [[PLLibraryViewController alloc] initWithInput:cell.input];
  UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:viewController];
  [self presentViewController:navController animated:YES completion:nil];
}

@end
