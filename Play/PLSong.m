//
//  PLSong.m
//  Play
//
//  Created by Nathan Borror on 12/31/12.
//  Copyright (c) 2012 Nathan Borror. All rights reserved.
//

#import "PLSong.h"

@implementation PLSong

- (instancetype)initWithArtist:(NSString *)aArtist
                         album:(NSString *)aAlbum
                         title:(NSString *)aTitle
                           uri:(NSString *)aUri
                      albumArt:(UIImage *)aAlbumArt
                      duration:(NSString *)aDuration
{
  if (self = [super init]) {
    _artist = aArtist;
    _album = aAlbum;
    _title = aTitle;
    _uri = aUri;
    _albumArt = aAlbumArt;
    _duration = aDuration;
  }
  return self;
}

@end
