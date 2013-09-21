//
//  SonosVolumeResponse.h
//  Play
//
//  Created by Nathan Borror on 2/21/13.
//  Copyright (c) 2013 Nathan Borror. All rights reserved.
//

@import Foundation;

@interface SonosVolumeResponse : NSObject <NSXMLParserDelegate>

@property (nonatomic, weak) id parentParserDelegate;
@property (nonatomic, strong) NSString *currentVolume;

@end
