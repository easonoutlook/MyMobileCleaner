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
    __block NSUInteger myCurrentScannedItemCount = 0;

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
         
         NSLog(@"100%% => all scanned crash log: %@", [formatter stringFromByteCount:totalSize]);

         myCrashLogs = crashLogs;
     }
     updateBlock:^(NSUInteger totalItemCount, MCDeviceCrashLogItem *currentScannedItem) {
         NSLog(@"%.1f%% -> scanned crash log: %@", 100.0*(++myCurrentScannedItemCount)/totalItemCount, currentScannedItem.path);
     }
     failureBlock:^{
         NSLog(@"=> failed to scan crash log");
     }];

    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
            [[MCDeviceController sharedInstance].selectedConnectedDevice cleanCrashLog:myCrashLogs
                                                                          successBlock:^{
                                                                              NSLog(@"100%% => success to clean all scanned crash log");
                                                                          } updateBlock:^(NSUInteger currentItemIndex) {
                                                                              NSLog(@"%.1f%% -> cleaned crash log: %@", 100.0*(currentItemIndex+1)/myCrashLogs.count, ((MCDeviceCrashLogItem *)(myCrashLogs[currentItemIndex])).path);
                                                                          } failureBlock:^{
                                                                              NSLog(@"=> failed to clean all scanned crash log");
                                                                          }];
        });
    });
}

- (void)deviceDidDisconnect
{

}

@end
