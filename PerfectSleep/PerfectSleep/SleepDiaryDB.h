//
//  SleepDiaryDB.h
//  PerfectSleep
//
//  Created by RoyHPR on 4/4/14.
//  Copyright (c) 2014 Huang Purong. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <sqlite3.h>
#import "SleepSetting.h"
#import "LoggedSleep.h"

@interface SleepDiaryDB : NSObject
{
    sqlite3* _prePopulatedDB;
}

+(SleepDiaryDB*)database;

-(LoggedSleep*)currentLoggedSleepOnDate:(NSDate*)date;
-(NSArray*)loggedSleepListFromDate:(NSDate*)startDate ToDate:(NSDate*)endDate;
-(void)updateLoggedSleepOnDate:(NSDate*)date WithSleep:(LoggedSleep*)sleep;
-(void)insertLoggedSleepWith:(LoggedSleep*)sleep;
-(void)removeLoggedSleepOnDate:(NSDate*)date;

-(SleepSetting*)currentSleepSetting;
-(void)updateSleepSettingWithSetting:(SleepSetting*)setting;

@end
