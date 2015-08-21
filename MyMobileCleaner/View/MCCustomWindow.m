//
//  MCCustomWindow.m
//  MyMobileCleaner
//
//  Created by GoKu on 8/21/15.
//  Copyright (c) 2015 GoKuStudio. All rights reserved.
//

#import "MCCustomWindow.h"

@implementation MCCustomWindow

- (instancetype)initWithContentRect:(NSRect)contentRect styleMask:(NSUInteger)aStyle backing:(NSBackingStoreType)bufferingType defer:(BOOL)flag
{
    self = [super initWithContentRect:contentRect styleMask:aStyle backing:bufferingType defer:flag];

    if (self) {
        [self setOpaque:NO];
        [self setBackgroundColor:[NSColor clearColor]];
        [self setMovableByWindowBackground:YES];
        [self setHasShadow:YES];
    }

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(theWindowDidDeminiaturize:) name:NSWindowDidDeminiaturizeNotification object:self];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(theWindowWillClose:) name:NSWindowWillCloseNotification object:self];

    return self;
}

- (void)theWindowWillClose:(NSNotification *)notification
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NSWindowDidDeminiaturizeNotification object:self];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NSWindowWillCloseNotification object:self];
}

- (void)theWindowDidDeminiaturize:(NSNotification *)notification
{
    [self invalidateShadow];
}

- (BOOL)canBecomeKeyWindow
{
    return YES;
}

- (BOOL)canBecomeMainWindow
{
    return YES;
}

@end
