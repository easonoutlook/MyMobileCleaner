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
    // clean crash log
    self.crashLogs = ((MCMainWindowController *)(self.manager)).myCrashLogs;

    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        [[MCDeviceController sharedInstance].selectedConnectedDevice cleanCrashLog:self.crashLogs
                                                                      successBlock:^{
                                                                          dispatch_async(dispatch_get_main_queue(), ^{
                                                                              [self.manager gotoNextStage];
                                                                          });
                                                                      } updateBlock:^(NSUInteger currentItemIndex) {
                                                                          NSLog(@"%.1f%% -> cleaned crash log: %@", 100.0*(currentItemIndex+1)/self.crashLogs.count, ((MCDeviceCrashLogItem *)(self.crashLogs[currentItemIndex])).path);
                                                                      } failureBlock:^{
                                                                          NSLog(@"=> failed to clean all scanned crash log");

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
