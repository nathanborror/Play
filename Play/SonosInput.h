//
//  SonosInput.h
//  Play
//
//  Created by Nathan Borror on 1/1/13.
//  Copyright (c) 2013 Nathan Borror. All rights reserved.
//

@import Foundation;

@class SonosInput;

@protocol SonosInputDelegate <NSObject>

- (void)input:(SonosInput *)input pairedWith:(SonosInput *)pairedWithInput;
- (void)input:(SonosInput *)input unpairedWith:(SonosInput *)unpairedWithInput;

@end

@interface SonosInput : NSObject <NSCoding>

@property (nonatomic, strong) NSString *ip;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *uid;
@property (nonatomic, strong) NSString *uri;
@property (nonatomic, strong) UIImage *icon;
@property (nonatomic, strong) id <SonosInputDelegate> delegate;
@property (nonatomic, strong) UIView *view;

- (id)initWithIP:(NSString *)aIP
            name:(NSString *)aName
             uid:(NSString *)aUid
            icon:(UIImage *)aIcon;

- (void)pairWithSonosInput:(SonosInput *)master;
- (void)unpair;

@end
