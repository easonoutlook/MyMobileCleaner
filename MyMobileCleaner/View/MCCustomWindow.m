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
    // force window to redraw shadow, or else there's no shadow after window comes back from dock.
    [self invalidateShadow];
}

#pragma mark - must override

- (BOOL)canBecomeKeyWindow
{
    return YES;
}

- (BOOL)canBecomeMainWindow
{
    return YES;
}

- (BOOL)acceptsFirstResponder
{
    return YES;
}

- (void)performClose:(id)sender
{
    [self close];
}

- (void)performMiniaturize:(id)sender
{
    [self miniaturize:sender];
}

- (void)performZoom:(id)sender
{
    [self zoom:sender];
}

@end
