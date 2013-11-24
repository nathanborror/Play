//
//  SonosConnection.h
//  Play
//
//  Created by Nathan Borror on 1/21/13.
//  Copyright (c) 2013 Nathan Borror. All rights reserved.
//

@import Foundation;

@interface SonosConnection : NSObject <NSURLConnectionDelegate, NSURLConnectionDataDelegate>
{
  NSURLConnection *internalConnection;
  NSMutableData *container;
}

@property (nonatomic, copy) NSURLRequest *request;
@property (nonatomic, copy) void (^completionBlock)(id obj, NSError *error);

- (id)initWithRequest:(NSURLRequest *)req completion:(void(^)(id obj, NSError *error))block;
- (void)start;

@end
