//
//  PLInput.m
//  Play
//
//  Created by Nathan Borror on 1/1/13.
//  Copyright (c) 2013 Nathan Borror. All rights reserved.
//

#import "PLInput.h"

@implementation PLInput
@synthesize ip, name;

- (id)initWithIP:(NSString *)aIP
            name:(NSString *)aName
{
  self = [super init];
  if (self) {
    self.ip = aIP;
    self.name = aName;
  }
  return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
  self = [super init];
  if (self) {
    [self setIp:[aDecoder decodeObjectForKey:@"ip"]];
    [self setName:[aDecoder decodeObjectForKey:@"name"]];
  }
  return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
  [aCoder encodeObject:ip forKey:@"ip"];
  [aCoder encodeObject:name forKey:@"name"];
}

@end
