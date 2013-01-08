//
//  PLInputStore.h
//  Play
//
//  Created by Nathan Borror on 1/1/13.
//  Copyright (c) 2013 Nathan Borror. All rights reserved.
//

#import <Foundation/Foundation.h>

@class PLInput;

@interface PLInputStore : NSObject

+ (PLInputStore *)sharedStore;

- (NSArray *)allInputs;
- (void)addInputWithIP:(NSString *)aIP name:(NSString *)aName uid:(NSString *)aUid;
- (void)removeInput:(PLInput *)input;
- (BOOL)saveChanges;

@end
