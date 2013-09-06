//
//  SonosPositionInfoResponse.m
//  Play
//
//  Created by Nathan Borror on 1/21/13.
//  Copyright (c) 2013 Nathan Borror. All rights reserved.
//

#import "SonosPositionInfoResponse.h"

@implementation SonosPositionInfoResponse

#pragma mark - NSXMLParserDelegate

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict
{
  if ([elementName isEqual:@"Track"]) {
    currentString = [[NSMutableString alloc] init];
    [self setTrack:currentString];
  } else if ([elementName isEqual:@"TrackDuration"]) {
    currentString = [[NSMutableString alloc] init];
    [self setDuration:currentString];
  } else if ([elementName isEqual:@"TrackMetaData"]) {
    currentString = [[NSMutableString alloc] init];
    [self setMetaData:currentString];
  } else if ([elementName isEqual:@"TrackURI"]) {
    currentString = [[NSMutableString alloc] init];
    [self setUri:currentString];
  } else if ([elementName isEqual:@"RelTime"]) {
    currentString = [[NSMutableString alloc] init];
    [self setRelTime:currentString];
  } else if ([elementName isEqual:@"AbsTime"]) {
    currentString = [[NSMutableString alloc] init];
    [self setAbsTime:currentString];
  } else if ([elementName isEqual:@"RelCount"]) {
    currentString = [[NSMutableString alloc] init];
    [self setRelCount:currentString];
  } else if ([elementName isEqual:@"AbsCount"]) {
    currentString = [[NSMutableString alloc] init];
    [self setAbsCount:currentString];
  }
}

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string
{
  [currentString appendString:string];
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName
{
  currentString = nil;

  if ([elementName isEqual:@"u:GetPositionInfoResponse"]) {
    [parser setDelegate:_parentParserDelegate];
  }
}

@end
