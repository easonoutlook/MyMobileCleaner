//
//  AppDelegate.m
//  MyMobileCleaner
//
//  Created by user on 8/18/15.
//  Copyright (c) 2015 GoKuStudio. All rights reserved.
//

#import "AppDelegate.h"
#import "MCDeviceController.h"

@interface AppDelegate () <MCDeviceControllerDelegate>

@end

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    // Insert code here to initialize your application

    [[MCDeviceController sharedInstance] monitorWithListener:self];
}

- (void)applicationWillTerminate:(NSNotification *)aNotification {
    // Insert code here to tear down your application
}

- (void)deviceDidConnect
{
    NSLog(@"%@", [[MCDeviceController sharedInstance].selectedConnectedDevice diskUsage]);

    [[MCDeviceController sharedInstance].selectedConnectedDevice scanCrashLogWithCompleteBlock:^(NSArray *logDirContents) {
        NSLog(@"%@", logDirContents);
    }];
}

- (void)deviceDidDisconnect
{

}

@end
