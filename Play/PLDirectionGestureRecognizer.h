//
//  PLDirectionGestureRecognizer.h
//  Play
//
//  Created by Nathan Borror on 2/19/13.
//  Copyright (c) 2013 Nathan Borror. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIGestureRecognizerSubclass.h>

typedef enum {
  DirectionPanGestureRecognizerVertical,
  DirectionPanGestureRecognizerHorizontal
} DirectionPanGestureRecognizerDirection;

@interface PLDirectionGestureRecognizer : UIPanGestureRecognizer

@property (nonatomic, assign) DirectionPanGestureRecognizerDirection direction;

@end
