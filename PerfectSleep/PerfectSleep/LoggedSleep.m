//
//  LoggedSleep.m
//  PerfectSleep
//
//  Created by RoyHPR on 8/4/14.
//  Copyright (c) 2014 Huang Purong. All rights reserved.
//

#import "LoggedSleep.h"

@implementation LoggedSleep

-(id)initWithDate:(NSDate*)date BedTime:(NSDate*)bedTime TimeOfTurningOutTheLight:(NSDate*)timeOfTurningOutTheLight DurationOfFallingAsleep:(NSString*)durationOfFallingAsleep NumberOfWakeup:(NSString*)numberOfWakeup TotalDurationOfWakeup:(NSString*)totalDurationOfWakeup TimeOfFinalAwakening:(NSDate*)timeOfFinalAwakening TimeOfGettingUp:(NSDate*)timeOfGettingUp TimeOfEatingLastBigMeal:(NSDate*)timeOfEatingLastBigMeal ActivityInLateEvening:(NSString*)activityInLateEvening AlcoholInLateEvening:(NSString*)alcoholInLateEvening Mood:(NSString*)mood SelfReportedSleepQuality:(NSString*)selfReportedSleepQuality
{
    if(self=[super init])
    {
        _date = date;
        _bedTime = bedTime;
        _timeOfTurningOutTheLight = timeOfTurningOutTheLight;
        _durationOfFallingAsleep = durationOfFallingAsleep;
        _numberOfWakeup = numberOfWakeup;
        _totalDurationOfWakeup = totalDurationOfWakeup;
        _timeOfFinalAwakening = timeOfFinalAwakening;
        _timeOfGettingUp = timeOfGettingUp;
        _timeOfEatingLastBigMeal = timeOfEatingLastBigMeal;
        _activityInLateEvening = activityInLateEvening;
        _alcoholInLateEvening = alcoholInLateEvening;
        _mood = mood;
        _selfReportedSleepQuality = selfReportedSleepQuality;
    }
    return self;
}

@end
