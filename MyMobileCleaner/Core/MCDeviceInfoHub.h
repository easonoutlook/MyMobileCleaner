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

@interface MCDeviceCrashLogItem : NSObject // direct descendant in device's Crash Log dir.

@property (nonatomic, strong) NSString *path;
@property (nonatomic, assign) BOOL isDir;
@property (nonatomic, strong) NSNumber *totalSize;
@property (nonatomic, strong) NSArray *allFiles; // of NSString

@end

@interface MCDeviceCrashLogSearchedItem : NSObject // just used in search

@property (nonatomic, assign) NSUInteger totalSize; // all dir size + all file size
@property (nonatomic, strong) NSMutableArray *allFiles; // of NSString

@end