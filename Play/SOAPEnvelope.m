//
//  SOAPEnvelope.m
//  Play
//
//  Created by Nathan Borror on 1/21/13.
//  Copyright (c) 2013 Nathan Borror. All rights reserved.
//

#import "SOAPEnvelope.h"
#import "SonosPositionInfoResponse.h"
#import "SonosErrorResponse.h"
#import "SonosVolumeResponse.h"

@implementation SOAPEnvelope
@synthesize action, response, parentParserDelegate;

- (id)init
{
  self = [super init];
  if (self) {
    response = nil;
  }
  return self;
}

#pragma mark - NSXMLParserDelegate

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict
{
  if ([elementName isEqual:@"u:GetPositionInfoResponse"]) {
    SonosPositionInfoResponse *res = [[SonosPositionInfoResponse alloc] init];
    [res setParentParserDelegate:self];
    [parser setDelegate:res];
    [self setResponse:res];
  } else if ([elementName isEqual:@"u:PauseResponse"]) {
    
  } else if ([elementName isEqual:@"u:PlayResponse"]) {

  } else if ([elementName isEqual:@"u:SetVolumeResponse"]) {
    
  } else if ([elementName isEqual:@"u:GetVolumeResponse"]) {
    SonosVolumeResponse *res = [[SonosVolumeResponse alloc] init];
    [res setParentParserDelegate:self];
    [parser setDelegate:res];
    [self setResponse:res];
  } else if ([elementName isEqual:@"u:SetAVTransportURIResponse"]) {

  } else if ([elementName isEqual:@"s:Fault"]) {
    SonosErrorResponse *res = [[SonosErrorResponse alloc] init];
    [res setParentParserDelegate:self];
    [parser setDelegate:res];
    [self setResponse:res];
  }
}

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string
{
  // TODO: Not sure what to do here or if I even need this
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName
{
  if ([elementName isEqual:@"s:Envelope"]) {
    [parser setDelegate:parentParserDelegate];
  }
}

@end
