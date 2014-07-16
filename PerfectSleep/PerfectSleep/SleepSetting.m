//
//  SleepSetting.m
//  PerfectSleep
//
//  Created by RoyHPR on 8/4/14.
//  Copyright (c) 2014 Huang Purong. All rights reserved.
//

#import "SleepSetting.h"

@implementation SleepSetting

-(id)initWithIsTimeOfTurningOutLight:(BOOL)isTimeOfTuringOutLight IsTimeOfFinalAwakening:(BOOL)isTimeOfFinalAwakening IsTimeOfLastBigMeal:(BOOL)isTimeOfLastBigMeal IsActivityAtLateEvening:(BOOL)isActivityAtLateEvening IsAlcoholAtLateEvening:(BOOL)isAlcoholAtLateEvening IsMood:(BOOL)isMood IsSelfReportedSleepQuality:(BOOL)isSelfReportedSleepQuality
{
    if(self == [super init])
    {
        _isTimeOfTurningOutLight = isTimeOfTuringOutLight;
        _isTimeOfFinalAwakening = isTimeOfFinalAwakening;
        _isTimeOfLastBigMeal = isTimeOfLastBigMeal;
        _isActivityAtLateEvening = isActivityAtLateEvening;
        _isAlcoholAtLateEvening = isAlcoholAtLateEvening;
        _isMood = isMood;
        _isSelfReportedSleepQuality = isSelfReportedSleepQuality;
    }
    return self;
}

@end
