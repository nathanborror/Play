//
//  PLInputCell.h
//  Play
//
//  Created by Nathan Borror on 4/14/13.
//  Copyright (c) 2013 Nathan Borror. All rights reserved.
//

@import UIKit;
@import QuartzCore;

typedef NS_ENUM(NSInteger, PLInputCellStatus) {
  PLInputCellStatusPlaying,
  PLInputCellStatusStopped,
  PLInputCellStatusPaused,
};

@class SonosInput;

@interface PLInputCell : UICollectionViewCell

@property (nonatomic, strong) SonosInput *input;
@property (nonatomic, assign) CGPoint origin;
@property (nonatomic, assign) PLInputCellStatus status;
@property (nonatomic, strong) UILabel *label;
@property (nonatomic, strong) UIImageView *indicator;
@property (nonatomic, strong) UIImageView *speakerIcon;

- (void)startDragging;
- (void)stopDragging;
- (void)pair:(SonosInput *)master;
- (void)unpair;

@end
