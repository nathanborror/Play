//
//  SonosController.m
//  Play
//
//  Created by Nathan Borror on 12/31/12.
//  Copyright (c) 2012 Nathan Borror. All rights reserved.
//

#import "SonosController.h"
#import "SonosConnection.h"
#import "SonosInput.h"
#import "SonosInputStore.h"
#import "RdioSong.h"
#import "RdioAlbum.h"

@implementation SonosController {
  int _volumeLevel;
}

- (id)initWithInput:(SonosInput *)input
{
  if (self = [super init]) {
    _isPlaying = YES;
    _volumeLevel = 0;
  }
  return self;
}

+ (SonosController *)sharedController
{
  static SonosController *sharedController = nil;
  if (!sharedController) {
    sharedController = [[SonosController alloc] initWithInput:[[SonosInputStore sharedStore] master]];
  }
  return sharedController;
}

+ (void)request:(SonosRequestType)type
          input:(SonosInput *)input
         action:(NSString *)action
         params:(NSDictionary *)params
     completion:(void (^)(id, NSError *))block
{
  if (!input) input = [[SonosInputStore sharedStore] master];

  NSURL *url;
  NSString *xmlns;

  switch (type) {
    case SonosRequestTypeAVTransport:
      url = [NSURL URLWithString:[NSString stringWithFormat:@"http://%@:1400/MediaRenderer/AVTransport/Control", input.ip]];
      xmlns = @"urn:schemas-upnp-org:service:AVTransport:1";
      break;
    case SonosRequestTypeConnectionManager:
      url = [NSURL URLWithString:[NSString stringWithFormat:@"http://%@:1400/MediaRenderer/ConnectionManager/Control", input.ip]];
      xmlns = @"urn:schemas-upnp-org:service:ConnectionManager:1";
      break;
    case SonosRequestTypeRenderingControl:
      url = [NSURL URLWithString:[NSString stringWithFormat:@"http://%@:1400/MediaRenderer/RenderingControl/Control", input.ip]];
      xmlns = @"urn:schemas-upnp-org:service:RenderingControl:1";
      break;
    case SonosRequestTypeContentDirectory:
      url = [NSURL URLWithString:[NSString stringWithFormat:@"http://%@:1400/MediaServer/ContentDirectory/Control", input.ip]];
      xmlns = @"urn:schemas-upnp-org:service:ContentDirectory:1";
      break;
    case SonosRequestTypeAlarmClock:
      url = [NSURL URLWithString:[NSString stringWithFormat:@"http://%@:1400/AlarmClock/Control", input.ip]];
      xmlns = @"urn:schemas-upnp-org:service:AlarmClock:1";
      break;
    case SonosRequestTypeMusicServices:
    case SonosRequestTypeAudioIn:
    case SonosRequestTypeDeviceProperties:
    case SonosRequestTypeSystemProperties:
    case SonosRequestTypeZoneGroupTopology:
    case SonosRequestTypeGroupManagement:
      break;
  }

  // Enumerate
  NSMutableString *requestParams = [[NSMutableString alloc] init];
  NSEnumerator *enumerator = [params keyEnumerator];
  NSString *key;
  while (key = [enumerator nextObject]) {
    requestParams = [NSMutableString stringWithFormat:@"<%@>%@</%@>%@", key, [params objectForKey:key], key, requestParams];
  }

  NSString *requestBody = [NSString stringWithFormat:@""
    "<s:Envelope xmlns:s='http://schemas.xmlsoap.org/soap/envelope/' s:encodingStyle='http://schemas.xmlsoap.org/soap/encoding/'>"
      "<s:Body>"
        "<u:%@ xmlns:u='%@'>"
          "%@"
        "</u:%@>"
      "</s:Body>"
    "</s:Envelope>", action, xmlns, requestParams, action];

  NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
  [request setHTTPMethod:@"POST"];
  [request addValue:@"text/xml" forHTTPHeaderField:@"Content-Type"];
  [request addValue:[NSString stringWithFormat:@"%@#%@", xmlns, action] forHTTPHeaderField:@"SOAPACTION"];
  [request setHTTPBody:[requestBody dataUsingEncoding:NSUTF8StringEncoding]];

  SonosConnection *connection = [[SonosConnection alloc] initWithRequest:request completion:block];
  [connection start];
}

- (void)play:(SonosInput *)input uri:(NSString *)uri completion:(void (^)(NSDictionary *, NSError *))block
{
  if (uri) {
    [input setUri:uri];
    NSDictionary *params = @{@"InstanceID": @0,
                             @"CurrentURI":uri,
                             @"CurrentURIMetaData": @""};
    [SonosController request:SonosRequestTypeAVTransport input:input action:@"SetAVTransportURI" params:params completion:^(id obj, NSError *error) {
      [self play:nil uri:nil completion:block];
    }];
  } else {
    NSDictionary *params = @{@"InstanceID": @0, @"Speed":@1};
    [SonosController request:SonosRequestTypeAVTransport input:input action:@"Play" params:params completion:^(id obj, NSError *error) {
      _isPlaying = YES;
      if (block) block(obj, error);
    }];
  }
}

