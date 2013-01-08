//
//  SonosController.m
//  Play
//
//  Created by Nathan Borror on 12/31/12.
//  Copyright (c) 2012 Nathan Borror. All rights reserved.
//

#import "SonosController.h"

static NSString *kSonosEndpointTransport = @"/MediaRenderer/AVTransport/Control";
static NSString *kSonosEndpointRendering = @"/MediaRenderer/RenderingControl/Control";
static NSString *kSonosEndpointDevice = @"/DeviceProperties/Control";
static NSString *kSonosEndpointContentDirectory = @"/MediaServer/ContentDirectory/Control";

static NSString *kSonosRequest = @""
  "<s:Envelope xmlns:s='http://schemas.xmlsoap.org/soap/envelope/' s:encodingStyle='http://schemas.xmlsoap.org/soap/encoding/'>"
    "<s:Body>%@</s:Body>"
  "</s:Envelope>";

static NSString *kSonosTemplateTransportHeader = @"urn:schemas-upnp-org:service:AVTransport:1#%@";
static NSString *kSonosTemplateTransportBody = @""
  "<u:%@ xmlns:u='urn:schemas-upnp-org:service:AVTransport:1'>"
    "<InstanceID>0</InstanceID>"
    "<Speed>1</Speed>"
  "</u:%@>";

static NSString *kSonosTemplateRenderingHeader = @"urn:schemas-upnp-org:service:RenderingControl:1#%@";
static NSString *kSonosTemplateContentDirectorytHeader = @"urn:schemas-upnp-org:service:ContentDirectory:1#%@";

