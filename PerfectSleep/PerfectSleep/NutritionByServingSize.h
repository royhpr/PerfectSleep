//
//  Serving.h
//  PerfectSleep
//
//  Created by Huang Purong on 5/11/13.
//  Copyright (c) 2013 Huang Purong. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NutritionByServingSize : NSObject

@property(nonatomic,readwrite)NSString* servingID;
@property(nonatomic,readwrite)NSString* servingDescription;
@property(nonatomic,readwrite)NSString* servingURL;
@property(nonatomic,readwrite)NSString* metricServingAmount;
@property(nonatomic,readwrite)NSString* metricServingUnit;
@property(nonatomic,readwrite)NSString* numberOfUnits;
@property(nonatomic,readwrite)NSString* measurementDescription;

@property(nonatomic,readwrite)NSString* calories;
@property(nonatomic,readwrite)NSString* carbohydrate;
@property(nonatomic,readwrite)NSString* protein;
@property(nonatomic,readwrite)NSString* fat;
@property(nonatomic,readwrite)NSString* saturatedFat;
@property(nonatomic,readwrite)NSString* polyUnsaturatedFat;
@property(nonatomic,readwrite)NSString* monounsaturatedFat;
@property(nonatomic,readwrite)NSString* transFat;
@property(nonatomic,readwrite)NSString* cholesterol;
@property(nonatomic,readwrite)NSString* sodium;
@property(nonatomic,readwrite)NSString* potassium;
@property(nonatomic,readwrite)NSString* fiber;
@property(nonatomic,readwrite)NSString* sugar;
@property(nonatomic,readwrite)NSString* vitaminA;
@property(nonatomic,readwrite)NSString* vitaminC;
@property(nonatomic,readwrite)NSString* calcium;
@property(nonatomic,readwrite)NSString* iron;

@end
