//
//  MCFlashRingView.m
//  MyMobileCleaner
//
//  Created by GoKu on 8/25/15.
//  Copyright (c) 2015 GoKuStudio. All rights reserved.
//

#import "MCFlashRingView.h"
#import <QuartzCore/QuartzCore.h>

@interface MCFlashRingView ()

@property (nonatomic, strong) CAShapeLayer *ringLayer;

@end

@implementation MCFlashRingView

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    
    // Drawing code here.
}

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setLayer:[[CALayer alloc] init]];
        [self setWantsLayer:YES];
    }

    return self;
}

- (void)setupRingWithColor:(NSColor *)color
{
    [self stopFlashRing];

    self.ringLayer = [CAShapeLayer layer];

    CGFloat radius = self.bounds.size.height/2 - 16;
    self.ringLayer.bounds = NSMakeRect(0, 0, radius * 2, radius * 2);
    self.ringLayer.position = CGPointMake(self.layer.frame.size.width/2, self.layer.frame.size.height/2);

    CGPathRef path = [self newCirclePathWithRadius:radius];
    self.ringLayer.path = path;
    CGPathRelease(path); path = NULL;

    self.ringLayer.lineWidth = 18;
    self.ringLayer.fillColor = [NSColor clearColor].CGColor;
    self.ringLayer.strokeColor = color.CGColor;

    [self.layer addSublayer:self.ringLayer];
}

- (void)stopFlashRing
{
    [self.ringLayer removeAllAnimations];
    [self.ringLayer removeFromSuperlayer];
}

- (void)startFlashRingWithColor:(NSColor *)color
{
    [self setupRingWithColor:color];

    CABasicAnimation *flashAnimation1 = [CABasicAnimation animationWithKeyPath:@"opacity"];
    flashAnimation1.fromValue = @(0);
    flashAnimation1.toValue = @(1);
    CABasicAnimation *flashAnimation2 = [CABasicAnimation animationWithKeyPath:@"lineWidth"];
    flashAnimation2.fromValue = @(18);
    flashAnimation2.toValue = @(36);

    CAAnimationGroup *flashAnimation = [CAAnimationGroup animation];
    flashAnimation.animations = @[flashAnimation1, flashAnimation2];
    flashAnimation.duration = 1;
    flashAnimation.autoreverses = YES;
    flashAnimation.repeatCount = HUGE_VAL;
    [self.ringLayer addAnimation:flashAnimation forKey:@"flash"];
}

#pragma mark - draw

- (CGPathRef)newCirclePathWithRadius:(CGFloat)radius
{
    NSBezierPath *path = [NSBezierPath bezierPathWithRoundedRect:CGRectMake(0, 0, 2.0 * radius, 2.0 * radius)
                                                         xRadius:radius
                                                         yRadius:radius];

    return [self copyQuartzPathFromNSBezierPath:path];
}

- (CGPathRef)copyQuartzPathFromNSBezierPath:(NSBezierPath *)bezierPath
{
    NSInteger i, numElements;

    // Need to begin a path here.
    CGPathRef           immutablePath = NULL;

    // Then draw the path elements.
    numElements = [bezierPath elementCount];
    if (numElements > 0) {
        CGMutablePathRef    path = CGPathCreateMutable();
        NSPoint             points[3];
        BOOL                didClosePath = YES;

        for (i = 0; i < numElements; i++) {
            switch ([bezierPath elementAtIndex:i associatedPoints:points]) {
                case NSMoveToBezierPathElement:
                    CGPathMoveToPoint(path, NULL, points[0].x, points[0].y);
                    break;

                case NSLineToBezierPathElement:
                    CGPathAddLineToPoint(path, NULL, points[0].x, points[0].y);
                    didClosePath = NO;
                    break;

                case NSCurveToBezierPathElement:
                    CGPathAddCurveToPoint(path, NULL, points[0].x, points[0].y,
                                          points[1].x, points[1].y,
                                          points[2].x, points[2].y);
                    didClosePath = NO;
                    break;

                case NSClosePathBezierPathElement:
                    CGPathCloseSubpath(path);
                    didClosePath = YES;
                    break;
            }
        }

        // Be sure the path is closed or Quartz may not do valid hit detection.
        if (!didClosePath) {
            CGPathCloseSubpath(path);
        }

        immutablePath = CGPathCreateCopy(path);
        CGPathRelease(path);
    }
    
    return immutablePath;
}

@end
