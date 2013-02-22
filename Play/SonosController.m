//
//  SonosController.m
//  Play
//
//  Created by Nathan Borror on 12/31/12.
//  Copyright (c) 2012 Nathan Borror. All rights reserved.
//

#import "SonosController.h"
#import "SonosResponse.h"
#import "SonosConnection.h"
#import "SonosInput.h"
#import "SonosInputStore.h"
#import "SonosVolumeResponse.h"

@interface SonosController ()
{
  NSString *sonosURL;
  NSInputStream *inputStream;
  int volumeLevel;
}
@end

@implementation SonosController

- (id)initWithInput:(SonosInput *)input
{
  self = [super init];
  if (self) {
    sonosURL = [NSString stringWithFormat:@"http://%@:1400", input.ip];
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

- (void)fetchSOAPURL:(NSURL *)url
                        action:(NSString *)action
                     body:(NSString *)body
               completion:(void(^)(id obj, NSError *error))block
{
  NSString *envelope = [NSString stringWithFormat:@""
    "<s:Envelope xmlns:s='http://schemas.xmlsoap.org/soap/envelope/' s:encodingStyle='http://schemas.xmlsoap.org/soap/encoding/'>"
      "<s:Body>%@</s:Body>"
    "</s:Envelope>", body];

  NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
  [request setHTTPMethod:@"POST"];
  [request addValue:@"text/xml" forHTTPHeaderField:@"Content-Type"];
  [request addValue:action forHTTPHeaderField:@"SOAPACTION"];
  [request setHTTPBody:[envelope dataUsingEncoding:NSUTF8StringEncoding]];

//  NSLog(@"\n\nACTION: %@", action);

  SonosResponse *response = [[SonosResponse alloc] init];
  SonosConnection *connection = [[SonosConnection alloc] initWithRequest:request];

  [connection setCompletionBlock:block];
  [connection setXmlRootObject:response];
  [connection start];
}

- (void)play:(SonosInput *)input track:(NSString *)track completion:(void (^)(SonosResponse *, NSError *))block
{
  if (track) {
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@", sonosURL, @"/MediaRenderer/AVTransport/Control"]];
    NSString *action = @"urn:schemas-upnp-org:service:AVTransport:1#SetAVTransportURI";
    NSString *body = [NSString stringWithFormat:@""
      "<u:SetAVTransportURI xmlns:u='urn:schemas-upnp-org:service:AVTransport:1'>"
        "<InstanceID>0</InstanceID>"
        "<CurrentURI>%@</CurrentURI>"
        "<CurrentURIMetaData></CurrentURIMetaData>"
      "</u:SetAVTransportURI>", track];
    [self fetchSOAPURL:url action:action body:body completion:^(SonosResponse *body, NSError *error) {
      [self play:input track:nil completion:block];
    }];
  } else {
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@", sonosURL, @"/MediaRenderer/AVTransport/Control"]];
    NSString *action = @"urn:schemas-upnp-org:service:AVTransport:1#Play";
    NSString *body = @""
      "<u:Play xmlns:u='urn:schemas-upnp-org:service:AVTransport:1'>"
        "<InstanceID>0</InstanceID>"
        "<Speed>1</Speed>"
      "</u:Play>";
    [self fetchSOAPURL:url action:action body:body completion:^(SonosResponse *body, NSError *error) {
      _isPlaying = YES;
      if (block) {
        block(body, error);
      }
    }];
  }
}

- (void)pause:(SonosInput *)input completion:(void (^)(SonosResponse *, NSError *))block
{
  NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@", sonosURL, @"/MediaRenderer/AVTransport/Control"]];
  NSString *action = @"urn:schemas-upnp-org:service:AVTransport:1#Pause";
  NSString *body = @""
    "<u:Pause xmlns:u='urn:schemas-upnp-org:service:AVTransport:1'>"
      "<InstanceID>0</InstanceID>"
      "<Speed>1</Speed>"
    "</u:Pause>";

  [self fetchSOAPURL:url action:action body:body completion:^(SonosResponse *body, NSError *error) {
    _isPlaying = NO;
    if (block) {
      block(body, error);
    }
  }];
}

- (void)stop:(SonosInput *)input completion:(void (^)(SonosResponse *, NSError *))block
{
  NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@", sonosURL, @"/MediaRenderer/AVTransport/Control"]];
  NSString *action = @"urn:schemas-upnp-org:service:AVTransport:1#Stop";
  NSString *body = @""
    "<u:Stop xmlns:u='urn:schemas-upnp-org:service:AVTransport:1'>"
      "<InstanceID>0</InstanceID>"
      "<Speed>1</Speed>"
    "</u:Stop>";

  [self fetchSOAPURL:url action:action body:body completion:^(SonosResponse *body, NSError *error) {
    _isPlaying = NO;
    if (block) {
      block(body, error);
    }
  }];
}

- (void)next:(SonosInput *)input completion:(void (^)(SonosResponse *, NSError *))block
{
  NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@", sonosURL, @"/MediaRenderer/AVTransport/Control"]];
  NSString *action = @"urn:schemas-upnp-org:service:AVTransport:1#Next";
  NSString *body = @""
    "<u:Next xmlns:u='urn:schemas-upnp-org:service:AVTransport:1'>"
      "<InstanceID>0</InstanceID>"
      "<Speed>1</Speed>"
    "</u:Next>";

  [self fetchSOAPURL:url action:action body:body completion:^(SonosResponse *body, NSError *error) {
    _isPlaying = YES;
    if (block) {
      block(body, error);
    }
  }];
}

- (void)previous:(SonosInput *)input completion:(void (^)(SonosResponse *, NSError *))block
{
  NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@", sonosURL, @"/MediaRenderer/AVTransport/Control"]];
  NSString *action = @"urn:schemas-upnp-org:service:AVTransport:1#Previous";
  NSString *body = @""
    "<u:Previous xmlns:u='urn:schemas-upnp-org:service:AVTransport:1'>"
      "<InstanceID>0</InstanceID>"
      "<Speed>1</Speed>"
    "</u:Previous>";

  [self fetchSOAPURL:url action:action body:body completion:^(SonosResponse *body, NSError *error) {
    _isPlaying = YES;
    if (block) {
      block(body, error);
    }
  }];
}

- (void)lineIn:(SonosInput *)input completion:(void (^)(SonosResponse *, NSError *))block
{
  NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@", sonosURL, @"/MediaRenderer/AVTransport/Control"]];
  NSString *action = @"urn:schemas-upnp-org:service:AVTransport:1#SetAVTransportURI";
  NSString *body = [NSString stringWithFormat:@""
    "<u:SetAVTransportURI xmlns:u='urn:schemas-upnp-org:service:AVTransport:1'>"
      "<InstanceID>0</InstanceID>"
      "<CurrentURI>x-rincon-stream:%@</CurrentURI>"
      "<CurrentURIMetaData></CurrentURIMetaData>"
    "</u:SetAVTransportURI>", input.uid];

  [self fetchSOAPURL:url action:action body:body completion:^(SonosResponse *body, NSError *error) {
    _isPlaying = YES;
    if (block) {
      block(body, error);
    }
  }];
}

- (void)volume:(SonosInput *)input completion:(void (^)(SonosResponse *, NSError *))block
{
  NSString *url = [NSString stringWithFormat:@"http://%@:1400%@", input.ip, @"/MediaRenderer/RenderingControl/Control"];
  NSString *action = @"urn:schemas-upnp-org:service:RenderingControl:1#GetVolume";
  NSString *body = @""
    "<u:GetVolume xmlns:u='urn:schemas-upnp-org:service:RenderingControl:1'>"
      "<InstanceID>0</InstanceID>"
      "<Channel>Master</Channel>"
    "</u:GetVolume>";

  [self fetchSOAPURL:[NSURL URLWithString:url] action:action body:body completion:block];
}

- (void)volume:(SonosInput *)input level:(int)level completion:(void (^)(SonosResponse *, NSError *))block
{
  if (volumeLevel == level) {
    return;
  }

  NSString *url = [NSString stringWithFormat:@"http://%@:1400%@", input.ip, @"/MediaRenderer/RenderingControl/Control"];
  NSString *action = @"urn:schemas-upnp-org:service:RenderingControl:1#SetVolume";
  NSString *body = [NSString stringWithFormat:@""
    "<u:SetVolume xmlns:u='urn:schemas-upnp-org:service:RenderingControl:1'>"
      "<InstanceID>0</InstanceID>"
      "<Channel>Master</Channel>"
      "<DesiredVolume>%d</DesiredVolume>"
    "</u:SetVolume>", level];

  [self fetchSOAPURL:[NSURL URLWithString:url] action:action body:body completion:^(SonosResponse *body, NSError *error) {
    volumeLevel = level;
    if (block) {
      block(body, error);
    }
  }];
}

- (void)trackInfo:(SonosInput *)input completion:(void (^)(SonosResponse *, NSError *))block
{
  NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@", sonosURL, @"/MediaRenderer/AVTransport/Control"]];
  NSString *action = @"urn:schemas-upnp-org:service:AVTransport:1#GetPositionInfo";
  NSString *body = @""
    "<u:GetPositionInfo xmlns:u='urn:schemas-upnp-org:service:AVTransport:1'>"
      "<InstanceID>0</InstanceID>"
    "</u:GetPositionInfo>";

  [self fetchSOAPURL:url action:action body:body completion:block];
}

- (void)browse:(SonosInput *)input completion:(void (^)(SonosResponse *, NSError *))block
{
  NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@", sonosURL, @"/MediaServer/ContentDirectory/Control"]];
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
  [self fetchSOAPURL:url action:action body:body completion:block];
}

@end
