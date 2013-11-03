//
//  SonosInput.m
//  Play
//
//  Created by Nathan Borror on 1/1/13.
//  Copyright (c) 2013 Nathan Borror. All rights reserved.
//

#import "SonosInput.h"
#import "SonosController.h"
#import "SonosInputStore.h"

@implementation SonosInput

- (id)initWithIP:(NSString *)aIP name:(NSString *)aName uid:(NSString *)aUid icon:(UIImage *)aIcon
{
  if (self = [super init]) {
    _ip = aIP;
    _name = aName;
    _uid = aUid;
    _icon = aIcon;
    _uri = nil;
  }
  return self;
}

- (void)pairWithSonosInput:(SonosInput *)input
{
  _uri = [NSString stringWithFormat:@"x-rincon:%@", input.uid];
  [[SonosController sharedController] play:self uri:_uri completion:nil];
}

- (void)unpair
{
  _uri = [NSString stringWithFormat:@"x-rincon-queue:%@#0", self.uid];
  [[SonosController sharedController] play:self uri:_uri completion:nil];
}


#pragma mark - NSCoding

- (id)initWithCoder:(NSCoder *)aDecoder
{
  self = [super init];
  if (self) {
    [self setIp:[aDecoder decodeObjectForKey:@"ip"]];
    [self setName:[aDecoder decodeObjectForKey:@"name"]];
    [self setUid:[aDecoder decodeObjectForKey:@"uid"]];
    [self setIcon:[aDecoder decodeObjectForKey:@"icon"]];
  }
  return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
  [aCoder encodeObject:_ip forKey:@"ip"];
  [aCoder encodeObject:_name forKey:@"name"];
  [aCoder encodeObject:_uid forKey:@"uid"];
  [aCoder encodeObject:_icon forKey:@"icon"];
}

@end
