//
//  MCDiskUsageCircleView.h
//  MyMobileCleaner
//
//  Created by GoKu on 8/24/15.
//  Copyright (c) 2015 GoKuStudio. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface MCDiskUsageCircleView : NSView

- (void)updateWithData:(NSArray *)data
                 color:(NSArray *)color
             animation:(void(^)(NSUInteger dataIndex))animation
            completion:(void(^)(MCDiskUsageCircleView *))completion;

@end
