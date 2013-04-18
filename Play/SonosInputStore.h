//
//  SonosInputStore.h
//  Play
//
//  Created by Nathan Borror on 1/1/13.
//  Copyright (c) 2013 Nathan Borror. All rights reserved.
//

#import <Foundation/Foundation.h>

@class SonosInput;

@interface SonosInputStore : NSObject

@property (nonatomic, readwrite) SonosInput *master;

+ (SonosInputStore *)sharedStore;

- (NSArray *)allInputs;
- (SonosInput *)inputAtIndex:(NSUInteger)index;
- (void)addInputWithIP:(NSString *)aIP name:(NSString *)aName uid:(NSString *)aUid icon:(UIImage *)aIcon;
- (void)removeInput:(SonosInput *)input;
- (BOOL)saveChanges;

@end
