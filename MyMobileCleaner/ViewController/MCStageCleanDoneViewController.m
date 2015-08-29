//
//  MCStageCleanDoneViewController.m
//  MyMobileCleaner
//
//  Created by GoKu on 8/21/15.
//  Copyright (c) 2015 GoKuStudio. All rights reserved.
//

#import "MCStageCleanDoneViewController.h"

@interface MCStageCleanDoneViewController ()

@property (weak) IBOutlet MCColorBackgroundView *colorBackground;
@property (weak) IBOutlet NSButton *btnDone;

@end

@implementation MCStageCleanDoneViewController

- (instancetype)initWithManager:(id<MCStageViewControllerManager>)manager
{
    self = [super initWithNibName:@"MCStageCleanDoneViewController" bundle:nil];
    if (self) {
        self.manager = manager;
    }
    return self;
}

- (void)stageViewDidAppear
{
    DDLogDebug(@"100%% => success to clean all scanned crash log");
}

- (IBAction)clickBtnDone:(id)sender {
    [self.view.window close];
}

@end
