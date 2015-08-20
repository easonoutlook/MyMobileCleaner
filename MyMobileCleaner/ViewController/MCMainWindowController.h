//
//  MCMainWindowController.h
//  MyMobileCleaner
//
//  Created by GoKu on 8/20/15.
//  Copyright (c) 2015 GoKuStudio. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "MCDeviceController.h"
#import "MCStageViewController.h"

@interface MCMainWindowController : NSWindowController <NSWindowDelegate, MCStageViewControllerManager, MCDeviceControllerDelegate>

- (void)goToWork;

@end
