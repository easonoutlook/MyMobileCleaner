//
//  MCDevice.m
//  MyMobileCleaner
//
//  Created by GoKu on 8/18/15.
//  Copyright (c) 2015 GoKuStudio. All rights reserved.
//

#import "MCDevice.h"
#import "LogFormatter.h"

@interface MCDevice ()

@property (nonatomic, assign) BOOL isInSession;

@property (nonatomic) SDMMD_AMDeviceRef rawDevice;
@property (nonatomic, readwrite, strong) NSString *udid;
@property (nonatomic, readwrite, strong) NSString *deviceName;
@property (nonatomic, readwrite, strong) NSString *deviceType;

@property (nonatomic, assign) BOOL needWaitingForPair;

@end

@implementation MCDevice

- (void)dealloc
{
    if ([self isConnectedDevice]) {
        [self stopConnection];
    }
}

- (BOOL)startConnection
{
    sdmmd_return_t result = SDMMD_AMDeviceConnect(_rawDevice);
    return SDM_MD_CallSuccessful(result);
}

- (BOOL)stopConnection
{
    sdmmd_return_t result = SDMMD_AMDeviceDisconnect(_rawDevice);
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

// the connection maybe closed due to long time, so suggest to reconnect for each action.
- (BOOL)reconnectDevice
{
    [self stopConnection];

    if ([self startConnection]) {
        if ([self startSession]) {
            CFTypeRef deviceType = SDMMD_AMDeviceCopyValue(_rawDevice, NULL, CFSTR(kProductType));
            _deviceType = [NSString stringWithUTF8String:SDMMD_ResolveModelToName(deviceType)];
            CFSafeRelease(deviceType);

            return YES;

        } else {
            DDLogError(@"[%s] failed to reconnect device: No Session", __FUNCTION__);
        }

    } else {
        DDLogError(@"[%s] failed to reconnect device: No Connection", __FUNCTION__);
    }
    
    return NO;
}

#pragma mark - connection

- (instancetype)initWithRawDevice:(SDMMD_AMDeviceRef)rawDevice
{
    self = [super init];
    if (self) {
        _rawDevice = rawDevice;

        [self startConnection];

        // udid
        CFStringRef deviceUDID = SDMMD_AMDeviceCopyUDID(_rawDevice);
        if (deviceUDID == NULL) {
            deviceUDID = SDMMD_AMDeviceCopyValue(_rawDevice, NULL, CFSTR(kUniqueDeviceID));
        }
        _udid = (__bridge_transfer NSString *)deviceUDID;

        // name
        CFStringRef deviceName = SDMMD_AMDeviceCopyValue(_rawDevice, NULL, CFSTR(kDeviceName));
        _deviceName = (__bridge_transfer NSString *)deviceName;

        // type
        if ([self startSession]) {
            CFTypeRef deviceType = SDMMD_AMDeviceCopyValue(_rawDevice, NULL, CFSTR(kProductType));
            _deviceType = [NSString stringWithUTF8String:SDMMD_ResolveModelToName(deviceType)];
            CFSafeRelease(deviceType);
        }
    }
    return self;
}

- (BOOL)isConnectedDevice
{
    return SDMMD_AMDeviceIsAttached(self.rawDevice) ? YES : NO;
}

- (BOOL)isPairedDevice
{
    return SDMMD_AMDeviceIsPaired(self.rawDevice) ? YES : NO;
}

- (BOOL)toPairDevice
{
    sdmmd_return_t sdm_return = SDMMD_AMDevicePair(self.rawDevice);
    return SDM_MD_CallSuccessful(sdm_return) ? YES : NO;
}

- (BOOL)unPairDevice
{
    sdmmd_return_t sdm_return = SDMMD_AMDeviceUnpair(self.rawDevice);
    return SDM_MD_CallSuccessful(sdm_return) ? YES : NO;
}

- (void)waitingForPairWithCompleteBlock:(void(^)())completeBlock
{
    self.needWaitingForPair = YES;

    __weak typeof(self) weakSelf = self;
    // by using weak self, after self is dealloc due to disconnection of user, the following while loop will stop. ^_^

    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        while (weakSelf.needWaitingForPair) {
            DDLogInfo(@"waiting for device to pair: %@", weakSelf.deviceName);

            if ([weakSelf isPairedDevice]) {

                // update device info after paired
                if ([weakSelf reconnectDevice]) {
                    if ([weakSelf startSession]) {
                        CFTypeRef deviceType = SDMMD_AMDeviceCopyValue(weakSelf.rawDevice, NULL, CFSTR(kProductType));
                        weakSelf.deviceType = [NSString stringWithUTF8String:SDMMD_ResolveModelToName(deviceType)];
                        CFSafeRelease(deviceType);
                    }
                }

                if (completeBlock) {
                    completeBlock();
                }
                
                weakSelf.needWaitingForPair = NO;

                break;

            } else {
                sleep(1);
            }
        }

        DDLogInfo(@"no need to wait for device to pair");
    });
}

