//
//  MCStageNoConnectionViewController.m
//  MyMobileCleaner
//
//  Created by GoKu on 8/21/15.
//  Copyright (c) 2015 GoKuStudio. All rights reserved.
//

#import "MCStageNoConnectionViewController.h"
#import "MCMainWindowController.h"

@interface MCStageNoConnectionViewController ()

@property (weak) IBOutlet MCColorBackgroundView *colorBackground;

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
