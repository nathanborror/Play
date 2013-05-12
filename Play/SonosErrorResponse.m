//
//  SonosErrorResponse.m
//  Play
//
//  Created by Nathan Borror on 1/21/13.
//  Copyright (c) 2013 Nathan Borror. All rights reserved.
//

#import "SonosErrorResponse.h"

@implementation SonosErrorResponse
@synthesize parentParserDelegate, code, string, detail;

#pragma mark - NSXMLParserDelegate

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict
{
  if ([elementName isEqual:@"faultcode"]) {
    currentString = [[NSMutableString alloc] init];
    [self setCode:currentString];
  } else if ([elementName isEqual:@"faultstring"]) {
    currentString = [[NSMutableString alloc] init];
    [self setString:currentString];
  } else if ([elementName isEqual:@"detail"]) {
    currentString = [[NSMutableString alloc] init];
    [self setDetail:currentString];
  }
}

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)aString
{
  [currentString appendString:aString];
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName
{
  currentString = nil;

  if ([elementName isEqual:@"s:Fault"]) {
    [parser setDelegate:parentParserDelegate];
  }
}

@end
