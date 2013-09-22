//
//  UIImage+BlurImage.m
//  Play
//
//  Created by Nathan Borror on 6/15/13.
//  Copyright (c) 2013 Nathan Borror. All rights reserved.
//

#import "UIImage+BlurImage.h"

@implementation UIImage (BlurImage)

+ (UIImage *)blurImage:(UIImage *)image radius:(CGFloat)radius scale:(CGFloat)scale
{
  CIImage *inputImage = [[CIImage alloc] initWithImage:image];
  CIFilter *blurFilter = [CIFilter filterWithName:@"CIGaussianBlur"];
  [blurFilter setDefaults];
  [blurFilter setValue:inputImage forKey:@"inputImage"];
  [blurFilter setValue:[NSNumber numberWithFloat:radius] forKey:@"inputRadius"];
  CIImage *outputImage = [blurFilter valueForKey:@"outputImage"];
  CIContext *context = [CIContext contextWithOptions:nil];

  return [UIImage imageWithCGImage:[context createCGImage:outputImage fromRect:outputImage.extent] scale:scale orientation:UIImageOrientationUp];
}

+ (UIImage *)blurImageNamed:(NSString *)name radius:(CGFloat)radius scale:(CGFloat)scale
{
  return [UIImage blurImage:[UIImage imageNamed:name] radius:radius scale:scale];
}

@end
