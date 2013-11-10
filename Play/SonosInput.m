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

    [[SonosController sharedController] mediaInfo:self completion:^(NSDictionary *response, NSError *error) {
      [self setUri:response[@"u:GetMediaInfoResponse"][@"CurrentURI"][@"text"]];
      _status = PLInputStatusStopped;

      NSString *masterUID = [_uri stringByReplacingOccurrencesOfString:@"x-rincon:" withString:@""];
      SonosInput *master = [[SonosInputStore sharedStore] inputWithUid:masterUID];
      if (master) {
        [self pairWithSonosInput:master];
      }
    }];
  }
  return self;
}

- (NSString *)description
{
  return [NSString stringWithFormat:@"<SonosInput: %@ (%@)>", _name, _uri];
}

- (void)pairWithSonosInput:(SonosInput *)master
{
  _uri = [NSString stringWithFormat:@"x-rincon:%@", master.uid];
  [[SonosController sharedController] play:self uri:_uri completion:nil];
  _status = PLInputStatusSlave;
}

- (void)unpair
{
  _uri = [NSString stringWithFormat:@"x-rincon-queue:%@#0", self.uid];
  [[SonosController sharedController] play:self uri:_uri completion:nil];
  _status = PLInputStatusStopped;
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
    [self setUri:[aDecoder decodeObjectForKey:@"uri"]];
  }
  return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
  [aCoder encodeObject:_ip forKey:@"ip"];
  [aCoder encodeObject:_name forKey:@"name"];
  [aCoder encodeObject:_uid forKey:@"uid"];
  [aCoder encodeObject:_icon forKey:@"icon"];
  [aCoder encodeObject:_uri forKey:@"uri"];
}

@end
