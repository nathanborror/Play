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


static inline NSString* NSStringFromCA3DTransform(CATransform3D t) {
  return [NSString stringWithFormat:@"[%0.2f %0.2f %0.2f %0.2f; %0.2f %0.2f %0.2f %0.2f; %0.2f %0.2f %0.2f %0.2f; %0.2f %0.2f %0.2f %0.2f]", t.m11, t.m12, t.m13, t.m14, t.m21, t.m22, t.m23, t.m24, t.m31, t.m32, t.m33, t.m34, t.m41, t.m42, t.m43, t.m44];
}

CGFloat* CATransformGetComponents(CATransform3D transform);

@interface NBAnimation : CAKeyframeAnimation

@property (nonatomic, retain) id fromValue;
@property (nonatomic, retain) id byValue;
@property (nonatomic, retain) id toValue;
@property (nonatomic, assign) NSUInteger numberOfBounces;
@property (nonatomic, assign) BOOL shouldOvershoot;         // Default YES
@property (nonatomic, assign) BOOL shake;                   // if shaking, set fromValue to the furthest value, and toValue
// to the current value

+ (NBAnimation *)animationWithKeyPath:(NSString *)keyPath;

@end
