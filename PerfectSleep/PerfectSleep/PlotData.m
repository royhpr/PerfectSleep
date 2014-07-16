//
//  PlotData.m
//  PerfectSleep
//
//  Created by Huang Purong on 2/4/14.
//  Copyright (c) 2014 Huang Purong. All rights reserved.
//

#import "PlotData.h"

@implementation PlotData

-(id)initWithIdentifierIndex:(int)index Category:(NSString*)category StartDate:(NSDate*)startDate EndDate:(NSDate*)endDate;
{
    self = [super init];
    if(self)
    {
        _identifierIndex = index;
        _category = category;
        _startDate = startDate;
        _endDate = endDate;
    }
    
    return self;
}

-(void)setPlotDataParameters
{
    [self initializeDBList];
    [self initializeXValueList];
    [self initializeYValueList];
    [self initializeData];
}

-(void)initializeDBList
{
    _dateList = [[NSMutableArray alloc]init];
    if([_category isEqualToString:@"Nutrition"])
    {
        _DBList = [[DietDiaryDB database]consumptionListBetweenStartDate:_startDate EndDate:_endDate];
        for(ConsumedFood* item in _DBList)
        {
            if(![_dateList containsObject:item.consumeDate])
                [_dateList addObject:item.consumeDate];
        }
    }
    else
    {
        _DBList = [[SleepDiaryDB database]loggedSleepListFromDate:_startDate ToDate:_endDate];
        for(LoggedSleep* item in _DBList)
        {
            if(![_dateList containsObject:item.date])
                [_dateList addObject:item.date];
        }
    }
}

-(void)initializeXValueList
{
    _xValueList = [[NSMutableArray alloc]init];
    
    NSDate* refDate = [self.delegate getReferenceDateFromPattern];
    if(refDate == nil)
    {
        if(_dateList.count != 0)
        {
            NSDate* minimumDate = [_dateList objectAtIndex:0];
            [self.delegate updateReferenceDateToPatternWithDate:minimumDate];
        }
    }
    else
    {
        if(_dateList.count != 0)
        {
            NSDate* minimumDate = [_dateList objectAtIndex:0];
            if([refDate compare:minimumDate] == NSOrderedDescending)
               [self.delegate updateReferenceDateToPatternWithDate:minimumDate];
        }
    }
    
    if(_dateList.count != 0)
    {
        NSDate* refDate = [self.delegate getReferenceDateFromPattern];
        for(NSDate* date in _dateList)
        {
            NSTimeInterval diff = [date timeIntervalSinceDate:refDate];
            [_xValueList addObject:[NSDecimalNumber numberWithDouble:diff]];
        }
    }
}

-(void)initializeYValueList
{
    NSMutableArray* yList = [[NSMutableArray alloc]init];
    if([_category isEqualToString:@"Nutrition"])
    {
        for(NSDate* date in _dateList)
        {
            [yList addObject:[self getAggregatedConsumedFoodBasedOnDate:date]];
        }
        [self generateYValueListBaseOnNutritionWithList:yList];
        [self generateDataPointLabelListBasedOnNutritionsWithList:yList];
    }
    else
    {
        yList = [[NSMutableArray alloc]initWithArray:_DBList];
        [self generateYValueListBaseOnOthersWithList:yList];
        [self generateDataPointLabelListBasedOnOthers];
    }
}

