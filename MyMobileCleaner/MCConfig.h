//
//  MCConfig.h
//  MyMobileCleaner
//
//  Created by GoKu on 9/3/15.
//  Copyright (c) 2015 GoKuStudio. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MCConfig : NSObject

+ (BOOL)isSoundEffectDisabled;
+ (void)setSoundEffectDisabled:(BOOL)disabled;

@end
