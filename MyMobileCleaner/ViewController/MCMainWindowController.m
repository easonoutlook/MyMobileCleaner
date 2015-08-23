//
//  MCMainWindowController.m
//  MyMobileCleaner
//
//  Created by GoKu on 8/20/15.
//  Copyright (c) 2015 GoKuStudio. All rights reserved.
//

#import "MCMainWindowController.h"
#import "MCCustomWindowButtonBar.h"
#import "MCStageNoConnectionViewController.h"
#import "MCStageConnectedButUnPairedViewController.h"
#import "MCStageConnectedAndPairedViewController.h"
#import "MCStageScanningViewController.h"
#import "MCStageScanDoneViewController.h"
#import "MCStageCleaningViewController.h"
#import "MCStageCleanDoneViewController.h"

@interface MCMainWindowController ()

@property (weak) IBOutlet MCCustomWindowButtonBar *windowButtonBar;
@property (weak) IBOutlet NSView *cavas;
@property (weak) IBOutlet NSTextField *labelTitle;
@property (weak) IBOutlet NSTextField *labelInfo;

@property (nonatomic, assign) MCStageViewControllerUIStage currentUIStage;
@property (nonatomic, strong) MCStageViewController *currentUIStageViewController;
@property (nonatomic, strong) MCStageNoConnectionViewController *stageNoConnectionViewController;
@property (nonatomic, strong) MCStageConnectedButUnPairedViewController *stageConnectedButUnPairedViewController;
@property (nonatomic, strong) MCStageConnectedAndPairedViewController *stageConnectedAndPairedViewController;
@property (nonatomic, strong) MCStageScanningViewController *stageScanningViewController;
@property (nonatomic, strong) MCStageScanDoneViewController *stageScanDoneViewController;
@property (nonatomic, strong) MCStageCleaningViewController *stageCleaningViewController;
@property (nonatomic, strong) MCStageCleanDoneViewController *stageCleanDoneViewController;

@end

@implementation MCMainWindowController

- (instancetype)init
{
    self = [super initWithWindowNibName:@"MCMainWindowController"];
    if (self) {
    }
    return self;
}

- (void)goToWork
{
    [[MCDeviceController sharedInstance] monitorWithListener:self];
}

- (void)windowDidLoad {
    [super windowDidLoad];

    // !!! important, or else the subviews in contentView maybe abnormal.
    // !!! because the contentView implements [drawRect:] to draw by itself.
    [self.window.contentView setWantsLayer:YES];

    self.currentUIStage = -1;
    [self showDefaultDisConnectStatus];
}

- (void)showDefaultDisConnectStatus
{
    self.labelTitle.stringValue = NSLocalizedStringFromTable(@"to.connect.title", @"MyMobileCleaner", @"to.connect");
    self.labelInfo.stringValue = NSLocalizedStringFromTable(@"to.connect.info", @"MyMobileCleaner", @"to.connect");

    [self updateStage:kMCStageViewControllerUIStageNoConnection animate:NO completion:nil];
}

- (void)windowWillClose:(NSNotification *)notification
{
    [[MCDeviceController sharedInstance] stopMonitor];

    // without delay, [windowWillClose:] will call 2 times. no idea.
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [[NSApplication sharedApplication] terminate:self];
    });
}