-(void)generateYValueListBaseOnOthersWithList:(NSMutableArray*)yList
{
    _yValueList = [[NSMutableArray alloc]init];
    NSMutableArray* discardedDateItems = [[NSMutableArray alloc]init];
    NSMutableArray* discardedXValueItems = [[NSMutableArray alloc]init];
    for (int i=0; i<yList.count; i++)
    {
        LoggedSleep* item = (LoggedSleep*)[yList objectAtIndex:i];
        id timeOfTurnOutTheLight = item.timeOfTurningOutTheLight == nil ? @"" : item.timeOfTurningOutTheLight;
        id timeOfEatingLastBigMeal = item.timeOfEatingLastBigMeal == nil ? @"" : item.timeOfEatingLastBigMeal;
        id activityInLateEvening = item.activityInLateEvening == nil ? @"" : item.activityInLateEvening;
        id alcoholInLateEvening = item.alcoholInLateEvening == nil ? @"" : item.alcoholInLateEvening;
        id mood = item.mood == nil ? @"" : item.mood;
        id selfReportedSleepQuality = item.selfReportedSleepQuality == nil ? @"" : item.selfReportedSleepQuality;
        id timeOfFinalAwakening = item.timeOfFinalAwakening == nil ? @"" : item.timeOfFinalAwakening;
        
        NSMutableArray* itemArray = [[NSMutableArray alloc]initWithObjects:@" ",item.bedTime, timeOfTurnOutTheLight, item.durationOfFallingAsleep, item.numberOfWakeup, item.totalDurationOfWakeup, item.timeOfGettingUp, timeOfEatingLastBigMeal, activityInLateEvening, alcoholInLateEvening, mood, selfReportedSleepQuality, timeOfFinalAwakening, nil];
 
        if([[itemArray objectAtIndex:_identifierIndex]isEqual:@""])
        {
            [discardedDateItems addObject:[_dateList objectAtIndex:i]];
            [discardedXValueItems addObject:[_xValueList objectAtIndex:i]];
        }
        else
        {
            //Calculated Sleep Duration
            if(_identifierIndex == 0)
            {
                NSDateFormatter* timeFormatter = [[NSDateFormatter alloc]init];
                [timeFormatter setDateFormat:@"MMMM dd, yyyy hh:mm a"];
                NSDate* bedTime = (NSDate*)[itemArray objectAtIndex:1];
                NSDate* timeOfGettingUp = (NSDate*)[itemArray objectAtIndex:6];
                NSTimeInterval distanceBetweenDates = [timeOfGettingUp timeIntervalSinceDate:bedTime];
                double secondsInAnHour = 3600;
                double hoursBetweenDates = (double)distanceBetweenDates / secondsInAnHour;
                
                //duration of falling asleep
                NSString* durationOfFallingAsleepItem = [itemArray objectAtIndex:3];
                NSArray* durationOfFallingAsleepItemList = [durationOfFallingAsleepItem componentsSeparatedByString:@" "];
                double fallAsleepInteger = 0.0;
                double fallAsleepFraction = 0.0;
                fallAsleepInteger = [[durationOfFallingAsleepItemList objectAtIndex:0]doubleValue];
                fallAsleepFraction = [[durationOfFallingAsleepItemList objectAtIndex:2]doubleValue] / 60.0;
                double durationOfFallingAsleep = fallAsleepInteger + fallAsleepFraction;

                //total duration of wake-up
                NSString* durationOfWakeupItem = [itemArray objectAtIndex:5];
                NSArray* durationOfWakeupItemList = [durationOfWakeupItem componentsSeparatedByString:@" "];
                double wakeupInteger = 0.0;
                double wakeupFraction = 0.0;
                wakeupInteger = [[durationOfWakeupItemList objectAtIndex:0]doubleValue];
                wakeupFraction = [[durationOfWakeupItemList objectAtIndex:2]doubleValue] / 60.0;
                double durationOfWakeup = wakeupInteger + wakeupFraction;

                [_yValueList addObject:[NSDecimalNumber numberWithDouble:(hoursBetweenDates - durationOfFallingAsleep - durationOfWakeup)]];
            }
            //Time
            else if(_identifierIndex == 1 ||
               _identifierIndex == 2 ||
               _identifierIndex == 6 ||
               _identifierIndex == 7 ||
               _identifierIndex == 12)
            {
                NSDateFormatter* timeFormatter = [[NSDateFormatter alloc]init];
                [timeFormatter setDateFormat:@"MMMM dd, yyyy hh:mm a"];
                NSDate* time = (NSDate*)[itemArray objectAtIndex:_identifierIndex];
                
                [_yValueList addObject:[NSDecimalNumber numberWithDouble:[self returnDurationPassedFromMidnightForTime:time]]];
            }
            //Duration
            else if(_identifierIndex == 3 ||
                    _identifierIndex == 5)
            {
                NSString* item = [itemArray objectAtIndex:_identifierIndex];
                NSArray* itemList = [item componentsSeparatedByString:@" "];
                double integer = 0.0;
                double fraction = 0.0;
                
                integer = [[itemList objectAtIndex:0]doubleValue];
                fraction = [[itemList objectAtIndex:2]doubleValue] / 60.0;
                [_yValueList addObject:[NSDecimalNumber numberWithDouble:(integer+fraction)]];
            }
            //Number
            else if(_identifierIndex == 4)
            {
                NSString* item = [itemArray objectAtIndex:_identifierIndex];
                NSArray* itemList = [item componentsSeparatedByString:@" "];
                double integer = [[itemList objectAtIndex:0]doubleValue];
                
                [_yValueList addObject:[NSDecimalNumber numberWithDouble:integer]];
            }
            //Activity
            else if(_identifierIndex == 8)
            {
                [_yValueList addObject:[NSDecimalNumber numberWithDouble:3.5]];
            }
            //Alcohol
            else if(_identifierIndex == 9)
            {
                NSString* item = [itemArray objectAtIndex:_identifierIndex];
                
                if([item isEqualToString:@"0"])
                {
                    [_yValueList addObject:[NSDecimalNumber numberWithDouble:[item doubleValue]]];
                }
                else
                {
                    NSArray* itemList = [item componentsSeparatedByString:@" "];
                    int index = [self getIntakeUnitIndexWithList:itemList];
                    double unitIntake = [self getIntakeNumberWithUnit:[itemList objectAtIndex:index] Index:index];
                    
                    [_yValueList addObject:[NSDecimalNumber numberWithDouble:[self getYvalueWithUnitIntake:unitIntake UnitIntakeIndex:index ItemList:itemList]]];
                }
            }
            //Mood
            else if(_identifierIndex == 10)
            {
                NSString* item = [itemArray objectAtIndex:_identifierIndex];
                double moodValue = 0.0;
                
                if([item isEqualToString:@"great"])
                    moodValue = 4.5;
                else if([item isEqualToString:@"soso"])
                    moodValue = 2.5;
                else
                    moodValue = 0.5;
                
                [_yValueList addObject:[NSDecimalNumber numberWithDouble:moodValue]];
            }
            //self reported quality
            else
            {
                NSString* item = [itemArray objectAtIndex:_identifierIndex];
                double sleepQualityValue = 0.0;
                
                if([item isEqualToString:@"0.0"])
                    sleepQualityValue = 0.0;
                else if([item isEqualToString:@"20.0"])
                    sleepQualityValue = 1.0;
                else if([item isEqualToString:@"40.0"])
                    sleepQualityValue = 2.0;
                else
                    sleepQualityValue = 3.0;
                
                [_yValueList addObject:[NSDecimalNumber numberWithDouble:sleepQualityValue]];
            }
        }
    }
    
    [self removeDate:discardedDateItems xValue:discardedXValueItems];
}

