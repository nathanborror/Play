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
  UICollectionView *_collectionView;

  DraggableCollectionViewFlowLayout *_layout;
}

- (instancetype)init
{
  if (self = [super init]) {
    [self setTitle:@"Speakers"];
    [self.view setBackgroundColor:[UIColor colorWithWhite:.97 alpha:1]];
  }
  return self;
}

- (void)viewDidLoad
{
  [super viewDidLoad];

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
  [_collectionView setContentInset:UIEdgeInsetsMake(0, 0, 96.0, 0)];
  [self.view addSubview:_collectionView];

  _data = [[SonosControllerStore sharedStore] data];
  [[SonosControllerStore sharedStore] addObserver:self forKeyPath:@"data" options:NSKeyValueObservingOptionNew context:nil];
}

- (void)viewWillLayoutSubviews
{
  [super viewWillLayoutSubviews];
  [_collectionView setFrame:self.view.bounds];
}

- (void)viewWillAppear:(BOOL)animated
{
  [super viewWillAppear:animated];
  [self.navigationController setNavigationBarHidden:YES animated:YES];
}

- (UITabBarItem *)tabBarItem
{
  return [[UITabBarItem alloc] initWithTitle:@"Speaker" image:[UIImage imageNamed:@"SpeakersTab"] selectedImage:[UIImage imageNamed:@"SpeakersTabSelected"]];
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
  if ([fromIndexPath isEqual:toIndexPath]) {
    return;
  }

  NSMutableArray *data1 = [_data objectAtIndex:fromIndexPath.section];
  NSMutableArray *data2 = [_data objectAtIndex:toIndexPath.section];
  SonosController *controller = [data1 objectAtIndex:fromIndexPath.item];
  SonosController *coordinator;

  for (SonosController *controller in data2) {
    if (controller.isCoordinator) {
      coordinator = controller;
      break;
    }
  }

  [[SonosControllerStore sharedStore] pairController:controller with:coordinator];

  [data1 removeObjectAtIndex:fromIndexPath.item];
  [data2 insertObject:controller atIndex:toIndexPath.item];
}

#pragma mark - KVO

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
  if ([keyPath isEqualToString:@"data"]) {
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
      _data = [[SonosControllerStore sharedStore] data];
      dispatch_async(dispatch_get_main_queue(), ^{
        [_collectionView reloadData];
      });
    }];
  }
}

@end
