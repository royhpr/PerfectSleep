//
//  ConsumedFood.m
//  PerfectSleep
//
//  Created by RoyHPR on 4/4/14.
//  Copyright (c) 2014 Huang Purong. All rights reserved.
//

#import "ConsumedFood.h"

@implementation ConsumedFood

-(id)initWith:(NSString*)consumeID :(NSString*)foodID :(NSString*)servingID :(NSString*)foodName :(NSString*)servingNumber :(NSString*)servingSize :(NSDate*)consumeDate :(NSString*)calories :(NSString*)totalFats :(NSString*)saturatedFat :(NSString*)polyUnsaturatedFat :(NSString*)monounUnsaturatedFat :(NSString*)cholesterol :(NSString*)sodium :(NSString*)pottasium :(NSString*)totalCarbohydrate :(NSString*)dietaryFiber :(NSString*)sugars :(NSString*)protein :(NSString*)vitaminA :(NSString*)vitaminC :(NSString*)calcium :(NSString*)iron
{
    if(self = [super init])
    {
        _consumeID = consumeID;
        _foodID = foodID;
        _servingID = servingID;
        _foodName = foodName;
        _servingNumber = servingNumber;
        _servingSize = servingSize;
        _consumeDate = consumeDate;
        _calories = calories;
        _totalFats = totalFats;
        _saturatedFat = saturatedFat;
        _polyUnsaturatedFat = polyUnsaturatedFat;
        _monounUnsaturatedFat = monounUnsaturatedFat;
        _cholesterol = cholesterol;
        _sodium = sodium;
        _pottasium = pottasium;
        _totalCarbohydrate = totalCarbohydrate;
        _dietaryFiber = dietaryFiber;
        _sugars = sugars;
        _protein = protein;
        _vitaminA = vitaminA;
        _vitaminC = vitaminC;
        _calcium = calcium;
        _iron = iron;
    }
    
    return self;
}

@end