-(void)generateHourBasedLabel
{
    for(NSDecimalNumber* number in _yValueList)
    {
        [_yValueDataPointLabelList addObject:[NSString stringWithFormat:@"%.2f hrs", [number doubleValue]]];
    }
}

-(void)generateTimeBasedLabel
{
    for(NSDecimalNumber* number in _yValueList)
    {
        double value = [number doubleValue];
        unsigned integer = value > 12.0 ? (unsigned)(value - 12) : (unsigned)value;
        unsigned fraction = (value * 100) - ((unsigned)value * 100);
        fraction = (double)fraction/100.0 * 60;
        NSString* suffix = value >= 12.0 ? @"pm" : @"am";
    
        [_yValueDataPointLabelList addObject:[NSString stringWithFormat:@"%02d:%02d %@",integer,fraction,suffix]];
    }
}

-(void)generateMinuteBasedLabel
{
    for(NSDecimalNumber* number in _yValueList)
    {
        unsigned minutes = [number doubleValue] * 60.0;
        
        [_yValueDataPointLabelList addObject:[NSString stringWithFormat:@"%02d mins", minutes]];
    }
}

-(void)generateCountBasedLabel
{
    for(NSDecimalNumber* number in _yValueList)
    {
        unsigned count = (unsigned)[number doubleValue];
        
        [_yValueDataPointLabelList addObject:[NSString stringWithFormat:@"%02d times", count]];
    }
}

-(void)generateActivityBasedLabel
{
    for(LoggedSleep* sleep in _DBList)
    {
        if(sleep.activityInLateEvening != nil)
        {
            [_yValueDataPointLabelList addObject:sleep.activityInLateEvening];
        }
    }
}

-(void)generateAlcoholBasedLabel
{
    for(NSDecimalNumber* number in _yValueList)
    {
        [_yValueDataPointLabelList addObject:[NSString stringWithFormat:@"%.2f ml", [number doubleValue]]];
    }
}

