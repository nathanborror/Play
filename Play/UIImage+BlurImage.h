//
//  UIImage+BlurImage.h
//  Play
//
//  Created by Nathan Borror on 6/15/13.
//  Copyright (c) 2013 Nathan Borror. All rights reserved.
//

@import UIKit;

@interface UIImage (BlurImage)

+ (UIImage *)blurImage:(UIImage *)image radius:(CGFloat)radius scale:(CGFloat)scale;
+ (UIImage *)blurImageNamed:(NSString *)name radius:(CGFloat)radius scale:(CGFloat)scale;

@end
