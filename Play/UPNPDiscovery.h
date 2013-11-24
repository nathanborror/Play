//
//  UPNPDiscovery.h
//  Home
//
//  Created by Drew Ingebretsen on 7/5/13.
//  Copyright (c) 2013 PeopleTech. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UPNPDiscovery : NSObject

-(void)findWithUrn:(NSString *)urn completion:(void(^)(NSArray *ipAddresses))block;
-(void)stop;

@end