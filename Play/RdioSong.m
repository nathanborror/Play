//
//  RdioSong.m
//  Play
//
//  Created by Drew Ingebretsen on 3/7/13.
//  Copyright (c) 2013 Nathan Borror. All rights reserved.
//

#import "RdioSong.h"
#import "RdioAlbum.h"

@implementation RdioSong

- (NSString *)albumArt
{
  NSString *url = _albumArt;

  NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"square-200" options:0 error:nil];
  NSTextCheckingResult *match = [regex firstMatchInString:url options:0 range:NSMakeRange(0, url.length)];

  if (match) {
    return [url stringByReplacingOccurrencesOfString:@"square-200" withString:@"square-600"];
  }
  return url;

  // This pulls the album artwork from sonos but it's low quality
//  NSString *url = [NSString stringWithFormat:@"http://10.0.1.9:1400/getaa?s=1&u=x-sonos-http:_t::%@::p::a%@.mp3?sid=11&flags=32", [self.key stringByReplacingOccurrencesOfString:@"t" withString:@""], self.album.key];
  return url;
}

@end