- (void)play:(SonosInput *)input rdioSong:(RdioSong *)song completion:(void(^)(NSDictionary *, NSError *))block
{
  // The Metadata shows correctly but may be user specific. Some of the numbers might
  // be tied to an individual Rdio user key, if that is the case more research needs
  // to be done here to get meta data shown correctly on the Sonos device for user
  // accounts outside my own.

  NSString *albumKey = [song.album.key substringFromIndex:1];
  NSString *songKey = [song.key substringFromIndex:1];
  NSString *trackURI = [NSString stringWithFormat:@"x-sonos-http:_t%%3a%%3a%@%%3a%%3ap%%3a%%3a%@.mp3?sid=11&amp;flags=32", songKey, albumKey];

  NSDictionary *params = @{@"InstanceID": @0,
                           @"CurrentURI":trackURI,
                           @"CurrentURIMetaData": @""};
  [SonosController request:SonosRequestTypeAVTransport input:input action:@"SetAVTransportURI" params:params completion:^(id obj, NSError *error) {
    [self play:nil uri:nil completion:block];
  }];
}

- (void)pause:(SonosInput *)input completion:(void (^)(NSDictionary *, NSError *))block
{
  NSDictionary *params = @{@"InstanceID": @0, @"Speed": @1};
  [SonosController request:SonosRequestTypeAVTransport input:input action:@"Pause" params:params completion:^(id obj, NSError *error) {
    _isPlaying = NO;
    if (block) block(obj, error);
  }];
}

- (void)stop:(SonosInput *)input completion:(void (^)(NSDictionary *, NSError *))block
{
  NSDictionary *params = @{@"InstanceID": @0, @"Speed": @1};
  [SonosController request:SonosRequestTypeAVTransport input:input action:@"Stop" params:params completion:^(id obj, NSError *error) {
    _isPlaying = NO;
    if (block) block(obj, error);
  }];
}

- (void)next:(SonosInput *)input completion:(void (^)(NSDictionary *, NSError *))block
{
  NSDictionary *params = @{@"InstanceID": @0, @"Speed": @1};
  [SonosController request:SonosRequestTypeAVTransport input:input action:@"Next" params:params completion:^(id obj, NSError *error) {
    _isPlaying = YES;
    if (block) block(obj, error);
  }];
}

- (void)previous:(SonosInput *)input completion:(void (^)(NSDictionary *, NSError *))block
{
  NSDictionary *params = @{@"InstanceID": @0, @"Speed": @1};
  [SonosController request:SonosRequestTypeAVTransport input:input action:@"Previous" params:params completion:^(id obj, NSError *error) {
    _isPlaying = YES;
    if (block) block(obj, error);
  }];
}

- (void)queue:(SonosInput *)input track:(NSString *)track completion:(void (^)(NSDictionary *, NSError *))block
{
  NSDictionary *params = @{@"InstanceID": @0,
                           @"EnqueuedURI": track,
                           @"EnqueuedURIMetaData": @"",
                           @"DesiredFirstTrackNumberEnqueued": @0,
                           @"EnqueueAsNext": @1};
  [SonosController request:SonosRequestTypeAVTransport input:input action:@"AddURIToQueue" params:params completion:^(id obj, NSError *error) {
    [self play:nil uri:nil completion:block];
  }];
}

- (void)lineIn:(SonosInput *)input completion:(void (^)(NSDictionary *, NSError *))block
{
  [self play:input uri:[NSString stringWithFormat:@"x-rincon-stream:%@", input.uid] completion:block];
}

- (void)volume:(SonosInput *)input completion:(void (^)(NSDictionary *, NSError *))block
{
  NSDictionary *params = @{@"InstanceID": @0,
                           @"Channel":@"Master"};
  [SonosController request:SonosRequestTypeRenderingControl input:input action:@"GetVolume" params:params completion:block];
}

- (void)volume:(SonosInput *)input level:(int)level completion:(void (^)(NSDictionary *, NSError *))block
{
  if (_volumeLevel == level) return;

  NSDictionary *params = @{@"InstanceID": @0,
                           @"Channel":@"Master",
                           @"DesiredVolume":[NSNumber numberWithInt:level]};
  [SonosController request:SonosRequestTypeRenderingControl input:input action:@"SetVolume" params:params completion:^(id obj, NSError *error) {
    _volumeLevel = level;
    if (block) block(obj, error);
  }];
}

- (void)trackInfo:(SonosInput *)input completion:(void (^)(NSDictionary *, NSError *))block
{
  NSDictionary *params = @{@"InstanceID": @0};
  [SonosController request:SonosRequestTypeAVTransport input:input action:@"GetPositionInfo" params:params completion:block];
}

- (void)status:(SonosInput *)input completion:(void (^)(NSDictionary *, NSError *))block
{
  NSDictionary *params = @{@"InstanceID": @0};
  [SonosController request:SonosRequestTypeAVTransport input:input action:@"GetTransportInfo" params:params completion:block];
}

- (void)browse:(SonosInput *)input completion:(void (^)(NSDictionary *, NSError *))block
{
  NSDictionary *params = @{@"ObjectID": @"A:ARTIST",
                           @"BrowseFlag": @"BrowseDirectChildren",
                           @"Filter": @"*",
                           @"StartingIndex": @0,
                           @"RequestedCount": @5,
                           @"SortCriteria": @"*"};
  [SonosController request:SonosRequestTypeContentDirectory input:input action:@"Browse" params:params completion:block];
}

@end
