//
//  MCStageScanDoneViewController.m
//  MyMobileCleaner
//
//  Created by GoKu on 8/21/15.
//  Copyright (c) 2015 GoKuStudio. All rights reserved.
//

#import "MCStageScanDoneViewController.h"
#import "MCMainWindowController.h"

@interface MCStageScanDoneViewController ()

@property (weak) IBOutlet MCColorBackgroundView *colorBackground;
@property (weak) IBOutlet NSTextField *labelTitle;
@property (weak) IBOutlet NSTextField *labelInfo;
@property (weak) IBOutlet NSButton *btnClean;
@property (weak) IBOutlet NSTextField *labelSize;

@end

@implementation MCStageScanDoneViewController

- (instancetype)initWithManager:(id<MCStageViewControllerManager>)manager
{
    self = [super initWithNibName:@"MCStageScanDoneViewController" bundle:nil];
    if (self) {
        self.manager = manager;
    }
    return self;
}

- (void)stageViewDidAppear
{
    self.labelTitle.stringValue = [MCDeviceController sharedInstance].selectedConnectedDevice.deviceName;
    self.labelInfo.stringValue = [MCDeviceController sharedInstance].selectedConnectedDevice.deviceType;

    NSUInteger totalSize = 0;

    for (MCDeviceCrashLogItem *item in ((MCMainWindowController *)(self.manager)).myCrashLogs) {
        totalSize += [item.size unsignedIntegerValue];
    }

    NSByteCountFormatter *formatter = [[NSByteCountFormatter alloc] init];
    formatter.countStyle = NSByteCountFormatterCountStyleBinary;
    formatter.adaptive = NO;
    formatter.zeroPadsFractionDigits = YES;

    NSLog(@"100%% => all scanned crash log: %@", [formatter stringFromByteCount:totalSize]);

    self.labelSize.stringValue = [formatter stringFromByteCount:totalSize];
}

- (IBAction)clickBtnClean:(id)sender {
    [self.manager gotoNextStage];
}

- (NSColor *)toneColor
{
    return self.colorBackground.cbvBackgroundColor ? : [NSColor clearColor];
}

@end
