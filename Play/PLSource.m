//
//  PLSource.m
//  Play
//
//  Created by Nathan Borror on 1/1/13.
//  Copyright (c) 2013 Nathan Borror. All rights reserved.
//

#import "PLSource.h"

@implementation PLSource

- (instancetype)initWithName:(NSString *)aName selection:(void (^)())aSelectionBlock
{
  if (self = [super init]) {
    _name = aName;
    _selectionBlock = aSelectionBlock;
  }
  return self;
}

@end
