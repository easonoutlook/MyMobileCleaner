//
//  MCCustomWindowButtonBar.m
//  MyMobileCleaner
//
//  Created by GoKu on 8/21/15.
//  Copyright (c) 2015 GoKuStudio. All rights reserved.
//

#import "MCCustomWindowButtonBar.h"

@interface MCCustomWindowButtonBar ()

@property (nonatomic, weak) NSButton *closeButton;
@property (nonatomic, weak) NSButton *miniButton;
@property (nonatomic, weak) NSButton *resizeButton;

@property (nonatomic, strong) NSColor *bgColor;

@property (nonatomic, assign) BOOL mouseInside;
@property (nonatomic, strong) NSTrackingArea * trackArea;

@end

@implementation MCCustomWindowButtonBar

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NSWindowDidResizeNotification object:self];
}

- (void)drawRect:(NSRect)dirtyRect {
    [NSGraphicsContext saveGraphicsState];

    NSBezierPath *path = [NSBezierPath bezierPathWithRect:dirtyRect];
    [self.bgColor setFill];
    [path fill];

    [NSGraphicsContext restoreGraphicsState];
}

- (instancetype)initWithFrame:(NSRect)frameRect
{
    self = [super initWithFrame:frameRect];
    if (self) {
        self.bgColor = [NSColor clearColor];

        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(parentWindowDidResize:) name:NSWindowDidResizeNotification object:self.window];
    }
    return self;
}

- (void)parentWindowDidResize:(NSNotification *)notification
{
    [self mouseExited:nil];
}

- (void)refreshButtonsWithBackgroundColor:(NSColor *)color
{
    self.bgColor = color ? : [NSColor clearColor];
    
    [self.closeButton removeFromSuperviewWithoutNeedingDisplay];
    [self.miniButton removeFromSuperviewWithoutNeedingDisplay];
    [self.resizeButton removeFromSuperviewWithoutNeedingDisplay];

    self.closeButton = [NSWindow standardWindowButton:NSWindowCloseButton forStyleMask:self.window.styleMask];
    self.miniButton = [NSWindow standardWindowButton:NSWindowMiniaturizeButton forStyleMask:self.window.styleMask];
    self.resizeButton = [NSWindow standardWindowButton:NSWindowZoomButton forStyleMask:self.window.styleMask];

    [self.closeButton setFrameOrigin:NSMakePoint(0, self.bounds.origin.y+self.bounds.size.height/2-self.closeButton.bounds.size.height/2)];
    [self.miniButton setFrameOrigin:NSMakePoint(20, self.bounds.origin.y+self.bounds.size.height/2-self.closeButton.bounds.size.height/2)];
    [self.resizeButton setFrameOrigin:NSMakePoint(40, self.bounds.origin.y+self.bounds.size.height/2-self.closeButton.bounds.size.height/2)];

    [self addSubview:self.closeButton];
    [self addSubview:self.miniButton];
    [self addSubview:self.resizeButton];

    self.closeButton.target = self.window;
    self.miniButton.target = self.window;
    self.resizeButton.target = self.window;

    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self setNeedsDisplayForStandardWindowButtons];
    });
}

- (void)updateTrackingAreas {
    if (self.trackArea) {
        [self removeTrackingArea:self.trackArea];
    }

    self.trackArea = [[NSTrackingArea alloc] initWithRect:self.bounds
                                                  options:NSTrackingMouseEnteredAndExited | NSTrackingActiveAlways
                                                    owner:self
                                                 userInfo:nil];
    [self addTrackingArea:self.trackArea];

    [super updateTrackingAreas];
}

- (void)mouseEntered:(NSEvent *)theEvent
{
    [super mouseEntered:theEvent];

    self.mouseInside = YES;
    [self setNeedsDisplayForStandardWindowButtons];
}

- (void)mouseExited:(NSEvent *)theEvent
{
    [super mouseExited:theEvent];

    self.mouseInside = NO;
    [self setNeedsDisplayForStandardWindowButtons];
}

- (BOOL)_mouseInGroup:(NSButton *)button
{
    return self.mouseInside;
}

// !!! remember to override NSWindow to implement canBecomeKeyWindow and canBecomeMainWindow to return YES,
// !!! or else the 3 widget window buttons will not show color while mouseExited, because the window can not get focus.

- (void)setNeedsDisplayForStandardWindowButtons
{
    [self.closeButton setNeedsDisplay:YES];
    [self.miniButton setNeedsDisplay:YES];
    [self.resizeButton setNeedsDisplay:YES];
}

@end
