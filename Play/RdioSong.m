//
//  RdioSong.m
//  Play
//
//  Created by Drew Ingebretsen on 3/7/13.
//  Copyright (c) 2013 Nathan Borror. All rights reserved.
//

#import "RdioSong.h"

@implementation RdioSong
@synthesize key, name, album, albumArt;

- (NSString *)albumArt
{
  NSString *url = self->albumArt;

  NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"square-200" options:0 error:nil];
  NSTextCheckingResult *match = [regex firstMatchInString:url options:0 range:NSMakeRange(0, url.length)];

  if (match) {
    return [url stringByReplacingOccurrencesOfString:@"square-200" withString:@"square-600"];
  }
  return url;
}

@end
