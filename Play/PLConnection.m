//
//  PLConnection.m
//  Play
//
//  Created by Nathan Borror on 1/21/13.
//  Copyright (c) 2013 Nathan Borror. All rights reserved.
//

#import "PLConnection.h"
#import "SonosMockResponses.h"

static NSMutableArray *sharedConnectionList = nil;

#if TARGET_IPHONE_SIMULATOR
static const BOOL kTargetSimulator = YES;
# else
static const BOOL kTargetSimulator = NO;
#endif

@implementation PLConnection
@synthesize request, completionBlock, xmlRootObject;

- (id)initWithRequest:(NSURLRequest *)req
{
  self = [super init];
  if (self) {
    [self setRequest:req];
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
  id rootObject = nil;
  if ([self xmlRootObject]) {
    // If running in simulator return a mock response.
    NSXMLParser *parser = kTargetSimulator ? [self respondWithMockResponse] : [[NSXMLParser alloc] initWithData:container];

    [parser setDelegate:[self xmlRootObject]];
    [parser parse];
    rootObject = [self xmlRootObject];
  }

  if ([self completionBlock]) {
    [self completionBlock](rootObject, nil);
  }
  [sharedConnectionList removeObject:self];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
  UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"Connection Error" message:error.localizedDescription delegate:nil cancelButtonTitle:@"Okay" otherButtonTitles:nil, nil];
  [av show];

  if ([self completionBlock]) {
    [self completionBlock](nil, error);
  }
  [sharedConnectionList removeObject:self];
}

- (NSXMLParser *)respondWithMockResponse
{
  NSLog(@"Mock Response returned");
  return [[NSXMLParser alloc] initWithData:[SonosMockResponses trackInfoResponse]];
}

@end
