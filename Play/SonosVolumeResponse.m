//
//  SonosVolumeResponse.m
//  Play
//
//  Created by Nathan Borror on 2/21/13.
//  Copyright (c) 2013 Nathan Borror. All rights reserved.
//

#import "SonosVolumeResponse.h"

@implementation SonosVolumeResponse
@synthesize parentParserDelegate, currentVolume;

#pragma mark - NSXMLParserDelegate

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict
{
  if ([elementName isEqual:@"CurrentVolume"]) {
    currentString = [[NSMutableString alloc] init];
    [self setCurrentVolume:currentString];
  }
}

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string
{
  [currentString appendString:string];
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName
{
  currentString = nil;

  if ([elementName isEqual:@"u:GetVolumeResponse"]) {
    [parser setDelegate:parentParserDelegate];
  }
}

@end
