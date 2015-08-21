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
@property (weak) IBOutlet NSTextField *labelTitle;
@property (weak) IBOutlet NSTextField *labelInfo;
@property (weak) IBOutlet NSProgressIndicator *progressBar;
@property (weak) IBOutlet NSImageView *error;

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
    self.labelTitle.stringValue = [MCDeviceController sharedInstance].selectedConnectedDevice.deviceName;
    self.labelInfo.stringValue = [MCDeviceController sharedInstance].selectedConnectedDevice.deviceType;

    self.progressBar.doubleValue = self.progressBar.minValue;
    self.error.hidden = YES;

    // scan crash log
    self.myCurrentScannedItemCount = 0;

    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        [[MCDeviceController sharedInstance].selectedConnectedDevice
         scanCrashLogSuccessBlock:^(NSArray *crashLogs) {
             dispatch_async(dispatch_get_main_queue(), ^{
                 ((MCMainWindowController *)(self.manager)).myCrashLogs = crashLogs;

                 self.progressBar.doubleValue = self.progressBar.maxValue;
                 [self.manager gotoNextStage];
             });
         }
         updateBlock:^(NSUInteger totalItemCount, MCDeviceCrashLogItem *currentScannedItem) {
             float progressValue = 100.0*(++self.myCurrentScannedItemCount)/totalItemCount;
             
             NSLog(@"%.1f%% -> scanned crash log: %@", progressValue, currentScannedItem.path);
             dispatch_async(dispatch_get_main_queue(), ^{
                 self.progressBar.doubleValue = progressValue*(self.progressBar.maxValue-self.progressBar.minValue)/100 + self.progressBar.minValue;
             });
         }
         failureBlock:^{
             NSLog(@"=> failed to scan crash log");

             dispatch_async(dispatch_get_main_queue(), ^{
                 self.error.hidden = NO;
             });

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
