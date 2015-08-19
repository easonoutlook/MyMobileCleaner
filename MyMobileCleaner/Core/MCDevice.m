//
//  MCDevice.m
//  MyMobileCleaner
//
//  Created by user on 8/18/15.
//  Copyright (c) 2015 GoKuStudio. All rights reserved.
//

#import "MCDevice.h"

@implementation MCDeviceDiskUsage

- (NSString *)description
{
    return [NSString stringWithFormat:@"total: %@, used: %@, free: %@, reserved: %@", self.totalDiskCapacity, self.totalDiskUsed, self.totalDiskFree, self.totalDiskReserved];
}

@end

@interface MCDevice ()

@property (nonatomic, assign) BOOL isInSession;

@property (nonatomic) SDMMD_AMDeviceRef rawDevice;
@property (nonatomic, readwrite, strong) NSString *udid;
@property (nonatomic, readwrite, strong) NSString *deviceName;
@property (nonatomic, readwrite, strong) NSString *deviceMode;

@end

@implementation MCDevice

- (void)dealloc
{
    if (self.isInSession) {
        SDMMD_AMDeviceStopSession(self.rawDevice);
    }

    if ([self isConnectedDevice]) {
        SDMMD_AMDeviceDisconnect(self.rawDevice);
    }
}

- (BOOL)startConnection
{
    sdmmd_return_t result = SDMMD_AMDeviceConnect(_rawDevice);
    return SDM_MD_CallSuccessful(result);
}

- (BOOL)startSession
{
    sdmmd_return_t result = SDMMD_AMDeviceStartSession(_rawDevice);
    if (SDM_MD_CallSuccessful(result)) {
        _isInSession = YES;
    } else {
        _isInSession = NO;
    }

    return _isInSession;
}

#pragma mark - api

- (instancetype)initWithRawDevice:(SDMMD_AMDeviceRef)rawDevice
{
    self = [super init];
    if (self) {
        _rawDevice = rawDevice;

        [self startConnection];
        [self startSession];

        CFStringRef deviceUDID = SDMMD_AMDeviceCopyUDID(_rawDevice);
        if (deviceUDID == NULL) {
            deviceUDID = SDMMD_AMDeviceCopyValue(_rawDevice, NULL, CFSTR(kUniqueDeviceID));
        }
        _udid = (__bridge_transfer NSString *)deviceUDID;

        CFStringRef deviceName = SDMMD_AMDeviceCopyValue(_rawDevice, NULL, CFSTR(kDeviceName));
        _deviceName = (__bridge_transfer NSString *)deviceName;

        CFTypeRef deviceModel = CFSTR("");
        if (_isInSession) {
            deviceModel = SDMMD_AMDeviceCopyValue(_rawDevice, NULL, CFSTR(kProductType));
        }
        _deviceMode = [NSString stringWithUTF8String:SDMMD_ResolveModelToName(deviceModel)];
        CFSafeRelease(deviceModel);
    }
    return self;
}

- (void)disconnectByUser
{
    self.isInSession = NO;
}

- (CFTypeRef)copyDeviceValueOfKey:(NSString *)key inDomain:(NSString *)domain
{
    CFTypeRef sdm_value = NULL;

    if (![self isConnectedDevice]) {
        kern_return_t sdm_return = SDMMD_AMDeviceConnect(self.rawDevice);
        if (!(SDM_MD_CallSuccessful(sdm_return))) {
            NSLog(@"[%s] failed: No Connection", __FUNCTION__);
            return sdm_value;
        }
    }

    if (!self.isInSession) {
        if (![self startSession]) {
            NSLog(@"[%s] failed: No Session", __FUNCTION__);
            return sdm_value;
        }
    }

    sdm_value = SDMMD_AMDeviceCopyValue(self.rawDevice, (__bridge CFStringRef)domain, (__bridge CFStringRef)key);
    if (sdm_value == NULL) {
        NSLog(@"[%s] failed: Copy Value Error", __FUNCTION__);
    }
    return sdm_value;
}

- (BOOL)isConnectedDevice
{
    return SDMMD_AMDeviceIsAttached(self.rawDevice) ? YES : NO;
}

- (BOOL)isPairedDevice
{
    return SDMMD_AMDeviceIsPaired(self.rawDevice) ? YES : NO;
}

- (BOOL)pairDevice
{
    sdmmd_return_t sdm_return = SDMMD_AMDevicePair(self.rawDevice);
    return SDM_MD_CallSuccessful(sdm_return) ? YES : NO;
}

- (BOOL)unPairDevice
{
    sdmmd_return_t sdm_return = SDMMD_AMDeviceUnpair(self.rawDevice);
    return SDM_MD_CallSuccessful(sdm_return) ? YES : NO;
}

