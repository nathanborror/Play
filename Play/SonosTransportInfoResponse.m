//
//  SonosTransportInfoResponse.m
//  Play
//
//  Created by Nathan Borror on 5/8/13.
//  Copyright (c) 2013 Nathan Borror. All rights reserved.
//

#import "SonosTransportInfoResponse.h"

@implementation SonosTransportInfoResponse {
  NSMutableString *_currentString;
}

#pragma mark - NSXMLParserDelegate

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict
{
  if ([elementName isEqual:@"CurrentTransportState"]) {
    _currentString = [[NSMutableString alloc] init];
    [self setState:_currentString];
  } else if ([elementName isEqual:@"CurrentTransportStatus"]) {
    _currentString = [[NSMutableString alloc] init];
    [self setStatus:_currentString];
  } else if ([elementName isEqual:@"CurrentSpeed"]) {
    _currentString = [[NSMutableString alloc] init];
    [self setSpeed:_currentString];
  }
}

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string
{
  [_currentString appendString:string];
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName
{
  _currentString = nil;

  if ([elementName isEqual:@"u:GetTransportInfoResponse"]) {
    [parser setDelegate:_parentParserDelegate];
  }
}
@end
