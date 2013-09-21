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
#import "SonosInput.h"
#import "SonosInputStore.h"
#import "SonosController.h"
#import "SonosPositionInfoResponse.h"
#import "SOAPEnvelope.h"
#import "UIImage+BlurImage.h"

static const CGFloat kInputGridTotalCells = 10;
static const CGFloat kInputGridTotalColumns = 2;
static const CGFloat kSongTitleFontSize = 17.0;
static const CGFloat kMiniBarHeight = 44;

@implementation PLSpeakersViewController {
  UIScrollView *_scrollView;
  CGPoint _cellPanCoordBegan;
  UIView *_paired;
  NSMutableArray *_pairedSpeakers;
  UIDynamicAnimator *_animator;
  NSMutableArray *_boxes;
  UIView *_miniBar;
}

- (id)init
{
  if (self = [super init]) {
    _pairedSpeakers = [[NSMutableArray alloc] init];
    _boxes = [[NSMutableArray alloc] init];
    _animator = [[UIDynamicAnimator alloc] initWithReferenceView:_scrollView];
  }
  return self;
}

- (void)viewDidLoad
{
  [super viewDidLoad];

  [self setTitle:@"Speakers"];
  [self.view setBackgroundColor:[UIColor colorWithRed:.85 green:.86 blue:.88 alpha:1]];

  UIBarButtonItem *addButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addInput)];
  [self.navigationItem setLeftBarButtonItem:addButton];

  UIBarButtonItem *done = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(done)];
  [self.navigationItem setRightBarButtonItem:done];

  _scrollView = [[UIScrollView alloc] initWithFrame:CGRectZero];
  [_scrollView setAutoresizingMask:UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight];
  [_scrollView setShowsVerticalScrollIndicator:NO];
  [self.view addSubview:_scrollView];

  // Build a grid for the speakers to use for placement
  const CGFloat kCellWidth = CGRectGetWidth(self.view.frame)/kInputGridTotalColumns;
  const CGFloat kCellHeight = kCellWidth;

  NSInteger currentColumn = 0, currentRow = 0;
  for (NSInteger i=0; i<kInputGridTotalCells; i++) {
    CALayer *box = [CALayer layer];
    [_scrollView.layer addSublayer:box];
    [_boxes addObject:box];
    [box setFrame:CGRectMake(currentColumn * kCellWidth, currentRow * kCellHeight, kCellWidth, kCellHeight)];

    if (currentColumn+1 < kInputGridTotalColumns) {
      currentColumn++;
    } else {
      currentColumn = 0;
      currentRow++;
    }
  }
  [_scrollView setContentSize:CGSizeMake(CGRectGetWidth(_scrollView.frame), kCellHeight*(kInputGridTotalCells/kInputGridTotalColumns))];

  // Display speakers in the grid layout
  [[[SonosInputStore sharedStore] allInputs] enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
    SonosInput *input = (SonosInput *)obj;
    [input setDelegate:self];

    CALayer *box = (CALayer *)[_boxes objectAtIndex:idx];

    PLInputCell *cell = [self inputCellForInput:input];
    [cell addTarget:self action:@selector(inputCellWasSelected:) forControlEvents:UIControlEventTouchUpInside];
    [cell setCenter:box.position];
    [_scrollView addSubview:cell];

    [input setView:cell];

    // Allow people to drag speakers into new grid cells
    UIPanGestureRecognizer *cellPan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panCell:)];
    [cell addGestureRecognizer:cellPan];
  }];

  // Mini Bar
  _miniBar = [[UIView alloc] initWithFrame:CGRectZero];
  [_miniBar setBackgroundColor:[UIColor colorWithWhite:.95 alpha:1]];
  [self.view addSubview:_miniBar];

  UIButton *miniTitle = [[UIButton alloc] init];
  [miniTitle setAutoresizingMask:UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight];
  [miniTitle addTarget:self action:@selector(done) forControlEvents:UIControlEventTouchUpInside];
  [miniTitle setTitle:@"Come Together" forState:UIControlStateNormal];
  [miniTitle setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
  [miniTitle.titleLabel setFont:[UIFont boldSystemFontOfSize:kSongTitleFontSize]];
  [miniTitle sizeToFit];
  [miniTitle setCenter:CGPointMake(CGRectGetWidth(_miniBar.bounds)/2, CGRectGetHeight(_miniBar.bounds)/2)];
  [_miniBar addSubview:miniTitle];

  UIButton *miniPause = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, kMiniBarHeight, kMiniBarHeight)];
  [miniPause setBackgroundImage:[UIImage imageNamed:@"PLPause"] forState:UIControlStateNormal];
  [_miniBar addSubview:miniPause];
}

