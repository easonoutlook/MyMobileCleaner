//
//  MCStageConnectedButUnPairedViewController.m
//  MyMobileCleaner
//
//  Created by GoKu on 8/21/15.
//  Copyright (c) 2015 GoKuStudio. All rights reserved.
//

#import "MCStageConnectedButUnPairedViewController.h"
#import "MCMainWindowController.h"

@interface MCStageConnectedButUnPairedViewController ()

@property (weak) IBOutlet MCColorBackgroundView *colorBackground;

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

- (NSColor *)toneColor
{
    return self.colorBackground.sdBackgroundColor ? : [NSColor clearColor];
}

@end
