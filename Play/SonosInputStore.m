//
//  SonosInputStore.m
//  Play
//
//  Created by Nathan Borror on 1/1/13.
//  Copyright (c) 2013 Nathan Borror. All rights reserved.
//

#import "SonosInputStore.h"
#import "SonosInput.h"

@interface SonosInputStore ()
{
  NSMutableArray *inputList;
}
@end

@implementation SonosInputStore
@synthesize master;

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

+ (SonosInputStore *)sharedStore
{
  static SonosInputStore *inputStore = nil;
  if (!inputStore) {
    inputStore = [[SonosInputStore alloc] init];
  }
  return inputStore;
}

- (NSArray *)allInputs
{
  return inputList;
}

- (void)addInputWithIP:(NSString *)aIP name:(NSString *)aName uid:(NSString *)aUid
{
  SonosInput *input = [[SonosInput alloc] initWithIP:aIP name:aName uid:aUid];
  [inputList addObject:input];
}

- (void)removeInput:(SonosInput *)input
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
