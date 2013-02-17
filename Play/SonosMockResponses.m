//
//  SonosMockResponses.m
//  Play
//
//  Created by Nathan Borror on 1/27/13.
//  Copyright (c) 2013 Nathan Borror. All rights reserved.
//

#import "SonosMockResponses.h"

@interface SonosMockResponses ()
{
  NSMutableDictionary *responses;
}
@end

@implementation SonosMockResponses

- (id)init
{
  self = [super init];
  if (self) {
    responses = [[NSMutableDictionary alloc] init];

    // Track Info
    // METHOD: POST http://SPEAKER_IP:1400/MediaRenderer/AVTransport/Control
    [responses setObject:@""
    "<s:Envelope xmlns:s='http://schemas.xmlsoap.org/soap/envelope/' s:encodingStyle='http://schemas.xmlsoap.org/soap/encoding/'>"
      "<s:Body>"
        "<u:GetPositionInfoResponse xmlns:u='urn:schemas-upnp-org:service:AVTransport:1'>"
          "<Track>1</Track>"
          "<TrackDuration>0:00:00</TrackDuration>"
          "<TrackMetaData>"
            "<DIDL-Lite xmlns:dc='http://purl.org/dc/elements/1.1/' xmlns:upnp='urn:schemas-upnp-org:metadata-1-0/upnp/' xmlns:r='urn:schemas-rinconnetworks-com:metadata-1-0/' xmlns='urn:schemas-upnp-org:metadata-1-0/DIDL-Lite/'>"
              "<item id='-1' parentID='-1' restricted='true'>"
              "<res protocolInfo='http-get:*:application/octet-stream:*'>http://mobile-iPhone-D8D1CBAC4DA9.x-udn/music/track.adts?id=CCAE56B9C5E54482</res>"
              "<r:streamContent></r:streamContent>"
              "<dc:title>track.adts?id=CCAE56B9C5E54482</dc:title>"
              "<upnp:class>object.item</upnp:class>"
              "</item>"
            "</DIDL-Lite>"
          "</TrackMetaData>"
          "<TrackURI>http://mobile-iPhone-D8D1CBAC4DA9.x-udn/music/track.adts?id=CCAE56B9C5E54482</TrackURI>"
          "<RelTime>0:00:43</RelTime>"
          "<AbsTime>NOT_IMPLEMENTED</AbsTime>"
          "<RelCount>2147483647</RelCount>"
          "<AbsCount>2147483647</AbsCount>"
        "</u:GetPositionInfoResponse>"
      "</s:Body>"
    "</s:Envelope>" forKey:@"urn:schemas-upnp-org:service:AVTransport:1#GetPositionInfo"];

    // Play
    // METHOD: POST http://SPEAKER_IP:1400/MediaRenderer/AVTransport/Control
    [responses setObject:@""
    "<s:Envelope xmlns:s='http://schemas.xmlsoap.org/soap/envelope/' s:encodingStyle='http://schemas.xmlsoap.org/soap/encoding/'>"
      "<s:Body>"
        "<u:PlayResponse xmlns:u='urn:schemas-upnp-org:service:AVTransport:1'></u:PlayResponse>"
      "</s:Body>"
    "</s:Envelope>" forKey:@"urn:schemas-upnp-org:service:AVTransport:1#Play"];

    // Play Track
    // METHOD: POST http://SPEAKER_IP:1400/MediaRenderer/AVTransport/Control
    [responses setObject:@""
    "<s:Envelope xmlns:s='http://schemas.xmlsoap.org/soap/envelope/' s:encodingStyle='http://schemas.xmlsoap.org/soap/encoding/'>"
      "<s:Body>"
        "<u:SetAVTransportURIResponse xmlns:u='urn:schemas-upnp-org:service:AVTransport:1'></u:SetAVTransportURIResponse>"
      "</s:Body>"
    "</s:Envelope>" forKey:@"urn:schemas-upnp-org:service:AVTransport:1#SetAVTransportURI"];

    // Pause
    // METHOD: POST http://SPEAKER_IP:1400/MediaRenderer/AVTransport/Control
    [responses setObject:@""
    "<s:Envelope xmlns:s='http://schemas.xmlsoap.org/soap/envelope/' s:encodingStyle='http://schemas.xmlsoap.org/soap/encoding/'>"
      "<s:Body>"
        "<u:PauseResponse xmlns:u='urn:schemas-upnp-org:service:AVTransport:1'></u:PauseResponse>"
      "</s:Body>"
    "</s:Envelope>" forKey:@"urn:schemas-upnp-org:service:AVTransport:1#Pause"];

    // Volume
    // METHOD: POST http://SPEAKER_IP:1400/MediaRenderer/AVTransport/Control
    [responses setObject:@""
    "<s:Envelope xmlns:s='http://schemas.xmlsoap.org/soap/envelope/' s:encodingStyle='http://schemas.xmlsoap.org/soap/encoding/'>"
      "<s:Body>"
        "<u:SetVolumeResponse xmlns:u='urn:schemas-upnp-org:service:RenderingControl:1'></u:SetVolumeResponse>"
      "</s:Body>"
    "</s:Envelope>" forKey:@"urn:schemas-upnp-org:service:RenderingControl:1#SetVolume"];

    
  }
  return self;
}

+ (SonosMockResponses *)sharedResponses
{
  static SonosMockResponses *sharedResponses = nil;
  if (!sharedResponses) {
    sharedResponses = [[SonosMockResponses alloc] init];
  }
  return sharedResponses;
}

- (NSData *)responseFor:(NSString *)action
{
  return [[responses objectForKey:action] dataUsingEncoding:NSUTF8StringEncoding];
}

@end
