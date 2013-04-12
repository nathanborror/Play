//
//  NBAnimation.m
//  NBKit
//
//  Created by Nathan Borror on 4/11/13.
//  Copyright (c) 2013 Nathan Borror. All rights reserved.
//  Forked from: https://github.com/khanlou/SKBounceAnimation
//

#import "NBAnimation.h"


float NBAnimationFPS = 60.0;

/*
 Keypaths:

 Float animations:
 anchorPoint
 cornerRadius
 borderWidth
 opacity
 shadowRadius
 shadowOpacity
 zPosition

 Point/size animations:
 position
 shadowOffset

 Rect animations:
 bounds
 frame - not strictly animatable, use bounds
 contentsRect

 Colors:
 backgroundColor
 borderColor
 shadowColor

 CATransform3D:
 transform

 Meaningless:
 backgroundFilters
 compositingFilter
 contents
 doubleSided
 filters
 hidden
 mask
 masksToBounds
 sublayers
 sublayerTransform

 */


CGFloat* CATransformGetComponents(CATransform3D transform) {
  CGFloat (*matrix)[4][4] = malloc(4 * 4 * sizeof(CGFloat));
  const char *base = (char *)&transform;

  for (int i = 0; i < 4; i++){
    for (int j = 0; j < 4; j++){
      // Compute address of value.m<i><k>
      CGFloat *pointer = (CGFloat *)(base + (i*4 + j)* sizeof(CGFloat));

      // Access to members via our pointer
      *matrix[i][j] = *pointer;
    }
  }

  return (CGFloat *)matrix;
}


@interface NBAnimation ()

- (void)createValueArray;
- (NSArray *)valueArrayForStartValue:(CGFloat)startValue endValue:(CGFloat)endValue;
- (CGPathRef)createPathFromXValues:(NSArray *)xValues yValues:(NSArray *)yValues;
- (NSArray *)createRectArrayFromXValues:(NSArray *)xValues yValues:(NSArray *)yValues widths:(NSArray *)widths heights:(NSArray *)heights;
- (NSArray *)createColorArrayFromRed:(NSArray *)redValues green:(NSArray *)greenValues blue:(NSArray *)blueValues alpha:(NSArray *)alphaValues;
- (NSArray *)createTransformArrayFromMatrix:(NSArray *)matrix;

@end


@implementation NBAnimation
@synthesize fromValue, byValue, toValue, numberOfBounces, shouldOvershoot;

+ (NBAnimation *)animationWithKeyPath:(NSString *)keyPath
{
  return [[self alloc] initWithKeyPath:keyPath];
}

- (id)initWithKeyPath:(NSString*)keyPath
{
  self = [super init];
  if (self){
    super.keyPath = keyPath;
    self.numberOfBounces = 2;
    self.shouldOvershoot = YES;
  }
  return self;
}

- (void)setFromValue:(id)newFromValue
{
  [super setValue:newFromValue forKey:@"fromValueKey"];
  [self createValueArray];
}

- (void)setByValue:(id)newByValue
{
  [super setValue:newByValue forKey:@"byValueKey"];
  // Don't know if this is to spec
  self.toValue = [NSNumber numberWithFloat:((NSNumber *)self.fromValue).floatValue + ((NSNumber *)self.byValue).floatValue];
  [self createValueArray];
}

- (void)setToValue:(id)newToValue
{
  [super setValue:newToValue forKey:@"toValueKey"];
  [self createValueArray];
}

- (void)setDuration:(CFTimeInterval)newDuration
{
  [super setDuration:newDuration];
  [self createValueArray];
}

- (void)setNumberOfBounces:(NSUInteger)newNumberOfBounces
{
  [super setValue:[NSNumber numberWithUnsignedInt:newNumberOfBounces] forKey:@"numBounces"];
  [self createValueArray];
}

- (NSUInteger)numberOfBounces
{
  return [[super valueForKey:@"numBounces"] unsignedIntValue];
}

- (void)setShouldOvershoot:(BOOL)newShouldOvershoot
{
  [super setValue:[NSNumber numberWithBool:newShouldOvershoot] forKey:@"shouldOvershootKey"];
  [self createValueArray];
}

- (BOOL)shouldOvershoot
{
  return [[super valueForKey:@"shouldOvershootKey"] boolValue];
}

- (void)setShake:(BOOL)newShake
{
  [super setValue:[NSNumber numberWithBool:newShake] forKey:@"shakeKey"];
  [self createValueArray];
}

- (BOOL)shake
{
  return [[super valueForKey:@"shakeKey"] boolValue];
}

- (id)fromValue
{
  return [super valueForKey:@"fromValueKey"];
}

- (id)byValue
{
  return [super valueForKey:@"byValueKey"];
}

- (id)toValue
{
  return [super valueForKey:@"toValueKey"];
}

