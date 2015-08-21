//
//  MCStageNoConnectionViewController.m
//  MyMobileCleaner
//
//  Created by user on 8/21/15.
//  Copyright (c) 2015 GoKuStudio. All rights reserved.
//

#import "MCStageNoConnectionViewController.h"
#import "MCMainWindowController.h"

@interface MCStageNoConnectionViewController ()

@end

@implementation MCStageNoConnectionViewController

- (instancetype)initWithManager:(id<MCStageViewControllerManager>)manager
{
    self = [super initWithNibName:@"MCStageNoConnectionViewController" bundle:nil];
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
