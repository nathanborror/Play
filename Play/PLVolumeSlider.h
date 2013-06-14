//
//  PLVolumeSlider.h
//  Play
//
//  Created by Nathan Borror on 2/19/13.
//  Copyright (c) 2013 Nathan Borror. All rights reserved.
//

@import UIKit;

@class SonosInput;

@interface PLVolumeSlider : UIView

@property (nonatomic, strong) SonosInput *input;
@property (nonatomic, assign) BOOL hideLabel;

@end