#pragma mark - function

- (MCDeviceDiskUsage *)diskUsage
{
    if (![self reconnectDevice]) {
        DDLogError(@"[%s] failed: Reconnect Device", __FUNCTION__);
        return nil;
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

        DDLogError(@"[%s] failed: Copy Value Error", __FUNCTION__);
        CFSafeRelease(valueTotalDiskCapacity);
        CFSafeRelease(valueTotalSystemCapacity);
        CFSafeRelease(valueTotalSystemAvailable);
        CFSafeRelease(valueTotalDataCapacity);
        CFSafeRelease(valueTotalDataAvailable);
        CFSafeRelease(valueAmountDataReserved);
        CFSafeRelease(valueAmountDataAvailable);

        return nil;
    }

    MCDeviceDiskUsage *disk = [[MCDeviceDiskUsage alloc] init];
    disk.totalDiskCapacity = (__bridge_transfer NSNumber *)valueTotalDiskCapacity;
    disk.totalDiskUsed = @(([(__bridge_transfer NSNumber *)valueTotalSystemCapacity unsignedIntegerValue] - [(__bridge_transfer NSNumber *)valueTotalSystemAvailable unsignedIntegerValue]) + ([(__bridge_transfer NSNumber *)valueTotalDataCapacity unsignedIntegerValue] - [(__bridge_transfer NSNumber *)valueTotalDataAvailable unsignedIntegerValue]));
    disk.totalDiskFree = (__bridge_transfer NSNumber *)valueAmountDataAvailable;
    disk.totalDiskReserved = @([(__bridge_transfer NSNumber *)valueTotalSystemAvailable unsignedIntegerValue] + [(__bridge_transfer NSNumber *)valueAmountDataReserved unsignedIntegerValue]);

    return disk;
}

- (void)scanCrashLogSuccessBlock:(void(^)(NSArray *crashLogs))successBlock
                     updateBlock:(void(^)(NSUInteger totalItemCount, MCDeviceCrashLogItem *currentScannedItem))updateBlock
                    failureBlock:(void(^)())failureBlock
{
    DDLogInfo(@"===== start to scan crash log =====");

    if (![self reconnectDevice]) {
        DDLogError(@"[%s] failed: Reconnect Device", __FUNCTION__);

        if (failureBlock) {
            failureBlock();
        }
        return;
    }

    kern_return_t sdm_return;

    SDMMD_AMConnectionRef sdm_afc_conn;
    if (SDMMD_AMDeviceGetInterfaceType(self.rawDevice) == kAMDInterfaceConnectionTypeIndirect) {
        sdm_return = SDMMD_AMDeviceSecureStartService(self.rawDevice, CFSTR(AMSVC_CRASH_REPORT_COPY_MOB), NULL, &sdm_afc_conn);
    } else {
        sdm_return = SDMMD_AMDeviceStartService(self.rawDevice, CFSTR(AMSVC_CRASH_REPORT_COPY_MOB), NULL, &sdm_afc_conn);
    }

    if (SDM_MD_CallSuccessful(sdm_return)) {
        SDMMD_AFCConnectionRef sdm_crash_report_conn = SDMMD_AFCConnectionCreate(sdm_afc_conn);

        if (sdm_crash_report_conn) {
            SDMMD_AFCOperationRef operation_read_dir = SDMMD_AFCOperationCreateReadDirectory(CFSTR(""));
            sdm_return = SDMMD_AFCProcessOperation(sdm_crash_report_conn, &operation_read_dir);
            if (SDM_MD_CallSuccessful(sdm_return)) {
                NSArray *dirContents = (__bridge_transfer NSArray *)(SDMMD_AFCOperationGetPacketResponse(operation_read_dir));

                NSMutableArray *crashLogs = [NSMutableArray array];
                for (NSString *path in dirContents) {
                    if ((path.length == 0) || [path isEqualToString:@"."] || [path isEqualToString:@".."]) {
                        continue;
                    }

                    MCDeviceCrashLogItem *item = [[MCDeviceCrashLogItem alloc] init];
                    item.path = path;

                    SDMMD_AFCOperationRef operation_get_info = SDMMD_AFCOperationCreateGetFileInfo((__bridge CFStringRef)path);
                    sdm_return = SDMMD_AFCProcessOperation(sdm_crash_report_conn, &operation_get_info);
                    if (SDM_MD_CallSuccessful(sdm_return)) {
                        NSDictionary *info = (__bridge_transfer NSDictionary *)(SDMMD_AFCOperationGetPacketResponse(operation_get_info));
                        item.isDir = [info[@kAFC_File_Info_st_ifmt] isEqualToString:@"S_IFDIR"];
                        MCDeviceCrashLogSearchedItem *searchedItem = [self infoOfItemWithFullPath:path AFCConnection:sdm_crash_report_conn];
                        item.totalSize = @(searchedItem.totalSize);
                        item.allFiles = searchedItem.allFiles;

                        if (updateBlock) {
                            updateBlock(dirContents.count-2, item);
                        }

                        [crashLogs addObject:item];
                    }
                }

                CFSafeRelease(sdm_crash_report_conn);

                if (successBlock) {
                    successBlock(crashLogs);
                }

                return;
            }

            CFSafeRelease(sdm_crash_report_conn);

        } else {
            DDLogError(@"[%s] failed: No AFC Connection", __FUNCTION__);
        }

    } else {
        DDLogError(@"[%s] failed: No Service", __FUNCTION__);
    }

    if (failureBlock) {
        failureBlock();
    }
}

