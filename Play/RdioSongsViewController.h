//
//  RdioSongsViewController.h
//  Play
//
//  Created by Nathan Borror on 7/7/13.
//  Copyright (c) 2013 Nathan Borror. All rights reserved.
//

@import UIKit;
#import <Rdio/Rdio.h>

@class RdioPlaylist;

@interface RdioSongsViewController : UITableViewController <RDAPIRequestDelegate, RdioDelegate>

- (id)initWithPlaylist:(RdioPlaylist *)aPlaylist;

@end
