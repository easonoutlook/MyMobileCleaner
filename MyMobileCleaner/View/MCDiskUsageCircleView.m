//
//  MCDiskUsageCircleView.m
//  MyMobileCleaner
//
//  Created by GoKu on 8/24/15.
//  Copyright (c) 2015 GoKuStudio. All rights reserved.
//

#import "MCDiskUsageCircleView.h"
#import <QuartzCore/QuartzCore.h>
#import "SoundManager.h"

static CGFloat barSpace = 0.03;

@interface MCDiskUsageCircleView ()

@property (nonatomic, assign) BOOL clockWise;

@property (nonatomic, strong) NSMutableArray *barLayers;

@property (nonatomic, copy) void (^updateWithAnimation)(NSUInteger dataIndex);
@property (nonatomic, copy) void (^updateWithCompletion)(MCDiskUsageCircleView *);

@end

@implementation MCDiskUsageCircleView

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _clockWise = NO;
        _barLayers = [[NSMutableArray alloc] init];

        [self setLayer:[[CALayer alloc] init]];
        [self setWantsLayer:YES];
    }

    return self;
}

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];

    // Drawing code here.
}

- (void)unloadData
{
    if (self.barLayers.count > 0) {

        for (CALayer *l in self.barLayers) {
            [l removeFromSuperlayer];
        }

        [self.barLayers removeAllObjects];
    }
}

- (void)updateWithData:(NSArray *)data
                 color:(NSArray *)color
             animation:(void(^)(NSUInteger dataIndex))animation
            completion:(void(^)(MCDiskUsageCircleView *))completion
{
    [self unloadData];
    self.updateWithAnimation = animation;
    self.updateWithCompletion = completion;

    NSInteger sum = 0;
    for (NSNumber *number in data) {
        sum += number.integerValue;
    }

    CGFloat radius = self.bounds.size.height/2 - 8;

    CGFloat fromValue = self.clockWise ? 1.0 : 0.0;
    for (NSUInteger i = 0; i < data.count; i++) {
        NSNumber *current = data[i];
        if (current.integerValue <= 0) {
            continue;
        }

        NSInteger currentValue = current.integerValue;

        CAShapeLayer *rainbowLayer = [CAShapeLayer layer];
        rainbowLayer.bounds = NSMakeRect(0, 0, radius * 2, radius * 2);
        rainbowLayer.position = CGPointMake(self.layer.frame.size.width/2, self.layer.frame.size.height/2);

        CGPathRef path = [self newCirclePathWithRadius:radius];
        rainbowLayer.path = path;
        rainbowLayer.lineCap = kCALineCapRound;
        CGPathRelease(path); path = NULL;

        rainbowLayer.fillColor = [NSColor clearColor].CGColor;
        rainbowLayer.strokeColor = color[i] ? ((NSColor *)(color[i])).CGColor : [NSColor whiteColor].CGColor;
        if (self.clockWise) {
            rainbowLayer.strokeEnd = fromValue;
            rainbowLayer.strokeStart = fromValue - (1.0 - 3*barSpace) * currentValue / sum;
        } else {
            rainbowLayer.strokeStart = fromValue;
            rainbowLayer.strokeEnd = (1.0 - 3*barSpace) * currentValue / sum + fromValue;
        }

        rainbowLayer.lineWidth = 8;

        [self.barLayers addObject:rainbowLayer];
        [self.layer addSublayer:rainbowLayer];

        fromValue = self.clockWise ? (rainbowLayer.strokeStart - barSpace) : (rainbowLayer.strokeEnd + barSpace);
    }

    [self popAnimation];

    if (self.updateWithCompletion) {
        self.updateWithCompletion(self);
    }
}

- (void)popAnimation
{
    CGFloat delay = 1;

    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delay * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [[Sound soundNamed:@"bubbles.mp3"] play];
    });

    for (NSUInteger i = 0; i < self.barLayers.count; ++i) {
        CAShapeLayer *rainbowLayer = self.barLayers[i];

        CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"lineWidth"];
        animation.duration = 0.2;
        animation.toValue = @(16);
//        animation.removedOnCompletion = NO;
        animation.autoreverses = YES;
        animation.fillMode = kCAFillModeForwards;
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)((delay+i*0.12) * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [rainbowLayer addAnimation:animation forKey:@"pop"];
            if (self.updateWithAnimation) {
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
                    self.updateWithAnimation(i);
                });
            }
        });
    }
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