- (void)cleanCrashLog:(NSArray *)crashLogs
         successBlock:(void(^)())successBlock
          updateBlock:(void(^)(NSUInteger currentItemIndex))updateBlock
         failureBlock:(void(^)())failureBlock
{
    DDLogInfo(@"===== start to clean crash log =====");

    if (crashLogs.count == 0) {
        if (successBlock) {
            successBlock();
        }
        return;
    }

    if (![self reconnectDevice]) {
        DDLogError(@"[%s] failed: Reconnect Device", __FUNCTION__);

        if (failureBlock) {
            failureBlock();
        }
        return;
    }
    
    kern_return_t sdm_return;

    SDMMD_AMConnectionRef sdm_afc_conn;
    if (SDMMD_AMDeviceGetInterfaceType(self.rawDevice) == kAMDInterfaceConnectionTypeIndirect) {
        sdm_return = SDMMD_AMDeviceSecureStartService(self.rawDevice, CFSTR(AMSVC_CRASH_REPORT_COPY_MOB), NULL, &sdm_afc_conn);
    } else {
        sdm_return = SDMMD_AMDeviceStartService(self.rawDevice, CFSTR(AMSVC_CRASH_REPORT_COPY_MOB), NULL, &sdm_afc_conn);
    }

    if (SDM_MD_CallSuccessful(sdm_return)) {
        SDMMD_AFCConnectionRef sdm_crash_report_conn = SDMMD_AFCConnectionCreate(sdm_afc_conn);

        if (sdm_crash_report_conn) {
            SDMMD_AFCOperationRef operation_remove_file = NULL;

            for (NSUInteger i = 0; i < crashLogs.count; ++i) {
                MCDeviceCrashLogItem *item = crashLogs[i];

                NSString *path = item.path;

                if (item.isDir) {
                    operation_remove_file = SDMMD_AFCOperationCreateRemovePathAndContents((__bridge CFStringRef)path);
                } else {
                    operation_remove_file = SDMMD_AFCOperationCreateRemovePath((__bridge CFStringRef)path);
                }

                sdm_return = SDMMD_AFCProcessOperation(sdm_crash_report_conn, &operation_remove_file);
                if (SDM_MD_CallSuccessful(sdm_return)) {
                } else {
                }

                if (updateBlock) {
                    updateBlock(i);
                }
            }

            CFSafeRelease(sdm_crash_report_conn);

            if (successBlock) {
                successBlock();
            }

            return;

        } else {
            DDLogError(@"[%s] failed: No AFC Connection", __FUNCTION__);
        }

    } else {
        DDLogError(@"[%s] failed: No Service", __FUNCTION__);
    }
    
    if (failureBlock) {
        failureBlock();
    }
}

