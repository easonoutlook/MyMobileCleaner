//
//  MCStageConnectedButUnPairedViewController.m
//  MyMobileCleaner
//
//  Created by user on 8/21/15.
//  Copyright (c) 2015 GoKuStudio. All rights reserved.
//

#import "MCStageConnectedButUnPairedViewController.h"
#import "MCMainWindowController.h"

@interface MCStageConnectedButUnPairedViewController ()

@end

@implementation MCStageConnectedButUnPairedViewController

- (instancetype)initWithManager:(id<MCStageViewControllerManager>)manager
{
    self = [super initWithNibName:@"MCStageConnectedButUnPairedViewController" bundle:nil];
    if (self) {
        self.manager = manager;
    }
    return self;
}

- (void)stageViewDidAppear
{
    ((MCMainWindowController *)(self.manager)).myCrashLogs = nil;
}

@end
