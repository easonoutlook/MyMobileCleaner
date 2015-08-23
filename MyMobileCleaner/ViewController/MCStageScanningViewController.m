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
@property (weak) IBOutlet NSProgressIndicator *progress;
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
    [self.progress startAnimation:self];
    self.error.hidden = YES;

    // scan crash log
    self.myCurrentScannedItemCount = 0;

    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        [[MCDeviceController sharedInstance].selectedConnectedDevice
         scanCrashLogSuccessBlock:^(NSArray *crashLogs) {
             ((MCMainWindowController *)(self.manager)).myCrashLogs = crashLogs;

             dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                 [self.progress stopAnimation:self];
                 [self.manager gotoNextStage];
             });

         }
         updateBlock:^(NSUInteger totalItemCount, MCDeviceCrashLogItem *currentScannedItem) {
             float progressValue = 100.0*(++self.myCurrentScannedItemCount)/totalItemCount;
             NSLog(@"%.1f%% -> scanned crash log: %@", progressValue, currentScannedItem.path);

         }
         failureBlock:^{
             NSLog(@"=> failed to scan crash log");

             dispatch_async(dispatch_get_main_queue(), ^{
                 [self.progress stopAnimation:self];
                 self.error.hidden = NO;
             });

             dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                 [self.manager gotoPreviousStage];
             });
         }];
    });
}

@end
