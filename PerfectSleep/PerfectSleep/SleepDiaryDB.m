//
//  SleepDiaryDB.m
//  PerfectSleep
//
//  Created by RoyHPR on 4/4/14.
//  Copyright (c) 2014 Huang Purong. All rights reserved.
//

#import "SleepDiaryDB.h"

@implementation SleepDiaryDB

- (id)init
{
    if ((self = [super init]))
    {
    }
    return self;
}

-(void)openDB
{
    if (sqlite3_open([[self documentDirectoryDatabaseLocation]UTF8String], &_prePopulatedDB) != SQLITE_OK)
    {
        NSLog(@"Failed to open database!");
    }
}

-(NSString*)documentDirectoryDatabaseLocation
{
    NSArray* documentDirectoryFolderLocation = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    
    return [[documentDirectoryFolderLocation objectAtIndex:0]stringByAppendingPathComponent:@"PerfectSleepDB.sqlite"];
}

+(SleepDiaryDB*)database
{
    static SleepDiaryDB* _database;
    if(_database == nil)
    {
        _database = [[SleepDiaryDB alloc]init];
    }
    return _database;
}

#pragma mark - All about logged sleep
-(LoggedSleep*)currentLoggedSleepOnDate:(NSDate*)sleepDate
{
    LoggedSleep* currentSleep;
    NSString* query = @"SELECT * FROM Sleep WHERE Date=?";
    sqlite3_stmt* statement;
    [self openDB];
    if (sqlite3_prepare_v2(_prePopulatedDB, [query UTF8String], -1, &statement, nil) == SQLITE_OK)
    {
        NSDateFormatter* dateFormat = [[NSDateFormatter alloc] init];
        [dateFormat setDateFormat:@"MMMM dd, yyyy"];
        NSString* sleepDateString = [dateFormat stringFromDate:sleepDate];
        
        sqlite3_bind_text( statement, 1,[sleepDateString UTF8String], -1, SQLITE_TRANSIENT);
        
        while (sqlite3_step(statement) == SQLITE_ROW)
        {
            char* date = (char *) sqlite3_column_text(statement, 0);
            char* bedTime = (char *) sqlite3_column_text(statement, 1);
            char* timeOfTurningOutTheLight = (char*)sqlite3_column_text(statement, 2);
            char* durationOfFallingAsleep = (char *) sqlite3_column_text(statement, 3);
            char* numberOfWakeup = (char *) sqlite3_column_text(statement, 4);
            char* totalDurationOfWakeup = (char *) sqlite3_column_text(statement, 5);
            char* timeOfGettingUp = (char *) sqlite3_column_text(statement, 6);
            char* timeOfEatingLastBigMeal = (char *)sqlite3_column_text(statement, 7);
            char* activityInLateEvening = (char*)sqlite3_column_text(statement, 8);
            char* alcoholInLateEvening = (char*)sqlite3_column_text(statement, 9);
            char* mood = (char*)sqlite3_column_text(statement, 10);
            char* selfReportedSleepQuality = (char*)sqlite3_column_text(statement, 11);
            char* timeOfFinalAwakening = (char*)sqlite3_column_text(statement, 12);
            
            NSDateFormatter* dateFormat = [[NSDateFormatter alloc] init];
            [dateFormat setDateFormat:@"MMMM dd, yyyy"];
            NSDateFormatter* timeFormat = [[NSDateFormatter alloc] init];
            [timeFormat setDateFormat:@"MMMM dd, yyyy hh:mm a"];
            NSDate* newDate = [dateFormat dateFromString:[NSString stringWithUTF8String:date]];
            NSDate* newBedTime = [timeFormat dateFromString:[NSString stringWithUTF8String:bedTime]];
            
            NSDate* newTimeOfTurnOutTheLight;
            if(timeOfTurningOutTheLight!=nil)
                newTimeOfTurnOutTheLight = [timeFormat dateFromString:[NSString stringWithUTF8String:timeOfTurningOutTheLight]];
            
            NSString* newDurationOfFallingAsleep = [[NSString alloc] initWithUTF8String:durationOfFallingAsleep];
            NSString* newNumberOfWakeup = [[NSString alloc] initWithUTF8String:numberOfWakeup];
            NSString* newTotalDurationOfWakeup = [[NSString alloc] initWithUTF8String:totalDurationOfWakeup];
            NSDate* newTimeOfGettingUp = [timeFormat dateFromString:[NSString stringWithUTF8String:timeOfGettingUp]];
            
            NSDate* newTimeOfEatingLastBigMeal;
            if(timeOfEatingLastBigMeal != nil)
                newTimeOfEatingLastBigMeal = [timeFormat dateFromString:[NSString stringWithUTF8String:timeOfEatingLastBigMeal]];
            
            NSString* newActivityInLatedEvening;
            if(activityInLateEvening != nil)
                newActivityInLatedEvening = [[NSString alloc]initWithUTF8String:activityInLateEvening];
            
            NSString* newAlcoholInLateEvening;
            if(alcoholInLateEvening != nil)
                newAlcoholInLateEvening = [[NSString alloc]initWithUTF8String:alcoholInLateEvening];
            
            NSString* newMood;
            if(mood != nil)
                newMood = [[NSString alloc]initWithUTF8String:mood];
            
            NSString* newSelfReportedSleepQuality;
            if(selfReportedSleepQuality != nil)
                newSelfReportedSleepQuality = [[NSString alloc]initWithUTF8String:selfReportedSleepQuality];
            
            NSDate* newTimeOfFinalAwakening;
            if(timeOfFinalAwakening != nil)
                newTimeOfFinalAwakening = [timeFormat dateFromString:[NSString stringWithUTF8String:timeOfFinalAwakening]];
            
            currentSleep = [[LoggedSleep alloc]initWithDate:newDate BedTime:newBedTime TimeOfTurningOutTheLight:newTimeOfTurnOutTheLight DurationOfFallingAsleep:newDurationOfFallingAsleep NumberOfWakeup:newNumberOfWakeup TotalDurationOfWakeup:newTotalDurationOfWakeup TimeOfFinalAwakening:newTimeOfFinalAwakening TimeOfGettingUp:newTimeOfGettingUp TimeOfEatingLastBigMeal:newTimeOfEatingLastBigMeal ActivityInLateEvening:newActivityInLatedEvening AlcoholInLateEvening:newAlcoholInLateEvening Mood:newMood SelfReportedSleepQuality:newSelfReportedSleepQuality];
        }
        sqlite3_finalize(statement);
        sqlite3_close(_prePopulatedDB);
    }
    return currentSleep;
}

