//
//  MCStageScanDoneViewController.m
//  MyMobileCleaner
//
//  Created by GoKu on 8/21/15.
//  Copyright (c) 2015 GoKuStudio. All rights reserved.
//

#import "MCStageScanDoneViewController.h"
#import "MCMainWindowController.h"
#import "MCFlashRingView.h"

@interface MCStageScanDoneViewController ()

@property (weak) IBOutlet MCColorBackgroundView *colorBackground;
@property (weak) IBOutlet NSButton *btnClean;
@property (weak) IBOutlet NSTextField *labelSize;
@property (weak) IBOutlet MCFlashRingView *flashRing;

@end

@implementation MCStageScanDoneViewController

- (instancetype)initWithManager:(id<MCStageViewControllerManager>)manager
{
    self = [super initWithNibName:@"MCStageScanDoneViewController" bundle:nil];
    if (self) {
        self.manager = manager;
    }
    return self;
}

- (void)stageViewDidAppear
{
    [self.flashRing startFlashRingWithColor:[NSColor greenColor]];

    NSUInteger totalSize = 0;
    NSMutableArray *allFiles = [NSMutableArray array];
    for (MCDeviceCrashLogItem *item in ((MCMainWindowController *)(self.manager)).myCrashLogs) {
        totalSize += [item.totalSize unsignedIntegerValue];
        [allFiles addObjectsFromArray:item.allFiles];
    }
    NSMutableArray *allFilesName = [NSMutableArray array];
    for (NSString *path in allFiles) {
        [allFilesName addObject:path.lastPathComponent];
    }

    NSByteCountFormatter *formatter = [[NSByteCountFormatter alloc] init];
    formatter.countStyle = NSByteCountFormatterCountStyleBinary;
    formatter.adaptive = NO;
    formatter.zeroPadsFractionDigits = YES;

    NSLog(@"100%% => all scanned crash log: %@", [formatter stringFromByteCount:totalSize]);
    NSLog(@"100%% => all scanned crash log: %@", allFilesName);

    self.labelSize.stringValue = [NSString stringWithFormat:((allFilesName.count > 1) ? NSLocalizedStringFromTable(@"scan.done.crash.log.info.many", @"MyMobileCleaner", @"scan.done") : NSLocalizedStringFromTable(@"scan.done.crash.log.info.single", @"MyMobileCleaner", @"scan.done")),
                                  @(allFilesName.count),
                                  [formatter stringFromByteCount:totalSize]];
}

- (IBAction)clickBtnClean:(id)sender {
    [self.flashRing stopFlashRing];
    [self.manager gotoNextStage];
}

@end
