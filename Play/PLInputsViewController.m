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
#import "PLInput.h"
#import "PLInputStore.h"

@interface PLInputsViewController ()
{
  UITableView *inputsTableView;
  NSArray *inputList;
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

    // Table
    inputsTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetHeight(self.view.bounds), CGRectGetHeight(self.view.bounds)) style:UITableViewStylePlain];
    [inputsTableView setAutoresizingMask:UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth];
    [inputsTableView setDelegate:self];
    [inputsTableView setDataSource:self];
    [self.view addSubview:inputsTableView];

    // TODO: Remove this and load these using UPnP's discovery stuff
    PLInputStore *inputStore = [PLInputStore sharedStore];
    [inputStore addInputWithIP:@"10.0.1.9" name:@"Living Room" uid:@"RINCON_000E58D0540801400"];
    [inputStore addInputWithIP:@"10.0.1.10" name:@"Bedroom" uid:@"RINCON_000E587641F201400"];
  }
  return self;
}

- (void)viewDidAppear:(BOOL)animated
{
  [super viewDidAppear:animated];
  [inputsTableView reloadData];
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

#pragma mark - UITableViewController

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
  return [[[PLInputStore sharedStore] allInputs] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
  PLInput *input = [[[PLInputStore sharedStore] allInputs] objectAtIndex:indexPath.row];
  UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"PLInputsTableViewCell"];
  if (!cell) {
    cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"PLInputsTableViewCell"];
  }
  [cell.textLabel setText:input.name];
  [cell setAccessoryType:UITableViewCellAccessoryDetailDisclosureButton];
  return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
  PLInput *input = [[[PLInputStore sharedStore] allInputs] objectAtIndex:indexPath.row];

  // TODO: This is going to become pretty unwieldy, I should probably find an
  // alternative that just saves the whole input object.
  [[NSUserDefaults standardUserDefaults] setObject:input.ip forKey:@"current_input_ip"];
  [[NSUserDefaults standardUserDefaults] setObject:input.name forKey:@"current_input_name"];
  [[NSUserDefaults standardUserDefaults] setObject:input.uid forKey:@"current_input_uid"];

  PLLibraryViewController *viewController = [[PLLibraryViewController alloc] init];
  [self.navigationController pushViewController:viewController animated:YES];

  UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
  [cell setSelected:NO];
}

- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath
{
  PLInput *input = [[[PLInputStore sharedStore] allInputs] objectAtIndex:indexPath.row];
  PLAddInputViewController *viewController = [[PLAddInputViewController alloc] initWithInput:input];
  [self.navigationController pushViewController:viewController animated:YES];
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
  if (editingStyle == UITableViewCellEditingStyleDelete) {
    PLInput *input = [[[PLInputStore sharedStore] allInputs] objectAtIndex:indexPath.row];
    [[PLInputStore sharedStore] removeInput:input];
    [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
  }
}

@end
