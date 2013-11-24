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
  NSArray *_groupings;
  UICollectionView *_collectionView;
}

- (void)viewDidLoad
{
  [super viewDidLoad];

  [self setTitle:@"Speakers"];
  [self.view setBackgroundColor:[UIColor colorWithWhite:.1 alpha:1]];

  _groupings = [[SonosInputStore sharedStore] allInputsGrouped];

  NBReorderableCollectionViewLayout *layout = [[NBReorderableCollectionViewLayout alloc] init];
  [layout setMinimumLineSpacing:1];
  [layout setMinimumInteritemSpacing:0];
  [layout setHeaderReferenceSize:CGSizeMake(CGRectGetWidth(self.view.bounds), 36)];

  if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
    [layout setItemSize:CGSizeMake(149, 100)];
  } else {
    [layout setItemSize:CGSizeMake(160, 100)];
  }

  _collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 60, CGRectGetWidth(self.view.bounds), CGRectGetWidth(self.view.bounds)) collectionViewLayout:layout];
  [_collectionView setClipsToBounds:NO];
  [_collectionView registerClass:[PLInputCell class] forCellWithReuseIdentifier:@"PLInputCell"];
  [_collectionView registerClass:[PLGroupHeaderView class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"PLGroupHeaderView"];
  [_collectionView setDelegate:self];
  [_collectionView setDataSource:self];
  [_collectionView setAutoresizingMask:UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight];
  [_collectionView setBackgroundColor:[UIColor clearColor]];
  [self.view addSubview:_collectionView];

  if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {

  } else {
    [_groupings enumerateObjectsUsingBlock:^(NSDictionary *group, NSUInteger idx, BOOL *stop) {
      SonosInput *master = (SonosInput *)group[@"master"];
      UIView *snapshot = master.nowPlayingSnapshot;

      if (!snapshot) {
        snapshot = [[UIView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.bounds), CGRectGetHeight(self.view.bounds))];
        [snapshot setBackgroundColor:[UIColor whiteColor]];
        [master setNowPlayingSnapshot:snapshot];
      }

      [snapshot setCenter:CGPointMake(CGRectGetWidth(self.view.bounds)/2, 0)];
      [snapshot.layer setZPosition:999-(idx*99)];
      [self.view addSubview:snapshot];

      UIButton *button = [[UIButton alloc] initWithFrame:snapshot.bounds];
      [button addTarget:self action:@selector(showNowPlaying) forControlEvents:UIControlEventTouchUpInside];
      [snapshot addSubview:button];
    }];
  }
}

- (void)viewDidAppear:(BOOL)animated
{
  [super viewDidAppear:animated];

  if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {

  } else {
    [_groupings enumerateObjectsUsingBlock:^(NSDictionary *group, NSUInteger idx, BOOL *stop) {
      UIView *snapshot = [(SonosInput *)group[@"master"] nowPlayingSnapshot];

      [UIView animateWithDuration:.5 animations:^{
        CATransform3D rotation = CATransform3DIdentity;
        rotation.m34 = 1.0 / -500;
        rotation = CATransform3DTranslate(rotation, 0, CGRectGetHeight(self.view.frame)-88-(88 * idx), -10);
        rotation = CATransform3DRotate(rotation, (-25.0 * M_PI / 180.0), 1, 0, 0);

        [snapshot.layer setAnchorPoint:CGPointMake(.5, 0)];
        [snapshot.layer setShouldRasterize:YES];
        [snapshot.layer setTransform:rotation];
      }];
    }];
  }
}

- (void)showNowPlaying
{
  [_groupings enumerateObjectsUsingBlock:^(NSDictionary *group, NSUInteger idx, BOOL *stop) {
    UIView *snapshot = [(SonosInput *)group[@"master"] nowPlayingSnapshot];

    [UIView animateWithDuration:.5 animations:^{
      CATransform3D rotation = CATransform3DIdentity;
      rotation.m34 = 1.0 / -500;
      rotation = CATransform3DTranslate(rotation, 0, 0, 1);
      rotation = CATransform3DRotate(rotation, (0.0 * M_PI / 180.0), 1, 0, 0);

      [snapshot.layer setAnchorPoint:CGPointMake(.5, 0)];
      [snapshot.layer setShouldRasterize:YES];
      [snapshot.layer setTransform:rotation];
    } completion:^(BOOL finished) {
      [self dismissViewControllerAnimated:NO completion:nil];
    }];
  }];
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
  return _groupings.count;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
  NSArray *inputs = (NSArray *)[_groupings objectAtIndex:section][@"inputs"];
  return inputs.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
  PLInputCell *cell = (PLInputCell *)[collectionView dequeueReusableCellWithReuseIdentifier:@"PLInputCell" forIndexPath:indexPath];
  NSArray *inputs = (NSArray *)[_groupings objectAtIndex:indexPath.section][@"inputs"];
  SonosInput *input = [inputs objectAtIndex:indexPath.row];
  [cell setInput:input];
  return cell;
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
{
  UICollectionReusableView *supplement;
  NSDictionary *group = [_groupings objectAtIndex:indexPath.section];

  if ([kind isEqualToString:UICollectionElementKindSectionHeader]) {
    PLGroupHeaderView *header = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"PLGroupHeaderView" forIndexPath:indexPath];
    SonosInput *master = (SonosInput *)group[@"master"];

    [header.title setText:@"Demo Mode"];

    [[SonosController sharedController] mediaInfo:master completion:^(NSDictionary *response, NSError *error) {
      NSString *title = response[@"u:GetMediaInfoResponse"][@"CurrentURIMetaData"][@"dc:title"][@"text"];
      if (!title) {
        title = response[@"u:GetMediaInfoResponse"][@"CurrentURI"][@"text"];
      }
      [header.title setText:title];
    }];
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
  NSMutableArray *data1 = [_groupings objectAtIndex:fromIndexPath.section][@"inputs"];
  NSMutableArray *data2 = [_groupings objectAtIndex:toIndexPath.section][@"inputs"];

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

  if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
    [navController setModalPresentationStyle:UIModalPresentationFormSheet];
  }

  [self presentViewController:navController animated:YES completion:nil];
}

@end