- (void)createValueArray
{
  if (!self.fromValue || !self.toValue || !self.duration) {
    return;
  }

  if ([self.fromValue isKindOfClass:NSNumber.class] && [self.toValue isKindOfClass:NSNumber.class]){
    self.values = [self valueArrayForStartValue:((NSNumber *)self.fromValue).floatValue endValue:((NSNumber *)self.toValue).floatValue];
  } else if ([self.fromValue isKindOfClass:UIColor.class] && [self.toValue isKindOfClass:UIColor.class]){
    const CGFloat *fromComponents = CGColorGetComponents(((UIColor*)self.fromValue).CGColor);
    const CGFloat *toComponents   = CGColorGetComponents(((UIColor*)self.toValue).CGColor);

    // Uncomment this to see start and target color components
    //NSLog(@"from %0.2f %0.2f %0.2f %0.2f", fromComponents[0], fromComponents[1], fromComponents[2], fromComponents[3]);
    //NSLog(@"to %0.2f %0.2f %0.2f %0.2f", toComponents[0], toComponents[1], toComponents[2], toComponents[3]);

    self.values = [self createColorArrayFromRed:[self valueArrayForStartValue:fromComponents[0] endValue:toComponents[0]]
                                          green:[self valueArrayForStartValue:fromComponents[1] endValue:toComponents[1]]
                                           blue:[self valueArrayForStartValue:fromComponents[2] endValue:toComponents[2]]
                                          alpha:[self valueArrayForStartValue:fromComponents[3] endValue:toComponents[3]]];
  } else if ([self.fromValue isKindOfClass:NSValue.class] && [self.toValue isKindOfClass:NSValue.class]){
    NSString *valueType = [NSString stringWithCString:[self.fromValue objCType] encoding:NSStringEncodingConversionAllowLossy];
    if ([valueType rangeOfString:@"CGRect"].location == 1) {
      CGRect fromRect = [self.fromValue CGRectValue];
      CGRect toRect = [self.toValue CGRectValue];
      self.values = [self createRectArrayFromXValues:
                     [self valueArrayForStartValue:fromRect.origin.x endValue:toRect.origin.x]
                                             yValues:
                     [self valueArrayForStartValue:fromRect.origin.y endValue:toRect.origin.y]
                                              widths:
                     [self valueArrayForStartValue:fromRect.size.width endValue:toRect.size.width]
                                             heights:
                     [self valueArrayForStartValue:fromRect.size.height endValue:toRect.size.height]];

    } else if ([valueType rangeOfString:@"CGPoint"].location == 1) {
      CGPoint fromPoint = [self.fromValue CGPointValue];
      CGPoint toPoint   = [self.toValue CGPointValue];

      CGPathRef path = [self createPathFromXValues:[self valueArrayForStartValue:fromPoint.x endValue:toPoint.x]
                                           yValues:[self valueArrayForStartValue:fromPoint.y endValue:toPoint.y]];
      self.path = path;
      CGPathRelease(path);

    } else if ([valueType rangeOfString:@"CATransform3D"].location == 1) {
      CATransform3D fromTransform = [self.fromValue CATransform3DValue];
      CATransform3D toTransform = [self.toValue CATransform3DValue];

      const char *toBase   = (char *)&fromTransform;
      const char *fromBase = (char *)&toTransform;

      /*// Uncomment this to see start and target transform components
       NSLog(@"from: %@", NSStringFromCA3DTransform(fromTransform));
       NSLog(@"to:   %@", NSStringFromCA3DTransform(toTransform));*/

      NSMutableArray* matrix = [NSMutableArray arrayWithCapacity:4];

      for (int j = 0; j < 4; j++){
        matrix[j] = [NSMutableArray arrayWithCapacity:4];
        for (int k = 0; k < 4; k++){
          // Compute address of value.m<i><k>
          CGFloat *fromAddress = (CGFloat *)(toBase   + (j*4 + k)* sizeof(CGFloat));
          CGFloat *toAddress   = (CGFloat *)(fromBase + (j*4 + k)* sizeof(CGFloat));

          // Access to members via our pointer
          matrix[j][k] = [self valueArrayForStartValue:*fromAddress endValue:*toAddress];
        }
      }

      self.values = [self createTransformArrayFromMatrix:matrix];
    } else if ([valueType rangeOfString:@"CGSize"].location == 1) {
      CGSize fromSize = [self.fromValue CGSizeValue];
      CGSize toSize   = [self.toValue CGSizeValue];

      CGPathRef path = [self createPathFromXValues:[self valueArrayForStartValue:fromSize.width endValue:toSize.width]
                                           yValues:[self valueArrayForStartValue:fromSize.height endValue:toSize.height]];
      CGPathRelease(path);
    }

    self.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
  }
}