-(NSArray*)loggedSleepListFromDate:(NSDate*)startDate ToDate:(NSDate*)endDate
{
    NSMutableArray* loggedSleepList = [[NSMutableArray alloc]init];
    NSString* query = @"SELECT * FROM Sleep WHERE Date BETWEEN ? AND ? ORDER BY Date";
    sqlite3_stmt* statement;
    [self openDB];
    if (sqlite3_prepare_v2(_prePopulatedDB, [query UTF8String], -1, &statement, nil) == SQLITE_OK)
    {
        NSDateFormatter* dateFormat = [[NSDateFormatter alloc] init];
        [dateFormat setDateFormat:@"MMMM dd, yyyy"];
        NSString* startDateString = [dateFormat stringFromDate:startDate];
        NSString* endDateString = [dateFormat stringFromDate:endDate];
        
        sqlite3_bind_text( statement, 1,[startDateString UTF8String], -1, SQLITE_TRANSIENT);
        sqlite3_bind_text( statement, 2,[endDateString UTF8String], -1, SQLITE_TRANSIENT);
        
        while (sqlite3_step(statement) == SQLITE_ROW)
        {
            char* date = (char *) sqlite3_column_text(statement, 0);
            char* bedTime = (char *) sqlite3_column_text(statement, 1);
            char* timeOfTurningOutTheLight = (char*)sqlite3_column_text(statement, 2);
            char* durationOfFallingAsleep = (char *) sqlite3_column_text(statement, 3);
            char* numberOfWakeup = (char *) sqlite3_column_text(statement, 4);
            char* totalDurationOfWakeup = (char *) sqlite3_column_text(statement, 5);
            char* timeOfGettingUp = (char *) sqlite3_column_text(statement, 6);
            char* timeOfEatingLastBigMeal = (char *)sqlite3_column_text(statement, 7);
            char* activityInLateEvening = (char*)sqlite3_column_text(statement, 8);
            char* alcoholInLateEvening = (char*)sqlite3_column_text(statement, 9);
            char* mood = (char*)sqlite3_column_text(statement, 10);
            char* selfReportedSleepQuality = (char*)sqlite3_column_text(statement, 11);
            char* timeOfFinalAwakening = (char*)sqlite3_column_text(statement, 12);
            
            NSDateFormatter* dateFormat = [[NSDateFormatter alloc] init];
            [dateFormat setDateFormat:@"MMMM dd, yyyy"];
            NSDateFormatter* timeFormat = [[NSDateFormatter alloc] init];
            [timeFormat setDateFormat:@"MMMM dd, yyyy hh:mm a"];
            NSDate* newDate = [dateFormat dateFromString:[NSString stringWithUTF8String:date]];
            NSDate* newBedTime = [timeFormat dateFromString:[NSString stringWithUTF8String:bedTime]];
            
            NSDate* newTimeOfTurnOutTheLight;
            if(timeOfTurningOutTheLight!=nil)
                newTimeOfTurnOutTheLight = [timeFormat dateFromString:[NSString stringWithUTF8String:timeOfTurningOutTheLight]];
            
            NSString* newDurationOfFallingAsleep = [[NSString alloc] initWithUTF8String:durationOfFallingAsleep];
            NSString* newNumberOfWakeup = [[NSString alloc] initWithUTF8String:numberOfWakeup];
            NSString* newTotalDurationOfWakeup = [[NSString alloc] initWithUTF8String:totalDurationOfWakeup];
            NSDate* newTimeOfGettingUp = [timeFormat dateFromString:[NSString stringWithUTF8String:timeOfGettingUp]];
            
            NSDate* newTimeOfEatingLastBigMeal;
            if(timeOfEatingLastBigMeal != nil)
                newTimeOfEatingLastBigMeal = [timeFormat dateFromString:[NSString stringWithUTF8String:timeOfEatingLastBigMeal]];
            
            NSString* newActivityInLatedEvening;
            if(activityInLateEvening != nil)
                newActivityInLatedEvening = [[NSString alloc]initWithUTF8String:activityInLateEvening];
            
            NSString* newAlcoholInLateEvening;
            if(alcoholInLateEvening != nil)
                newAlcoholInLateEvening = [[NSString alloc]initWithUTF8String:alcoholInLateEvening];
            
            NSString* newMood;
            if(mood != nil)
                newMood = [[NSString alloc]initWithUTF8String:mood];
            
            NSString* newSelfReportedSleepQuality;
            if(selfReportedSleepQuality != nil)
                newSelfReportedSleepQuality = [[NSString alloc]initWithUTF8String:selfReportedSleepQuality];
            
            NSDate* newTimeOfFinalAwakening;
            if(timeOfFinalAwakening != nil)
                newTimeOfFinalAwakening = [timeFormat dateFromString:[NSString stringWithUTF8String:timeOfFinalAwakening]];
            
            LoggedSleep* sleep = [[LoggedSleep alloc]initWithDate:newDate BedTime:newBedTime TimeOfTurningOutTheLight:newTimeOfTurnOutTheLight DurationOfFallingAsleep:newDurationOfFallingAsleep NumberOfWakeup:newNumberOfWakeup TotalDurationOfWakeup:newTotalDurationOfWakeup TimeOfFinalAwakening:newTimeOfFinalAwakening TimeOfGettingUp:newTimeOfGettingUp TimeOfEatingLastBigMeal:newTimeOfEatingLastBigMeal ActivityInLateEvening:newActivityInLatedEvening AlcoholInLateEvening:newAlcoholInLateEvening Mood:newMood SelfReportedSleepQuality:newSelfReportedSleepQuality];
            [loggedSleepList addObject:sleep];
        }
        sqlite3_finalize(statement);
        sqlite3_close(_prePopulatedDB);
    }
    return loggedSleepList;
}

