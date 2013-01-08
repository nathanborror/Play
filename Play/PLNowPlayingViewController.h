//
//  ViewController.h
//  Play
//
//  Created by Nathan Borror on 12/30/12.
//  Copyright (c) 2012 Nathan Borror. All rights reserved.
//

#import <UIKit/UIKit.h>

@class PLSong;

@interface PLNowPlayingViewController : UIViewController <UITableViewDelegate, UITableViewDataSource>

- (id)initWithSong:(PLSong *)song;
- (id)initWithLineIn:(NSString *)uid;

@end
