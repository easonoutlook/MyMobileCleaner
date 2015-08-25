//
//  MCFlashRingView.h
//  MyMobileCleaner
//
//  Created by GoKu on 8/25/15.
//  Copyright (c) 2015 GoKuStudio. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface MCFlashRingView : NSView

- (void)stopFlashRing;
- (void)startFlashRingWithColor:(NSColor *)color;

@end
