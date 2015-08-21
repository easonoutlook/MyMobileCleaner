//
//  MCStageCleanDoneViewController.m
//  MyMobileCleaner
//
//  Created by user on 8/21/15.
//  Copyright (c) 2015 GoKuStudio. All rights reserved.
//

#import "MCStageCleanDoneViewController.h"

@interface MCStageCleanDoneViewController ()

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
    NSLog(@"100%% => success to clean all scanned crash log");
}

@end
