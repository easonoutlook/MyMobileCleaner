//
//  MCDeviceController.h
//  MyMobileCleaner
//
//  Created by GoKu on 8/18/15.
//  Copyright (c) 2015 GoKuStudio. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SDMMobileDevice.h"
#import "MCDevice.h"

@protocol MCDeviceControllerDelegate <NSObject>

- (void)deviceDidConnectAndPaired;
- (void)deviceDidConnectButUnPaired;
- (void)deviceDidDisconnect;

@end

@interface MCDeviceController : NSObject

@property (nonatomic, strong, readonly) MCDevice *selectedConnectedDevice;

+ (instancetype)sharedInstance;

- (void)monitorWithListener:(id<MCDeviceControllerDelegate>)listener;
- (void)stopMonitor;

@end
