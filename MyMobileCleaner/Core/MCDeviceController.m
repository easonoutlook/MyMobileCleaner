//
//  MCDeviceController.m
//  MyMobileCleaner
//
//  Created by GoKu on 8/18/15.
//  Copyright (c) 2015 GoKuStudio. All rights reserved.
//

#import "MCDeviceController.h"

@interface MCDeviceController ()

@property (atomic, assign) BOOL isRunning;
@property (nonatomic, strong) NSOperationQueue *workQueue;

@property (nonatomic, strong) NSArray *allConnectedDevices;
@property (nonatomic, strong, readwrite) MCDevice *selectedConnectedDevice;
@property (nonatomic, strong) NSString *selectedConnectedDeviceUDID;

@property (nonatomic, weak) id<MCDeviceControllerDelegate> listener;

@end

@implementation MCDeviceController

- (void)dealloc
{
    [self stopMonitor];
}

+ (instancetype)sharedInstance
{
    static MCDeviceController *sharedInstance = nil;
    static dispatch_once_t onceToken = 0;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[MCDeviceController alloc] init];
        sharedInstance.isRunning = NO;
    });
    return sharedInstance;
}

#pragma mark - run & stop

- (void)monitorWithListener:(id<MCDeviceControllerDelegate>)listener
{
    if (self.isRunning) {
        NSLog(@"device controller is already running");
        return;
    }

    self.listener = listener;

    self.isRunning = YES;

    self.workQueue = [[NSOperationQueue alloc] init];
    self.workQueue.maxConcurrentOperationCount = 1;

    SDMMobileDevice;

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(notifyConnect:)
                                                 name:(__bridge NSString *)kSDMMD_USBMuxListenerDeviceAttachedNotificationFinished
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(notifyDisconnect:)
                                                 name:(__bridge NSString *)kSDMMD_USBMuxListenerDeviceDetachedNotificationFinished
                                               object:nil];

    NSLog(@"device controller starts running");
}

- (void)stopMonitor
{
    self.listener = nil;

    self.isRunning = NO;

    [self.workQueue cancelAllOperations];
    self.workQueue = nil;

    self.allConnectedDevices = nil;
    self.selectedConnectedDevice = nil;
    self.selectedConnectedDeviceUDID = nil;

    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:(__bridge NSString *)kSDMMD_USBMuxListenerDeviceAttachedNotificationFinished
                                                  object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:(__bridge NSString *)kSDMMD_USBMuxListenerDeviceDetachedNotificationFinished
                                                  object:nil];

    NSLog(@"device controller stops running");
}

#pragma mark - notification

- (void)notifyConnect:(NSNotification *)note
{
    if (!self.isRunning) {
        return;
    }

    [self.workQueue addOperationWithBlock:^{
        if (!self.selectedConnectedDevice) {
            self.allConnectedDevices = (__bridge_transfer NSArray *)(SDMMD_AMDCreateDeviceList());

            self.selectedConnectedDevice = [[MCDevice alloc] initWithRawDevice:(__bridge SDMMD_AMDeviceRef)(self.allConnectedDevices.firstObject)];
            self.selectedConnectedDeviceUDID = self.selectedConnectedDevice.udid;

            NSLog(@"connect to a new device: {UDID: %@}", self.selectedConnectedDeviceUDID);

            if ([self.selectedConnectedDevice isPairedDevice]) {
                [self.listener deviceDidConnectAndPaired];

            } else {
                [self.listener deviceDidConnectButUnPaired];
            }

        } else {
            NSLog(@"already connecting to a device, so ignore others connected.");
        }
    }];
}

- (void)notifyDisconnect:(NSNotification *)note
{
    if (!self.isRunning) {
        return;
    }

    [self.workQueue addOperationWithBlock:^{
        /*
        self.allConnectedDevices = (__bridge_transfer NSArray *)(SDMMD_AMDCreateDeviceList());

        BOOL selectedDeviceStillConnected = NO;

        for (id device in self.allConnectedDevices) {
            SDMMD_AMDeviceRef refDevice = (__bridge SDMMD_AMDeviceRef)device;

            CFStringRef refDeviceUDID = SDMMD_AMDeviceCopyUDID(refDevice);
            if (refDeviceUDID == NULL) {
                refDeviceUDID = SDMMD_AMDeviceCopyValue(refDevice, NULL, CFSTR(kUniqueDeviceID));
            }
            NSString *deviceUDID = (__bridge_transfer NSString *)refDeviceUDID;

            if ([self.selectedConnectedDeviceUDID isEqualToString:deviceUDID]) {
                selectedDeviceStillConnected = YES;

                self.selectedConnectedDevice = [[MCDevice alloc] initWithRawDevice:refDevice];
                self.selectedConnectedDeviceUDID = self.selectedConnectedDevice.udid;

                break;
            }
        }
        */

        BOOL selectedDeviceStillConnected = [self.selectedConnectedDevice isConnectedDevice];

        if (selectedDeviceStillConnected) {
            NSLog(@"selected device is still connected, so ignore others disconnected.");

        } else {
            NSLog(@"disconnect with device: {UDID: %@}", self.selectedConnectedDeviceUDID);

            self.selectedConnectedDevice = nil;
            self.selectedConnectedDeviceUDID = nil;

            [self.listener deviceDidDisconnect];
        }
    }];
}

@end
