//
//  ViewController.h
//  Play
//
//  Created by Nathan Borror on 12/30/12.
//  Copyright (c) 2012 Nathan Borror. All rights reserved.
//

@import UIKit;
@import QuartzCore;

@class PLSong;
@class SonosInput;
@class RdioSong;
@class PLNowPlayingViewController;

@protocol PLNowPlayingViewControllerDelegate

- (void)nowPlayingViewController:(PLNowPlayingViewController *)viewController handleViewController:(UIViewController *)toViewController;

@end

@interface PLNowPlayingViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, UIViewControllerTransitioningDelegate, UISplitViewControllerDelegate>

@property (nonatomic, weak) id<PLNowPlayingViewControllerDelegate> delegate;

- (id)initWithSong:(PLSong *)song;
- (id)initWithRdioSong:(RdioSong *)song;
- (id)initWithLineIn:(SonosInput *)input;

@end
