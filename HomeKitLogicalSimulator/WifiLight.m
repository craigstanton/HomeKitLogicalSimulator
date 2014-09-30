//
//  WifiLight.m
//  HomeKitLogicalSimulator
//
//  Created by Craig Stanton on 2014-09-30.
//  Copyright (c) 2014 Oltica. All rights reserved.
//

#import "WifiLight.h"
#import "OTIHAPCore.h"
#import "HAKLightBulbService.h"
#import "HAKAccessory.h"
#import "HAKAccessoryInformationService.h"
#import "HAKCharacteristic.h"
#import "HAKNameCharacteristic.h"
#import "HAKSerialNumberCharacteristic.h"
#import "HAKManufacturerCharacteristic.h"
#import "HAKModelCharacteristic.h"
#import "HAKIdentifyCharacteristic.h"


#import "HAKOnCharacteristic.h"
#import "HAKHueCharacteristic.h"
#import "HAKSaturationCharacteristic.h"
#import "HAKBrightnessCharacteristic.h"

#import "GCDAsyncSocket.h"


@interface WifiLight () {
    OTIHAPCore *_accessoryCore;
    
    HAKAccessory *_wifiLightAccessory;
    
    HAKOnCharacteristic                   *_currentOnState;
    HAKHueCharacteristic                  *_currentHueState;
    HAKSaturationCharacteristic           *_currentSaturationState;
    HAKBrightnessCharacteristic           *_currentBrightnessState;
    HAKNameCharacteristic                 *_currentNameState;
    
    BOOL                                  _isLightOn;
    
    GCDAsyncSocket                        *_tcpSocket;
    BOOL                                  _pendingUpdate;
}

@end

@implementation WifiLight

- (id)initWithSerialNumber:(NSString *)serialNumber Core:(OTIHAPCore *)core {
    self = [super init];
    if (self) {
        _accessoryCore = core;
        
        _wifiLightAccessory = [self createWifiLightAccessoryWithSerialNumber:serialNumber];
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(characteristicDidUpdateValueNotification:) name:@"HAKCharacteristicDidUpdateValueNotification" object:nil];
        
        
        _tcpSocket = [[GCDAsyncSocket alloc] initWithDelegate:self delegateQueue:dispatch_get_main_queue()];
        [_tcpSocket connectToHost:@"192.168.1.3" onPort:8899 error:nil];
    }
    return self;
}

