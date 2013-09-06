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

static const CGFloat kFieldPadding = 10.0;

@implementation PLAddInputViewController {
  SonosInput *input;
  UITextField *ipTextField;
  UITextField *nameTextField;
  UITextField *uidTextField;
}

- (id)init
{
  return [self initWithInput:nil];
}

- (id)initWithInput:(SonosInput *)aInput
{
  if (self = [super init]) {
    input = aInput;
  }
  return self;
}

- (void)viewDidLoad
{
  [super viewDidLoad];

  [self setTitle:@"Add Speaker"];
  [self.view setBackgroundColor:[UIColor whiteColor]];

  UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(done)];
  [self.navigationItem setRightBarButtonItem:doneButton];

  if (input) {
    [self setTitle:input.name];
  } else {
    if (self.isPresentedAsModal) {
      // Cancel Button
      UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancel)];
      [self.navigationItem setLeftBarButtonItem:cancelButton];
    }
  }

  // IP Input
  ipTextField = [[UITextField alloc] initWithFrame:CGRectMake(kFieldPadding, 80, CGRectGetWidth(self.view.frame)-(kFieldPadding*2), 50)];
  [ipTextField setDelegate:self];
  [ipTextField setPlaceholder:@"IP Address"];
  [ipTextField setText:input.ip];
  [ipTextField setReturnKeyType:UIReturnKeyNext];
  [ipTextField setBorderStyle:UITextBorderStyleRoundedRect];
  [self.view addSubview:ipTextField];

  nameTextField = [[UITextField alloc] initWithFrame:CGRectMake(kFieldPadding, CGRectGetMaxY(ipTextField.frame)+kFieldPadding, CGRectGetWidth(self.view.frame)-(kFieldPadding*2), 50)];
  [nameTextField setDelegate:self];
  [nameTextField setPlaceholder:@"Name"];
  [nameTextField setText:input.name];
  [nameTextField setReturnKeyType:UIReturnKeyNext];
  [nameTextField setBorderStyle:UITextBorderStyleRoundedRect];
  [self.view addSubview:nameTextField];

  uidTextField = [[UITextField alloc] initWithFrame:CGRectMake(kFieldPadding, CGRectGetMaxY(nameTextField.frame)+kFieldPadding, CGRectGetWidth(self.view.frame)-(kFieldPadding*2), 50)];
  [uidTextField setDelegate:self];
  [uidTextField setPlaceholder:@"UID"];
  [uidTextField setText:input.uid];
  [uidTextField setReturnKeyType:UIReturnKeyDone];
  [uidTextField setBorderStyle:UITextBorderStyleRoundedRect];
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
  [[SonosInputStore sharedStore] addInputWithIP:[ipTextField text] name:[nameTextField text] uid:[uidTextField text] icon:nil];
  [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

- (void)cancel
{
  [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

@end
