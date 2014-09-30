//
//  WifiLight.h
//  HomeKitLogicalSimulator
//
//  Created by Craig Stanton on 2014-09-30.
//  Copyright (c) 2014 Oltica. All rights reserved.
//

#import <Foundation/Foundation.h>

@class HAKAccessory, OTIHAPCore;

@interface WifiLight : NSObject

- (id)initWithSerialNumber:(NSString *)serialNumber Core:(OTIHAPCore *)core;
- (HAKAccessory *)accessory;

@end
