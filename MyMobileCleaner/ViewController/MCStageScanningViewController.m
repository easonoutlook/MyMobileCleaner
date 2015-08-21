//
//  MCStageScanningViewController.m
//  MyMobileCleaner
//
//  Created by GoKu on 8/21/15.
//  Copyright (c) 2015 GoKuStudio. All rights reserved.
//

#import "MCStageScanningViewController.h"
#import "MCMainWindowController.h"

@interface MCStageScanningViewController ()

@property (weak) IBOutlet MCColorBackgroundView *colorBackground;

@property (nonatomic, assign) NSUInteger myCurrentScannedItemCount;

@end

@implementation MCStageScanningViewController

- (instancetype)initWithManager:(id<MCStageViewControllerManager>)manager
{
    self = [super initWithNibName:@"MCStageScanningViewController" bundle:nil];
    if (self) {
        self.manager = manager;
    }
    return self;
}

- (void)stageViewDidAppear
{
    // scan crash log
    self.myCurrentScannedItemCount = 0;

    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        [[MCDeviceController sharedInstance].selectedConnectedDevice
         scanCrashLogSuccessBlock:^(NSArray *crashLogs) {
             dispatch_async(dispatch_get_main_queue(), ^{
                 ((MCMainWindowController *)(self.manager)).myCrashLogs = crashLogs;
                 [self.manager gotoNextStage];
             });
         }
         updateBlock:^(NSUInteger totalItemCount, MCDeviceCrashLogItem *currentScannedItem) {
             NSLog(@"%.1f%% -> scanned crash log: %@", 100.0*(++self.myCurrentScannedItemCount)/totalItemCount, currentScannedItem.path);
         }
         failureBlock:^{
             NSLog(@"=> failed to scan crash log");

             dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                 [self.manager gotoPreviousStage];
             });
         }];
    });
}

- (NSColor *)toneColor
{
    return self.colorBackground.cbvBackgroundColor ? : [NSColor clearColor];
}

@end
