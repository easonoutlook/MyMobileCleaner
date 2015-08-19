//
//  MCDeviceInfoHub.h
//  MyMobileCleaner
//
//  Created by GoKu on 8/19/15.
//  Copyright (c) 2015 GoKuStudio. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MCDeviceDiskUsage : NSObject

@property (nonatomic, strong) NSNumber *totalDiskCapacity;
@property (nonatomic, strong) NSNumber *totalDiskUsed;
@property (nonatomic, strong) NSNumber *totalDiskFree;
@property (nonatomic, strong) NSNumber *totalDiskReserved;

@end

@interface MCDeviceCrashLogItem : NSObject

@property (nonatomic, strong) NSString *path;
@property (nonatomic, strong) NSNumber *size;
@property (nonatomic, assign) BOOL isDir;

@end