- (void)viewWillLayoutSubviews
{
  [super viewWillLayoutSubviews];

  [_scrollView setFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.bounds), CGRectGetHeight(self.view.bounds))];
  [_miniBar setFrame:CGRectMake(0, CGRectGetHeight(self.view.bounds)-kMiniBarHeight, CGRectGetWidth(self.view.bounds), kMiniBarHeight)];
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

#pragma mark - InputCells

- (NSInteger)numberOfInputs
{
  return [[[SonosInputStore sharedStore] allInputs] count];
}

- (PLInputCell *)inputCellForInput:(SonosInput *)input
{
  PLInputCell *cell = [[PLInputCell alloc] initWithInput:input];
  return cell;
}

- (void)inputCellWasSelected:(PLInputCell *)cell
{
  PLLibraryViewController *viewController = [[PLLibraryViewController alloc] init];
  [self.navigationController pushViewController:viewController animated:YES];
}

- (void)moveInputCell:(PLInputCell *)cell toPoint:(CGPoint)point
{
  // TODO: Figure out how to paire speakers with this new behavior
  UISnapBehavior *snap = [[UISnapBehavior alloc] initWithItem:cell snapToPoint:point];
  [snap setDamping:.7];
  [_animator addBehavior:snap];
}

- (void)pairSonosInput:(SonosInput *)master with:(SonosInput *)slave
{
  [slave pairWithSonosInput:master];
}

#pragma mark - UIPanGestureRecognizer

- (void)panCell:(UIGestureRecognizer *)recognizer
{
  PLInputCell *cell = (PLInputCell *)[recognizer view];
  [_animator removeAllBehaviors];

  switch (recognizer.state) {
    case UIGestureRecognizerStateBegan: {
      _cellPanCoordBegan = [recognizer locationInView:cell];
      [cell setOrigin:cell.center];
      [cell startDragging];
      [self.view bringSubviewToFront:cell];
    } break;
    case UIGestureRecognizerStateChanged: {
      CGPoint panCoordChange = [recognizer locationInView:cell];

      CGFloat deltaX = panCoordChange.x - _cellPanCoordBegan.x;
      CGFloat deltaY = panCoordChange.y - _cellPanCoordBegan.y;

      CGPoint newPoint = CGPointMake(cell.center.x + deltaX, cell.center.y + deltaY);
      cell.center = newPoint;

      [_boxes enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        CALayer *box = (CALayer *)obj;
        if (CGRectContainsPoint(box.frame, cell.center)) {
          [box setBackgroundColor:[UIColor colorWithWhite:.97 alpha:1].CGColor];
        } else {
          [box setBackgroundColor:[UIColor clearColor].CGColor];
        }
      }];
    } break;
    case UIGestureRecognizerStateEnded:
    case UIGestureRecognizerStateCancelled: {
      [cell stopDragging];
      [_boxes enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        CALayer *box = (CALayer *)obj;
        if (CGRectContainsPoint(box.frame, cell.center)) {
          [box setBackgroundColor:[UIColor clearColor].CGColor];
          [self moveInputCell:cell toPoint:box.position];
        }
      }];
    } break;
    case UIGestureRecognizerStateFailed:
    case UIGestureRecognizerStatePossible:
      break;
  }
}

#pragma mark - SonosInputDelegate

- (void)input:(SonosInput *)input pairedWith:(SonosInput *)pairedWithInput
{
//  PLInputCell *inputCell = (PLInputCell *)[input view];
//  PLInputCell *masterCell = (PLInputCell *)[pairedWithInput view];
//  [self moveInputCell:inputCell toPoint:masterCell.center];
}

- (void)input:(SonosInput *)input unpairedWith:(SonosInput *)unpairedWithInput
{

}

@end
