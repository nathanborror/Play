//
//  ViewController+ModalCheck.m
//  Play
//
//  Created by Nathan Borror on 1/1/13.
//  Copyright (c) 2013 Nathan Borror. All rights reserved.
//

#import "UIViewController+ModalCheck.h"

@implementation UIViewController(ModalCheck)

- (BOOL)isPresentedAsModal {
  return (
           (self.presentingViewController &&
            self.presentingViewController.presentedViewController == self)
           ||
           // If I have a navigation controller, check if its parent modal
           // view controller is self navigation controller.
           (self.navigationController &&
            self.navigationController.presentingViewController &&
            self.navigationController.presentingViewController.presentedViewController == self.navigationController)
           ||
           // If the parent of my UITabBarController is also a UITabBarController
           // class, then there is no way to do that, except by using a modal presentation
           [[[self tabBarController] presentingViewController] isKindOfClass:[UITabBarController class]]
         );
}

@end
