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
@class RdioSong;

@interface PLNowPlayingViewController : UIViewController <UITableViewDelegate, UIViewControllerTransitioningDelegate, UISplitViewControllerDelegate>

- (id)initWithSong:(PLSong *)song;
- (id)initWithRdioSong:(RdioSong *)song;

@end
