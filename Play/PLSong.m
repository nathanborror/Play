//
//  PLSong.m
//  Play
//
//  Created by Nathan Borror on 12/31/12.
//  Copyright (c) 2012 Nathan Borror. All rights reserved.
//

#import "PLSong.h"

@implementation PLSong
@synthesize artist, album, title, uri, albumArt, duration;

- (id)initWithArtist:(NSString *)aArtist
               album:(NSString *)aAlbum
               title:(NSString *)aTitle
                 uri:(NSString *)aUri
            albumArt:(UIImage *)aAlbumArt
            duration:(NSString *)aDuration
{
  self = [super init];
  if (self) {
    self.artist = aArtist;
    self.album = aAlbum;
    self.title = aTitle;
    self.uri = aUri;
    self.albumArt = aAlbumArt;
    self.duration = aDuration;
  }
  return self;
}

@end