- (NSArray *)createRectArrayFromXValues:(NSArray *)xValues yValues:(NSArray *)yValues widths:(NSArray *)widths heights:(NSArray *)heights
{
  NSAssert(xValues.count == yValues.count && xValues.count == widths.count && xValues.count == heights.count, @"array must have arrays of equal size");

  NSUInteger numberOfRects = xValues.count;
  NSMutableArray *values = [NSMutableArray arrayWithCapacity:numberOfRects];
  CGRect value;

  for (int i = 1; i < numberOfRects; i++) {
    value = CGRectMake(
                       [xValues[i] floatValue],
                       [yValues[i] floatValue],
                       [widths[i] floatValue],
                       [heights[i] floatValue]
                       );
    [values addObject:[NSValue valueWithCGRect:value]];
  }
  return values;
}

- (CGPathRef)createPathFromXValues:(NSArray *)xValues yValues:(NSArray *)yValues
{
  NSUInteger numberOfPoints = xValues.count;
  CGMutablePathRef path = CGPathCreateMutable();
  CGPoint value;
  value = CGPointMake([[xValues objectAtIndex:0] floatValue], [[yValues objectAtIndex:0] floatValue]);
  CGPathMoveToPoint(path, NULL, value.x, value.y);

  for (int i = 1; i < numberOfPoints; i++){
    value = CGPointMake([xValues[i] floatValue], [yValues[i] floatValue]);
    CGPathAddLineToPoint(path, NULL, value.x, value.y);
  }

  return path;
}

- (NSArray *)createTransformArrayFromMatrix:(NSArray *)matrix
{
  // Number of transforms to create
  NSUInteger numberOfTransforms = ((NSArray *)matrix[0][0]).count;

  // Collection for NSValues with transforms
  NSMutableArray *values = [NSMutableArray arrayWithCapacity:numberOfTransforms];

  // Transform to fill
  CATransform3D value;
  const char *base = (char *)&value;

  for (int i = 1; i < numberOfTransforms; i++) {
    // Reset transform
    value = CATransform3DIdentity;

    for (int j = 0; j < 4; j++) {
      for (int k = 0; k < 4; k++) {
        // Read value, which should be written
        NSNumber* value = matrix[j][k][i];

        // Compute address of value.m<j><k>
        CGFloat *member = (CGFloat *)(base + (j*4 + k)* sizeof(CGFloat));

        // Write to member via our pointer
        *member = value.floatValue;
      }
    }

    [values addObject:[NSValue valueWithCATransform3D:value]];
  }

  return values;
}

- (NSArray *)createColorArrayFromRed:(NSArray *)redValues green:(NSArray *)greenValues blue:(NSArray *)blueValues alpha:(NSArray *)alphaValues
{
  NSAssert(redValues.count == blueValues.count && redValues.count == greenValues.count && redValues.count == alphaValues.count, @"array must have arrays of equal size");

  NSUInteger numberOfColors = redValues.count;
  NSMutableArray *values = [NSMutableArray arrayWithCapacity:numberOfColors];
  UIColor *value;

  for (int i = 1; i < numberOfColors; i++){
    value = [UIColor colorWithRed:[redValues[i] floatValue]
                            green:[greenValues[i] floatValue]
                             blue:[blueValues[i] floatValue]
                            alpha:[alphaValues[i] floatValue]];
    //NSLog(@"a color %@", value);
    [values addObject:(id)value.CGColor];
  }

  return values;
}

- (NSArray *)valueArrayForStartValue:(CGFloat)startValue endValue:(CGFloat)endValue
{
  // Calculate step count for duration and fixed FPS
  int steps = NBAnimationFPS * self.duration;

  CGFloat alpha = 0;
  if (startValue == endValue) {
    alpha = log2f(0.1f)/steps;
  } else {
    alpha = log2f(0.1f/fabsf(endValue - startValue))/steps;
  }
  if (alpha > 0) {
    alpha = -1.0f*alpha;
  }
  CGFloat numberOfPeriods = self.numberOfBounces/2 + 0.5;
  CGFloat omega = numberOfPeriods * 2*M_PI/steps;

  // Uncomment this to get the equation of motion
  //NSLog(@"y = %0.2f * e^(%0.5f*x)*cos(%0.10f*x)+ %0.0f over %d frames", startValue - endValue, alpha, omega, endValue, steps);

  NSMutableArray *values = [NSMutableArray arrayWithCapacity:steps];
  CGFloat value = 0;

  const CGFloat sign = (endValue - startValue) / fabsf(endValue - startValue);

  CGFloat oscillationComponent;
  CGFloat coefficient;

  // Conforms to y = A * e^(-alpha*t)*cos(omega*t)
  for (int t = 0; t < steps; t++) {
    // Decaying mass-spring-damper solution with initial displacement

    if (self.shake) {
      oscillationComponent = sin(omega*t);
    } else {
      oscillationComponent = cos(omega*t);
    }

    if (self.shouldOvershoot) {
      coefficient =  (startValue - endValue);
    } else {
      coefficient = -1*sign*fabsf((startValue - endValue));
    }

    value = coefficient * pow(2.71, alpha*t)* oscillationComponent + endValue;
    
    [values addObject:[NSNumber numberWithFloat:value]];
  }
  
  return values;
}

@end