-(void)generateMoodBasedLabel
{
    for(LoggedSleep* sleep in _DBList)
    {
        if(sleep.mood != nil)
        {
            [_yValueDataPointLabelList addObject:sleep.mood];
        }
    }
}

-(void)generateSelfReportedBasedLabel
{
    for(NSDecimalNumber* number in _yValueList)
    {
        unsigned integer = (unsigned)[number doubleValue];
        
        switch (integer)
        {
            case 0:
                [_yValueDataPointLabelList addObject:@"Poor"];
                break;
            case 1:
                [_yValueDataPointLabelList addObject:@"Moderate"];
                break;
            case 2:
                [_yValueDataPointLabelList addObject:@"Good"];
                break;
            case 3:
                [_yValueDataPointLabelList addObject:@"Perfect"];
                break;
                
            default:
                break;
        }
    }
}

-(void)generateDataPointLabelListBasedOnOthers
{
    _yValueDataPointLabelList = [[NSMutableArray alloc]init];
    //Calculated Sleep Duration
    if(_identifierIndex == 0)
    {
        [self generateHourBasedLabel];
    }
    //Time
    else if(_identifierIndex == 1 ||
            _identifierIndex == 2 ||
            _identifierIndex == 6 ||
            _identifierIndex == 7 ||
            _identifierIndex == 12)
    {
        [self generateTimeBasedLabel];
    }
    //Duration
    else if(_identifierIndex == 3 ||
            _identifierIndex == 5)
    {
        [self generateMinuteBasedLabel];
    }
    //Number
    else if(_identifierIndex == 4)
    {
        [self generateCountBasedLabel];
    }
    //Activity
    else if(_identifierIndex == 8)
    {
        [self generateActivityBasedLabel];
    }
    //Alcohol
    else if(_identifierIndex == 9)
    {
        [self generateAlcoholBasedLabel];
    }
    //Mood
    else if(_identifierIndex == 10)
    {
        [self generateMoodBasedLabel];
    }
    //self reported quality
    else
    {
        [self generateSelfReportedBasedLabel];
    }
}

-(void)generateDataPointLabelListBasedOnNutritionsWithList:(NSMutableArray*)yList
{
    _yValueDataPointLabelList = [[NSMutableArray alloc]init];
    for(NSMutableArray* item in yList)
    {
        if(_identifierIndex == 0)
        {
            [_yValueDataPointLabelList addObject:[NSString stringWithFormat:@"%.2fkcal", [[item objectAtIndex:_identifierIndex]doubleValue]]];
        }
        else if(_identifierIndex == 1 ||
                _identifierIndex == 2 ||
                _identifierIndex == 3 ||
                _identifierIndex == 4 ||
                _identifierIndex == 8 ||
                _identifierIndex == 9 ||
                _identifierIndex == 10 ||
                _identifierIndex == 11)
        {
            [_yValueDataPointLabelList addObject:[NSString stringWithFormat:@"%.3fg", [[item objectAtIndex:_identifierIndex]doubleValue]]];
        }
        else if(_identifierIndex == 5 ||
                _identifierIndex == 6 ||
                _identifierIndex == 7)
        {
            [_yValueDataPointLabelList addObject:[NSString stringWithFormat:@"%.3fmg", [[item objectAtIndex:_identifierIndex]doubleValue]]];
        }
        else
        {
            [_yValueDataPointLabelList addObject:[NSString stringWithFormat:@"%.2f%%", [[item objectAtIndex:_identifierIndex]doubleValue]]];
        }
    }
}

-(double)returnDurationPassedFromMidnightForTime:(NSDate*)time
{
    NSDateComponents *components = [[NSCalendar currentCalendar] components:NSIntegerMax fromDate:time];
    [components setHour:0];
    [components setMinute:0];
    [components setSecond:0];
    
    NSDate *midnight = [[NSCalendar currentCalendar] dateFromComponents:components];
    NSDateComponents *diff = [[NSCalendar currentCalendar] components:NSHourCalendarUnit | NSMinuteCalendarUnit fromDate:midnight toDate:time options:0];
    
    NSInteger numberOfHoursPastMidnight = [diff hour];
    NSInteger numberOfMinutesPastMidnight = [diff minute];
    
    double duration = (double)numberOfHoursPastMidnight + (double)numberOfMinutesPastMidnight/60.0;
    
    return duration;
}

