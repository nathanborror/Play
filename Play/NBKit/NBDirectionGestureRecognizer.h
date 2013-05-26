//
//  NBDirectionGestureRecognizer.h
//  NBKit
//
//  Created by Nathan Borror on 2/19/13.
//  Copyright (c) 2013 Nathan Borror. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIGestureRecognizerSubclass.h>

typedef enum {
  NBDirectionPanGestureRecognizerVertical,
  NBDirectionPanGestureRecognizerHorizontal
} NBDirectionPanGestureRecognizer;

@interface NBDirectionGestureRecognizer : UIPanGestureRecognizer

@property (nonatomic, assign) NBDirectionPanGestureRecognizer direction;

@end