- (CFTypeRef)copyDeviceValueOfKey:(NSString *)key inDomain:(NSString *)domain
{
    CFTypeRef sdm_value = NULL;

    if (![self reconnectDevice]) {
        DDLogError(@"[%s] failed: Reconnect Device", __FUNCTION__);

    } else {
        sdm_value = SDMMD_AMDeviceCopyValue(self.rawDevice, (__bridge CFStringRef)domain, (__bridge CFStringRef)key);
        if (sdm_value == NULL) {
            DDLogError(@"[%s] failed: Copy Value Error", __FUNCTION__);
        }
    }

    return sdm_value;
}

#pragma mark - inner

- (MCDeviceCrashLogSearchedItem *)infoOfItemWithFullPath:(NSString *)path
                                           AFCConnection:(SDMMD_AFCConnectionRef)afc_conn
{
    MCDeviceCrashLogSearchedItem *searchedItem = [[MCDeviceCrashLogSearchedItem alloc] init];
    searchedItem.totalSize = 0;
    searchedItem.allFiles = [NSMutableArray array];

    SDMMD_AFCOperationRef operation_get_info = SDMMD_AFCOperationCreateGetFileInfo((__bridge CFStringRef)path);
    kern_return_t sdm_return = SDMMD_AFCProcessOperation(afc_conn, &operation_get_info);

    if (SDM_MD_CallSuccessful(sdm_return)) {
        NSDictionary *info = (__bridge_transfer NSDictionary *)(SDMMD_AFCOperationGetPacketResponse(operation_get_info));

        searchedItem.totalSize += [(NSString *)(info[@kAFC_File_Info_st_size]) integerValue];

        BOOL isDir = [info[@kAFC_File_Info_st_ifmt] isEqualToString:@"S_IFDIR"];
        if (isDir) {
            SDMMD_AFCOperationRef operation_read_dir = SDMMD_AFCOperationCreateReadDirectory((__bridge CFStringRef)path);
            sdm_return = SDMMD_AFCProcessOperation(afc_conn, &operation_read_dir);

            if (SDM_MD_CallSuccessful(sdm_return)) {
                NSArray *dirContents = (__bridge_transfer NSArray *)(SDMMD_AFCOperationGetPacketResponse(operation_read_dir));
                for (NSString *subPath in dirContents) {
                    if ((subPath.length == 0) || [subPath isEqualToString:@"."] || [subPath isEqualToString:@".."]) {
                        continue;
                    }

                    NSString *newPath = [path stringByAppendingPathComponent:subPath];
                    MCDeviceCrashLogSearchedItem *subSearchedItem = [self infoOfItemWithFullPath:newPath AFCConnection:afc_conn];
                    searchedItem.totalSize += subSearchedItem.totalSize;
                    [searchedItem.allFiles addObjectsFromArray:subSearchedItem.allFiles];
                }
            }

        } else {
            [searchedItem.allFiles addObject:path];
        }
    }

    return searchedItem;
}

- (SDMMD_AMDeviceRef)findDeviceFromUDID:(NSString *)udid
{
    NSArray *devices = (__bridge_transfer NSArray *)(SDMMD_AMDCreateDeviceList());
    SDMMD_AMDeviceRef device = NULL;

    if (devices.count) {
        BOOL foundDevice = NO;
        NSString *foundDeviceId;

        NSUInteger index;
        for (index = 0; index < devices.count; ++index) {
            SDMMD_AMDeviceRef device = (__bridge SDMMD_AMDeviceRef)(devices[index]);
            CFStringRef deviceUDID = SDMMD_AMDeviceCopyUDID(device);
            if (deviceUDID == NULL) {
                deviceUDID = SDMMD_AMDeviceCopyValue(_rawDevice, NULL, CFSTR(kUniqueDeviceID));
            }
            if (deviceUDID) {
                foundDeviceId = (__bridge_transfer NSString *)(deviceUDID);
                if ([foundDeviceId isEqualToString:udid]) {
                    foundDevice = YES;
                    break;
                }
            }
        }

        if (foundDevice) {
            device = SDMMD_AMDeviceCreateCopy((__bridge SDMMD_AMDeviceRef)(devices[index]));
        } else {
            DDLogError(@"[%s] failed: No device found with {UDID: %@}", __FUNCTION__, udid);
        }

    } else {
        DDLogError(@"[%s] failed: No Devices", __FUNCTION__);
    }
    
    return device;
}

@end
