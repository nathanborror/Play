//
//  SonosPositionInfoResponse.m
//  Play
//
//  Created by Nathan Borror on 1/21/13.
//  Copyright (c) 2013 Nathan Borror. All rights reserved.
//

#import "SonosPositionInfoResponse.h"

@implementation SonosPositionInfoResponse {
  NSMutableString *_currentString;
}

#pragma mark - NSXMLParserDelegate

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict
{
  if ([elementName isEqual:@"Track"]) {
    _currentString = [[NSMutableString alloc] init];
    [self setTrack:_currentString];
  } else if ([elementName isEqual:@"TrackDuration"]) {
    _currentString = [[NSMutableString alloc] init];
    [self setDuration:_currentString];
  } else if ([elementName isEqual:@"TrackMetaData"]) {
    _currentString = [[NSMutableString alloc] init];
    [self setMetaData:_currentString];
  } else if ([elementName isEqual:@"TrackURI"]) {
    _currentString = [[NSMutableString alloc] init];
    [self setUri:_currentString];
  } else if ([elementName isEqual:@"RelTime"]) {
    _currentString = [[NSMutableString alloc] init];
    [self setRelTime:_currentString];
  } else if ([elementName isEqual:@"AbsTime"]) {
    _currentString = [[NSMutableString alloc] init];
    [self setAbsTime:_currentString];
  } else if ([elementName isEqual:@"RelCount"]) {
    _currentString = [[NSMutableString alloc] init];
    [self setRelCount:_currentString];
  } else if ([elementName isEqual:@"AbsCount"]) {
    _currentString = [[NSMutableString alloc] init];
    [self setAbsCount:_currentString];
  }
}

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string
{
  [_currentString appendString:string];
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName
{
  _currentString = nil;

  if ([elementName isEqual:@"u:GetPositionInfoResponse"]) {
    [parser setDelegate:_parentParserDelegate];
  }
}

@end
