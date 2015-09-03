//
//  MCConfig.m
//  MyMobileCleaner
//
//  Created by GoKu on 9/3/15.
//  Copyright (c) 2015 GoKuStudio. All rights reserved.
//

#import "MCConfig.h"

@implementation MCConfig

+ (BOOL)isSoundEffectDisabled
{
    return [[NSUserDefaults standardUserDefaults] boolForKey:@"soundEffectDisabled"];
}

+ (void)setSoundEffectDisabled:(BOOL)disabled
{
    [[NSUserDefaults standardUserDefaults] setBool:disabled forKey:@"soundEffectDisabled"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

@end
