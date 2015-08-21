//
//  MCColorBackgroundView.m
//  MyMobileCleaner
//
//  Created by GoKu on 8/21/15.
//  Copyright (c) 2015 GoKuStudio. All rights reserved.
//

#import "MCColorBackgroundView.h"

#define kDefaultBackgroundColor     [NSColor whiteColor]
#define kDefaultBorderColor         [NSColor whiteColor]

@implementation MCColorBackgroundView

- (void)drawRect:(NSRect)dirtyRect {
    [NSGraphicsContext saveGraphicsState];

    NSBezierPath *path = [NSBezierPath bezierPathWithRoundedRect:dirtyRect
                                                         xRadius:self.cbvCornerRadius
                                                         yRadius:self.cbvCornerRadius];
    path.lineWidth = self.cbvBorderWidth;

    NSColor *backgroundColor = self.cbvBackgroundColor ? : kDefaultBackgroundColor;
    NSColor *borderColor = self.cbvBorderColor ? : kDefaultBorderColor;

    [backgroundColor setFill];
    [borderColor setStroke];

    [path fill];
    [path stroke];

    [NSGraphicsContext restoreGraphicsState];
}

@end
