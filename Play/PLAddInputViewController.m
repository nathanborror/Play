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
  SonosInput *_input;
  UITextField *_ipTextField;
  UITextField *_nameTextField;
  UITextField *_uidTextField;
}

- (id)init
{
  return [self initWithInput:nil];
}

- (id)initWithInput:(SonosInput *)aInput
{
  if (self = [super init]) {
    _input = aInput;
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

  if (_input) {
    [self setTitle:_input.name];
  } else {
    if (self.isPresentedAsModal) {
      // Cancel Button
      UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancel)];
      [self.navigationItem setLeftBarButtonItem:cancelButton];
    }
  }

  // IP Input
  _ipTextField = [[UITextField alloc] initWithFrame:CGRectMake(kFieldPadding, 80, CGRectGetWidth(self.view.frame)-(kFieldPadding*2), 50)];
  [_ipTextField setDelegate:self];
  [_ipTextField setPlaceholder:@"IP Address"];
  [_ipTextField setText:_input.ip];
  [_ipTextField setReturnKeyType:UIReturnKeyNext];
  [_ipTextField setBorderStyle:UITextBorderStyleRoundedRect];
  [self.view addSubview:_ipTextField];

  _nameTextField = [[UITextField alloc] initWithFrame:CGRectMake(kFieldPadding, CGRectGetMaxY(_ipTextField.frame)+kFieldPadding, CGRectGetWidth(self.view.frame)-(kFieldPadding*2), 50)];
  [_nameTextField setDelegate:self];
  [_nameTextField setPlaceholder:@"Name"];
  [_nameTextField setText:_input.name];
  [_nameTextField setReturnKeyType:UIReturnKeyNext];
  [_nameTextField setBorderStyle:UITextBorderStyleRoundedRect];
  [self.view addSubview:_nameTextField];

  _uidTextField = [[UITextField alloc] initWithFrame:CGRectMake(kFieldPadding, CGRectGetMaxY(_nameTextField.frame)+kFieldPadding, CGRectGetWidth(self.view.frame)-(kFieldPadding*2), 50)];
  [_uidTextField setDelegate:self];
  [_uidTextField setPlaceholder:@"UID"];
  [_uidTextField setText:_input.uid];
  [_uidTextField setReturnKeyType:UIReturnKeyDone];
  [_uidTextField setBorderStyle:UITextBorderStyleRoundedRect];
  [self.view addSubview:_uidTextField];
}

- (void)viewDidAppear:(BOOL)animated
{
  [super viewDidAppear:animated];
  [_ipTextField becomeFirstResponder];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
  if (textField == _ipTextField) {
    [_nameTextField becomeFirstResponder];
  } else if (textField == _nameTextField) {
    [_uidTextField becomeFirstResponder];
  } else {
    [_nameTextField resignFirstResponder];
  }
  return YES;
}

- (void)done
{
  [[SonosInputStore sharedStore] addInputWithIP:[_ipTextField text] name:[_nameTextField text] uid:[_uidTextField text] icon:nil];
  [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

- (void)cancel
{
  [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

@end
