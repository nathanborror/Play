//
//  SonosController.h
//  Play
//
//  Created by Nathan Borror on 12/31/12.
//  Copyright (c) 2012 Nathan Borror. All rights reserved.
//

#import <Foundation/Foundation.h>

@class SonosResponse;

@interface SonosController : NSObject

@property (nonatomic, readonly) BOOL isPlaying;

- (id)initWithIP:(NSString *)ip;

+ (SonosController *)sharedController;

- (SonosResponse *)fetchSOAPURL:(NSURL *)url
                        action:(NSString *)action
                             body:(NSString *)body
                   withCompletion:(void(^)(SonosResponse *body, NSError *error))block;

- (void)play:(NSString *)uri;
- (void)pause;
- (void)stop;
- (void)next;
- (void)previous;
- (void)volume;
- (void)volume:(int)volume;
- (void)lineIn:(NSString *)uid;
- (void)trackInfoWithCompletion:(void(^)(SonosResponse *response, NSError *error))block;
- (void)browseWithCompletion:(void(^)(SonosResponse *response, NSError *error))block;

@end
