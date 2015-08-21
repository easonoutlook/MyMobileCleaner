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

@property (nonatomic, strong) IBInspectable NSColor *cbvBackgroundColor;
@property (nonatomic, strong) IBInspectable NSColor *cbvBorderColor;
@property (nonatomic, assign) IBInspectable CGFloat cbvBorderWidth;
@property (nonatomic, assign) IBInspectable CGFloat cbvCornerRadius;

@end
