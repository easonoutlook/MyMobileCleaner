//
//  AppDelegate.m
//  MyMobileCleaner
//
//  Created by GoKu on 8/18/15.
//  Copyright (c) 2015 GoKuStudio. All rights reserved.
//

#import "AppDelegate.h"
#import "MCMainWindowController.h"

@interface AppDelegate ()

@property (nonatomic, strong) MCMainWindowController *mainWindowController;

@end

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    // Insert code here to initialize your application

    self.mainWindowController = [[MCMainWindowController alloc] init];
    self.mainWindowController.window.canHide = YES;

    [self.mainWindowController goToWork];

    // delay to show main window, so there's no flash because of "no connection" -> "connected".
    // remember to uncheck "Visible At Launch" in main window's xib
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self.mainWindowController showWindow:self];
        [self.mainWindowController.window makeKeyAndOrderFront:self];
        [[NSApplication sharedApplication] activateIgnoringOtherApps:YES];
    });
}

- (void)applicationWillTerminate:(NSNotification *)aNotification {
    // Insert code here to tear down your application
}

@end
