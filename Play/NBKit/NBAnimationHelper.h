//
//  NBAnimationHelper.h
//  Play
//
//  Created by Nathan Borror on 5/26/13.
//  Copyright (c) 2013 Nathan Borror. All rights reserved.
//

@import Foundation;
#import "NBAnimation.h"

@interface NBAnimationHelper : NSObject

+ (NBAnimation *)animate:(UIView *)view
                    from:(id)from
                      to:(id)to
                duration:(CGFloat)duration
               stiffness:(NBAnimationStiffness)stiffness
              forKeyPath:(NSString *)keyPath
                  forKey:(NSString *)key
                delegate:(id)delegate;

+ (NBAnimation *)animatePosition:(UIView *)view
                            from:(CGPoint)from
                              to:(CGPoint)to
                          forKey:(NSString *)key
                        delegate:(id)delegate;

+ (NBAnimation *)animateTransform:(UIView *)view
                             from:(CATransform3D)from
                               to:(CATransform3D)to
                           forKey:(NSString *)key
                         delegate:(id)delegate;

+ (NBAnimation *)animateBounds:(UIView *)view
                          from:(CGRect)from
                            to:(CGRect)to
                        forKey:(NSString *)key
                      delegate:(id)delegate;

@end
