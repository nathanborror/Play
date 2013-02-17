//
//  SonosInput.h
//  Play
//
//  Created by Nathan Borror on 1/1/13.
//  Copyright (c) 2013 Nathan Borror. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SonosInput : NSObject <NSCoding>

@property (nonatomic, readwrite) NSString *ip;
@property (nonatomic, readwrite) NSString *name;
@property (nonatomic, readwrite) NSString *uid;

- (id)initWithIP:(NSString *)aIP
            name:(NSString *)aName
             uid:(NSString *)aUid;


@end
