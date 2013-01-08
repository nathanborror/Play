//
//  SonosController.h
//  Play
//
//  Created by Nathan Borror on 12/31/12.
//  Copyright (c) 2012 Nathan Borror. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SonosController : NSObject

@property (nonatomic, readonly) BOOL isPlaying;

- (id)initWithIP:(NSString *)ip;

+ (SonosController *)sharedController;

- (void)play:(NSString *)uri;
- (void)pause;
- (void)stop;
- (void)next;
- (void)previous;
- (void)join;
- (void)volume;
- (void)volume:(int)volume;
- (void)trackInfo;
- (void)lineIn:(NSString *)uid;
- (void)search;

@end
