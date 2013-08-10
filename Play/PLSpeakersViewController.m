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
#import "PLNowPlayingViewController.h"
#import "PLVolumeSlider.h"
#import "PLInputCell.h"
#import "SonosInput.h"
#import "SonosInputStore.h"
#import "SonosController.h"
#import "SonosPositionInfoResponse.h"
#import "SOAPEnvelope.h"
#import "UIImage+BlurImage.h"

#define ACTIVE_POSITION (CGRectGetWidth(self.view.bounds)/2)+(CGRectGetWidth(self.view.bounds)/4)-(CGRectGetWidth(cell.bounds)/2)
#define RESTING_POSITION (CGRectGetWidth(self.view.bounds)/4)-(CGRectGetWidth(cell.bounds)/2)

static const CGFloat kInputOffRestingX = 23.0;
static const CGFloat kInputOnRestingX = 185.0;
static const CGFloat kControlButtonWidth = 60.0;
static const CGFloat kControlButtonHeight = 60.0;
static const CGFloat kControlButtonTopSpacing = 2.0;
static const CGFloat kControlButtonSpacing = 30.0;
static const CGFloat kControlVolumeSpacing = 10.0;

@interface PLSpeakersViewController ()
{
  NSArray *inputList;
  CGPoint cellPanCoordBegan;
  UIView *paired;
  NSMutableArray *pairedSpeakers;
  UIDynamicAnimator *animator;
}
@end

@implementation PLSpeakersViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
  self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
  if (self) {
    [self.navigationItem setTitle:@"Speakers"];
    pairedSpeakers = [[NSMutableArray alloc] init];

    animator = [[UIDynamicAnimator alloc] initWithReferenceView:self.view];

    // Add Button
    UIBarButtonItem *addButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addInput)];
    [self.navigationItem setLeftBarButtonItem:addButton];

    // TODO: Remove this and load these using UPnP's discovery stuff
    SonosInputStore *inputStore = [SonosInputStore sharedStore];
    [inputStore addInputWithIP:@"10.0.1.9" name:@"Living Room" uid:@"RINCON_000E58D0540801400" icon:[UIImage imageNamed:@"SonosAmp"]];
    [inputStore addInputWithIP:@"10.0.1.10" name:@"Bedroom" uid:@"RINCON_000E587641F201400" icon:[UIImage imageNamed:@"SonosSpeakerPlay3Light"]];
    [inputStore addInputWithIP:@"10.0.1.11" name:@"Kitchen" uid:@"RINCON_000E587BBA5201400" icon:[UIImage imageNamed:@"SonosSpeakerPlay3Dark"]];

    // Make the first input in the master input for now.
    [inputStore setMaster:[inputStore inputAtIndex:0]];

    // Now playing
    UIBarButtonItem *playing = [[UIBarButtonItem alloc] initWithTitle:@"Playing" style:UIBarButtonItemStylePlain target:self action:@selector(nowPlaying)];
    [self.navigationItem setRightBarButtonItem:playing];

    [self setBackground];
    [self setInputs];
  }
  return self;
}

- (void)nowPlaying
{
  PLNowPlayingViewController *viewController = [[PLNowPlayingViewController alloc] init];
  UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:viewController];
  [self.navigationController presentViewController:navController animated:YES completion:nil];
}

- (void)addInput
{
  PLAddInputViewController *viewController = [[PLAddInputViewController alloc] init];
  UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:viewController];
  [self.navigationController presentViewController:navigationController animated:YES completion:nil];
}

- (void)setBackground
{
  // Drag inputs here to turn them on
  paired = [[UIView alloc] initWithFrame:CGRectMake(CGRectGetWidth(self.view.bounds)/2, 0, CGRectGetWidth(self.view.bounds)/2, CGRectGetHeight(self.view.bounds))];
  [self.view addSubview:paired];

  // Divider
  UIView *divider = [[UIView alloc] initWithFrame:CGRectMake((CGRectGetWidth(self.view.bounds)/2)-2, 75, 1, CGRectGetHeight(self.view.bounds)-85)];
  [divider setBackgroundColor:[UIColor colorWithWhite:0 alpha:.2]];
  [divider setAutoresizingMask:UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin];
  [self.view addSubview:divider];
}

#pragma mark - InputCells

- (void)setInputs
{
  for (int i = 0; i < [self numberOfInputs]; i++) {
    SonosInput *input = [[SonosInputStore sharedStore] inputAtIndex:i];
    PLInputCell *cell = [self inputCellForInput:input];
    [cell addTarget:self action:@selector(inputCellWasSelected:) forControlEvents:UIControlEventTouchUpInside];

    if ([input isEqual:[[SonosInputStore sharedStore] master]]) {
      [cell setFrame:CGRectOffset(cell.bounds, ACTIVE_POSITION, (CGRectGetHeight(cell.bounds)*i)+(20*(i+1))+70)];
      [pairedSpeakers addObject:input];
    } else {
      [cell setFrame:CGRectOffset(cell.bounds, RESTING_POSITION, (CGRectGetHeight(cell.bounds)*i)+(20*(i+1))+70)];
    }

    [cell setAutoresizingMask:UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleLeftMargin];

    [cell setOrigin:cell.center];
    [self.view addSubview:cell];

    UIPanGestureRecognizer *cellPan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panCell:)];
    [cell addGestureRecognizer:cellPan];

    // Check to see if any inputs are playing other speakers.
    // This would mean they're a slave of another speaker.
    [[SonosController sharedController] trackInfo:input completion:^(SOAPEnvelope *envelope, NSError *error) {
      SonosPositionInfoResponse *response = (SonosPositionInfoResponse *)[envelope response];
      NSMutableString *uri = [NSMutableString stringWithFormat:@"%@", response.uri];

      NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"x-rincon:" options:0 error:nil];
      NSTextCheckingResult *match = [regex firstMatchInString:uri options:0 range:NSMakeRange(0, uri.length)];

      if (match) {
        [self inputCell:cell isHighlighted:YES];
        [pairedSpeakers addObject:cell];
      }
    }];
  }
}

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

- (void)inputCell:(PLInputCell *)cell isHighlighted:(BOOL)active
{
  SonosInputStore *inputStore = [SonosInputStore sharedStore];

  CGPoint toPoint;

  if (active) {
    // If there are no speakers in the grouped colum, set the master to
    // the speaker being dragged over.
    if ([pairedSpeakers count] == 0) {
      [inputStore setMaster:cell.input];
    }

    toPoint = CGPointMake((CGRectGetWidth(self.view.bounds)/2)+(CGRectGetWidth(self.view.bounds)/4), cell.origin.y);
    [pairedSpeakers addObject:cell];
    [cell pair:inputStore.master];
  } else {
    toPoint = CGPointMake((CGRectGetWidth(self.view.bounds)/4), cell.origin.y);
    [pairedSpeakers removeObjectIdenticalTo:cell];
    [cell unpair];
  }

  
  UISnapBehavior *snap = [[UISnapBehavior alloc] initWithItem:cell snapToPoint:toPoint];
  [snap setDamping:.7];
  [animator addBehavior:snap];
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
    } break;
    case UIGestureRecognizerStateEnded:
    case UIGestureRecognizerStateCancelled: {
      [cell stopDragging];
      if (CGRectContainsPoint(paired.frame, cell.center)) {
        [self inputCell:cell isHighlighted:YES];
      } else {
        [self inputCell:cell isHighlighted:NO];
      }
    } break;
    case UIGestureRecognizerStateFailed:
    case UIGestureRecognizerStatePossible:
      break;
  }
}

@end
