//
//  PLInput.h
//  Play
//
//  Created by Nathan Borror on 1/1/13.
//  Copyright (c) 2013 Nathan Borror. All rights reserved.
//

#import <Foundation/Foundation.h>

@class PLSong;

@interface PLInput : NSObject <NSCoding>

@property (nonatomic, readwrite) NSString *ip;
@property (nonatomic, readwrite) NSString *name;
@property (nonatomic, readwrite) NSString *uid;
@property (nonatomic, readwrite) PLSong *playingSong;

- (id)initWithIP:(NSString *)aIP
            name:(NSString *)aName
             uid:(NSString *)aUid;


@end
