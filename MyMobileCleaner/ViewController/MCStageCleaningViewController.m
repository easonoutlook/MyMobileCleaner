//
//  MCStageCleaningViewController.m
//  MyMobileCleaner
//
//  Created by GoKu on 8/21/15.
//  Copyright (c) 2015 GoKuStudio. All rights reserved.
//

#import "MCStageCleaningViewController.h"
#import "MCMainWindowController.h"

@interface MCStageCleaningViewController ()

@property (weak) IBOutlet MCColorBackgroundView *colorBackground;
@property (weak) IBOutlet NSProgressIndicator *progress;
@property (weak) IBOutlet NSButton *btnError;
@property (weak) IBOutlet NSTextField *labelError;

@property (nonatomic, strong) NSArray *crashLogs;

@end

@implementation MCStageCleaningViewController

- (instancetype)initWithManager:(id<MCStageViewControllerManager>)manager
{
    self = [super initWithNibName:@"MCStageCleaningViewController" bundle:nil];
    if (self) {
        self.manager = manager;
    }
    return self;
}

- (void)stageViewDidAppear
{
    [self.progress startAnimation:self];
    self.btnError.hidden = YES;
    self.labelError.hidden = YES;
    
    // clean crash log
    self.crashLogs = ((MCMainWindowController *)(self.manager)).myCrashLogs;

    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        [[MCDeviceController sharedInstance].selectedConnectedDevice cleanCrashLog:self.crashLogs
                                                                      successBlock:^{
                                                                          dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(kDefaultWaitDuration * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                                                                              [self.progress stopAnimation:self];
                                                                              [self.manager gotoNextStage];
                                                                          });

                                                                      } updateBlock:^(NSUInteger currentItemIndex) {
                                                                          float progressValue = 100.0*(currentItemIndex+1)/self.crashLogs.count;
                                                                          DDLogDebug(@"%.1f%% -> cleaned crash log: %@", progressValue, ((MCDeviceCrashLogItem *)(self.crashLogs[currentItemIndex])).path);

                                                                      } failureBlock:^{
                                                                          DDLogError(@"=> failed to clean all scanned crash log");

                                                                          dispatch_async(dispatch_get_main_queue(), ^{
                                                                              [self.progress stopAnimation:self];
                                                                              self.btnError.hidden = NO;
                                                                              self.labelError.hidden = NO;
                                                                          });
                                                                      }];
    });
}

- (IBAction)clickBtnError:(id)sender {
    [self.view.window close];
}

@end
