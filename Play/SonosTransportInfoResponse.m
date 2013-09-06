//
//  SonosTransportInfoResponse.m
//  Play
//
//  Created by Nathan Borror on 5/8/13.
//  Copyright (c) 2013 Nathan Borror. All rights reserved.
//

#import "SonosTransportInfoResponse.h"

@implementation SonosTransportInfoResponse

#pragma mark - NSXMLParserDelegate

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict
{
  if ([elementName isEqual:@"CurrentTransportState"]) {
    currentString = [[NSMutableString alloc] init];
    [self setState:currentString];
  } else if ([elementName isEqual:@"CurrentTransportStatus"]) {
    currentString = [[NSMutableString alloc] init];
    [self setStatus:currentString];
  } else if ([elementName isEqual:@"CurrentSpeed"]) {
    currentString = [[NSMutableString alloc] init];
    [self setSpeed:currentString];
  }
}

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string
{
  [currentString appendString:string];
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName
{
  currentString = nil;

  if ([elementName isEqual:@"u:GetTransportInfoResponse"]) {
    [parser setDelegate:_parentParserDelegate];
  }
}
@end