-(void)updateLoggedSleepOnDate:(NSDate*)date WithSleep:(LoggedSleep*)sleep
{
    NSString* query = @"UPDATE Sleep SET BedTime=?, TimeOfTurningOutTheLight=?, DurationOfFallingAsleep=?, NumberOfWakeup=?, TotalDurationOfWakeup=?, TimeOfGettingUp=?, TimeOfEatingLastBigMeal=?, ActivityInLateEvening=?, AlcoholInLateEvening=?, Mood=?, SelfReportedSleepQuality=?, TimeOfFinalAwakening=? WHERE Date=?";
    sqlite3_stmt* statement;
    
    NSDateFormatter* dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"MMMM dd, yyyy"];
    NSDateFormatter* timeFormat = [[NSDateFormatter alloc] init];
    [timeFormat setDateFormat:@"MMMM dd, yyyy hh:mm a"];
    
    [self openDB];
    if (sqlite3_prepare_v2(_prePopulatedDB, [query UTF8String], -1, &statement, nil) == SQLITE_OK)
    {
        NSString* date =[dateFormat stringFromDate:sleep.date];
        NSString* bedTime = [timeFormat stringFromDate:sleep.bedTime];
        NSString* timeOfTurnOutTheLight = [timeFormat stringFromDate:sleep.timeOfTurningOutTheLight];
        NSString* timeOfGettingUp = [timeFormat stringFromDate:sleep.timeOfGettingUp];
        NSString* timeOfEatingLastBigMeal = [timeFormat stringFromDate:sleep.timeOfEatingLastBigMeal];
        NSString* timeOfFinalAwakening = [timeFormat stringFromDate:sleep.timeOfFinalAwakening];
        
        sqlite3_bind_text( statement, 1,[bedTime UTF8String], -1, SQLITE_TRANSIENT);
        sqlite3_bind_text( statement, 2,[timeOfTurnOutTheLight UTF8String], -1, SQLITE_TRANSIENT);
        sqlite3_bind_text( statement, 3,[sleep.durationOfFallingAsleep UTF8String], -1, SQLITE_TRANSIENT);
        sqlite3_bind_text( statement, 4,[sleep.numberOfWakeup UTF8String], -1, SQLITE_TRANSIENT);
        sqlite3_bind_text( statement, 5,[sleep.totalDurationOfWakeup UTF8String], -1, SQLITE_TRANSIENT);
        sqlite3_bind_text( statement, 6,[timeOfGettingUp UTF8String], -1, SQLITE_TRANSIENT);
        sqlite3_bind_text( statement, 7,[timeOfEatingLastBigMeal UTF8String], -1, SQLITE_TRANSIENT);
        sqlite3_bind_text( statement, 8,[sleep.activityInLateEvening UTF8String], -1, SQLITE_TRANSIENT);
        sqlite3_bind_text( statement, 9,[sleep.alcoholInLateEvening UTF8String], -1, SQLITE_TRANSIENT);
        sqlite3_bind_text( statement, 10,[sleep.mood UTF8String], -1, SQLITE_TRANSIENT);
        sqlite3_bind_text( statement, 11,[sleep.selfReportedSleepQuality UTF8String], -1, SQLITE_TRANSIENT);
        sqlite3_bind_text( statement, 12,[timeOfFinalAwakening UTF8String], -1, SQLITE_TRANSIENT);
        sqlite3_bind_text( statement, 13,[date UTF8String], -1, SQLITE_TRANSIENT);
    }
    if(sqlite3_step(statement) != SQLITE_DONE )
    {
        NSLog( @"Update Sleep Error: %s", sqlite3_errmsg(_prePopulatedDB));
    }
    sqlite3_finalize(statement);
    sqlite3_close(_prePopulatedDB);
}

