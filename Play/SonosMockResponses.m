//
//  SonosMockResponses.m
//  Play
//
//  Created by Nathan Borror on 1/27/13.
//  Copyright (c) 2013 Nathan Borror. All rights reserved.
//

#import "SonosMockResponses.h"

@implementation SonosMockResponses

+ (NSData *)trackInfoResponse
{
  NSString *mockResponseXML = @""
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
  "</s:Envelope>";

  return [mockResponseXML dataUsingEncoding:NSUTF8StringEncoding];
}

@end
