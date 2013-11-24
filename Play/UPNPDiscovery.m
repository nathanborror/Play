//
//  UPNPDiscovery.m
//  Home
//
//  Created by Drew Ingebretsen on 7/5/13.
//  Copyright (c) 2013 PeopleTech. All rights reserved.
//

#import "UPNPDiscovery.h"
#import "GCDAsyncUdpSocket.h"

static UPNPDiscovery *_sharedController = nil;

@implementation UPNPDiscovery {
  GCDAsyncUdpSocket *_UDPSocket;
  NSArray *_ipAddresses;
  NSString *_urn;
  void (^_completion)(NSArray *ipAddresses);
}

- (void)findWithUrn:(NSString *)urn completion:(void (^)(NSArray *))block {
  _completion = block;
  _urn = urn;
  _ipAddresses = [NSArray array];
  _UDPSocket = [[GCDAsyncUdpSocket alloc] initWithDelegate:self delegateQueue:dispatch_get_main_queue()];

  NSError *error = nil;

  if (![_UDPSocket bindToPort:0 error:&error]) {
    NSLog(@"Error binding: %@", error.description);
  }

  if (![_UDPSocket beginReceiving:&error]) {
    NSLog(@"Error receiving: %@", error.description);
  }

  [_UDPSocket enableBroadcast:YES error:&error];

  if (error) {
    NSLog(@"Error enabling broadcast: %@", error.description);
  }

  NSString *msg = [NSString stringWithFormat:@"M-SEARCH * HTTP/1.1\r\nHost: 239.255.255.250:1900\r\nMan: ssdp:discover\r\nMx: 1\r\nST: %@\r\n\r\n", _urn];
  NSData *data = [msg dataUsingEncoding:NSUTF8StringEncoding];
  [_UDPSocket sendData:data toHost:@"239.255.255.250" port:1900 withTimeout:2 tag:1];

  dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 2 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
    [self stop];
  });
}

- (void)stop {
  [_UDPSocket close];
  _UDPSocket = nil;
  _completion(_ipAddresses);
}

#pragma mark - GCDAsyncUdpSocketDelegate

- (void)udpSocket:(GCDAsyncUdpSocket *)sock didReceiveData:(NSData *)data fromAddress:(NSData *)address withFilterContext:(id)filterContext {
  NSString *msg = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
  if ([msg rangeOfString:_urn].location != NSNotFound) {
    NSRegularExpression *regex = [[NSRegularExpression alloc] initWithPattern:@"http:\\/\\/(.*?)\\/" options:0 error:nil];
    NSArray *matches = [regex matchesInString:msg options:0 range:NSMakeRange(0, msg.length)];
    if (matches.count > 0) {
      NSTextCheckingResult *result = matches[0];
      NSString *matched = [msg substringWithRange:[result rangeAtIndex:0]];
      NSString *ip = [[matched substringFromIndex:7] substringToIndex:matched.length-8];
      _ipAddresses = [_ipAddresses arrayByAddingObject:ip];
    }
  }
}

@end
