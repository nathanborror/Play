//
//  NBAnimationHelper.h
//  Play
//
//  Created by Nathan Borror on 5/26/13.
//  Copyright (c) 2013 Nathan Borror. All rights reserved.
//

#import <Foundation/Foundation.h>

@class NBAnimation;

@interface NBAnimationHelper : NSObject

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