- (MCDeviceDiskUsage *)diskUsage
{
    if (![self isConnectedDevice]) {
        kern_return_t sdm_return = SDMMD_AMDeviceConnect(self.rawDevice);
        if (!(SDM_MD_CallSuccessful(sdm_return))) {
            NSLog(@"[%s] failed: No Connection", __FUNCTION__);
            return nil;
        }
    }

    if (!self.isInSession) {
        if (![self startSession]) {
            NSLog(@"[%s] failed: No Session", __FUNCTION__);
            return nil;
        }
    }

    CFNumberRef valueTotalDiskCapacity = SDMMD_AMDeviceCopyValue(self.rawDevice, CFSTR(kDiskUsageDomain), CFSTR(kTotalDiskCapacity));
    CFNumberRef valueTotalSystemCapacity = SDMMD_AMDeviceCopyValue(self.rawDevice, CFSTR(kDiskUsageDomain), CFSTR(kTotalSystemCapacity));
    CFNumberRef valueTotalSystemAvailable = SDMMD_AMDeviceCopyValue(self.rawDevice, CFSTR(kDiskUsageDomain), CFSTR(kTotalSystemAvailable));
    CFNumberRef valueTotalDataCapacity = SDMMD_AMDeviceCopyValue(self.rawDevice, CFSTR(kDiskUsageDomain), CFSTR(kTotalDataCapacity));
    CFNumberRef valueTotalDataAvailable = SDMMD_AMDeviceCopyValue(self.rawDevice, CFSTR(kDiskUsageDomain), CFSTR(kTotalDataAvailable));
    CFNumberRef valueAmountDataReserved = SDMMD_AMDeviceCopyValue(self.rawDevice, CFSTR(kDiskUsageDomain), CFSTR(kAmountDataReserved));
    CFNumberRef valueAmountDataAvailable = SDMMD_AMDeviceCopyValue(self.rawDevice, CFSTR(kDiskUsageDomain), CFSTR(kAmountDataAvailable));

    /*
     kTotalDiskCapacity = kTotalSystemCapacity + kTotalDataCapacity
     kTotalDataAvailable = kAmountDataReserved + kAmountDataAvailable
     total for user     = kTotalDiskCapacity
     used for user      = (kTotalSystemCapacity - kTotalSystemAvailable) + (kTotalDataCapacity - kTotalDataAvailable)
     free for user      = kAmountDataAvailable
     reserved for user  = total - used - free = kTotalSystemAvailable + kAmountDataReserved
    */

    if (valueTotalDiskCapacity == NULL ||
        valueTotalSystemCapacity == NULL ||
        valueTotalSystemAvailable == NULL ||
        valueTotalDataCapacity == NULL ||
        valueTotalDataAvailable == NULL ||
        valueAmountDataReserved == NULL ||
        valueAmountDataAvailable == NULL) {

        NSLog(@"[%s] failed: Copy Value Error", __FUNCTION__);
        return nil;
    }

    MCDeviceDiskUsage *disk = [[MCDeviceDiskUsage alloc] init];
    disk.totalDiskCapacity = (__bridge_transfer NSNumber *)valueTotalDiskCapacity;
    disk.totalDiskUsed = @(([(__bridge_transfer NSNumber *)valueTotalSystemCapacity unsignedIntegerValue] - [(__bridge_transfer NSNumber *)valueTotalSystemAvailable unsignedIntegerValue]) + ([(__bridge_transfer NSNumber *)valueTotalDataCapacity unsignedIntegerValue] - [(__bridge_transfer NSNumber *)valueTotalDataAvailable unsignedIntegerValue]));
    disk.totalDiskFree = (__bridge_transfer NSNumber *)valueAmountDataAvailable;
    disk.totalDiskReserved = @([(__bridge_transfer NSNumber *)valueTotalSystemAvailable unsignedIntegerValue] + [(__bridge_transfer NSNumber *)valueAmountDataReserved unsignedIntegerValue]);

    return disk;
}

- (void)scanCrashLogWithCompleteBlock:(void(^)(NSArray *logDirContents))completeBlock
{
    kern_return_t sdm_return;

    if (![self isConnectedDevice]) {
        sdm_return = SDMMD_AMDeviceConnect(self.rawDevice);
        if (!(SDM_MD_CallSuccessful(sdm_return))) {
            NSLog(@"[%s] failed: No Connection", __FUNCTION__);
            return;
        }
    }

    if (!self.isInSession) {
        if (![self startSession]) {
            NSLog(@"[%s] failed: No Session", __FUNCTION__);
            return;
        }
    }

    SDMMD_AMConnectionRef sdm_afc_conn;
    if (SDMMD_AMDeviceGetInterfaceType(self.rawDevice) == kAMDInterfaceConnectionTypeIndirect) {
        sdm_return = SDMMD_AMDeviceSecureStartService(self.rawDevice, CFSTR(AMSVC_CRASH_REPORT_COPY_MOB), NULL, &sdm_afc_conn);
    } else {
        sdm_return = SDMMD_AMDeviceStartService(self.rawDevice, CFSTR(AMSVC_CRASH_REPORT_COPY_MOB), NULL, &sdm_afc_conn);
    }

    if (SDM_MD_CallSuccessful(sdm_return)) {
        SDMMD_AFCConnectionRef sdm_crash_report_conn = SDMMD_AFCConnectionCreate(sdm_afc_conn);

        if (sdm_crash_report_conn) {
            SDMMD_AFCOperationRef read_dir = SDMMD_AFCOperationCreateReadDirectory(CFSTR(""));
            sdm_return = SDMMD_AFCProcessOperation(sdm_crash_report_conn, &read_dir);
            if (SDM_MD_CallSuccessful(sdm_return)) {
                CFArrayRef dirArray = SDMMD_AFCOperationGetPacketResponse(read_dir);
                NSArray *dirContents = (__bridge_transfer NSArray *)dirArray;

                NSMutableArray *logDirContents = [NSMutableArray array];
                for (NSString *item in dirContents) {
                    if ((item.length == 0) || [item isEqualToString:@"."] || [item isEqualToString:@".."]) {
                        continue;
                    }
                    [logDirContents addObject:item];
                }

                if (completeBlock) {
                    completeBlock(logDirContents);
                }
            }

        } else {
            NSLog(@"[%s] failed: No AFC Connection", __FUNCTION__);
        }

        CFSafeRelease(sdm_crash_report_conn);

    } else {
        NSLog(@"[%s] failed: No Service", __FUNCTION__);
    }
}

- (void)cleanCrashLog:(NSArray *)logDirContents
    withCompleteBlock:(void(^)())completeBlock
{

}

- (void)takeScreenShot
{

}

@end
