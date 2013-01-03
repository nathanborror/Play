//
//  PLSource.h
//  Play
//
//  Created by Nathan Borror on 1/1/13.
//  Copyright (c) 2013 Nathan Borror. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PLSource : NSObject

@property (nonatomic, readwrite) NSString *name;

- (id)initWithName:(NSString *)aName;

@end
