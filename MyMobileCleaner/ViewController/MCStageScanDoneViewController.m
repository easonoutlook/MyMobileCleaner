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
    NSUInteger totalSize = 0;
    for (MCDeviceCrashLogItem *item in ((MCMainWindowController *)(self.manager)).myCrashLogs) {
        totalSize += [item.size unsignedIntegerValue];
    }

    NSByteCountFormatter *formatter = [[NSByteCountFormatter alloc] init];
    formatter.countStyle = NSByteCountFormatterCountStyleBinary;
    formatter.adaptive = NO;
    formatter.zeroPadsFractionDigits = YES;

    NSLog(@"100%% => all scanned crash log: %@", [formatter stringFromByteCount:totalSize]);

    self.labelSize.stringValue = [NSString stringWithFormat:NSLocalizedStringFromTable(@"scan.done.crash.log.info", @"MyMobileCleaner", @"scan.done"), [formatter stringFromByteCount:totalSize]];
}

- (IBAction)clickBtnClean:(id)sender {
    [self.manager gotoNextStage];
}

@end
