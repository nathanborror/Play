//
//  PLSpeakersViewController.h
//  Play
//
//  Created by Nathan Borror on 1/1/13.
//  Copyright (c) 2013 Nathan Borror. All rights reserved.
//

@import UIKit;
@import QuartzCore;

#import "SonosInput.h"
#import "PLNowPlayingViewController.h"

@interface PLSpeakersViewController : UIViewController <SonosInputDelegate, UISplitViewControllerDelegate, PLNowPlayingViewControllerDelegate>

@end
