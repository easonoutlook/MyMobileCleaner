//
//  MCStageViewController.h
//  MyMobileCleaner
//
//  Created by user on 8/20/15.
//  Copyright (c) 2015 GoKuStudio. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "MCDeviceController.h"

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
