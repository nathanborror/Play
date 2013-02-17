//
//  PLAddInputViewController.m
//  Play
//
//  Created by Nathan Borror on 1/1/13.
//  Copyright (c) 2013 Nathan Borror. All rights reserved.
//

#import "PLAddInputViewController.h"
#import "PLTextField.h"
#import "SonosInput.h"
#import "SonosInputStore.h"
#import "UIViewController+ModalCheck.h"

static float kFieldPadding = 20.f;

@interface PLAddInputViewController ()
{
  SonosInput *input;
  UITextField *ipTextField;
  UITextField *nameTextField;
  UITextField *uidTextField;
}
@end

@implementation PLAddInputViewController

- (id)init
{
  return [self initWithInput:nil];
}

- (id)initWithInput:(SonosInput *)aInput
{
  self = [super init];
  if (self) {
    input = aInput;

    if (input) {
      [self.navigationItem setTitle:input.name];
    } else {
      [self.navigationItem setTitle:@"Add Speaker"];
      if (self.isPresentedAsModal) {
        // Cancel Button
        UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancel)];
        [self.navigationItem setLeftBarButtonItem:cancelButton];
      }
    }

    // Done Button
    UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(done)];
    [self.navigationItem setRightBarButtonItem:doneButton];

    [self.view setBackgroundColor:[UIColor colorWithRed:.82 green:.85 blue:.91 alpha:1]];
  }
  return self;
}

- (void)viewDidLoad
{
  [super viewDidLoad];

  // IP Input
  ipTextField = [[PLTextField alloc] initWithFrame:CGRectMake(kFieldPadding, 50, CGRectGetWidth(self.view.frame)-(kFieldPadding*2), 50)];
  [ipTextField setDelegate:self];
  [ipTextField setPlaceholder:@"IP Address"];
  [ipTextField setText:input.ip];
  [ipTextField setReturnKeyType:UIReturnKeyNext];
  [self.view addSubview:ipTextField];

  nameTextField = [[PLTextField alloc] initWithFrame:CGRectMake(kFieldPadding, CGRectGetMaxY(ipTextField.frame)+kFieldPadding, CGRectGetWidth(self.view.frame)-(kFieldPadding*2), 50)];
  [nameTextField setDelegate:self];
  [nameTextField setPlaceholder:@"Name"];
  [nameTextField setText:input.name];
  [nameTextField setReturnKeyType:UIReturnKeyNext];
  [self.view addSubview:nameTextField];

  uidTextField = [[PLTextField alloc] initWithFrame:CGRectMake(kFieldPadding, CGRectGetMaxY(nameTextField.frame)+kFieldPadding, CGRectGetWidth(self.view.frame)-(kFieldPadding*2), 50)];
  [uidTextField setDelegate:self];
  [uidTextField setPlaceholder:@"UID"];
  [uidTextField setText:input.uid];
  [uidTextField setReturnKeyType:UIReturnKeyDone];
  [self.view addSubview:uidTextField];
}

- (void)viewDidAppear:(BOOL)animated
{
  [super viewDidAppear:animated];
  [ipTextField becomeFirstResponder];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
  if (textField == ipTextField) {
    [nameTextField becomeFirstResponder];
  } else if (textField == nameTextField) {
    [uidTextField becomeFirstResponder];
  } else {
    [nameTextField resignFirstResponder];
  }
  return YES;
}

- (void)done
{
  [[SonosInputStore sharedStore] addInputWithIP:[ipTextField text] name:[nameTextField text] uid:[uidTextField text]];
  [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

- (void)cancel
{
  [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

@end
