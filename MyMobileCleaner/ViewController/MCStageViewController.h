//
//  MCStageViewController.h
//  MyMobileCleaner
//
//  Created by GoKu on 8/20/15.
//  Copyright (c) 2015 GoKuStudio. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "MCDeviceController.h"
#import "MCColorBackgroundView.h"

static CGFloat const kDefaultWaitDuration = 0.02;

typedef NS_ENUM(NSUInteger, MCStageViewControllerUIStage) {
    kMCStageViewControllerUIStageNoConnection = 0,
    kMCStageViewControllerUIStageConnectedButUnPaired,
    kMCStageViewControllerUIStageConnectedAndPaired,
    kMCStageViewControllerUIStageScanning,
    kMCStageViewControllerUIStageScanDone,
    kMCStageViewControllerUIStageCleaning,
    kMCStageViewControllerUIStageCleanDone
};

@protocol MCStageViewControllerManager <NSObject>

- (void)gotoNextStage;
- (void)gotoPreviousStage;

@end

@interface MCStageViewController : NSViewController

@property (nonatomic, weak) id<MCStageViewControllerManager> manager;

- (instancetype)initWithManager:(id<MCStageViewControllerManager>)manager;

- (void)stageViewDidAppear;

@end
