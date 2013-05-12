//
//  SonosTransportInfoResponse.h
//  Play
//
//  Created by Nathan Borror on 5/8/13.
//  Copyright (c) 2013 Nathan Borror. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SonosTransportInfoResponse : NSObject <NSXMLParserDelegate>
{
  NSMutableString *currentString;
}

@property (nonatomic, weak) id parentParserDelegate;
@property (nonatomic, strong) NSString *state;
@property (nonatomic, strong) NSString *status;
@property (nonatomic, strong) NSString *speed;

@end
