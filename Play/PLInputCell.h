//
//  PLInputCell.h
//  Play
//
//  Created by Nathan Borror on 4/14/13.
//  Copyright (c) 2013 Nathan Borror. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

@class PLInput;

@interface PLInputCell : UICollectionViewCell

@property (nonatomic, strong) PLInput *input;
@property (nonatomic, assign) CGPoint origin;

- (void)pair:(PLInput *)master;
- (void)unpair;

@end