@interface SonosController ()
{
  NSString *sonosURL;
  NSInputStream *inputStream;
  int volumeLevel;
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

- (void)sendTransportCommand:(NSString *)command
                    complete:(void (^)(NSURLResponse *response, NSData *data, NSError *error))block
{
  [self sendCommandToEndpoint:kSonosEndpointTransport
                       action:[NSString stringWithFormat:kSonosTemplateTransportHeader, command]
                         body:[NSString stringWithFormat:kSonosTemplateTransportBody, command, command]
               complete:block];
}

- (void)sendCommandToEndpoint:(NSString *)endpoint
                       action:(NSString *)action
                         body:(NSString *)body
                     complete:(void (^)(NSURLResponse *response, NSData *data, NSError *error))block
{
  NSString *envelope = [NSString stringWithFormat:kSonosRequest, body];
  
  NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@", sonosURL, endpoint]];
  NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
  
  [request setHTTPMethod:@"POST"];
  [request addValue:@"text/xml" forHTTPHeaderField:@"Content-Type"];
  [request addValue:action forHTTPHeaderField:@"SOAPACTION"];
  [request setHTTPBody:[envelope dataUsingEncoding:NSUTF8StringEncoding]];

  NSLog(@"REQUEST:\n %@\n\n", envelope);

  NSOperationQueue *queue = [[NSOperationQueue alloc] init];
  
  [NSURLConnection sendAsynchronousRequest:request queue:queue completionHandler:
    ^(NSURLResponse *response, NSData *data, NSError *error) {
      if (block) {
        NSLog(@"RESPONSE DATA:\n %@\n\n", [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
        block(response, data, error);
      }
    }];
}

- (void)play:(NSString *)uri
{
  if (uri) {
    NSString *header = [NSString stringWithFormat:kSonosTemplateTransportHeader, @"SetAVTransportURI"];
    NSString *body = [NSString stringWithFormat:@""
      "<u:SetAVTransportURI xmlns:u='urn:schemas-upnp-org:service:AVTransport:1'>"
        "<InstanceID>0</InstanceID>"
        "<CurrentURI>%@</CurrentURI>"
        "<CurrentURIMetaData></CurrentURIMetaData>"
      "</u:SetAVTransportURI>", uri];
    [self sendCommandToEndpoint:kSonosEndpointTransport action:header body:body complete:^(NSURLResponse *response, NSData *data, NSError *error) {
      [self play:nil];
    }];
  } else {
    NSString *header = [NSString stringWithFormat:kSonosTemplateTransportHeader, @"Play"];
    NSString *body = [NSString stringWithFormat:kSonosTemplateTransportBody, @"Play", @"Play"];
    [self sendCommandToEndpoint:kSonosEndpointTransport action:header body:body complete:^(NSURLResponse *response, NSData *data, NSError *error) {
      _isPlaying = YES;
    }];
  }
}

- (void)pause
{
  NSString *header = [NSString stringWithFormat:kSonosTemplateTransportHeader, @"Pause"];
  NSString *body = [NSString stringWithFormat:kSonosTemplateTransportBody, @"Pause", @"Pause"];
  [self sendCommandToEndpoint:kSonosEndpointTransport action:header body:body complete:^(NSURLResponse *response, NSData *data, NSError *error) {
    _isPlaying = NO;
  }];
}

- (void)stop
{
  [self sendTransportCommand:@"Stop" complete:^(NSURLResponse *response, NSData *data, NSError *error) {
    _isPlaying = NO; // TODO: Check to make sure this is actually true.
  }];
}

- (void)next
{
  [self sendTransportCommand:@"Next" complete:nil];
}

- (void)previous
{
  [self sendTransportCommand:@"Previous" complete:nil];
}

- (void)speakers
{
  // TODO: Discover speakers using UPnP's discovery stuff.
}

- (void)lineIn:(NSString *)uid
{
  NSString *header = [NSString stringWithFormat:kSonosTemplateTransportHeader, @"SetAVTransportURI"];
  NSString *body = [NSString stringWithFormat:@""
    "<u:SetAVTransportURI xmlns:u='urn:schemas-upnp-org:service:AVTransport:1'>"
      "<InstanceID>0</InstanceID>"
      "<CurrentURI>x-rincon-stream:%@</CurrentURI>"
      "<CurrentURIMetaData></CurrentURIMetaData>"
    "</u:SetAVTransportURI>", uid];
  [self sendCommandToEndpoint:kSonosEndpointTransport action:header body:body complete:^(NSURLResponse *response, NSData *data, NSError *error) {
    [self play:nil];
  }];
}

- (void)join
{
  NSString *body = @""
    "<u:SetAVTransportURI xmlns:u='urn:schemas-upnp-org:service:AVTransport:1'>"
      "<InstanceID>0</InstanceID>"
      "<CurrentURI>x-rincon:</CurrentURI>"
      "<CurrentURIMetaData></CurrentURIMetaData>"
    "</u:SetAVTransportURI>";
  [self sendCommandToEndpoint:kSonosEndpointTransport
                       action:[NSString stringWithFormat:kSonosTemplateTransportHeader, @"SetAVTransportURI"]
                         body:body
                     complete:nil];
}

- (void)volume
{
  NSString *header = [NSString stringWithFormat:kSonosTemplateRenderingHeader, @"GetVolume"];
  NSString *body = @""
    "<u:GetVolume xmlns:u='urn:schemas-upnp-org:service:RenderingControl:1'>"
      "<InstanceID>0</InstanceID>"
      "<Channel>Master</Channel>"
    "</u:GetVolume>";
  [self sendCommandToEndpoint:kSonosEndpointRendering action:header body:body complete:nil];
}

- (void)volume:(int)volume
{
  if (volumeLevel == volume) {
    return;
  }
  NSString *header = [NSString stringWithFormat:kSonosTemplateRenderingHeader, @"SetVolume"];
  NSString *body = [NSString stringWithFormat:@""
    "<u:SetVolume xmlns:u='urn:schemas-upnp-org:service:RenderingControl:1'>"
      "<InstanceID>0</InstanceID>"
      "<Channel>Master</Channel>"
      "<DesiredVolume>%d</DesiredVolume>"
    "</u:SetVolume>", volume];
  [self sendCommandToEndpoint:kSonosEndpointRendering action:header body:body complete:nil];
  volumeLevel = volume;
}

- (void)trackInfo
{
  NSString *header = [NSString stringWithFormat:kSonosTemplateTransportHeader, @"GetPositionInfo"];
  NSString *body = @""
    "<u:GetPositionInfo xmlns:u='urn:schemas-upnp-org:service:AVTransport:1'>"
      "<InstanceID>0</InstanceID>"
    "</u:GetPositionInfo>";
  [self sendCommandToEndpoint:kSonosEndpointTransport action:header body:body complete:^(NSURLResponse *response, NSData *data, NSError *error) {
    // TODO: Parse response.
  }];
}

- (void)search
{
  NSString *header = [NSString stringWithFormat:kSonosTemplateContentDirectorytHeader, @"ContentDirectory"];
  NSString *body = @""
    "<u:Browse xmlns:u='urn:schemas-upnp-org:service:ContentDirectory:1'>"
      "<ObjectID>A:ARTIST</ObjectID>"
      "<BrowseFlag>BrowseDirectChildren</BrowseFlag>"
      "<Filter>*</Filter>"
      "<StartingIndex>0</StartingIndex>"
      "<RequestedCount>10</RequestedCount>"
      "<SortCriteria>*</SortCriteria>"
    "</u:Browse>";
  [self sendCommandToEndpoint:kSonosEndpointContentDirectory action:header body:body complete:^(NSURLResponse *response, NSData *data, NSError *error) {
    // TODO: Parse response.
  }];
}

@end
