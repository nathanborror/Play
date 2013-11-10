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
#import "UPNPDiscovery.h"
#import "XMLReader.h"

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
      // http://SPEAKER_IP:1400/xml/AVTransport1.xml
      url = [NSURL URLWithString:[NSString stringWithFormat:@"http://%@:1400/MediaRenderer/AVTransport/Control", input.ip]];
      xmlns = @"urn:schemas-upnp-org:service:AVTransport:1";
      break;
    case SonosRequestTypeConnectionManager:
      // http://SPEAKER_IP:1400/xml/ConnectionManager1.xml
      url = [NSURL URLWithString:[NSString stringWithFormat:@"http://%@:1400/MediaServer/ConnectionManager/Control", input.ip]];
      xmlns = @"urn:schemas-upnp-org:service:ConnectionManager:1";
      break;
    case SonosRequestTypeRenderingControl:
      // http://SPEAKER_IP:1400/xml/RenderingControl1.xml
      url = [NSURL URLWithString:[NSString stringWithFormat:@"http://%@:1400/MediaRenderer/RenderingControl/Control", input.ip]];
      xmlns = @"urn:schemas-upnp-org:service:RenderingControl:1";
      break;
    case SonosRequestTypeContentDirectory:
      // http://SPEAKER_IP:1400/xml/ContentDirectory1.xml
      url = [NSURL URLWithString:[NSString stringWithFormat:@"http://%@:1400/MediaServer/ContentDirectory/Control", input.ip]];
      xmlns = @"urn:schemas-upnp-org:service:ContentDirectory:1";
      break;
    case SonosRequestTypeQueue:
      // http://SPEAKER_IP:1400/xml/Queue1.xml
      url = [NSURL URLWithString:[NSString stringWithFormat:@"http://%@:1400/MediaRenderer/Queue/Control", input.ip]];
      xmlns = @"urn:schemas-upnp-org:service:Queue:1";
      break;
    case SonosRequestTypeAlarmClock:
      // http://SPEAKER_IP:1400/xml/AlarmClock1.xml
      url = [NSURL URLWithString:[NSString stringWithFormat:@"http://%@:1400/AlarmClock/Control", input.ip]];
      xmlns = @"urn:schemas-upnp-org:service:AlarmClock:1";
      break;
    case SonosRequestTypeMusicServices:
      // http://SPEAKER_IP:1400/xml/MusicServices1.xml
      url = [NSURL URLWithString:[NSString stringWithFormat:@"http://%@:1400/MusicServices/Control", input.ip]];
      xmlns = @"urn:schemas-upnp-org:service:MusicServices:1";
      break;
    case SonosRequestTypeAudioIn:
      // http://SPEAKER_IP:1400/xml/AudioIn1.xml
      url = [NSURL URLWithString:[NSString stringWithFormat:@"http://%@:1400/AudioIn/Control", input.ip]];
      xmlns = @"urn:schemas-upnp-org:service:AudioIn:1";
      break;
    case SonosRequestTypeDeviceProperties:
      // http://SPEAKER_IP:1400/xml/DeviceProperties1.xml
      url = [NSURL URLWithString:[NSString stringWithFormat:@"http://%@:1400/DeviceProperties/Control", input.ip]];
      xmlns = @"urn:schemas-upnp-org:service:DeviceProperties:1";
      break;
    case SonosRequestTypeSystemProperties:
      // http://SPEAKER_IP:1400/xml/SystemProperties1.xml
      url = [NSURL URLWithString:[NSString stringWithFormat:@"http://%@:1400/SystemProperties/Control", input.ip]];
      xmlns = @"urn:schemas-upnp-org:service:SystemProperties:1";
      break;
    case SonosRequestTypeZoneGroupTopology:
      // http://SPEAKER_IP:1400/xml/ZoneGroupTopology1.xml
      url = [NSURL URLWithString:[NSString stringWithFormat:@"http://%@:1400/ZoneGroupTopology/Control", input.ip]];
      xmlns = @"urn:schemas-upnp-org:service:ZoneGroupTopology:1";
      break;
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

+ (void)discover:(void(^)(NSArray *inputs, NSError *error))block{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        UPNPDiscovery *discover = [[UPNPDiscovery alloc] init];
        [discover FindDevicesWithST:@"urn:schemas-upnp-org:device:ZonePlayer:1" completion:^(NSArray *ipAddresses){
            if (ipAddresses.count>0){
                NSString *ipAddress = [ipAddresses objectAtIndex:0];
                NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"http://%@/status/topology", ipAddress]];
                NSURLRequest *request = [[NSURLRequest alloc] initWithURL:url cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:5];
                [NSURLConnection sendAsynchronousRequest:request queue:[[NSOperationQueue alloc] init] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error){
                    NSHTTPURLResponse *hResponse = (NSHTTPURLResponse*)response;
                    if (hResponse.statusCode == 200){
                        NSDictionary *responseDictionary = [XMLReader dictionaryForXMLData:data error:&error];
                        NSArray *inputDictionaryArray = responseDictionary[@"ZPSupportInfo"][@"ZonePlayers"][@"ZonePlayer"];
                        NSArray *inputStores = [inputDictionaryArray valueForKey:@"group"];
                        NSMutableDictionary *zoneDictionary = [NSMutableDictionary dictionary];
                        for (NSString *string in inputStores){
                            if (![string hasSuffix:@":0"]){
                                [zoneDictionary setObject:[[SonosInputStore alloc] init] forKey:string];
                            }
                        }
                        for (NSDictionary *dictionary in inputDictionaryArray){
                            NSString *name = dictionary[@"text"];
                            NSString *uuid = dictionary[@"uuid"];
                            NSString *group = dictionary[@"group"];
                            NSString *ip = [[dictionary[@"location"] stringByReplacingOccurrencesOfString:@"http://" withString:@""] stringByReplacingOccurrencesOfString:@":1400/xml/device_description.xml" withString:@""];
                            
                            SonosInputStore *inputStore = [zoneDictionary objectForKey:group];
                            [inputStore addInputWithIP:ip name:name uid:uuid icon:nil];
                            if ([dictionary[@"coordinator"] isEqualToString:@"true"]){
                                inputStore.master = [[inputStore allInputs] lastObject];
                            }
                            
                        }
                        block([zoneDictionary allValues], error);
                    }
                }];
            }
        }];
    
    });
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

- (void)seek:(SonosInput *)input timestamp:(NSString*)timestamp completion:(void(^)(NSDictionary *response, NSError *error))block{
    NSDictionary *params = @{@"InstanceID": @0, @"Unit": @"REL_TIME"};
    [SonosController request:SonosRequestTypeAVTransport input:input action:@"Seek" params:params completion:^(id obj, NSError *error) {
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

- (void)queue:(SonosInput *)input rdioSong:(RdioSong *)song completion:(void(^)(NSDictionary *response, NSError *error))block{
    NSString *albumKey = [song.album.key substringFromIndex:1];
    NSString *songKey = [song.key substringFromIndex:1];
    NSString *trackURI = [NSString stringWithFormat:@"x-sonos-http:_t%%3a%%3a%@%%3a%%3ap%%3a%%3a%@.mp3?sid=11&amp;flags=32", songKey, albumKey];
    
    NSDictionary *params = @{@"InstanceID": @0,
                             @"EnqueuedURI": trackURI,
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

- (void)mediaInfo:(SonosInput *)input completion:(void (^)(NSDictionary *, NSError *))block
{
  NSDictionary *params = @{@"InstanceID": @0};
  [SonosController request:SonosRequestTypeAVTransport input:input action:@"GetMediaInfo" params:params completion:block];
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
