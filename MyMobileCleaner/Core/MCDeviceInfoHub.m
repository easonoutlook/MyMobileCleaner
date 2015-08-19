//
//  MCDeviceInfoHub.m
//  MyMobileCleaner
//
//  Created by GoKu on 8/19/15.
//  Copyright (c) 2015 GoKuStudio. All rights reserved.
//

#import "MCDeviceInfoHub.h"

@implementation MCDeviceDiskUsage

- (NSString *)description
{
    NSByteCountFormatter *formatter = [[NSByteCountFormatter alloc] init];
    formatter.countStyle = NSByteCountFormatterCountStyleFile;
    formatter.adaptive = NO;
    formatter.zeroPadsFractionDigits = YES;

    return [NSString stringWithFormat:@"disk usage: {\n\ttotal:\t\t%@\n\tused:\t\t%@\n\tfree:\t\t%@\n\treserved:\t%@\n}",
            [formatter stringFromByteCount:[self.totalDiskCapacity unsignedIntegerValue]],
            [formatter stringFromByteCount:[self.totalDiskUsed unsignedIntegerValue]],
            [formatter stringFromByteCount:[self.totalDiskFree unsignedIntegerValue]],
            [formatter stringFromByteCount:[self.totalDiskReserved unsignedIntegerValue]]];
}

@end

@implementation MCDeviceCrashLogItem

@end