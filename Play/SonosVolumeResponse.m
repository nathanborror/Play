//
//  SonosVolumeResponse.m
//  Play
//
//  Created by Nathan Borror on 2/21/13.
//  Copyright (c) 2013 Nathan Borror. All rights reserved.
//

#import "SonosVolumeResponse.h"

@implementation SonosVolumeResponse {
  NSMutableString *_currentString;
}

#pragma mark - NSXMLParserDelegate

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict
{
  if ([elementName isEqual:@"CurrentVolume"]) {
    _currentString = [[NSMutableString alloc] init];
    [self setCurrentVolume:_currentString];
  }
}

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string
{
  [_currentString appendString:string];
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName
{
  _currentString = nil;

  if ([elementName isEqual:@"u:GetVolumeResponse"]) {
    [parser setDelegate:_parentParserDelegate];
  }
}

@end
