//
//  SonosInput.m
//  Play
//
//  Created by Nathan Borror on 1/1/13.
//  Copyright (c) 2013 Nathan Borror. All rights reserved.
//

#import "SonosInput.h"

@implementation SonosInput
@synthesize ip, name, uid;

- (id)initWithIP:(NSString *)aIP
            name:(NSString *)aName
             uid:(NSString *)aUid
{
  self = [super init];
  if (self) {
    self.ip = aIP;
    self.name = aName;
    self.uid = aUid;
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
  }
  return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
  [aCoder encodeObject:ip forKey:@"ip"];
  [aCoder encodeObject:name forKey:@"name"];
  [aCoder encodeObject:uid forKey:@"uid"];
}

@end
