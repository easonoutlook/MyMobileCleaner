//
//  MCDevice.h
//  MyMobileCleaner
//
//  Created by GoKu on 8/18/15.
//  Copyright (c) 2015 GoKuStudio. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SDMMobileDevice.h"
#import "MCDeviceInfoHub.h"

@interface MCDevice : NSObject

@property (nonatomic, readonly, strong) NSString *udid;
@property (nonatomic, readonly, strong) NSString *deviceName;
@property (nonatomic, readonly, strong) NSString *deviceMode;

- (instancetype)initWithRawDevice:(SDMMD_AMDeviceRef)rawDevice;
- (void)disconnectByUser;

- (CFTypeRef)copyDeviceValueOfKey:(NSString *)key inDomain:(NSString *)domain;

- (BOOL)isConnectedDevice;
- (BOOL)isPairedDevice;
- (BOOL)pairDevice;
- (BOOL)unPairDevice;

- (MCDeviceDiskUsage *)diskUsage;
- (void)scanCrashLogSuccessBlock:(void(^)(NSArray *crashLogs))successBlock // array of MCDeviceCrashLogItem
                    failureBlock:(void(^)())failureBlock;
- (void)cleanCrashLog:(NSArray *)crashLogs // array of MCDeviceCrashLogItem
         successBlock:(void(^)())successBlock
         failureBlock:(void(^)())failureBlock;

@end
