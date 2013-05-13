//
//  SonosInputCell.h
//  Play
//
//  Created by Nathan Borror on 4/14/13.
//  Copyright (c) 2013 Nathan Borror. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

typedef NS_ENUM(NSInteger, SonosInputCellStatus) {
  SonosInputCellStatusPlaying,
  SonosInputCellStatusStopped,
  SonosInputCellStatusPaused,
};

@class SonosInput;

@interface SonosInputCell : UIButton

@property (nonatomic, strong) SonosInput *input;
@property (nonatomic, assign) CGPoint origin;
@property (nonatomic, assign) SonosInputCellStatus status;

- (id)initWithInput:(SonosInput *)aInput;
- (void)startDragging;
- (void)stopDragging;
- (void)pair:(SonosInput *)master;
- (void)unpair;

@end
