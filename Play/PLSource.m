//
//  PLSource.m
//  Play
//
//  Created by Nathan Borror on 1/1/13.
//  Copyright (c) 2013 Nathan Borror. All rights reserved.
//

#import "PLSource.h"

@implementation PLSource
@synthesize name;

- (id)initWithName:(NSString *)aName selection:(void (^)())aSelectionBlock
{
  self = [super init];
  if (self) {
    self.name = aName;
    self.selectionBlock = aSelectionBlock;
  }
  return self;
}

@end
