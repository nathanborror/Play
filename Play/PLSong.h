//
//  PLSong.h
//  Play
//
//  Created by Nathan Borror on 12/31/12.
//  Copyright (c) 2012 Nathan Borror. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PLSong : NSObject

@property (nonatomic, readwrite) NSString *artist;
@property (nonatomic, readwrite) NSString *album;
@property (nonatomic, readwrite) NSString *title;
@property (nonatomic, readwrite) NSString *uri;
@property (nonatomic, readwrite) UIImage *albumArt;
@property (nonatomic, readwrite) NSString *duration;

- (id)initWithArtist:(NSString *)aArtist
               album:(NSString *)aAlbum
               title:(NSString *)aTitle
                 uri:(NSString *)aUri
            albumArt:(UIImage *)aAlbumArt
            duration:(NSString *)aDuration;

@end
