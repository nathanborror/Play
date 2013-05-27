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
#import "SonosInput.h"
#import "SonosInputStore.h"
#import "SonosInputCell.h"
#import "SonosController.h"
#import "SonosPositionInfoResponse.h"
#import "SOAPEnvelope.h"
#import "NBKit/NBAnimationHelper.h"
#import "PLControlMenu.h"

static const CGFloat kInputOffRestingX = 23.0;
static const CGFloat kInputOnRestingX = 185.0;

@interface PLSpeakersViewController ()
{
  NSArray *inputList;
  CGPoint cellPanCoordBegan;
  PLControlMenu *controlMenu;
  UIView *paired;
  NSMutableArray *pairedSpeakers;
}
@end

@implementation PLSpeakersViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
  self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
  if (self) {
    [self.navigationItem setTitle:@"Speakers"];
    pairedSpeakers = [[NSMutableArray alloc] init];

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

    [self setBackground];
    [self setInputs];

    controlMenu = [[PLControlMenu alloc] initWithFrame:CGRectMake(0, 15, CGRectGetWidth(self.view.bounds), CGRectGetHeight(self.view.bounds)-15)];
    [self.view addSubview:controlMenu];
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
  [self.view setBackgroundColor:[UIColor colorWithWhite:.2 alpha:1]];

  // Drag inputs here to turn them on
  paired = [[UIView alloc] initWithFrame:CGRectMake(CGRectGetWidth(self.view.bounds)/2, 0, CGRectGetWidth(self.view.bounds)/2, CGRectGetHeight(self.view.bounds))];
  [self.view addSubview:paired];

  // Divider
  UIImageView *divider = [[UIImageView alloc] initWithImage:[[UIImage imageNamed:@"InputDivider"] resizableImageWithCapInsets:UIEdgeInsetsMake(2, 2, 2, 2) resizingMode:UIImageResizingModeStretch]];
  [divider setFrame:CGRectMake((CGRectGetWidth(self.view.bounds)/2)-2, 15, 4, CGRectGetHeight(self.view.bounds)-40)];
  [divider setAutoresizingMask:UIViewAutoresizingFlexibleHeight];
  [self.view addSubview:divider];
}

#pragma mark - InputCells

- (void)setInputs
{
  for (int i = 0; i < [self numberOfInputs]; i++) {
    SonosInput *input = [[SonosInputStore sharedStore] inputAtIndex:i];
    SonosInputCell *cell = [self inputCellForInput:input];
    [cell addTarget:self action:@selector(inputCellWasSelected:) forControlEvents:UIControlEventTouchUpInside];

    if ([input isEqual:[[SonosInputStore sharedStore] master]]) {
      [cell setFrame:CGRectOffset(cell.bounds, kInputOnRestingX, (CGRectGetHeight(cell.bounds)*i)+(20*(i+1))+30)];
      [pairedSpeakers addObject:input];
    } else {
      [cell setFrame:CGRectOffset(cell.bounds, kInputOffRestingX, (CGRectGetHeight(cell.bounds)*i)+(20*(i+1))+30)];
    }

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

- (SonosInputCell *)inputCellForInput:(SonosInput *)input
{
  SonosInputCell *cell = [[SonosInputCell alloc] initWithInput:input];
  return cell;
}

- (void)inputCellWasSelected:(SonosInputCell *)inputCell
{
  PLLibraryViewController *viewController = [[PLLibraryViewController alloc] init];
  [self.navigationController pushViewController:viewController animated:YES];
}

- (void)inputCell:(SonosInputCell *)inputCell isHighlighted:(BOOL)active
{
  SonosInputStore *inputStore = [SonosInputStore sharedStore];

  CGPoint fromPoint = inputCell.center;
  CGPoint toPoint;

  if (active) {
    // If there are no speakers in the grouped colum, set the master to
    // the speaker being dragged over.
    if ([pairedSpeakers count] == 0) {
      [inputStore setMaster:inputCell.input];
    }

    toPoint = CGPointMake(kInputOnRestingX+CGRectGetWidth(inputCell.bounds)/2, inputCell.origin.y);
    [pairedSpeakers addObject:inputCell];
    [inputCell pair:inputStore.master];
  } else {
    toPoint = CGPointMake(kInputOffRestingX+CGRectGetWidth(inputCell.bounds)/2, inputCell.origin.y);
    [pairedSpeakers removeObjectIdenticalTo:inputCell];
    [inputCell unpair];
  }

  [NBAnimationHelper animatePosition:inputCell from:fromPoint to:toPoint forKey:@"cellBounce" delegate:nil];
}

#pragma mark - UIPanGestureRecognizer

- (void)panCell:(UIGestureRecognizer *)recognizer
{
  SonosInputCell *cell = (SonosInputCell *)[recognizer view];

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
      [self.view bringSubviewToFront:controlMenu];
    } break;
    case UIGestureRecognizerStateFailed:
    case UIGestureRecognizerStatePossible:
      break;
  }
}

@end
