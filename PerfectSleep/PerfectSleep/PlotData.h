//
//  PlotData.h
//  PerfectSleep
//
//  Created by Huang Purong on 2/4/14.
//  Copyright (c) 2014 Huang Purong. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CorePlotHeaders/CorePlot-CocoaTouch.h"
#import "DietDiaryDB.h"
#import "SleepDiaryDB.h"
#import "ConsumedFood.h"
#import "LoggedSleep.h"

@protocol PlotDataDelegate <NSObject>

@required
-(NSDate*)getReferenceDateFromPattern;
-(void)updateReferenceDateToPatternWithDate:(NSDate*)date;

@end

@interface PlotData : NSObject

@property (nonatomic, assign) id<PlotDataDelegate> delegate;
@property(nonatomic, readonly)int identifierIndex;
@property(nonatomic, readonly)NSString* category;
@property(nonatomic, readonly)NSDate* startDate;
@property(nonatomic, readonly)NSDate* endDate;
@property(nonatomic, readonly)NSMutableArray* data;
@property(nonatomic, readonly)NSMutableArray* xValueList;
@property(nonatomic, readonly)NSMutableArray* yValueList;
@property(nonatomic, readonly)NSMutableArray* yValueDataPointLabelList;
@property(nonatomic, readonly)NSArray* DBList;
@property(nonatomic, readonly)NSMutableArray* dateList;

-(id)initWithIdentifierIndex:(int)index Category:(NSString*)category StartDate:(NSDate*)startDate EndDate:(NSDate*)endDate;
-(void)setPlotDataParameters;

@end
