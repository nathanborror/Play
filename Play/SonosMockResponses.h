//
//  SonosMockResponses.h
//  Play
//
//  Created by Nathan Borror on 1/27/13.
//  Copyright (c) 2013 Nathan Borror. All rights reserved.
//

@import Foundation;

@interface SonosMockResponses : NSObject

+ (SonosMockResponses *)sharedResponses;

- (NSData *)responseFor:(NSString *)action;

@end
