//
//  SonosInputStore.m
//  Play
//
//  Created by Nathan Borror on 1/1/13.
//  Copyright (c) 2013 Nathan Borror. All rights reserved.
//

#import "SonosInputStore.h"
#import "SonosInput.h"

@implementation SonosInputStore {
  NSMutableArray *_inputList;
}

- (id)init
{
  if (self = [super init]) {
    NSString *path = [self inputArchivePath];
    _inputList = [NSKeyedUnarchiver unarchiveObjectWithFile:path];
    if (!_inputList) {
      _inputList = [[NSMutableArray alloc] init];
    }
  }
  return self;
}

+ (SonosInputStore *)sharedStore
{
  static SonosInputStore *inputStore;
  if (!inputStore) {
    inputStore = [[SonosInputStore alloc] init];
  }
  return inputStore;
}

- (void)setInputs:(NSArray*)inputs{
    _inputList = [inputs mutableCopy];
}

- (NSArray *)allInputs
{
  return _inputList;
}

- (SonosInput *)inputAtIndex:(NSUInteger)index
{
  return [_inputList objectAtIndex:index];
}

- (SonosInput *)inputWithUid:(NSString *)uid
{
  for (SonosInput *input in _inputList) {
    if ([input.uid isEqual:uid]) {
      return input;
    }
  }
  return nil;
}

- (SonosInput *)addInputWithIP:(NSString *)aIP name:(NSString *)aName uid:(NSString *)aUid icon:(UIImage *)aIcon
{
  SonosInput *input = [[SonosInput alloc] initWithIP:aIP name:aName uid:aUid icon:aIcon];
  [_inputList addObject:input];
  return input;
}

- (void)removeInput:(SonosInput *)input
{
  [_inputList removeObjectIdenticalTo:input];
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
  return [NSKeyedArchiver archiveRootObject:_inputList toFile:path];
}

@end
