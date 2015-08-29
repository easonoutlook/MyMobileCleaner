//
//  LogFormatter.h
//  MyMobileCleaner
//
//  Created by GoKu on 8/29/15.
//  Copyright (c) 2015 GoKuStudio. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CocoaLumberjack/CocoaLumberjack.h>

extern int ddLogLevel;

@interface LogFormatter :  NSObject <DDLogFormatter>

+ (void)setupLog;

@end
