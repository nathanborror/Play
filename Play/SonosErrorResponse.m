//
//  SonosErrorResponse.m
//  Play
//
//  Created by Nathan Borror on 1/21/13.
//  Copyright (c) 2013 Nathan Borror. All rights reserved.
//

#import "SonosErrorResponse.h"

@implementation SonosErrorResponse {
  NSMutableString *_currentString;
}

#pragma mark - NSXMLParserDelegate

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict
{
  if ([elementName isEqual:@"faultcode"]) {
    _currentString = [[NSMutableString alloc] init];
    [self setCode:_currentString];
  } else if ([elementName isEqual:@"faultstring"]) {
    _currentString = [[NSMutableString alloc] init];
    [self setString:_currentString];
  } else if ([elementName isEqual:@"detail"]) {
    _currentString = [[NSMutableString alloc] init];
    [self setDetail:_currentString];
  }
}

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)aString
{
  [_currentString appendString:aString];
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName
{
  _currentString = nil;

  if ([elementName isEqual:@"s:Fault"]) {
    [parser setDelegate:_parentParserDelegate];
  }
}

@end
