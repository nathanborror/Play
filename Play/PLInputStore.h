//
//  PLInputStore.h
//  Play
//
//  Created by Nathan Borror on 1/1/13.
//  Copyright (c) 2013 Nathan Borror. All rights reserved.
//

@import Foundation;

@class PLInput;

@interface PLInputStore : NSObject

@property (nonatomic, readwrite) PLInput *master;

+ (PLInputStore *)sharedStore;

- (NSArray *)allInputs;
- (NSArray *)allInputsGrouped;
- (PLInput *)inputAtIndex:(NSUInteger)index;
- (PLInput *)inputWithUid:(NSString *)uid;
- (PLInput *)addInputWithIP:(NSString *)aIP name:(NSString *)aName uid:(NSString *)aUid;
- (NSDictionary *)groupForInput:(PLInput *)input;
- (void)removeInput:(PLInput *)input;
- (BOOL)saveChanges;
- (void)pairInput:(PLInput *)input1 withInput:(PLInput *)input2;

@end
