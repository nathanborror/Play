//
//  NBArrayDataSource.m
//  NBKit
//
//  Created by Nathan Borror on 10/31/13.
//  Copyright (c) 2013 Nathan Borror. All rights reserved.
//

#import "NBArrayDataSource.h"

@interface NBArrayDataSource ()

@property (nonatomic, strong) NSArray *items;
@property (nonatomic, copy) NSString *cellIdentifier;
@property (nonatomic, copy) TableViewCellConfigureBlock configureCellBlock;

@end

@implementation NBArrayDataSource

- (id)init
{
  return nil;
}

- (id)initWithItems:(NSArray *)anItems cellIdentifier:(NSString *)aCellIdentifier configureCellBlock:(TableViewCellConfigureBlock)aConfigureBlock
{
  if (self = [super init]) {
    _items = anItems;
    _cellIdentifier = aCellIdentifier;
    _configureCellBlock = aConfigureBlock;
  }
  return self;
}

- (id)itemAtIndexPath:(NSIndexPath *)indexPath
{
  return _items[(NSInteger)indexPath.item];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
  return _items.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
  UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:_cellIdentifier forIndexPath:indexPath];
  id item = [self itemAtIndexPath:indexPath];
  _configureCellBlock(cell, item);
  return cell;
}

@end
