//
//  RdioAlbum.h
//  Play
//
//  Created by Drew Ingebretsen on 3/7/13.
//  Copyright (c) 2013 Nathan Borror. All rights reserved.
//

#import <Foundation/Foundation.h>

@class RdioArtist, RdioSong;

@interface RdioAlbum : NSObject

@property (nonatomic, retain) NSString *key;
@property (nonatomic, retain) NSString *name;
@property (nonatomic, retain) RdioArtist *artist;
@property (nonatomic, retain) NSMutableArray *songs;

@end
