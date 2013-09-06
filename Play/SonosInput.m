//
//  SonosInput.m
//  Play
//
//  Created by Nathan Borror on 1/1/13.
//  Copyright (c) 2013 Nathan Borror. All rights reserved.
//

#import "SonosInput.h"
#import "SonosController.h"
#import "SonosPositionInfoResponse.h"
#import "SonosInputStore.h"
#import "SOAPEnvelope.h"

@implementation SonosInput
@synthesize delegate, view;

- (id)initWithIP:(NSString *)aIP name:(NSString *)aName uid:(NSString *)aUid icon:(UIImage *)aIcon
{
  if (self = [super init]) {
    _ip = aIP;
    _name = aName;
    _uid = aUid;
    _icon = aIcon;
    _uri = nil;

    [self checkUri];
//    [NSTimer scheduledTimerWithTimeInterval:5 target:self selector:@selector(checkUri) userInfo:nil repeats:YES];
  }
  return self;
}

- (void)pairWithSonosInput:(SonosInput *)input
{
  _uri = [NSString stringWithFormat:@"x-rincon:%@", input.uid];
  [[SonosController sharedController] play:self track:_uri completion:nil];
}

- (void)unpair
{
  _uri = [NSString stringWithFormat:@"x-rincon-queue:%@#0", self.uid];
  [[SonosController sharedController] play:self track:_uri completion:nil];
}

- (void)checkUri
{
  [[SonosController sharedController] trackInfo:self completion:^(SOAPEnvelope *envelope, NSError *error) {
    SonosPositionInfoResponse *response = (SonosPositionInfoResponse *)[envelope response];
    _uri = [NSString stringWithFormat:@"%@", response.uri];

    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"x-rincon:" options:0 error:nil];
    NSTextCheckingResult *match = [regex firstMatchInString:_uri options:0 range:NSMakeRange(0, _uri.length)];

    if (match) {
      NSString *uid = [_uri stringByReplacingOccurrencesOfString:@"x-rincon:" withString:@""];
      SonosInput *pairedWithInput = [[SonosInputStore sharedStore] inputWithUid:uid];
      if (self.delegate) {
        [self.delegate input:self pairedWith:pairedWithInput];
      }
    }
  }];
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
