//
//  SonosInputCell.h
//  Play
//
//  Created by Nathan Borror on 4/14/13.
//  Copyright (c) 2013 Nathan Borror. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

@class SonosInput;

@interface SonosInputCell : UIButton

@property (nonatomic, strong) SonosInput *input;

- (id)initWithInput:(SonosInput *)aInput;
- (void)startDragging;
- (void)stopDragging;

@end
