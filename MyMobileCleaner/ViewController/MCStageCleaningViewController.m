//
//  MCStageCleaningViewController.m
//  MyMobileCleaner
//
//  Created by GoKu on 8/21/15.
//  Copyright (c) 2015 GoKuStudio. All rights reserved.
//

#import "MCStageCleaningViewController.h"
#import "MCMainWindowController.h"

@interface MCStageCleaningViewController ()

@property (weak) IBOutlet MCColorBackgroundView *colorBackground;
@property (weak) IBOutlet NSTextField *labelTitle;
@property (weak) IBOutlet NSTextField *labelInfo;
@property (weak) IBOutlet NSProgressIndicator *progressBar;
@property (weak) IBOutlet NSImageView *error;

@property (nonatomic, strong) NSArray *crashLogs;

@end

@implementation MCStageCleaningViewController

- (instancetype)initWithManager:(id<MCStageViewControllerManager>)manager
{
    self = [super initWithNibName:@"MCStageCleaningViewController" bundle:nil];
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
    
    // clean crash log
    self.crashLogs = ((MCMainWindowController *)(self.manager)).myCrashLogs;

    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        [[MCDeviceController sharedInstance].selectedConnectedDevice cleanCrashLog:self.crashLogs
                                                                      successBlock:^{
                                                                          dispatch_async(dispatch_get_main_queue(), ^{
                                                                              self.progressBar.doubleValue = self.progressBar.maxValue;
                                                                              [self.manager gotoNextStage];
                                                                          });
                                                                      } updateBlock:^(NSUInteger currentItemIndex) {
                                                                          float progressValue = 100.0*(currentItemIndex+1)/self.crashLogs.count;
                                                                          
                                                                          NSLog(@"%.1f%% -> cleaned crash log: %@", progressValue, ((MCDeviceCrashLogItem *)(self.crashLogs[currentItemIndex])).path);
                                                                          dispatch_async(dispatch_get_main_queue(), ^{
                                                                              self.progressBar.doubleValue = progressValue*(self.progressBar.maxValue-self.progressBar.minValue)/100 + self.progressBar.minValue;
                                                                          });
                                                                      } failureBlock:^{
                                                                          NSLog(@"=> failed to clean all scanned crash log");

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
