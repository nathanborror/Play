//
//  PLInput.m
//  Play
//
//  Created by Nathan Borror on 1/1/13.
//  Copyright (c) 2013 Nathan Borror. All rights reserved.
//

#import "PLInput.h"
#import "SonosController.h"
#import "PLInputStore.h"

@implementation PLInput

- (instancetype)initWithIP:(NSString *)aIP name:(NSString *)aName uid:(NSString *)aUid
{
  if (self = [super init]) {
    _ip = aIP;
    _name = aName;
    _uid = aUid;
  }
  return self;
}

- (NSString *)description
{
  return [NSString stringWithFormat:@"<PLInput: %@>", _name];
}

//- (void)pairWithInput:(PLInput *)master
//{
//  _uri = [NSString stringWithFormat:@"x-rincon:%@", master.uid];
//  [[SonosController sharedController] play:self uri:_uri completion:nil];
//  _status = PLInputStatusSlave;
//}
//
//- (void)unpair
//{
//  _uri = [NSString stringWithFormat:@"x-rincon-queue:%@#0", self.uid];
//  [[SonosController sharedController] play:self uri:_uri completion:nil];
//  _status = PLInputStatusStopped;
//}

#pragma mark - NSCoding

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
  self = [super init];
  if (self) {
    [self setIp:[aDecoder decodeObjectForKey:@"ip"]];
    [self setName:[aDecoder decodeObjectForKey:@"name"]];
    [self setUid:[aDecoder decodeObjectForKey:@"uid"]];
    [self setUri:[aDecoder decodeObjectForKey:@"uri"]];
  }
  return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
  [aCoder encodeObject:_ip forKey:@"ip"];
  [aCoder encodeObject:_name forKey:@"name"];
  [aCoder encodeObject:_uid forKey:@"uid"];
  [aCoder encodeObject:_uri forKey:@"uri"];
}

@end
