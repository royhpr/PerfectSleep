//
//  LoggedSleep.h
//  PerfectSleep
//
//  Created by RoyHPR on 8/4/14.
//  Copyright (c) 2014 Huang Purong. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LoggedSleep : NSObject

@property(nonatomic, readwrite)NSDate* date;
@property(nonatomic, readwrite)NSDate* bedTime;
@property(nonatomic, readwrite)NSDate* timeOfTurningOutTheLight;
@property(nonatomic, readwrite)NSString* durationOfFallingAsleep;
@property(nonatomic, readwrite)NSString* numberOfWakeup;
@property(nonatomic, readwrite)NSString* totalDurationOfWakeup;
@property(nonatomic, readwrite)NSDate* timeOfGettingUp;
@property(nonatomic, readwrite)NSDate* timeOfEatingLastBigMeal;
@property(nonatomic, readwrite)NSString* activityInLateEvening;
@property(nonatomic, readwrite)NSString* alcoholInLateEvening;
@property(nonatomic, readwrite)NSString* mood;
@property(nonatomic, readwrite)NSString* selfReportedSleepQuality;
@property(nonatomic, readwrite)NSDate* timeOfFinalAwakening;


-(id)initWithDate:(NSDate*)date BedTime:(NSDate*)bedTime TimeOfTurningOutTheLight:(NSDate*)timeOfTurningOutTheLight DurationOfFallingAsleep:(NSString*)durationOfFallingAsleep NumberOfWakeup:(NSString*)numberOfWakeup TotalDurationOfWakeup:(NSString*)totalDurationOfWakeup TimeOfFinalAwakening:(NSDate*)timeOfFinalAwakening TimeOfGettingUp:(NSDate*)timeOfGettingUp TimeOfEatingLastBigMeal:(NSDate*)timeOfEatingLastBigMeal ActivityInLateEvening:(NSString*)activityInLateEvening AlcoholInLateEvening:(NSString*)alcoholInLateEvening Mood:(NSString*)mood SelfReportedSleepQuality:(NSString*)selfReportedSleepQuality;
@end