- (void)characteristicDidUpdateValueNotification:(NSNotification *)aNote {
    HAKCharacteristic *characteristic = aNote.object;
    if ([characteristic.service.accessory isEqual:_wifiLightAccessory]) {
        if ([characteristic isKindOfClass:[HAKIdentifyCharacteristic class]]) {
            id value = aNote.userInfo[@"HAKCharacteristicValueKey"];
            if ([value isKindOfClass:[NSNumber class]]) {
                if ([value isEqualToNumber: @1]) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        /*         PHLightState *lightState = [[PHLightState alloc] init];
                         [lightState setAlert:ALERT_LSELECT];
                         [currentLightState setAlert:ALERT_LSELECT];
                         [[[[PHOverallFactory alloc] init] bridgeSendAPI] updateLightStateForId:_huelight.identifier withLighState:lightState completionHandler:^(NSArray *errors) {
                         if (errors) {
                         NSLog(@"ERROR:%@",errors);
                         }
                         }];*/
                    });
                }else{
                    dispatch_async(dispatch_get_main_queue(), ^{
                        /*        PHLightState *lightState = [[PHLightState alloc] init];
                         [lightState setAlert:ALERT_NONE];
                         [currentLightState setAlert:ALERT_NONE];
                         [[[[PHOverallFactory alloc] init] bridgeSendAPI] updateLightStateForId:_huelight.identifier withLighState:lightState completionHandler:^(NSArray *errors) {
                         if (errors) {
                         NSLog(@"ERROR:%@",errors);
                         }
                         }];*/
                    });
                }
            }
        }
        if (characteristic == _currentOnState) {
            
                dispatch_async(dispatch_get_global_queue(0, 0), ^{
                    if([_tcpSocket isConnected])
                    {
                        if(_currentOnState.boolValue)
                        {
                            const unsigned char bytes[] = {0x42, 0x00, 0x55};
                            NSData *data = [NSData dataWithBytes:bytes length:sizeof(bytes)];
                            [_tcpSocket writeData:data withTimeout:1.0f tag:1];
                        } else {
                            const unsigned char bytes[] = {0x41, 0x00, 0x55};
                            NSData *data = [NSData dataWithBytes:bytes length:sizeof(bytes)];
                            [_tcpSocket writeData:data withTimeout:1.0f tag:2];
                            
                        }
                        
                        
                    }
                });
            
        }
        if ([characteristic isKindOfClass:[HAKHueCharacteristic class]]) {
            id value = aNote.userInfo[@"HAKCharacteristicValueKey"];
            if ([value isKindOfClass:[NSNumber class]]) {
                dispatch_async(dispatch_get_global_queue(0, 0), ^{
                    if([_tcpSocket isConnected])
                    {
                        NSNumber *newVal = (NSNumber *)value;
                        //                        if([newVal intValue] > 0)
                        {
                            const unsigned char bytes[] = {0x42, 0x00, 0x55};
                            NSData *data = [NSData dataWithBytes:bytes length:sizeof(bytes)];
                            [_tcpSocket writeData:data withTimeout:1.0f tag:3];
                            
                            [NSThread sleepForTimeInterval:0.1f];
                            NSLog(@"Setting the Hue to %d",[newVal intValue]);
                            const unsigned char bytes2[] = {0x40, [newVal intValue], 0x55};
                            NSData *data2 = [NSData dataWithBytes:bytes2 length:sizeof(bytes)];
                            [_tcpSocket writeData:data2 withTimeout:1.0f tag:4];
                            
                        }
                    }
                    
                    
                    /*    if (![currentLightState.hue isEqualToNumber:value]) {
                     NSLog(@"UpdateHue:%@",value);
                     _pendingUpdate = YES;
                     PHLightState *lightState = [[PHLightState alloc] init];
                     
                     [lightState setHue:value];
                     [currentLightState setHue:value];
                     [[[[PHOverallFactory alloc] init] bridgeSendAPI] updateLightStateForId:_huelight.identifier withLighState:lightState completionHandler:^(NSArray *errors) {
                     if (errors) {
                     NSLog(@"ERROR:%@",errors);
                     }
                     }];
                     }*/
                });
            }
        }
        if ([characteristic isKindOfClass:[HAKSaturationCharacteristic class]]) {
            id value = aNote.userInfo[@"HAKCharacteristicValueKey"];
            if ([value isKindOfClass:[NSNumber class]]) {
                dispatch_async(dispatch_get_global_queue(0, 0), ^{
                    if([_tcpSocket isConnected])
                    {
                        NSNumber *newVal = (NSNumber *)value;
                        if([newVal intValue] == 0)
                        {
                            
                            const unsigned char bytes[] = {0xC2, 0x00, 0x55};
                            NSData *data = [NSData dataWithBytes:bytes length:sizeof(bytes)];
                            [_tcpSocket writeData:data withTimeout:1.0f tag:5];
                        }
                    }
                    /*     if (![currentLightState.saturation isEqualToNumber:value]) {
                     NSLog(@"UpdateSaturation");
                     _pendingUpdate = YES;
                     PHLightState *lightState = [[PHLightState alloc] init];
                     [lightState setSaturation:value];
                     [currentLightState setSaturation:value];
                     [[[[PHOverallFactory alloc] init] bridgeSendAPI] updateLightStateForId:_huelight.identifier withLighState:lightState completionHandler:^(NSArray *errors) {
                     if (errors) {
                     NSLog(@"ERROR:%@",errors);
                     }
                     }];
                     }*/
                });
            }
        }
        if ([characteristic isKindOfClass:[HAKBrightnessCharacteristic class]]) {
            id value = aNote.userInfo[@"HAKCharacteristicValueKey"];
            if ([value isKindOfClass:[NSNumber class]]) {
                dispatch_async(dispatch_get_global_queue(0, 0), ^{
                    if([_tcpSocket isConnected])
                    {
                        NSNumber *newVal = (NSNumber *)value;
                        //                        if([newVal intValue] > 0)
                        {
                            const unsigned char bytes[] = {0x42, 0x00, 0x55};
                            NSData *data = [NSData dataWithBytes:bytes length:sizeof(bytes)];
                            [_tcpSocket writeData:data withTimeout:1.0f tag:6];
                            
                            [NSThread sleepForTimeInterval:0.1f];
                            NSLog(@"Setting the brightness to %d",[newVal intValue]);
                            const unsigned char bytes2[] = {0x4E, [newVal intValue], 0x55};
                            NSData *data2 = [NSData dataWithBytes:bytes2 length:sizeof(bytes)];
                            [_tcpSocket writeData:data2 withTimeout:1.0f tag:7];
                            
                        }
                    }

                });
            }
        }
    }
 /*   if ([characteristic.service.accessory isEqual:_garageDoorAccessory]) {
        NSLog(@"GetUpdate:%@",characteristic);
        if (characteristic == _lockTargetState) {
            NSLog(@"Lock Target State Change:%i",_lockTargetState.targetState);
            if (_targetDoorState.targetDoorState == 0) {
                _lockCurrentState.currentState = 0;
            } else {
                _lockCurrentState.currentState = 1;
            }
        }
        if (characteristic == _targetDoorState) {
            NSLog(@"Target Door State Change:%i",_targetDoorState.targetDoorState);
            if (_targetDoorState.targetDoorState == 0 && !_isDoorOpen) {
                _currentDoorState.currentDoorState = 2;
                if (_doorTimer != nil) {
                    [_doorTimer invalidate];
                    _doorTimer = nil;
                }
                dispatch_async(dispatch_get_main_queue(), ^{
                    _doorTimer = [NSTimer scheduledTimerWithTimeInterval:5.0 target:self selector:@selector(updateCurrentDoorState) userInfo:nil repeats:NO];
                });
            } else {
                _currentDoorState.currentDoorState = 3;
                if (_doorTimer != nil) {
                    [_doorTimer invalidate];
                    _doorTimer = nil;
                }
                dispatch_async(dispatch_get_main_queue(), ^{
                    _doorTimer = [NSTimer scheduledTimerWithTimeInterval:5.0 target:self selector:@selector(updateCurrentDoorState) userInfo:nil repeats:NO];
                });
            }
        }
    }*/
}



