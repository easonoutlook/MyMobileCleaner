//
//  MCStageConnectedAndPairedViewController.m
//  MyMobileCleaner
//
//  Created by GoKu on 8/21/15.
//  Copyright (c) 2015 GoKuStudio. All rights reserved.
//

#import "MCStageConnectedAndPairedViewController.h"
#import "MCMainWindowController.h"
#import "MCDiskUsageCircleView.h"

@interface MCStageConnectedAndPairedViewController ()

@property (weak) IBOutlet MCColorBackgroundView *colorBackground;
@property (weak) IBOutlet NSButton *btnScan;
@property (weak) IBOutlet MCDiskUsageCircleView *chartDiskUsage;

@end

@implementation MCStageConnectedAndPairedViewController

- (instancetype)initWithManager:(id<MCStageViewControllerManager>)manager
{
    self = [super initWithNibName:@"MCStageConnectedAndPairedViewController" bundle:nil];
    if (self) {
        self.manager = manager;
    }
    return self;
}

- (void)stageViewDidAppear
{
    ((MCMainWindowController *)(self.manager)).myCrashLogs = nil;
    
    // disk usage
    NSLog(@"%@", [[MCDeviceController sharedInstance].selectedConnectedDevice diskUsage]);

    [self.chartDiskUsage updateWithData:@[[[MCDeviceController sharedInstance].selectedConnectedDevice diskUsage].totalDiskUsed,
                                          [[MCDeviceController sharedInstance].selectedConnectedDevice diskUsage].totalDiskReserved,
                                          [[MCDeviceController sharedInstance].selectedConnectedDevice diskUsage].totalDiskFree]
                                  color:@[[NSColor redColor],
                                          [NSColor yellowColor],
                                          [NSColor greenColor]]
                               animated:YES
                             completion:nil];
}

- (IBAction)clickBtnScan:(id)sender {
    [self.manager gotoNextStage];
}

@end
