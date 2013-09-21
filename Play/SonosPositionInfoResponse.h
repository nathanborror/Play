//
//  SonosPositionInfoResponse.h
//  Play
//
//  Created by Nathan Borror on 1/21/13.
//  Copyright (c) 2013 Nathan Borror. All rights reserved.
//

@import Foundation;

@interface SonosPositionInfoResponse : NSObject <NSXMLParserDelegate>

@property (nonatomic, weak) id parentParserDelegate;
@property (nonatomic, strong) NSString *track;
@property (nonatomic, strong) NSString *duration;
@property (nonatomic, strong) NSString *metaData;
@property (nonatomic, strong) NSString *uri;
@property (nonatomic, strong) NSString *relTime;
@property (nonatomic, strong) NSString *absTime;
@property (nonatomic, strong) NSString *relCount;
@property (nonatomic, strong) NSString *absCount;

@end
