//
//  PLInputsViewController.m
//  Play
//
//  Created by Nathan Borror on 1/1/13.
//  Copyright (c) 2013 Nathan Borror. All rights reserved.
//

#import "PLInputsViewController.h"
#import "PLLibraryViewController.h"
#import "PLAddInputViewController.h"
#import "PLNowPlayingViewController.h"
#import "SonosInput.h"
#import "SonosInputStore.h"
#import "SonosInputCell.h"
#import "NBAnimation.h"

@interface PLInputsViewController ()
{
  NSArray *inputList;
  NBAnimation *cellBounce;
  CGPoint cellPanCoordBegan;
  CGPoint cellOriginalCenter;
}
@end

@implementation PLInputsViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
  self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
  if (self) {
    [self.navigationItem setTitle:@"Speakers"];

    // Add Button
    UIBarButtonItem *addButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addInput)];
    [self.navigationItem setLeftBarButtonItem:addButton];

    // Now Playing Button
    UIBarButtonItem *nowPlayingButton = [[UIBarButtonItem alloc] initWithTitle:@"Playing" style:UIBarButtonItemStyleDone target:self action:@selector(nowPlaying)];
    [self.navigationItem setRightBarButtonItem:nowPlayingButton];

    // TODO: Remove this and load these using UPnP's discovery stuff
    SonosInputStore *inputStore = [SonosInputStore sharedStore];
    [inputStore addInputWithIP:@"10.0.1.9" name:@"Living Room" uid:@"RINCON_000E58D0540801400" icon:[UIImage imageNamed:@"SonosAmp"]];
    [inputStore addInputWithIP:@"10.0.1.10" name:@"Bedroom" uid:@"RINCON_000E587641F201400" icon:[UIImage imageNamed:@"SonosSpeakerPlay3Light"]];
    [inputStore addInputWithIP:@"10.0.1.18" name:@"Kitchen" uid:@"RINCON_000E587BBA5201400" icon:[UIImage imageNamed:@"SonosSpeakerPlay3Dark"]];

    // Cell bounce animation
    cellBounce = [NBAnimation animationWithKeyPath:@"position"];
    [cellBounce setDuration:0.7f];
    [cellBounce setNumberOfBounces:2];
    [cellBounce setShouldOvershoot:YES];

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
  UIImageView *background = [[UIImageView alloc] initWithFrame:self.view.bounds];
  [background setBackgroundColor:[UIColor colorWithWhite:.2 alpha:1]];
  [background setAutoresizingMask:UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight];
  [self.view addSubview:background];
}

#pragma mark - Inputs

- (void)setInputs
{
  for (int i = 0; i < [self numberOfInputs]; i++) {
    SonosInput *input = [[SonosInputStore sharedStore] inputAtIndex:i];
    SonosInputCell *cell = [self cellForInput:input];
    [cell setFrame:CGRectOffset(cell.bounds, 100, (CGRectGetHeight(cell.bounds)*i)+(20*(i+1)))];
    [cell addTarget:self action:@selector(inputWasSelected:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:cell];

    UIPanGestureRecognizer *cellPan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panCell:)];
    [cell addGestureRecognizer:cellPan];
  }
}

- (NSInteger)numberOfInputs
{
  return [[[SonosInputStore sharedStore] allInputs] count];
}

- (SonosInputCell *)cellForInput:(SonosInput *)input
{
  SonosInputCell *cell = [[SonosInputCell alloc] initWithInput:input];
  return cell;
}

- (void)inputWasSelected:(SonosInputCell *)inputCell
{
  [[SonosInputStore sharedStore] setMaster:inputCell.input];
  PLLibraryViewController *viewController = [[PLLibraryViewController alloc] init];
  [self.navigationController pushViewController:viewController animated:YES];
}

#pragma mark - UIPanGestureRecognizer

- (void)panCell:(UIGestureRecognizer *)recognizer
{
  SonosInputCell *cell = (SonosInputCell *)[recognizer view];

  if (recognizer.state == UIGestureRecognizerStateBegan) {
    cellPanCoordBegan = [recognizer locationInView:cell];
    cellOriginalCenter = cell.center;
    [self.view bringSubviewToFront:cell];
    [cell startDragging];
  }

  if (recognizer.state == UIGestureRecognizerStateChanged) {
    CGPoint panCoordChange = [recognizer locationInView:cell];

    CGFloat deltaX = panCoordChange.x - cellPanCoordBegan.x;
    CGFloat deltaY = panCoordChange.y - cellPanCoordBegan.y;

    CGPoint newPoint = CGPointMake(cell.center.x + deltaX, cell.center.y + deltaY);
    cell.center = newPoint;
  }

  if (recognizer.state == UIGestureRecognizerStateEnded) {
    // TODO: snap to grid

    id fromValue = [NSValue valueWithCGPoint:cell.center];
    id toValue = [NSValue valueWithCGPoint:cellOriginalCenter];

    [cellBounce setFromValue:fromValue];
    [cellBounce setToValue:toValue];

    [cell.layer addAnimation:cellBounce forKey:@"cellBounce"];
    [cell.layer setValue:toValue forKeyPath:@"position"];

    [cell stopDragging];
  }
}

@end
