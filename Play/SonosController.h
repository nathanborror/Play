//
//  SonosController.h
//  Play
//
//  Created by Nathan Borror on 12/31/12.
//  Copyright (c) 2012 Nathan Borror. All rights reserved.
//

@import Foundation;

typedef NS_ENUM(NSInteger, SonosRequestType) {
  SonosRequestTypeAVTransport,
  SonosRequestTypeConnectionManager,
  SonosRequestTypeRenderingControl,
  SonosRequestTypeContentDirectory,
  SonosRequestTypeQueue,
  SonosRequestTypeAlarmClock,
  SonosRequestTypeMusicServices,
  SonosRequestTypeAudioIn,
  SonosRequestTypeDeviceProperties,
  SonosRequestTypeSystemProperties,
  SonosRequestTypeZoneGroupTopology,
  SonosRequestTypeGroupManagement,
};

@class PLInput;
@class RdioSong;

@interface SonosController : NSObject

@property (nonatomic, readonly) BOOL isPlaying;

- (instancetype)initWithInput:(PLInput *)input;

+ (SonosController *)sharedController;

+ (void)request:(SonosRequestType)type
          input:(PLInput *)input
         action:(NSString *)action
         params:(NSDictionary *)params
     completion:(void(^)(id obj, NSError *error))block;

+ (void)discover:(void(^)(NSArray *inputs, NSError *error))block;

- (void)play:(PLInput *)input uri:(NSString *)uri completion:(void(^)(NSDictionary *response, NSError *error))block;
- (void)play:(PLInput *)input rdioSong:(RdioSong *)song completion:(void(^)(NSDictionary *response, NSError *error))block;
- (void)pause:(PLInput *)input completion:(void(^)(NSDictionary *response, NSError *error))block;
- (void)stop:(PLInput *)input completion:(void(^)(NSDictionary *response, NSError *error))block;
- (void)next:(PLInput *)input completion:(void(^)(NSDictionary *response, NSError *error))block;
- (void)previous:(PLInput *)input completion:(void(^)(NSDictionary *response, NSError *error))block;
- (void)queue:(PLInput *)input track:(NSString *)track completion:(void(^)(NSDictionary *response, NSError *error))block;
- (void)volume:(PLInput *)input completion:(void(^)(NSDictionary *response, NSError *error))block;
- (void)volume:(PLInput *)input level:(int)level completion:(void(^)(NSDictionary *response, NSError *error))block;
- (void)lineIn:(PLInput *)input completion:(void(^)(NSDictionary *response, NSError *error))block;
- (void)trackInfo:(PLInput *)input completion:(void(^)(NSDictionary *response, NSError *error))block;
- (void)mediaInfo:(PLInput *)input completion:(void(^)(NSDictionary *response, NSError *error))block;
- (void)status:(PLInput *)input completion:(void(^)(NSDictionary *response, NSError *error))block;
- (void)browse:(PLInput *)input completion:(void(^)(NSDictionary *response, NSError *error))block;

@end
