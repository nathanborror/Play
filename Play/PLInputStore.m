//
//  PLInputStore.m
//  Play
//
//  Created by Nathan Borror on 1/1/13.
//  Copyright (c) 2013 Nathan Borror. All rights reserved.
//

#import "PLInputStore.h"
#import "PLInput.h"

@interface PLInputStore ()
{
  NSMutableArray *inputList;
}
@end

@implementation PLInputStore

- (id)init
{
  self = [super init];
  if (self) {
    NSString *path = [self inputArchivePath];
    inputList = [NSKeyedUnarchiver unarchiveObjectWithFile:path];
    if (!inputList) {
      inputList = [[NSMutableArray alloc] init];
    }
  }
  return self;
}

+ (PLInputStore *)sharedStore
{
  static PLInputStore *inputStore = nil;
  if (!inputStore) {
    inputStore = [[PLInputStore alloc] init];
  }
  return inputStore;
}

- (NSArray *)allInputs
{
  return inputList;
}

- (void)addInputWithIP:(NSString *)aIP name:(NSString *)aName
{
  PLInput *input = [[PLInput alloc] initWithIP:aIP name:aName];
  [inputList addObject:input];
}

- (void)removeInput:(PLInput *)input
{
  [inputList removeObjectIdenticalTo:input];
}

#pragma mark - NSCoding

- (NSString *)inputArchivePath
{
  NSArray *documentDirectories = NSSearchPathForDirectoriesInDomains(NSDocumentationDirectory, NSUserDomainMask, YES);
  NSString *documentDirectory = [documentDirectories objectAtIndex:0];
  return [documentDirectory stringByAppendingPathComponent:@"inputs.archive"];
}

- (BOOL)saveChanges
{
  NSString *path = [self inputArchivePath];
  return [NSKeyedArchiver archiveRootObject:inputList toFile:path];
}

@end
