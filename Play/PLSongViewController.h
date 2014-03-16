//
//  PLSongViewController.h
//  Play
//
//  Created by Nathan Borror on 1/1/13.
//  Copyright (c) 2013 Nathan Borror. All rights reserved.
//

@import UIKit;
@import MediaPlayer;
@import AVFoundation;

@interface PLSongViewController : UIViewController <UITableViewDelegate>

- (instancetype)initWithSongs:(NSArray *)aSongs;

@end
