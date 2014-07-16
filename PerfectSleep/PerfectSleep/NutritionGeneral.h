//
//  Nutrition.h
//  PerfectSleep
//
//  Created by Huang Purong on 4/11/13.
//  Copyright (c) 2013 Huang Purong. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NutritionByServingSize.h"

@interface NutritionGeneral : NSObject

@property(nonatomic,readwrite)NSString* foodID;
@property(nonatomic,readwrite)NSString* foodName;
@property(nonatomic,readwrite)NSString* foodType;
@property(nonatomic,readwrite)NSString* brandName;
@property(nonatomic,readwrite)NSString* foodURL;

@property(nonatomic,readwrite)NSMutableArray* servings;

@end
