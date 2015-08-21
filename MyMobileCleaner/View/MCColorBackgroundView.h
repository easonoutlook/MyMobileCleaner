//
//  MCColorBackgroundView.h
//  MyMobileCleaner
//
//  Created by GoKu on 8/21/15.
//  Copyright (c) 2015 GoKuStudio. All rights reserved.
//

#import <Cocoa/Cocoa.h>

IB_DESIGNABLE
@interface MCColorBackgroundView : NSView

@property (nonatomic, strong) IBInspectable NSColor *sdBackgroundColor;
@property (nonatomic, strong) IBInspectable NSColor *sdBorderColor;
@property (nonatomic, assign) IBInspectable CGFloat sdBorderWidth;
@property (nonatomic, assign) IBInspectable CGFloat sdCornerRadius;

@end
