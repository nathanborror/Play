//
//  SonosInput.h
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

@interface SonosInput : NSObject <NSCoding>

@property (nonatomic, strong) NSString *ip;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *uid;
@property (nonatomic, strong) NSString *uri;
@property (nonatomic, strong) UIImage *icon;
@property (nonatomic, readonly) PLInputStatus status;

- (id)initWithIP:(NSString *)aIP
            name:(NSString *)aName
             uid:(NSString *)aUid
            icon:(UIImage *)aIcon;

- (void)pairWithSonosInput:(SonosInput *)master;
- (void)unpair;

@end
