//
//  PLAddInputViewController.h
//  Play
//
//  Created by Nathan Borror on 1/1/13.
//  Copyright (c) 2013 Nathan Borror. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SonosInput;

@interface PLAddInputViewController : UIViewController <UITextFieldDelegate>

- (id)initWithInput:(SonosInput *)aInput;

@end
