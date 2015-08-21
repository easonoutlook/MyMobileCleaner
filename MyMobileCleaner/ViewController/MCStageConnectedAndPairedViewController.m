//
//  MCStageConnectedAndPairedViewController.m
//  MyMobileCleaner
//
//  Created by GoKu on 8/21/15.
//  Copyright (c) 2015 GoKuStudio. All rights reserved.
//

#import "MCStageConnectedAndPairedViewController.h"
#import "MCMainWindowController.h"

@interface MCStageConnectedAndPairedViewController ()

@property (weak) IBOutlet MCColorBackgroundView *colorBackground;
@property (weak) IBOutlet NSTextField *labelTitle;
@property (weak) IBOutlet NSTextField *labelInfo;
@property (weak) IBOutlet NSButton *btnScan;

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
    self.labelTitle.stringValue = [MCDeviceController sharedInstance].selectedConnectedDevice.deviceName;
    self.labelInfo.stringValue = [MCDeviceController sharedInstance].selectedConnectedDevice.deviceType;

    ((MCMainWindowController *)(self.manager)).myCrashLogs = nil;
    
    // disk usage
    NSLog(@"%@", [[MCDeviceController sharedInstance].selectedConnectedDevice diskUsage]);
}

- (IBAction)clickBtnScan:(id)sender {
    [self.manager gotoNextStage];
}

- (NSColor *)toneColor
{
    return self.colorBackground.cbvBackgroundColor ? : [NSColor clearColor];
}

@end