-(void)removeDate:(NSMutableArray*)dateArray xValue:(NSMutableArray*)xValueArray
{
    if(_dateList.count != 0)
    {
        for(id date in dateArray)
        {
            [_dateList removeObject:date];
        }
        
        for(id xValue in xValueArray)
        {
            [_xValueList removeObject:xValue];
        }
    }
}

-(double)getYvalueWithUnitIntake:(double)unitIntake UnitIntakeIndex:(int)index ItemList:(NSArray*)list
{
    double result=0.0;
    if(index==1)
    {
        NSString* item = [list objectAtIndex:0];
        if([item rangeOfString:@"/"].location == NSNotFound)
        {
            result = [item doubleValue]*unitIntake;
        }
        else
        {
            result = [self getFractionWithString:item]*unitIntake;
        }
    }
    else
    {
        double integer = [[list objectAtIndex:0]doubleValue];
        double fraction = [self getFractionWithString:[list objectAtIndex:1]];
        
        result = (integer+fraction)*unitIntake;
    }
    return result;
}

-(double)getFractionWithString:(NSString*)item
{
    double fraction = 0.0;
    if([item isEqualToString:@"1/4"])
        fraction = 0.25;
    else if([item isEqualToString:@"1/2"])
        fraction = 0.50;
    else
        fraction = 0.75;
    
    return fraction;
}

-(int)getIntakeUnitIndexWithList:(NSArray*)list
{
    int index = 0;
    for(int i=0; i<list.count; i++)
    {
        NSString* item = [list objectAtIndex:i];
        if([item rangeOfString:@"ml"].location != NSNotFound)
        {
            index = i;
            break;
        }
    }
    return index;
}

-(double)getIntakeNumberWithUnit:(NSString*)unit Index:(int)index
{
    NSString* unitNumber = [unit substringWithRange:NSMakeRange(0, [unit length] - 2)];
    double result = [unitNumber doubleValue];
    
    switch (index)
    {
        case 0:
            result = result * 0.13;
            break;
        case 1:
            result = result * 0.13;
            break;
        case 2:
            result = result * 0.027;
            break;
        case 3:
            result = result * 0.049;
            break;
        case 4:
            result = result * 0.2;
            break;
        case 5:
            result = result * 0.4;
            break;
            
        default:
            break;
    }
    
    return result;
}

-(void)generateYValueListBaseOnNutritionWithList:(NSMutableArray*)yList
{
    _yValueList = [[NSMutableArray alloc]init];
    for(NSMutableArray* item in yList)
    {
        [_yValueList addObject:[NSDecimalNumber numberWithDouble:[[item objectAtIndex:_identifierIndex]doubleValue]]];
    }
}

-(NSMutableArray*)getAggregatedConsumedFoodBasedOnDate:(NSDate*)date
{
    NSMutableArray* aggregated = [[NSMutableArray alloc]initWithObjects:@"0.0",@"0.0",@"0.0",@"0.0",@"0.0",@"0.0",@"0.0",@"0.0",@"0.0",@"0.0",@"0.0",@"0.0",@"0.0",@"0.0",@"0.0",@"0.0", nil];
    
    for(ConsumedFood* item in _DBList)
    {
        if([item.consumeDate compare:date] == NSOrderedSame)
        {
            NSMutableArray* second = [[NSMutableArray alloc]initWithObjects:item.calories,item.totalFats,item.saturatedFat,item.polyUnsaturatedFat,item.monounUnsaturatedFat,item.cholesterol,item.sodium,item.pottasium,item.totalCarbohydrate,item.dietaryFiber,item.sugars,item.protein,item.vitaminA,item.vitaminC,item.calcium,item.iron, nil];
            aggregated = [self addFirstConsumedFood:aggregated WithSecondConsumedFood:second WithSecondServingNumber:item.servingNumber];
        }
    }
    
    return aggregated;
}