- (void)updateStage:(MCStageViewControllerUIStage)newStage
            animate:(BOOL)animate
         completion:(void(^)(MCStageViewController *))completion
{
    if (self.currentUIStage == newStage) {
        return;
    }

    NSLog(@"UI stage change: %ld -> %ld", self.currentUIStage, newStage);

    if (self.currentUIStageViewController) {
        [self.currentUIStageViewController.view removeFromSuperview];
    }

    self.currentUIStage = newStage;
    switch (self.currentUIStage) {
        case kMCStageViewControllerUIStageNoConnection:
            if (!self.stageNoConnectionViewController) {
                self.stageNoConnectionViewController = [[MCStageNoConnectionViewController alloc] initWithManager:self];
            }
            self.currentUIStageViewController = self.stageNoConnectionViewController;
            break;
        case kMCStageViewControllerUIStageConnectedButUnPaired:
            if (!self.stageConnectedButUnPairedViewController) {
                self.stageConnectedButUnPairedViewController = [[MCStageConnectedButUnPairedViewController alloc] initWithManager:self];
            }
            self.currentUIStageViewController = self.stageConnectedButUnPairedViewController;
            break;
        case kMCStageViewControllerUIStageConnectedAndPaired:
            if (!self.stageConnectedAndPairedViewController) {
                self.stageConnectedAndPairedViewController = [[MCStageConnectedAndPairedViewController alloc] initWithManager:self];
            }
            self.currentUIStageViewController = self.stageConnectedAndPairedViewController;
            break;
        case kMCStageViewControllerUIStageScanning:
            if (!self.stageScanningViewController) {
                self.stageScanningViewController = [[MCStageScanningViewController alloc] initWithManager:self];
            }
            self.currentUIStageViewController = self.stageScanningViewController;
            break;
        case kMCStageViewControllerUIStageScanDone:
            if (!self.stageScanDoneViewController) {
                self.stageScanDoneViewController = [[MCStageScanDoneViewController alloc] initWithManager:self];
            }
            self.currentUIStageViewController = self.stageScanDoneViewController;
            break;
        case kMCStageViewControllerUIStageCleaning:
            if (!self.stageCleaningViewController) {
                self.stageCleaningViewController = [[MCStageCleaningViewController alloc] initWithManager:self];
            }
            self.currentUIStageViewController = self.stageCleaningViewController;
            break;
        case kMCStageViewControllerUIStageCleanDone:
            if (!self.stageCleanDoneViewController) {
                self.stageCleanDoneViewController = [[MCStageCleanDoneViewController alloc] initWithManager:self];
            }
            self.currentUIStageViewController = self.stageCleanDoneViewController;
            break;
        default:
            break;
    }

    [self.cavas addSubview:self.currentUIStageViewController.view];
    [self.cavas addConstraints:@[[NSLayoutConstraint constraintWithItem:self.currentUIStageViewController.view
                                                              attribute:NSLayoutAttributeTop
                                                              relatedBy:NSLayoutRelationEqual
                                                                 toItem:self.cavas
                                                              attribute:NSLayoutAttributeTop
                                                             multiplier:1
                                                               constant:0],
                                 [NSLayoutConstraint constraintWithItem:self.currentUIStageViewController.view
                                                              attribute:NSLayoutAttributeBottom
                                                              relatedBy:NSLayoutRelationEqual
                                                                 toItem:self.cavas
                                                              attribute:NSLayoutAttributeBottom
                                                             multiplier:1
                                                               constant:0],
                                 [NSLayoutConstraint constraintWithItem:self.currentUIStageViewController.view
                                                              attribute:NSLayoutAttributeLeading
                                                              relatedBy:NSLayoutRelationEqual
                                                                 toItem:self.cavas
                                                              attribute:NSLayoutAttributeLeading
                                                             multiplier:1
                                                               constant:0],
                                 [NSLayoutConstraint constraintWithItem:self.currentUIStageViewController.view
                                                              attribute:NSLayoutAttributeTrailing
                                                              relatedBy:NSLayoutRelationEqual
                                                                 toItem:self.cavas
                                                              attribute:NSLayoutAttributeTrailing
                                                             multiplier:1
                                                               constant:0]]];

    [self.currentUIStageViewController stageViewDidAppear];

    [self refreshWindowButtonBar];
}

