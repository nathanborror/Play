//
//  SonosConnection.m
//  Play
//
//  Created by Nathan Borror on 1/21/13.
//  Copyright (c) 2013 Nathan Borror. All rights reserved.
//

#import "SonosConnection.h"
#import "SonosMockResponses.h"
#import "SonosErrorResponse.h"

static NSMutableArray *sharedConnectionList = nil;

#if TARGET_IPHONE_SIMULATOR
static const BOOL kTargetSimulator = NO;
# else
static const BOOL kTargetSimulator = NO;
#endif

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

  if (kTargetSimulator) {
    // Bypass NSURLConnection and call connectionDidFinishLoading directly
    NSData *mockResponse = [[SonosMockResponses sharedResponses] responseFor:[_request valueForHTTPHeaderField:@"SOAPACTION"]];
    [container appendData:mockResponse];
    [self connectionDidFinishLoading:nil];
  } else {
    internalConnection = [[NSURLConnection alloc] initWithRequest:self.request delegate:self startImmediately:YES];
  }

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
  id rootObject = nil;
  if (_envelope) {
    NSXMLParser *parser = [[NSXMLParser alloc] initWithData:container];

    [parser setDelegate:[self envelope]];
    [parser parse];
    rootObject = [self envelope];
  }

  if (_completionBlock) {
    if ([[rootObject response] class] == [SonosErrorResponse class]) {
      SonosErrorResponse *error = (SonosErrorResponse *)[rootObject response];
      NSLog(@"\n\nSonosErrorResponse:"
            "\n\tRequest: %@"
            "\n\tCode: %@"
            "\n\tString: %@"
            "\n\tDetail: %@"
            "\n\tHTTPBody: %@"
            "\n\n", _request.URL, error.code, error.string, error.detail, [[NSString alloc] initWithData:_request.HTTPBody encoding:NSUTF8StringEncoding]);
    }
    _completionBlock(rootObject, nil);
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
