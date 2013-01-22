//
//  SonosController.m
//  Play
//
//  Created by Nathan Borror on 12/31/12.
//  Copyright (c) 2012 Nathan Borror. All rights reserved.
//

#import "SonosController.h"
#import "SonosResponse.h"
#import "PLConnection.h"


@interface SonosController ()
{
  NSString *sonosURL;
  NSInputStream *inputStream;
  int volumeLevel;
  SonosResponse *response;
}
@end

@implementation SonosController

- (id)initWithIP:(NSString *)ip
{
  self = [super init];
  if (self) {
    sonosURL = [NSString stringWithFormat:@"http://%@:1400", ip];
    _isPlaying = YES;
    volumeLevel = 0;
  }
  return self;
}

+ (SonosController *)sharedController
{
  static SonosController *sharedController = nil;
  if (!sharedController) {
    sharedController = [[SonosController alloc] initWithIP:[[NSUserDefaults standardUserDefaults] objectForKey:@"current_input_ip"]];
  }
  return sharedController;
}

- (SonosResponse *)fetchSOAPURL:(NSURL *)url
                        action:(NSString *)action
                     body:(NSString *)body
               withCompletion:(void(^)(SonosResponse *body, NSError *error))block
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

  NSLog(@"\n\nACTION: %@", action);

  SonosResponse *res = [[SonosResponse alloc] init];
  PLConnection *connection = [[PLConnection alloc] initWithRequest:request];

  [connection setCompletionBlock:block];
  [connection setXmlRootObject:res];
  [connection start];

  return res;
}

- (void)play:(NSString *)uri
{
  if (uri) {
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@", sonosURL, @"/MediaRenderer/AVTransport/Control"]];
    NSString *action = @"urn:schemas-upnp-org:service:AVTransport:1#SetAVTransportURI";
    NSString *body = [NSString stringWithFormat:@""
      "<u:SetAVTransportURI xmlns:u='urn:schemas-upnp-org:service:AVTransport:1'>"
        "<InstanceID>0</InstanceID>"
        "<CurrentURI>%@</CurrentURI>"
        "<CurrentURIMetaData></CurrentURIMetaData>"
      "</u:SetAVTransportURI>", uri];
    response = [self fetchSOAPURL:url action:action body:body withCompletion:^(SonosResponse *body, NSError *error) {
      [self play:nil];
    }];
  } else {
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@", sonosURL, @"/MediaRenderer/AVTransport/Control"]];
    NSString *action = @"urn:schemas-upnp-org:service:AVTransport:1#Play";
    NSString *body = @""
      "<u:Play xmlns:u='urn:schemas-upnp-org:service:AVTransport:1'>"
        "<InstanceID>0</InstanceID>"
        "<Speed>1</Speed>"
      "</u:Play>";
    response = [self fetchSOAPURL:url action:action body:body withCompletion:^(SonosResponse *body, NSError *error) {
      _isPlaying = YES;
    }];
  }
}

- (void)pause
{
  NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@", sonosURL, @"/MediaRenderer/AVTransport/Control"]];
  NSString *action = @"urn:schemas-upnp-org:service:AVTransport:1#Pause";
  NSString *body = @""
    "<u:Pause xmlns:u='urn:schemas-upnp-org:service:AVTransport:1'>"
      "<InstanceID>0</InstanceID>"
      "<Speed>1</Speed>"
    "</u:Pause>";

  response = [self fetchSOAPURL:url action:action body:body withCompletion:^(SonosResponse *body, NSError *error) {
    _isPlaying = NO;
  }];
}

- (void)stop
{
  NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@", sonosURL, @"/MediaRenderer/AVTransport/Control"]];
  NSString *action = @"urn:schemas-upnp-org:service:AVTransport:1#Stop";
  NSString *body = @""
    "<u:Stop xmlns:u='urn:schemas-upnp-org:service:AVTransport:1'>"
      "<InstanceID>0</InstanceID>"
      "<Speed>1</Speed>"
    "</u:Stop>";

  response = [self fetchSOAPURL:url action:action body:body withCompletion:^(SonosResponse *body, NSError *error) {
    _isPlaying = NO;
  }];
}

