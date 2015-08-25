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
#import "MCStageScanDonePopoverCellView.h"

@interface MCStageScanDoneViewController ()

@property (weak) IBOutlet MCColorBackgroundView *colorBackground;
@property (weak) IBOutlet NSButton *btnClean;
@property (weak) IBOutlet NSTextField *labelSize;
@property (weak) IBOutlet MCFlashRingView *flashRing;

@property (strong) IBOutlet NSPopover *infoPopover;
@property (nonatomic, strong) NSMutableArray *allFilesName;

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
    self.allFilesName = [NSMutableArray array];
    for (NSString *path in allFiles) {
        [self.allFilesName addObject:path.lastPathComponent];
    }

    NSByteCountFormatter *formatter = [[NSByteCountFormatter alloc] init];
    formatter.countStyle = NSByteCountFormatterCountStyleBinary;
    formatter.adaptive = NO;
    formatter.zeroPadsFractionDigits = YES;

    NSLog(@"100%% => all scanned crash log: %@", [formatter stringFromByteCount:totalSize]);
    NSLog(@"100%% => all scanned crash log: %@", self.allFilesName);

    self.labelSize.stringValue = [NSString stringWithFormat:((self.allFilesName.count > 1) ? NSLocalizedStringFromTable(@"scan.done.crash.log.info.many", @"MyMobileCleaner", @"scan.done") : NSLocalizedStringFromTable(@"scan.done.crash.log.info.single", @"MyMobileCleaner", @"scan.done")),
                                  @(self.allFilesName.count),
                                  [formatter stringFromByteCount:totalSize]];
}

- (IBAction)clickInfo:(id)sender {
    NSButton *infoButton = sender;
    [self.infoPopover showRelativeToRect:infoButton.bounds
                                  ofView:infoButton
                           preferredEdge:NSMaxYEdge];
}


- (IBAction)clickBtnClean:(id)sender {
    [self.flashRing stopFlashRing];
    [self.manager gotoNextStage];
}

#pragma mark - NSTableViewDelegate

- (NSInteger)numberOfRowsInTableView:(NSTableView *)aTableView
{
    return self.allFilesName.count;
}

- (NSView *)tableView:(NSTableView *)tableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row
{
    MCStageScanDonePopoverCellView *cellView = [tableView makeViewWithIdentifier:@"MCStageScanDonePopoverCellView" owner:self];
    cellView.name.stringValue = self.allFilesName[row];

    return cellView;
}

@end
