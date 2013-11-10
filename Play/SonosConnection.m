//
//  SonosConnection.m
//  Play
//
//  Created by Nathan Borror on 1/21/13.
//  Copyright (c) 2013 Nathan Borror. All rights reserved.
//

#import "SonosConnection.h"
#import "XMLReader.h"

static NSMutableArray *sharedConnectionList = nil;

@implementation SonosConnection

- (id)initWithRequest:(NSURLRequest *)req completion:(void (^)(id, NSError *))block
{
  if (self = [super init]) {
    [self setRequest:req];
    [self setCompletionBlock:block];
  }
  return self;
}

- (void)start
{
  container = [[NSMutableData alloc] init];
  internalConnection = [[NSURLConnection alloc] initWithRequest:self.request delegate:self startImmediately:YES];

  if (!sharedConnectionList) {
    sharedConnectionList = [[NSMutableArray alloc] init];
  }
  [sharedConnectionList addObject:self];
}

#pragma mark - NSURLConnectionDelegate

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
  [container appendData:data];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
  NSDictionary *response = [XMLReader dictionaryForXMLData:container options:XMLReaderOptionsProcessNamespaces error:nil];
  NSDictionary *body = response[@"s:Envelope"][@"s:Body"];

  // Check for embedded XML
  if (body[@"u:GetMediaInfoResponse"][@"CurrentURIMetaData"][@"text"]) {
    NSString *metadataString = body[@"u:GetMediaInfoResponse"][@"CurrentURIMetaData"][@"text"];
    NSDictionary *metadata = [XMLReader dictionaryForXMLString:metadataString error:nil];
    body[@"u:GetMediaInfoResponse"][@"CurrentURIMetaData"] = metadata[@"DIDL-Lite"][@"item"];
  }

  if (_completionBlock) {
    _completionBlock(body, nil);
  }
  [sharedConnectionList removeObject:self];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
  if (_completionBlock) {
    _completionBlock(nil, error);
  }
  [sharedConnectionList removeObject:self];
}

@end
