//
//  MCDevice.h
//  MyMobileCleaner
//
//  Created by user on 8/18/15.
//  Copyright (c) 2015 GoKuStudio. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SDMMobileDevice.h"

@interface MCDeviceDiskUsage : NSObject

@property (nonatomic, strong) NSNumber *totalDiskCapacity;
@property (nonatomic, strong) NSNumber *totalDiskUsed;
@property (nonatomic, strong) NSNumber *totalDiskFree;
@property (nonatomic, strong) NSNumber *totalDiskReserved;

@end

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
- (void)scanCrashLogWithCompleteBlock:(void(^)(NSArray *logDirContents))completeBlock; // array of dic {name + size}
- (void)cleanCrashLog:(NSArray *)logDirContents // array of dic {name + size}
    withCompleteBlock:(void(^)())completeBlock;

- (void)takeScreenShot;

@end
