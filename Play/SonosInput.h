//
//  SonosInput.h
//  Play
//
//  Created by Nathan Borror on 1/1/13.
//  Copyright (c) 2013 Nathan Borror. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SonosInput : NSObject <NSCoding>

@property (nonatomic, strong) NSString *ip;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *uid;
@property (nonatomic, strong) UIImage *icon;

- (id)initWithIP:(NSString *)aIP
            name:(NSString *)aName
             uid:(NSString *)aUid
            icon:(UIImage *)aIcon;

@end
