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
@property (weak) IBOutlet NSView *boxUsed;
@property (weak) IBOutlet NSView *boxReserved;
@property (weak) IBOutlet NSView *boxFree;
@property (weak) IBOutlet NSTextField *labelSizeUsed;
@property (weak) IBOutlet NSTextField *labelSizeReserved;
@property (weak) IBOutlet NSTextField *labelSizeFree;

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

    self.boxUsed.hidden = YES;
    self.boxReserved.hidden = YES;
    self.boxFree.hidden = YES;

    NSByteCountFormatter *formatter = [[NSByteCountFormatter alloc] init];
    formatter.countStyle = NSByteCountFormatterCountStyleBinary;
    formatter.adaptive = NO;
    formatter.zeroPadsFractionDigits = YES;
    self.labelSizeUsed.stringValue = [formatter stringFromByteCount:[[[MCDeviceController sharedInstance].selectedConnectedDevice diskUsage].totalDiskUsed unsignedIntegerValue]];
    self.labelSizeReserved.stringValue = [formatter stringFromByteCount:[[[MCDeviceController sharedInstance].selectedConnectedDevice diskUsage].totalDiskReserved unsignedIntegerValue]];
    self.labelSizeFree.stringValue = [formatter stringFromByteCount:[[[MCDeviceController sharedInstance].selectedConnectedDevice diskUsage].totalDiskFree unsignedIntegerValue]];

    [self.chartDiskUsage updateWithData:@[[[MCDeviceController sharedInstance].selectedConnectedDevice diskUsage].totalDiskUsed,
                                          [[MCDeviceController sharedInstance].selectedConnectedDevice diskUsage].totalDiskReserved,
                                          [[MCDeviceController sharedInstance].selectedConnectedDevice diskUsage].totalDiskFree]
                                  color:@[[NSColor redColor],
                                          [NSColor yellowColor],
                                          [NSColor greenColor]]
                               animation:^(NSUInteger dataIndex) {
                                   dispatch_async(dispatch_get_main_queue(), ^{
                                       if (dataIndex == 0) {
                                           self.boxUsed.hidden = NO;
                                       } else if (dataIndex == 1) {
                                           self.boxReserved.hidden = NO;
                                       } else if (dataIndex == 2) {
                                           self.boxFree.hidden = NO;
                                       }
                                   });
                               }
                             completion:nil];
}

- (IBAction)clickBtnScan:(id)sender {
    [self.manager gotoNextStage];
}

@end