-(NSMutableArray*)addFirstConsumedFood:(NSMutableArray*)first WithSecondConsumedFood:(NSMutableArray*)second WithSecondServingNumber:(NSString*)secondServingNumberString;
{
    NSMutableArray* result = [[NSMutableArray alloc]init];
    double secondServingNumber;
    NSArray* secondStringList = [secondServingNumberString componentsSeparatedByString:@"+"];
    
    if(secondStringList.count==1)
    {
        secondServingNumber = [[secondStringList objectAtIndex:0]doubleValue];
    }
    else
    {
        double integer = [[secondStringList objectAtIndex:0]doubleValue];
        double fraction;
        
        if([[secondStringList objectAtIndex:1]isEqualToString:@"1/4"])
        {
            fraction = 0.25;
        }
        else if([[secondStringList objectAtIndex:1]isEqualToString:@"1/2"])
        {
            fraction = 0.5;
        }
        else
        {
            fraction = 0.75;
        }
        secondServingNumber = integer + fraction;
    }

    [result addObject:[NSString stringWithFormat:@"%f",([[first objectAtIndex:0]doubleValue] + [[second objectAtIndex:0]doubleValue]*secondServingNumber)]];
    [result addObject:[NSString stringWithFormat:@"%f",([[first objectAtIndex:1]doubleValue] + [[second objectAtIndex:1]doubleValue]*secondServingNumber)]];
    [result addObject:[NSString stringWithFormat:@"%f",([[first objectAtIndex:2]doubleValue] + [[second objectAtIndex:2]doubleValue]*secondServingNumber)]];
    [result addObject:[NSString stringWithFormat:@"%f",([[first objectAtIndex:3]doubleValue] + [[second objectAtIndex:3]doubleValue]*secondServingNumber)]];
    [result addObject:[NSString stringWithFormat:@"%f",([[first objectAtIndex:4]doubleValue] + [[second objectAtIndex:4]doubleValue]*secondServingNumber)]];
    [result addObject:[NSString stringWithFormat:@"%f",([[first objectAtIndex:5]doubleValue] + [[second objectAtIndex:5]doubleValue]*secondServingNumber)]];
    [result addObject:[NSString stringWithFormat:@"%f",([[first objectAtIndex:6]doubleValue] + [[second objectAtIndex:6]doubleValue]*secondServingNumber)]];
    [result addObject:[NSString stringWithFormat:@"%f",([[first objectAtIndex:7]doubleValue] + [[second objectAtIndex:7]doubleValue]*secondServingNumber)]];
    [result addObject:[NSString stringWithFormat:@"%f",([[first objectAtIndex:8]doubleValue] + [[second objectAtIndex:8]doubleValue]*secondServingNumber)]];
    [result addObject:[NSString stringWithFormat:@"%f",([[first objectAtIndex:9]doubleValue] + [[second objectAtIndex:9]doubleValue]*secondServingNumber)]];
    [result addObject:[NSString stringWithFormat:@"%f",([[first objectAtIndex:10]doubleValue] + [[second objectAtIndex:10]doubleValue]*secondServingNumber)]];
    [result addObject:[NSString stringWithFormat:@"%f",([[first objectAtIndex:11]doubleValue] + [[second objectAtIndex:11]doubleValue]*secondServingNumber)]];
    [result addObject:[NSString stringWithFormat:@"%f",([[first objectAtIndex:12]doubleValue] + [[second objectAtIndex:12]doubleValue]*secondServingNumber)]];
    [result addObject:[NSString stringWithFormat:@"%f",([[first objectAtIndex:13]doubleValue] + [[second objectAtIndex:13]doubleValue]*secondServingNumber)]];
    [result addObject:[NSString stringWithFormat:@"%f",([[first objectAtIndex:14]doubleValue] + [[second objectAtIndex:14]doubleValue]*secondServingNumber)]];
    [result addObject:[NSString stringWithFormat:@"%f",([[first objectAtIndex:15]doubleValue] + [[second objectAtIndex:15]doubleValue]*secondServingNumber)]];
    
    return result;
}

-(void)initializeData
{
    _data = [[NSMutableArray alloc]init];
    NSUInteger i;
    for ( i = 0; i < _yValueList.count; i++ )
    {
        [_data addObject:[NSDictionary dictionaryWithObjectsAndKeys: [_xValueList objectAtIndex:i], [NSNumber numberWithInt:CPTScatterPlotFieldX], [_yValueList objectAtIndex:i], [NSNumber numberWithInt:CPTScatterPlotFieldY], nil]];
    }
}

-(NSDate*)getCurrentDateDisplayWithText:(NSString*)text
{
    NSString *dateString = text;
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"MMMM dd, yyyy"];
    NSDate *dateFromString = [[NSDate alloc] init];
    dateFromString = [dateFormatter dateFromString:dateString];
    
    return dateFromString;
}

@end
