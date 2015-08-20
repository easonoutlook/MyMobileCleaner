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
@property (nonatomic, readonly, strong) NSString *deviceType; // need device paired

- (instancetype)initWithRawDevice:(SDMMD_AMDeviceRef)rawDevice;

- (BOOL)isConnectedDevice;
- (BOOL)isPairedDevice;
- (BOOL)toPairDevice;
- (BOOL)unPairDevice;
- (void)waitingForPairWithCompleteBlock:(void(^)())completeBlock;

- (MCDeviceDiskUsage *)diskUsage;

- (void)scanCrashLogSuccessBlock:(void(^)(NSArray *crashLogs))successBlock // array of MCDeviceCrashLogItem
                     updateBlock:(void(^)(NSUInteger totalItemCount, MCDeviceCrashLogItem *currentScannedItem))updateBlock
                    failureBlock:(void(^)())failureBlock;
- (void)cleanCrashLog:(NSArray *)crashLogs // array of MCDeviceCrashLogItem
         successBlock:(void(^)())successBlock
          updateBlock:(void(^)(NSUInteger currentItemIndex))updateBlock
         failureBlock:(void(^)())failureBlock;

// not recommend to use this api, unless you know how to parse the returned value.
- (CFTypeRef)copyDeviceValueOfKey:(NSString *)key inDomain:(NSString *)domain;

@end
