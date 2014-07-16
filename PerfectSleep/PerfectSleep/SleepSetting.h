//
//  SleepSetting.h
//  PerfectSleep
//
//  Created by RoyHPR on 8/4/14.
//  Copyright (c) 2014 Huang Purong. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SleepSetting : NSObject

@property(nonatomic, readwrite)BOOL isTimeOfTurningOutLight;
@property(nonatomic, readwrite)BOOL isTimeOfFinalAwakening;
@property(nonatomic, readwrite)BOOL isTimeOfLastBigMeal;
@property(nonatomic, readwrite)BOOL isActivityAtLateEvening;
@property(nonatomic, readwrite)BOOL isAlcoholAtLateEvening;
@property(nonatomic, readwrite)BOOL isMood;
@property(nonatomic, readwrite)BOOL isSelfReportedSleepQuality;

-(id)initWithIsTimeOfTurningOutLight:(BOOL)isTimeOfTuringOutLight IsTimeOfFinalAwakening:(BOOL)isTimeOfFinalAwakening IsTimeOfLastBigMeal:(BOOL)isTimeOfLastBigMeal IsActivityAtLateEvening:(BOOL)isActivityAtLateEvening IsAlcoholAtLateEvening:(BOOL)isAlcoholAtLateEvening IsMood:(BOOL)isMood IsSelfReportedSleepQuality:(BOOL)isSelfReportedSleepQuality;
@end