- (void)next
{
  NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@", sonosURL, @"/MediaRenderer/AVTransport/Control"]];
  NSString *action = @"urn:schemas-upnp-org:service:AVTransport:1#Next";
  NSString *body = @""
    "<u:Next xmlns:u='urn:schemas-upnp-org:service:AVTransport:1'>"
      "<InstanceID>0</InstanceID>"
      "<Speed>1</Speed>"
    "</u:Next>";

  response = [self fetchSOAPURL:url action:action body:body withCompletion:^(SonosResponse *body, NSError *error) {
    _isPlaying = YES;
  }];
}

- (void)previous
{
  NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@", sonosURL, @"/MediaRenderer/AVTransport/Control"]];
  NSString *action = @"urn:schemas-upnp-org:service:AVTransport:1#Previous";
  NSString *body = @""
    "<u:Previous xmlns:u='urn:schemas-upnp-org:service:AVTransport:1'>"
      "<InstanceID>0</InstanceID>"
      "<Speed>1</Speed>"
    "</u:Previous>";

  response = [self fetchSOAPURL:url action:action body:body withCompletion:^(SonosResponse *body, NSError *error) {
    _isPlaying = YES;
  }];
}

- (void)speakers
{
  // TODO: Discover speakers using UPnP's discovery stuff.
}

- (void)lineIn:(NSString *)uid
{
  NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@", sonosURL, @"/MediaRenderer/AVTransport/Control"]];
  NSString *action = @"urn:schemas-upnp-org:service:AVTransport:1#SetAVTransportURI";
  NSString *body = [NSString stringWithFormat:@""
    "<u:SetAVTransportURI xmlns:u='urn:schemas-upnp-org:service:AVTransport:1'>"
      "<InstanceID>0</InstanceID>"
      "<CurrentURI>x-rincon-stream:%@</CurrentURI>"
      "<CurrentURIMetaData></CurrentURIMetaData>"
    "</u:SetAVTransportURI>", uid];

  response = [self fetchSOAPURL:url action:action body:body withCompletion:^(SonosResponse *body, NSError *error) {
    _isPlaying = YES;
  }];
}

- (void)volume
{
  NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@", sonosURL, @"/MediaRenderer/RenderingControl/Control"]];
  NSString *action = @"urn:schemas-upnp-org:service:RenderingControl:1#GetVolume";
  NSString *body = @""
    "<u:GetVolume xmlns:u='urn:schemas-upnp-org:service:RenderingControl:1'>"
      "<InstanceID>0</InstanceID>"
      "<Channel>Master</Channel>"
    "</u:GetVolume>";

  response = [self fetchSOAPURL:url action:action body:body withCompletion:^(SonosResponse *body, NSError *error) {
    // TODO: Do something
  }];
}

- (void)volume:(int)volume
{
  if (volumeLevel == volume) {
    return;
  }

  NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@", sonosURL, @"/MediaRenderer/RenderingControl/Control"]];
  NSString *action = @"urn:schemas-upnp-org:service:RenderingControl:1#SetVolume";
  NSString *body = [NSString stringWithFormat:@""
    "<u:SetVolume xmlns:u='urn:schemas-upnp-org:service:RenderingControl:1'>"
      "<InstanceID>0</InstanceID>"
      "<Channel>Master</Channel>"
      "<DesiredVolume>%d</DesiredVolume>"
    "</u:SetVolume>", volume];

  response = [self fetchSOAPURL:url action:action body:body withCompletion:^(SonosResponse *body, NSError *error) {
    volumeLevel = volume;
  }];
}

- (void)trackInfoWithCompletion:(void(^)(SonosResponse *response, NSError *error))block
{
  NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@", sonosURL, @"/MediaRenderer/AVTransport/Control"]];
  NSString *action = @"urn:schemas-upnp-org:service:AVTransport:1#GetPositionInfo";
  NSString *body = @""
    "<u:GetPositionInfo xmlns:u='urn:schemas-upnp-org:service:AVTransport:1'>"
      "<InstanceID>0</InstanceID>"
    "</u:GetPositionInfo>";

  response = [self fetchSOAPURL:url action:action body:body withCompletion:block];
}

- (void)browseWithCompletion:(void (^)(SonosResponse *, NSError *))block
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
  response = [self fetchSOAPURL:url action:action body:body withCompletion:block];
}

@end
