//
//  SonosInput.m
//  Play
//
//  Created by Nathan Borror on 1/1/13.
//  Copyright (c) 2013 Nathan Borror. All rights reserved.
//

#import "SonosInput.h"

@implementation SonosInput
@synthesize ip, name, uid, icon;

- (id)initWithIP:(NSString *)aIP
            name:(NSString *)aName
             uid:(NSString *)aUid
            icon:(UIImage *)aIcon
{
  self = [super init];
  if (self) {
    self.ip = aIP;
    self.name = aName;
    self.uid = aUid;
    self.icon = aIcon;
  }
  return self;
}

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
  [aCoder encodeObject:ip forKey:@"ip"];
  [aCoder encodeObject:name forKey:@"name"];
  [aCoder encodeObject:uid forKey:@"uid"];
  [aCoder encodeObject:icon forKey:@"icon"];
}

@end
