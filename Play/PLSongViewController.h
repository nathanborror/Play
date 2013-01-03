//
//  PLSongViewController.h
//  Play
//
//  Created by Nathan Borror on 1/1/13.
//  Copyright (c) 2013 Nathan Borror. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MediaPlayer/MediaPlayer.h>
#import <AVFoundation/AVFoundation.h>

@interface PLSongViewController : UIViewController <UITableViewDelegate, UITableViewDataSource>

- (id)initWithSongs:(NSArray *)aSongs;

@end