- (HAKAccessory *)accessory {
    return _wifiLightAccessory;
}

- (HAKAccessory *)createWifiLightAccessoryWithSerialNumber:(NSString *)serialNumber {
    NSLog(@"Init Accessory With Serial Number:%@",serialNumber);
    HAKAccessory *wifiLight = [_accessoryCore getAccessoryWithSerialNumber:serialNumber];
    
    if (wifiLight != nil) {
        for (HAKService *service in wifiLight.services) {
            if ([service isKindOfClass:[HAKLightBulbService class]]) {
                HAKLightBulbService *gcs = (HAKLightBulbService *)service;
                
                
                _currentOnState         = gcs.onCharacteristic;
                _currentHueState        = gcs.hueCharacteristic;
                _currentSaturationState = gcs.saturationCharacteristic;
                _currentNameState       = gcs.nameCharacteristic;
                _currentBrightnessState = gcs.brightnessCharacteristic;
                
                            }
        }
    } else {
        wifiLight = [[HAKAccessory alloc]init];
        
        HAKAccessoryInformationService *infoService = [[HAKAccessoryInformationService alloc] init];
        infoService.nameCharacteristic.name = @"Wifi Light";
        infoService.serialNumberCharacteristic.serialNumber = serialNumber.copy;
        infoService.manufacturerCharacteristic.manufacturer = @"MiLight";
        infoService.modelCharacteristic.model = @"Bulb";
        
        wifiLight.accessoryInformationService = infoService;
        [wifiLight addService:infoService];
        [wifiLight addService:[self setupLightBulbService]];
    }
    
    return wifiLight;
}

- (HAKLightBulbService *)setupLightBulbService {
    HAKLightBulbService *service = [[HAKLightBulbService alloc] init];
    
    
    /*
     TODO
    service.onCharacteristic = [[HAKOnCharacteristic alloc] init];
    service.onCharacteristic.boolValue = false;
    _currentOnState = service.onCharacteristic;*/
    
    
    service.hueCharacteristic = [[HAKHueCharacteristic alloc] init];
    service.hueCharacteristic.hue = 0;
    _currentHueState = service.hueCharacteristic;
    
    service.nameCharacteristic = [[HAKNameCharacteristic alloc] init];
    service.nameCharacteristic.name = @"Light Bulb Zone 1";
    
    service.saturationCharacteristic = [[HAKSaturationCharacteristic alloc] init];
    service.saturationCharacteristic.saturation = 0;
    _currentSaturationState = service.saturationCharacteristic;
    
    service.brightnessCharacteristic = [[HAKBrightnessCharacteristic alloc] init];
    service.brightnessCharacteristic.brightness = 0;
    _currentBrightnessState = service.brightnessCharacteristic;
    
    
    return service;
}

#pragma mark Socket delegate
- (void)socket:(GCDAsyncSocket *)sock didConnectToHost:(NSString *)host port:(uint16_t)port
{
    NSLog(@"Connected to %@ on %d",host, port);
    //    const unsigned char bytes[] = {0x47, 0x00, 0x55};
    //  NSData *data = [NSData dataWithBytes:bytes length:sizeof(bytes)];
    
    //[tcpSocket writeData:data withTimeout:1.0f tag:1];
    
}


- (void)socket:(GCDAsyncSocket *)sock didWriteDataWithTag:(long)tag
{
    NSLog(@"Did write with tag %ld",tag);
}

@end
