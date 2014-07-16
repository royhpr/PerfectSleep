//
//  ServingSize.h
//  PerfectSleepApp
//
//  Created by Huang Purong on 13/2/14.
//  Copyright (c) 2014 Huang Purong. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ServingSize : NSObject

@property(nonatomic, readwrite)int numberOfUnit;
@property(nonatomic, readwrite)NSString* measurementUnit;
@property(nonatomic, readwrite)NSMutableArray* nutritionUnitValueList;

@end
