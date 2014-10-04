//
//  AppDelegate.m
//  HomeKitLogicalSimulator
//
//  Created by Khaos Tian on 8/21/14.
//  Copyright (c) 2014 Oltica. All rights reserved.
//

#import "AppDelegate.h"
#import "OTIHAPCore.h"
#import "GarageDoorOpener.h"
#import "Thermostat.h"
#import "WifiLight.h"

@interface AppDelegate ()

@property (weak) IBOutlet NSWindow *window;
@property (strong, nonatomic) OTIHAPCore *accessoryCore;
@property (strong, nonatomic) GarageDoorOpener *doorOpener;
@property (strong, nonatomic) Thermostat *thermostat;
@property (strong, nonatomic) WifiLight *wifiLight;
@property (strong, nonatomic) WifiLight *wifiLight2;
@property (strong, nonatomic) WifiLight *wifiLight3;
@property (strong, nonatomic) WifiLight *wifiLight4;


@property (strong, nonatomic) NSStatusItem *statusItem;

@end

@implementation AppDelegate
            
- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    _statusItem = [[NSStatusBar systemStatusBar] statusItemWithLength:NSVariableStatusItemLength];
    
    // The text that will be shown in the menu bar
    _statusItem.title = @"";
    _statusItem.toolTip = @"Wifi Lights Bridge";
    
    // The image that will be shown in the menu bar, a 16x16 black png works best
    _statusItem.image = [NSImage imageNamed:@"statusicon"];
    
    // The highlighted image, use a white version of the normal image
    _statusItem.alternateImage = [NSImage imageNamed:@"statusicon"];
    
    // The image gets a blue background when the item is selected
    _statusItem.highlightMode = YES;
    
    NSMenu *menu = [[NSMenu alloc] init];
    [menu addItemWithTitle:@"Open Preferences" action:@selector(openPreferences:) keyEquivalent:@""];
    [menu addItemWithTitle:@"View Log" action:@selector(viewLog:) keyEquivalent:@""];
    [menu addItem:[NSMenuItem separatorItem]]; // A thin grey line
    [menu addItemWithTitle:@"Quit Wifi Lights Bridge" action:@selector(terminate:) keyEquivalent:@""];
    _statusItem.menu = menu;
    
    
    
    
    
    _accessoryCore = [[OTIHAPCore alloc]initAsBridge:YES];
    
    _doorOpener = [[GarageDoorOpener alloc] initWithSerialNumber:@"B0107469FA37" Core:_accessoryCore];
    NSLog(@"Opener:%@",_doorOpener);
    
    [_accessoryCore addAccessory:[_doorOpener accessory]];
    
    _thermostat = [[Thermostat alloc] initWithSerialNumber:@"E1E46A9C0345" Core:_accessoryCore];
    NSLog(@"Thermostat:%@",_thermostat);
    
    [_accessoryCore addAccessory:[_thermostat accessory]];
    
    
    _wifiLight = [[WifiLight alloc] initWithSerialNumber:@"1234" Zone:1 Core:_accessoryCore];
    NSLog(@"WifiLight:%@",_wifiLight);
    
    [_accessoryCore addAccessory:[_wifiLight accessory]];
    
    
    _wifiLight2 = [[WifiLight alloc] initWithSerialNumber:@"12345" Zone:2 Core:_accessoryCore];
    NSLog(@"WifiLight2 :%@",_wifiLight2);
    [_accessoryCore addAccessory:[_wifiLight2 accessory]];
    
    _wifiLight3 = [[WifiLight alloc] initWithSerialNumber:@"123456" Zone:3 Core:_accessoryCore];
    NSLog(@"WifiLight3 :%@",_wifiLight3);
    [_accessoryCore addAccessory:[_wifiLight3 accessory]];
    
    
    _wifiLight4 = [[WifiLight alloc] initWithSerialNumber:@"1234567" Zone:4 Core:_accessoryCore];
    NSLog(@"WifiLight4 :%@",_wifiLight4);
    [_accessoryCore addAccessory:[_wifiLight4 accessory]];

}

- (void)terminate:(id)sender
{
    
}

-(void) openPreferences:(id)sender
{
    
}

-(void) viewLog:(id)sender
{
    
}

- (void)applicationWillTerminate:(NSNotification *)aNotification {
    // Insert code here to tear down your application
}

@end
