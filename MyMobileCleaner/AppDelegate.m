//
//  AppDelegate.m
//  MyMobileCleaner
//
//  Created by GoKu on 8/18/15.
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

    __block NSArray *myCrashLogs = nil;

    [[MCDeviceController sharedInstance].selectedConnectedDevice
     scanCrashLogSuccessBlock:^(NSArray *crashLogs) {
         NSUInteger totalSize = 0;

         for (MCDeviceCrashLogItem *item in crashLogs) {
             totalSize += [item.size unsignedIntegerValue];
         }

         NSByteCountFormatter *formatter = [[NSByteCountFormatter alloc] init];
         formatter.countStyle = NSByteCountFormatterCountStyleFile;
         formatter.adaptive = NO;
         formatter.zeroPadsFractionDigits = YES;
         
         NSLog(@"crash log: %@", [formatter stringFromByteCount:totalSize]);

         myCrashLogs = crashLogs;
     }
     failureBlock:^{
         NSLog(@"failed to scan crash log");
     }];
}

- (void)deviceDidDisconnect
{

}

@end
