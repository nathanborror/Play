//
//  NBAnimation.h
//  NBKit
//
//  Created by Nathan Borror on 4/11/13.
//  Copyright (c) 2013 Nathan Borror. All rights reserved.
//  Forked from: https://github.com/khanlou/SKBounceAnimation
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

typedef enum {
	NBAnimationStiffnessLight,
	NBAnimationStiffnessMedium,
	NBAnimationStiffnessHeavy
} NBAnimationStiffness;

@interface NBAnimation : CAKeyframeAnimation

@property (nonatomic, retain) id fromValue;
@property (nonatomic, retain) id byValue;
@property (nonatomic, retain) id toValue;
@property (nonatomic, assign) NSUInteger numberOfBounces;
@property (nonatomic, assign) BOOL shouldOvershoot; //default YES
@property (nonatomic, assign) BOOL shake; //if shaking, set fromValue to the furthest value, and toValue to the current value
@property (nonatomic, assign) NBAnimationStiffness stiffness;

+ (NBAnimation *) animationWithKeyPath:(NSString*)keyPath;


@end