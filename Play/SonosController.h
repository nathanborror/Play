//
//  SonosController.h
//  Play
//
//  Created by Nathan Borror on 12/31/12.
//  Copyright (c) 2012 Nathan Borror. All rights reserved.
//

#import <Foundation/Foundation.h>

@class SonosResponse;
@class SonosInput;

@interface SonosController : NSObject

@property (nonatomic, readonly) BOOL isPlaying;

- (id)initWithInput:(SonosInput *)input;

+ (SonosController *)sharedController;

- (SonosResponse *)fetchSOAPURL:(NSURL *)url
                        action:(NSString *)action
                             body:(NSString *)body
                   completion:(void(^)(SonosResponse *body, NSError *error))block;

- (void)play:(SonosInput *)input track:(NSString *)track completion:(void(^)(SonosResponse *response, NSError *error))block;
- (void)pause:(SonosInput *)input completion:(void(^)(SonosResponse *response, NSError *error))block;
- (void)stop:(SonosInput *)input completion:(void(^)(SonosResponse *response, NSError *error))block;
- (void)next:(SonosInput *)input completion:(void(^)(SonosResponse *response, NSError *error))block;
- (void)previous:(SonosInput *)input completion:(void(^)(SonosResponse *response, NSError *error))block;
- (void)volume:(SonosInput *)input completion:(void(^)(SonosResponse *response, NSError *error))block;
- (void)volume:(SonosInput *)input level:(int)level completion:(void(^)(SonosResponse *response, NSError *error))block;
- (void)lineIn:(SonosInput *)input completion:(void(^)(SonosResponse *response, NSError *error))block;
- (void)trackInfo:(SonosInput *)input completion:(void(^)(SonosResponse *response, NSError *error))block;
- (void)browse:(SonosInput *)input completion:(void(^)(SonosResponse *response, NSError *error))block;

@end