- (void)refreshWindowButtonBar
{
    [self.windowButtonBar removeFromSuperviewWithoutNeedingDisplay];
    [self.window.contentView addSubview:self.windowButtonBar];
    [self.window.contentView addConstraints:@[[NSLayoutConstraint constraintWithItem:self.windowButtonBar
                                                                           attribute:NSLayoutAttributeTop
                                                                           relatedBy:NSLayoutRelationEqual
                                                                              toItem:self.window.contentView
                                                                           attribute:NSLayoutAttributeTop
                                                                          multiplier:1
                                                                            constant:16],
                                              [NSLayoutConstraint constraintWithItem:self.windowButtonBar
                                                                           attribute:NSLayoutAttributeLeading
                                                                           relatedBy:NSLayoutRelationEqual
                                                                              toItem:self.window.contentView
                                                                           attribute:NSLayoutAttributeLeading
                                                                          multiplier:1
                                                                            constant:16]]];
    [self.windowButtonBar layoutButtonsVertical:YES];
}

#pragma mark - MCStageViewControllerManager

- (void)gotoNextStage
{
    if (self.currentUIStage == kMCStageViewControllerUIStageConnectedAndPaired) {
        [self updateStage:kMCStageViewControllerUIStageScanning animate:NO completion:nil];

    } else if (self.currentUIStage == kMCStageViewControllerUIStageScanning) {
        [self updateStage:kMCStageViewControllerUIStageScanDone animate:NO completion:nil];

    } else if (self.currentUIStage == kMCStageViewControllerUIStageScanDone) {
        [self updateStage:kMCStageViewControllerUIStageCleaning animate:NO completion:nil];

    } else if (self.currentUIStage == kMCStageViewControllerUIStageCleaning) {
        [self updateStage:kMCStageViewControllerUIStageCleanDone animate:NO completion:nil];

    } else if (self.currentUIStage == kMCStageViewControllerUIStageCleanDone) {
        [self updateStage:kMCStageViewControllerUIStageConnectedAndPaired animate:NO completion:nil];

    } else {

    }
}

- (void)gotoPreviousStage
{
    if (self.currentUIStage == kMCStageViewControllerUIStageScanning) {
        [self updateStage:kMCStageViewControllerUIStageConnectedAndPaired animate:NO completion:nil];

    } else if (self.currentUIStage == kMCStageViewControllerUIStageScanDone) {
        [self updateStage:kMCStageViewControllerUIStageConnectedAndPaired animate:NO completion:nil];

    } else if (self.currentUIStage == kMCStageViewControllerUIStageCleaning) {
        [self updateStage:kMCStageViewControllerUIStageConnectedAndPaired animate:NO completion:nil];

    } else {

    }
}

#pragma mark - MCDeviceControllerDelegate

- (void)deviceDidConnectButUnPaired
{
    dispatch_async(dispatch_get_main_queue(), ^{
        self.labelTitle.stringValue = [MCDeviceController sharedInstance].selectedConnectedDevice.deviceName;
        self.labelInfo.stringValue = NSLocalizedStringFromTable(@"to.pair.info", @"MyMobileCleaner", @"to.pair");

        [self updateStage:kMCStageViewControllerUIStageConnectedButUnPaired animate:NO completion:nil];
    });

    [[MCDeviceController sharedInstance].selectedConnectedDevice waitingForPairWithCompleteBlock:^{
        [self deviceDidConnectAndPaired];
    }];

    // try to pair: not work, no idea. let user do it by himself.
//    [[MCDeviceController sharedInstance].selectedConnectedDevice toPairDevice];
}

- (void)deviceDidConnectAndPaired
{
    dispatch_async(dispatch_get_main_queue(), ^{
        self.labelTitle.stringValue = [MCDeviceController sharedInstance].selectedConnectedDevice.deviceName;
        self.labelInfo.stringValue = [MCDeviceController sharedInstance].selectedConnectedDevice.deviceType;

        [self updateStage:kMCStageViewControllerUIStageConnectedAndPaired animate:NO completion:nil];
    });
}

- (void)deviceDidDisconnect
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self showDefaultDisConnectStatus];
    });
}

@end
