//
//  PLLibraryViewController.h
//  Play
//
//  Created by Nathan Borror on 1/1/13.
//  Copyright (c) 2013 Nathan Borror. All rights reserved.
//

@import UIKit;

@class SonosController;

@interface PLLibraryViewController : UIViewController <UITableViewDelegate>

- (instancetype)initWithController:(SonosController *)controller;

@end