-(void)insertLoggedSleepWith:(LoggedSleep*)sleep
{
    NSString* query = @"INSERT INTO Sleep Values(?,?,?,?,?,?,?,?,?,?,?,?,?)";
    sqlite3_stmt* statement;
    
    NSDateFormatter* dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"MMMM dd, yyyy"];
    NSDateFormatter* timeFormat = [[NSDateFormatter alloc] init];
    [timeFormat setDateFormat:@"MMMM dd, yyyy hh:mm a"];
    
    [self openDB];
    if (sqlite3_prepare_v2(_prePopulatedDB, [query UTF8String], -1, &statement, nil) == SQLITE_OK)
    {
        NSString* date =[dateFormat stringFromDate:sleep.date];
        NSString* bedTime = [timeFormat stringFromDate:sleep.bedTime];
        NSString* timeOfTurnOutTheLight = [timeFormat stringFromDate:sleep.timeOfTurningOutTheLight];
        NSString* timeOfGettingUp = [timeFormat stringFromDate:sleep.timeOfGettingUp];
        NSString* timeOfEatingLastBigMeal = [timeFormat stringFromDate:sleep.timeOfEatingLastBigMeal];
        NSString* timeOfFinalAwakening = [timeFormat stringFromDate:sleep.timeOfFinalAwakening];
        
        sqlite3_bind_text( statement, 1,[date UTF8String], -1, SQLITE_TRANSIENT);
        sqlite3_bind_text( statement, 2,[bedTime UTF8String], -1, SQLITE_TRANSIENT);
        sqlite3_bind_text( statement, 3,[timeOfTurnOutTheLight UTF8String], -1, SQLITE_TRANSIENT);
        sqlite3_bind_text( statement, 4,[sleep.durationOfFallingAsleep UTF8String], -1, SQLITE_TRANSIENT);
        sqlite3_bind_text( statement, 5,[sleep.numberOfWakeup UTF8String], -1, SQLITE_TRANSIENT);
        sqlite3_bind_text( statement, 6,[sleep.totalDurationOfWakeup UTF8String], -1, SQLITE_TRANSIENT);
        sqlite3_bind_text( statement, 7,[timeOfGettingUp UTF8String], -1, SQLITE_TRANSIENT);
        sqlite3_bind_text( statement, 8,[timeOfEatingLastBigMeal UTF8String], -1, SQLITE_TRANSIENT);
        sqlite3_bind_text( statement, 9,[sleep.activityInLateEvening UTF8String], -1, SQLITE_TRANSIENT);
        sqlite3_bind_text( statement, 10,[sleep.alcoholInLateEvening UTF8String], -1, SQLITE_TRANSIENT);
        sqlite3_bind_text( statement, 11,[sleep.mood UTF8String], -1, SQLITE_TRANSIENT);
        sqlite3_bind_text( statement, 12,[sleep.selfReportedSleepQuality UTF8String], -1, SQLITE_TRANSIENT);
        sqlite3_bind_text( statement, 13,[timeOfFinalAwakening UTF8String], -1, SQLITE_TRANSIENT);
    }
    if(sqlite3_step(statement) != SQLITE_DONE )
    {
        NSLog( @"Insert Sleep Error: %s", sqlite3_errmsg(_prePopulatedDB));
    }
    sqlite3_finalize(statement);
    sqlite3_close(_prePopulatedDB);
}

