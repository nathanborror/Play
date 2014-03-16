//
//  PLInputStore.m
//  Play
//
//  Created by Nathan Borror on 1/1/13.
//  Copyright (c) 2013 Nathan Borror. All rights reserved.
//

#import "PLInputStore.h"
#import "PLInput.h"
#import "SonosController.h"

@implementation PLInputStore {
  NSMutableArray *_inputList;
}

- (instancetype)init
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
  return _inputList;
}

- (NSArray *)allInputsGrouped
{
  NSMutableArray *groupedInputs = [[NSMutableArray alloc] init];

  // Find all the master inputs
  [_inputList enumerateObjectsUsingBlock:^(PLInput *master, NSUInteger idx, BOOL *stop) {
    if (master.status != PLInputStatusSlave) {
      NSMutableArray *inputs = [[NSMutableArray alloc] init];

      // Associate grouped inputs with their respective master
      // input using the 'group' attribute.
      [_inputList enumerateObjectsUsingBlock:^(PLInput *input, NSUInteger idx, BOOL *stop) {
        if (input.status == PLInputStatusSlave && [master.group isEqualToString:input.group]) {
          [inputs addObject:input];
        }
      }];

      [inputs addObject:master];
      [groupedInputs addObject:@{@"master": master, @"inputs": inputs}];
    }
  }];

  return groupedInputs;
}

- (PLInput *)inputAtIndex:(NSUInteger)index
{
  return [_inputList objectAtIndex:index];
}

- (PLInput *)inputWithUid:(NSString *)uid
{
  for (PLInput *input in _inputList) {
    if ([input.uid isEqual:uid]) {
      return input;
    }
  }
  return nil;
}

- (PLInput *)addInputWithIP:(NSString *)aIP name:(NSString *)aName uid:(NSString *)aUid
{
  PLInput *input = [[PLInput alloc] initWithIP:aIP name:aName uid:aUid];
  [_inputList addObject:input];
  return input;
}

- (void)removeInput:(PLInput *)input
{
  [_inputList removeObjectIdenticalTo:input];
}

- (NSDictionary *)groupForInput:(PLInput *)input
{
  NSMutableArray *inputs = [[NSMutableArray alloc] init];

  [_inputList enumerateObjectsUsingBlock:^(PLInput *aInput, NSUInteger idx, BOOL *stop) {
    if ([input.group isEqualToString:aInput.group] && aInput.status == PLInputStatusSlave) {
      [inputs addObject:input];
    }
  }];

  [inputs addObject:input];
  return @{@"master": input, @"inputs": inputs};
}

- (void)pairInput:(PLInput *)input1 withInput:(PLInput *)input2
{
  [input1 setUri:[NSString stringWithFormat:@"x-rincon:%@", input2.uid]];
  [[SonosController sharedController] play:input1 uri:input1.uri completion:nil];
  [input1 setStatus:PLInputStatusSlave];
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
