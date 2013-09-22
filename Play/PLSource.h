//
//  PLSource.h
//  Play
//
//  Created by Nathan Borror on 1/1/13.
//  Copyright (c) 2013 Nathan Borror. All rights reserved.
//

@import Foundation;

@interface PLSource : NSObject

@property (nonatomic, readwrite) NSString *name;
@property (nonatomic, copy) void (^selectionBlock)();

- (id)initWithName:(NSString *)aName selection:(void (^)())aSelectionBlock;

@end
