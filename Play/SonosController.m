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
#import "SonosVolumeResponse.h"
#import "SonosErrorResponse.h"
#import "SOAPEnvelope.h"
#import "RdioSong.h"
#import "RdioAlbum.h"

@interface SonosController ()
{
  NSInputStream *inputStream;
  int volumeLevel;
}
@end

@implementation SonosController

- (id)initWithInput:(SonosInput *)input
{
  self = [super init];
  if (self) {
    _isPlaying = YES;
    volumeLevel = 0;
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

- (void)fetch:(NSString *)path
        input:(SonosInput *)input
       action:(NSString *)action
         body:(NSString *)body
   completion:(void(^)(id obj, NSError *error))block
{
  if (!input) {
    input = [[SonosInputStore sharedStore] master];
  }

  NSURL *soapURL = [NSURL URLWithString:[NSString stringWithFormat:@"http://%@:1400%@", input.ip, path]];
  NSString *soapRequestBody = [NSString stringWithFormat:@""
    "<s:Envelope xmlns:s='http://schemas.xmlsoap.org/soap/envelope/' s:encodingStyle='http://schemas.xmlsoap.org/soap/encoding/'>"
      "<s:Body>%@</s:Body>"
    "</s:Envelope>", body];

  NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:soapURL];
  [request setHTTPMethod:@"POST"];
  [request addValue:@"text/xml" forHTTPHeaderField:@"Content-Type"];
  [request addValue:action forHTTPHeaderField:@"SOAPACTION"];
  [request setHTTPBody:[soapRequestBody dataUsingEncoding:NSUTF8StringEncoding]];

  SOAPEnvelope *envelope = [[SOAPEnvelope alloc] init];
  SonosConnection *connection = [[SonosConnection alloc] initWithRequest:request completion:block];

  [connection setEnvelope:envelope];
  [connection start];
}

- (void)play:(SonosInput *)input track:(NSString *)track completion:(void (^)(SOAPEnvelope *, NSError *))block
{
  if (track) {
    NSString *path = @"/MediaRenderer/AVTransport/Control";
    NSString *action = @"urn:schemas-upnp-org:service:AVTransport:1#SetAVTransportURI";
    NSString *body = [NSString stringWithFormat:@""
      "<u:SetAVTransportURI xmlns:u='urn:schemas-upnp-org:service:AVTransport:1'>"
        "<InstanceID>0</InstanceID>"
        "<CurrentURI>%@</CurrentURI>"
        "<CurrentURIMetaData></CurrentURIMetaData>"
      "</u:SetAVTransportURI>", track];
    [self fetch:path input:input action:action body:body completion:^(SOAPEnvelope *envelope, NSError *error) {
      [self play:nil track:nil completion:block];
    }];
  } else {
    NSString *path = @"/MediaRenderer/AVTransport/Control";
    NSString *action = @"urn:schemas-upnp-org:service:AVTransport:1#Play";
    NSString *body = @""
      "<u:Play xmlns:u='urn:schemas-upnp-org:service:AVTransport:1'>"
        "<InstanceID>0</InstanceID>"
        "<Speed>1</Speed>"
      "</u:Play>";
    [self fetch:path input:input action:action body:body completion:^(SOAPEnvelope *envelope, NSError *error) {
      _isPlaying = YES;
      if (block) {
        block(envelope, error);
      }
    }];
  }
}

- (void)play:(SonosInput *)input rdioSong:(RdioSong *)song completion:(void(^)(SOAPEnvelope *, NSError *))block
{
  // The Metadata shows correctly but may be user specific. Some of the numbers might
  // be tied to an individual Rdio user key, if that is the case more research needs
  // to be done here to get meta data shown correctly on the Sonos device for user
  // accounts outside my own.

  NSString *path = @"/MediaRenderer/AVTransport/Control";
  NSString *albumKey = [song.album.key substringFromIndex:1];
  NSString *songKey = [song.key substringFromIndex:1];
  NSString *trackURI = [NSString stringWithFormat:@"x-sonos-http:_t%%3a%%3a%@%%3a%%3aa%%3a%%3a%@.mp3?sid=11&flags=32", songKey, albumKey];
  NSString *action = @"urn:schemas-upnp-org:service:AVTransport:1#SetAVTransportURI";

  NSString *body = [NSString stringWithFormat:@""
    "<u:SetAVTransportURI xmlns:u='urn:schemas-upnp-org:service:AVTransport:1'>"
      "<InstanceID>0</InstanceID>"
      "<CurrentURI>%@</CurrentURI>"
      "<CurrentURIMetaData></CurrentURIMetaData>"
    "</u:SetAVTransportURI>", trackURI];

  [self fetch:path input:input action:action body:body completion:^(SOAPEnvelope *envelope, NSError *error) {
    [self play:nil track:nil completion:block];
  }];
}

- (void)pause:(SonosInput *)input completion:(void (^)(SOAPEnvelope *, NSError *))block
{
  NSString *path = @"/MediaRenderer/AVTransport/Control";
  NSString *action = @"urn:schemas-upnp-org:service:AVTransport:1#Pause";
  NSString *body = @""
    "<u:Pause xmlns:u='urn:schemas-upnp-org:service:AVTransport:1'>"
      "<InstanceID>0</InstanceID>"
      "<Speed>1</Speed>"
    "</u:Pause>";

  [self fetch:path input:input action:action body:body completion:^(SOAPEnvelope *envelope, NSError *error) {
    _isPlaying = NO;
    if (block) {
      block(envelope, error);
    }
  }];
}

- (void)stop:(SonosInput *)input completion:(void (^)(SOAPEnvelope *, NSError *))block
{
  NSString *path = @"/MediaRenderer/AVTransport/Control";
  NSString *action = @"urn:schemas-upnp-org:service:AVTransport:1#Stop";
  NSString *body = @""
    "<u:Stop xmlns:u='urn:schemas-upnp-org:service:AVTransport:1'>"
      "<InstanceID>0</InstanceID>"
      "<Speed>1</Speed>"
    "</u:Stop>";

  [self fetch:path input:input action:action body:body completion:^(SOAPEnvelope *envelope, NSError *error) {
    _isPlaying = NO;
    if (block) {
      block(envelope, error);
    }
  }];
}

- (void)next:(SonosInput *)input completion:(void (^)(SOAPEnvelope *, NSError *))block
{
  NSString *path = @"/MediaRenderer/AVTransport/Control";
  NSString *action = @"urn:schemas-upnp-org:service:AVTransport:1#Next";
  NSString *body = @""
    "<u:Next xmlns:u='urn:schemas-upnp-org:service:AVTransport:1'>"
      "<InstanceID>0</InstanceID>"
      "<Speed>1</Speed>"
    "</u:Next>";

  [self fetch:path input:input action:action body:body completion:^(SOAPEnvelope *envelope, NSError *error) {
    _isPlaying = YES;
    if (block) {
      block(envelope, error);
    }
  }];
}

- (void)previous:(SonosInput *)input completion:(void (^)(SOAPEnvelope *, NSError *))block
{
  NSString *path = @"/MediaRenderer/AVTransport/Control";
  NSString *action = @"urn:schemas-upnp-org:service:AVTransport:1#Previous";
  NSString *body = @""
    "<u:Previous xmlns:u='urn:schemas-upnp-org:service:AVTransport:1'>"
      "<InstanceID>0</InstanceID>"
      "<Speed>1</Speed>"
    "</u:Previous>";

  [self fetch:path input:input action:action body:body completion:^(SOAPEnvelope *envelope, NSError *error) {
    _isPlaying = YES;
    if (block) {
      block(envelope, error);
    }
  }];
}

- (void)lineIn:(SonosInput *)input completion:(void (^)(SOAPEnvelope *, NSError *))block
{
  NSString *path = @"/MediaRenderer/AVTransport/Control";
  NSString *action = @"urn:schemas-upnp-org:service:AVTransport:1#SetAVTransportURI";
  NSString *body = [NSString stringWithFormat:@""
    "<u:SetAVTransportURI xmlns:u='urn:schemas-upnp-org:service:AVTransport:1'>"
      "<InstanceID>0</InstanceID>"
      "<CurrentURI>x-rincon-stream:%@</CurrentURI>"
      "<CurrentURIMetaData></CurrentURIMetaData>"
    "</u:SetAVTransportURI>", input.uid];

  [self fetch:path input:input action:action body:body completion:^(SOAPEnvelope *envelope, NSError *error) {
    _isPlaying = YES;
    if (block) {
      block(envelope, error);
    }
  }];
}

- (void)volume:(SonosInput *)input completion:(void (^)(SOAPEnvelope *, NSError *))block
{
  NSString *path = @"/MediaRenderer/RenderingControl/Control";
  NSString *action = @"urn:schemas-upnp-org:service:RenderingControl:1#GetVolume";
  NSString *body = @""
    "<u:GetVolume xmlns:u='urn:schemas-upnp-org:service:RenderingControl:1'>"
      "<InstanceID>0</InstanceID>"
      "<Channel>Master</Channel>"
    "</u:GetVolume>";

  [self fetch:path input:input action:action body:body completion:block];
}

- (void)volume:(SonosInput *)input level:(int)level completion:(void (^)(SOAPEnvelope *, NSError *))block
{
  if (volumeLevel == level) {
    return;
  }

  NSString *path = @"/MediaRenderer/RenderingControl/Control";
  NSString *action = @"urn:schemas-upnp-org:service:RenderingControl:1#SetVolume";
  NSString *body = [NSString stringWithFormat:@""
    "<u:SetVolume xmlns:u='urn:schemas-upnp-org:service:RenderingControl:1'>"
      "<InstanceID>0</InstanceID>"
      "<Channel>Master</Channel>"
      "<DesiredVolume>%d</DesiredVolume>"
    "</u:SetVolume>", level];

  [self fetch:path input:input action:action body:body completion:^(SOAPEnvelope *envelope, NSError *error) {
    volumeLevel = level;
    if (block) {
      block(envelope, error);
    }
  }];
}

- (void)trackInfo:(SonosInput *)input completion:(void (^)(SOAPEnvelope *, NSError *))block
{
  NSString *path = @"/MediaRenderer/AVTransport/Control";
  NSString *action = @"urn:schemas-upnp-org:service:AVTransport:1#GetPositionInfo";
  NSString *body = @""
    "<u:GetPositionInfo xmlns:u='urn:schemas-upnp-org:service:AVTransport:1'>"
      "<InstanceID>0</InstanceID>"
    "</u:GetPositionInfo>";

  [self fetch:path input:input action:action body:body completion:block];
}

- (void)browse:(SonosInput *)input completion:(void (^)(SOAPEnvelope *, NSError *))block
{
  NSString *path = @"/MediaServer/ContentDirectory/Control";
  NSString *action = @"urn:schemas-upnp-org:service:ContentDirectory:1#Browse";
  NSString *body = @""
    "<u:Browse xmlns:u='urn:schemas-upnp-org:service:ContentDirectory:1'>"
      "<ObjectID>A:ARTIST</ObjectID>"
      "<BrowseFlag>BrowseDirectChildren</BrowseFlag>"
      "<Filter>*</Filter>"
      "<StartingIndex>0</StartingIndex>"
      "<RequestedCount>5</RequestedCount>"
      "<SortCriteria>*</SortCriteria>"
    "</u:Browse>";
  [self fetch:path input:input action:action body:body completion:block];
}

@end