-(void)removeLoggedSleepOnDate:(NSDate*)date
{
    NSString* query = @"DELETE FROM Sleep WHERE Date=?";
    sqlite3_stmt* statement;
    
    NSDateFormatter* dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"MMMM dd, yyyy"];
    
    [self openDB];
    if (sqlite3_prepare_v2(_prePopulatedDB, [query UTF8String], -1, &statement, nil) == SQLITE_OK)
    {
        NSString* dateString =[dateFormat stringFromDate:date];
        
        sqlite3_bind_text( statement, 1,[dateString UTF8String], -1, SQLITE_TRANSIENT);
    }
    if(sqlite3_step(statement) != SQLITE_DONE )
    {
        NSLog( @"Delete Sleep Error: %s", sqlite3_errmsg(_prePopulatedDB));
    }
    sqlite3_finalize(statement);
    sqlite3_close(_prePopulatedDB);
}


#pragma mark - All about sleep setting
-(SleepSetting*)currentSleepSetting
{
    SleepSetting* setting;
    NSString* query = @"SELECT * FROM SleepSetting";
    sqlite3_stmt* statement;
    [self openDB];
    if (sqlite3_prepare_v2(_prePopulatedDB, [query UTF8String], -1, &statement, nil) == SQLITE_OK)
    {
        while (sqlite3_step(statement) == SQLITE_ROW)
        {
            char* timeOfTurningOutTheLight = (char *) sqlite3_column_text(statement, 0);
            char* timeOfFinalAwakening = (char *) sqlite3_column_text(statement, 1);
            char* timeOfEatingLastBigMeal = (char*)sqlite3_column_text(statement, 2);
            char* activityInLateEvening = (char *) sqlite3_column_text(statement, 3);
            char* alcoholInLateEvening = (char *) sqlite3_column_text(statement, 4);
            char* mood = (char *) sqlite3_column_text(statement, 5);
            char* selfReportedSleepQuality = (char *) sqlite3_column_text(statement, 6);
            
            NSString* newTimeOfTurningOutTheLight = [[NSString alloc] initWithUTF8String:timeOfTurningOutTheLight];
            NSString* newTimeOfFinalAwakening = [[NSString alloc] initWithUTF8String:timeOfFinalAwakening];
            NSString* newTimeOfEatingLastBigMeal = [[NSString alloc] initWithUTF8String:timeOfEatingLastBigMeal];
            NSString* newActivityInLateEvening = [[NSString alloc]initWithUTF8String:activityInLateEvening];
            NSString* newAlcoholInLateEvening = [[NSString alloc]initWithUTF8String:alcoholInLateEvening];
            NSString* newMood = [[NSString alloc]initWithUTF8String:mood];
            NSString* newSelfReportedSleepQuality = [[NSString alloc]initWithUTF8String:selfReportedSleepQuality];
            
            BOOL boolTimeOfTurningOutTheLight = [newTimeOfTurningOutTheLight isEqualToString:@"NO"] ? NO : YES;
            BOOL boolTimeOfFinalAwakening = [newTimeOfFinalAwakening isEqualToString:@"NO"] ? NO : YES;
            BOOL boolTimeOfEatingLastBigMeal = [newTimeOfEatingLastBigMeal isEqualToString:@"NO"] ? NO : YES;
            BOOL boolActivityInLateEvening = [newActivityInLateEvening isEqualToString:@"NO"] ? NO : YES;
            BOOL boolAlcoholInLateEvening = [newAlcoholInLateEvening isEqualToString:@"NO"] ? NO : YES;
            BOOL boolMood = [newMood isEqualToString:@"NO"] ? NO : YES;
            BOOL boolSelfReportedSleepQuality = [newSelfReportedSleepQuality isEqualToString:@"NO"] ? NO : YES;
            
            setting = [[SleepSetting alloc]initWithIsTimeOfTurningOutLight:boolTimeOfTurningOutTheLight IsTimeOfFinalAwakening:boolTimeOfFinalAwakening IsTimeOfLastBigMeal:boolTimeOfEatingLastBigMeal IsActivityAtLateEvening:boolActivityInLateEvening IsAlcoholAtLateEvening:boolAlcoholInLateEvening IsMood:boolMood IsSelfReportedSleepQuality:boolSelfReportedSleepQuality];
        }
        sqlite3_finalize(statement);
        sqlite3_close(_prePopulatedDB);
    }
    return setting;
}

