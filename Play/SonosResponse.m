//
//  SonosResponse.m
//  Play
//
//  Created by Nathan Borror on 1/21/13.
//  Copyright (c) 2013 Nathan Borror. All rights reserved.
//

#import "SonosResponse.h"
#import "SonosPositionInfoResponse.h"
#import "SonosErrorResponse.h"

@implementation SonosResponse
@synthesize action, response, parentParserDelegate;

- (id)init
{
  self = [super init];
  if (self) {
    //
  }
  return self;
}

#pragma mark - NSXMLParserDelegate

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict
{
  // NSLog(@"\t%@ found a %@ element", self, elementName);
  // TODO: The following probably won't scale to more complex actions

  if ([elementName isEqual:@"u:GetPositionInfoResponse"]) {
    SonosPositionInfoResponse *res = [[SonosPositionInfoResponse alloc] init];
    [res setParentParserDelegate:self];
    [parser setDelegate:res];
    [self setResponse:res];
  } else if ([elementName isEqual:@"u:PauseResponse"]) {
    
  } else if ([elementName isEqual:@"u:PlayResponse"]) {

  } else if ([elementName isEqual:@"u:SetVolumeResponse"]) {
    
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
