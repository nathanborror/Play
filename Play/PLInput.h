//
//  PLInput.h
//  Play
//
//  Created by Nathan Borror on 1/1/13.
//  Copyright (c) 2013 Nathan Borror. All rights reserved.
//

@import Foundation;

typedef NS_ENUM(NSInteger, PLInputStatus) {
  PLInputStatusPlaying,
  PLInputStatusStopped,
  PLInputStatusPaused,
  PLInputStatusSlave,
};

@interface PLInput : NSObject <NSCoding>

@property (nonatomic, strong) NSString *ip;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *uid;
@property (nonatomic, strong) NSString *uri;
@property (nonatomic, strong) NSString *group;
@property (nonatomic, assign) PLInputStatus status;

- (instancetype)initWithIP:(NSString *)aIP name:(NSString *)aName uid:(NSString *)aUid;

- (void)pairWithInput:(PLInput *)master;
- (void)unpair;

@end