-(void)updateSleepSettingWithSetting:(SleepSetting*)setting
{
    NSString* query = @"UPDATE SleepSetting SET TimeOfTurningOurTheLight=?, TimeOfFinalAwakening=?, TimeOfEatingLastBigMeal=?, ActivityInLateEvening=?, AlcoholInLateEvening=?, Mood=?, SelfReportedSleepQuality=?";
    sqlite3_stmt* statement;
    
    NSString* timeOfTurningOutTheLight = setting.isTimeOfTurningOutLight ? @"YES" : @"NO";
    NSString* timeOfFinalAwakening = setting.isTimeOfFinalAwakening ? @"YES" : @"NO";
    NSString* timeOfEatingLastBigMeal = setting.isTimeOfLastBigMeal ? @"YES" : @"NO";
    NSString* activityInLateEvening = setting.isActivityAtLateEvening ? @"YES" : @"NO";
    NSString* alcoholInLateEvening = setting.isAlcoholAtLateEvening ? @"YES" : @"NO";
    NSString* mood = setting.isMood ? @"YES" : @"NO";
    NSString* selfReportedSleepQuality = setting.isSelfReportedSleepQuality ? @"YES" : @"NO";
    
    [self openDB];
    if (sqlite3_prepare_v2(_prePopulatedDB, [query UTF8String], -1, &statement, nil) == SQLITE_OK)
    {
        sqlite3_bind_text( statement, 1,[timeOfTurningOutTheLight UTF8String], -1, SQLITE_TRANSIENT);
        sqlite3_bind_text( statement, 2,[timeOfFinalAwakening UTF8String], -1, SQLITE_TRANSIENT);
        sqlite3_bind_text( statement, 3,[timeOfEatingLastBigMeal UTF8String], -1, SQLITE_TRANSIENT);
        sqlite3_bind_text( statement, 4,[activityInLateEvening UTF8String], -1, SQLITE_TRANSIENT);
        sqlite3_bind_text( statement, 5,[alcoholInLateEvening UTF8String], -1, SQLITE_TRANSIENT);
        sqlite3_bind_text( statement, 6,[mood UTF8String], -1, SQLITE_TRANSIENT);
        sqlite3_bind_text( statement, 7,[selfReportedSleepQuality UTF8String], -1, SQLITE_TRANSIENT);
    }
    if(sqlite3_step(statement) != SQLITE_DONE )
    {
        NSLog( @"Update Sleep Setting Error: %s", sqlite3_errmsg(_prePopulatedDB));
    }
    sqlite3_finalize(statement);
    sqlite3_close(_prePopulatedDB);
}

@end
