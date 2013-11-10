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

typedef void (^findDeviceBlock)(NSArray *ipAddresses);

@interface UPNPDiscovery()
@property (nonatomic, strong) GCDAsyncUdpSocket *udpSocket;
@property (nonatomic, strong) NSString *st;
@property (nonatomic, strong) findDeviceBlock completionBlock;
@property (nonatomic, strong) NSArray *ipAddressArray;
@end

@implementation UPNPDiscovery

-(void)FindDevicesWithST:(NSString*)stString completion:(findDeviceBlock)block{
    self.completionBlock = block;
    self.st = stString;
    self.ipAddressArray = [NSArray array];
    self.udpSocket = [[GCDAsyncUdpSocket alloc] initWithDelegate:self delegateQueue:dispatch_get_main_queue()];
    NSError *error = nil;
    if (![self.udpSocket bindToPort:0 error:&error])
        NSLog(@"Error binding: %@", error.description);
    if (![self.udpSocket beginReceiving:&error])
        NSLog(@"Error receiving: %@", error.description);
    [self.udpSocket enableBroadcast:YES error:&error];
    if (error)
        NSLog(@"Error enabling broadcast: %@", error.description);
    
    NSString *msg = [NSString stringWithFormat:@"M-SEARCH * HTTP/1.1\r\nHost: 239.255.255.250:1900\r\nMan: ssdp:discover\r\nMx: 1\r\nST: %@\r\n\r\n",stString];
    NSData *msgData = [msg dataUsingEncoding:NSUTF8StringEncoding];
    [self.udpSocket sendData:msgData toHost:@"239.255.255.250" port:1900 withTimeout:2 tag:1];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 2 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        [self stopDiscovery];
    });
}

- (void)stopDiscovery {
    [self.udpSocket close];
    self.udpSocket = nil;
    self.completionBlock(self.ipAddressArray);
}

#pragma mark - GCDAsyncUdpSocketDelegate

- (void)udpSocket:(GCDAsyncUdpSocket *)sock didReceiveData:(NSData *)data fromAddress:(NSData *)address withFilterContext:(id)filterContext {
    NSString *msg = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    if ([msg rangeOfString:self.st].location != NSNotFound) {
        NSRegularExpression *reg = [[NSRegularExpression alloc] initWithPattern:@"http:\\/\\/(.*?)\\/" options:0 error:nil];
        NSArray *matches = [reg matchesInString:msg options:0 range:NSMakeRange(0, msg.length)];
        if (matches.count > 0) {
            NSTextCheckingResult *result = matches[0];
            NSString *matched = [msg substringWithRange:[result rangeAtIndex:0]];
            NSString *ip = [[matched substringFromIndex:7] substringToIndex:matched.length-8];
            self.ipAddressArray = [self.ipAddressArray arrayByAddingObject:ip];
        }
    }
}

@end
