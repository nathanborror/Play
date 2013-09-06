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

@implementation PLSpeakersViewController {
  UIScrollView *scrollView;
  CGPoint cellPanCoordBegan;
  UIView *paired;
  NSMutableArray *pairedSpeakers;
  UIDynamicAnimator *animator;
  NSMutableArray *boxes;
}

- (id)init
{
  if (self = [super init]) {
    [self.navigationItem setTitle:@"Speakers"];
    pairedSpeakers = [[NSMutableArray alloc] init];
    boxes = [[NSMutableArray alloc] init];
    animator = [[UIDynamicAnimator alloc] initWithReferenceView:scrollView];

    [self.view setBackgroundColor:[UIColor colorWithRed:.85 green:.86 blue:.88 alpha:1]];

    // Build a grid for the speakers to use for placement
    const CGFloat kCellWidth = CGRectGetWidth(self.view.frame)/kInputGridTotalColumns;
    const CGFloat kCellHeight = kCellWidth;

    NSInteger currentColumn = 0, currentRow = 0;
    for (NSInteger i=0; i<kInputGridTotalCells; i++) {
      CALayer *box = [CALayer layer];
      [scrollView.layer addSublayer:box];
      [boxes addObject:box];
      [box setFrame:CGRectMake(currentColumn * kCellWidth, currentRow * kCellHeight, kCellWidth, kCellHeight)];

      if (currentColumn+1 < kInputGridTotalColumns) {
        currentColumn++;
      } else {
        currentColumn = 0;
        currentRow++;
      }
    }
    [scrollView setContentSize:CGSizeMake(CGRectGetWidth(scrollView.frame), kCellHeight*(kInputGridTotalCells/kInputGridTotalColumns))];

    // Display speakers in the grid layout
    [[[SonosInputStore sharedStore] allInputs] enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
      SonosInput *input = (SonosInput *)obj;
      [input setDelegate:self];

      CALayer *box = (CALayer *)[boxes objectAtIndex:idx];

      PLInputCell *cell = [self inputCellForInput:input];
      [cell addTarget:self action:@selector(inputCellWasSelected:) forControlEvents:UIControlEventTouchUpInside];
      [cell setCenter:box.position];
      [scrollView addSubview:cell];

      [input setView:cell];

      // Allow people to drag speakers into new grid cells
      UIPanGestureRecognizer *cellPan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panCell:)];
      [cell addGestureRecognizer:cellPan];
    }];

    // Mini Bar
    UIView *miniBar = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetHeight(self.view.bounds)-44, CGRectGetWidth(self.view.bounds), 44)];
    [miniBar setBackgroundColor:[UIColor colorWithWhite:.95 alpha:1]];
    [self.view addSubview:miniBar];

    UIButton *miniTitle = [[UIButton alloc] init];
    [miniTitle addTarget:self action:@selector(done) forControlEvents:UIControlEventTouchUpInside];
    [miniTitle setTitle:@"Come Together" forState:UIControlStateNormal];
    [miniTitle setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [miniTitle.titleLabel setFont:[UIFont boldSystemFontOfSize:kSongTitleFontSize]];
    [miniTitle sizeToFit];
    [miniTitle setCenter:CGPointMake(CGRectGetWidth(miniBar.bounds)/2, CGRectGetHeight(miniBar.bounds)/2)];
    [miniBar addSubview:miniTitle];

    UIButton *miniPause = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 44, 44)];
    [miniPause setBackgroundImage:[UIImage imageNamed:@"PLPause"] forState:UIControlStateNormal];
    [miniBar addSubview:miniPause];
  }
  return self;
}

- (void)viewDidLoad
{
  [super viewDidLoad];

  // Add Button
  UIBarButtonItem *addButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addInput)];
  [self.navigationItem setLeftBarButtonItem:addButton];

  // Done Button
  UIBarButtonItem *done = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(done)];
  [self.navigationItem setRightBarButtonItem:done];

  // Scroll View
  scrollView = [[UIScrollView alloc] initWithFrame:self.view.frame];
  [scrollView setAutoresizingMask:UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight];
  [scrollView setShowsVerticalScrollIndicator:NO];
  [self.view addSubview:scrollView];
}

- (void)viewWillLayoutSubviews
{
  [super viewWillLayoutSubviews];
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
  [animator addBehavior:snap];
}

- (void)pairSonosInput:(SonosInput *)master with:(SonosInput *)slave
{
  [slave pairWithSonosInput:master];
}

#pragma mark - UIPanGestureRecognizer

- (void)panCell:(UIGestureRecognizer *)recognizer
{
  PLInputCell *cell = (PLInputCell *)[recognizer view];
  [animator removeAllBehaviors];

  switch (recognizer.state) {
    case UIGestureRecognizerStateBegan: {
      cellPanCoordBegan = [recognizer locationInView:cell];
      [cell setOrigin:cell.center];
      [cell startDragging];
      [self.view bringSubviewToFront:cell];
    } break;
    case UIGestureRecognizerStateChanged: {
      CGPoint panCoordChange = [recognizer locationInView:cell];

      CGFloat deltaX = panCoordChange.x - cellPanCoordBegan.x;
      CGFloat deltaY = panCoordChange.y - cellPanCoordBegan.y;

      CGPoint newPoint = CGPointMake(cell.center.x + deltaX, cell.center.y + deltaY);
      cell.center = newPoint;

      [boxes enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
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
      [boxes enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
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
