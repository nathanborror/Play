//
//  PLInputCell.h
//  Play
//
//  Created by Nathan Borror on 4/14/13.
//  Copyright (c) 2013 Nathan Borror. All rights reserved.
//

@import UIKit;
@import QuartzCore;

@class SonosInput;

@interface PLInputCell : UICollectionViewCell

@property (nonatomic, strong) SonosInput *input;
@property (nonatomic, assign) CGPoint origin;

- (void)pair:(SonosInput *)master;
- (void)unpair;

@end
