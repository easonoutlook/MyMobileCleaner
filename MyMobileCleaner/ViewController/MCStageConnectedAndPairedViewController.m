//
//  MCStageConnectedAndPairedViewController.m
//  MyMobileCleaner
//
//  Created by user on 8/21/15.
//  Copyright (c) 2015 GoKuStudio. All rights reserved.
//

#import "MCStageConnectedAndPairedViewController.h"
#import "MCMainWindowController.h"

@interface MCStageConnectedAndPairedViewController ()

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
}

@end
