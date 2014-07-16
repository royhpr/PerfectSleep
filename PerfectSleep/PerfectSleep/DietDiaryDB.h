//
//  DietDiaryDB.h
//  PerfectSleep
//
//  Created by RoyHPR on 4/4/14.
//  Copyright (c) 2014 Huang Purong. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <sqlite3.h>
#import "ConsumedFood.h"
#import "Food.h"

@interface DietDiaryDB : NSObject
{
    sqlite3* _prePopulatedDB;
}

+(DietDiaryDB*)database;
-(NSArray*)consumeIDList;
-(NSArray*)consumptionListBetweenStartDate:(NSDate*)startDate EndDate:(NSDate*)endDate;
-(void)addConsumptionWithConsumeID:(NSString*)consumeID FoodID:(NSString*)foodID ServingID:(NSString*)servingID FoodName:(NSString*)foodName ServingNumber:(NSString*)servingNumber ServingSize:(NSString*)servingSize ConsumeDate:(NSDate*)consumeDate Calories:(NSString*)calories TotalFats:(NSString*)totalFats saturatedFat:(NSString*)saturatedFat polyUnsaturatedFat:(NSString*)polyUnsaturatedFat MonounUnsaturatedFat:(NSString*)monounUnsaturatedFat Cholesterol:(NSString*)cholesterol Sodium:(NSString*)sodium Potassium:(NSString*)potassium TotalCarbohydrate:(NSString*)totalCarbohydrate DietaryFiber:(NSString*)dietaryFiber Sugars:(NSString*)sugars Protein:(NSString*)protein VitaminA:(NSString*)vitaminA VitaminC:(NSString*)vitaminC Calcium:(NSString*)calcium Iron:(NSString*)iron;
-(void)updateConsumptionWithConsumeID:(NSString*)consumeID ServingID:(NSString*)servingID ServingNumber:(NSString*)servingNumber ServingSize:(NSString*)servingSize Calories:(NSString*)calories TotalFats:(NSString*)totalFats saturatedFat:(NSString*)saturatedFat polyUnsaturatedFat:(NSString*)polyUnsaturatedFat MonounUnsaturatedFat:(NSString*)monounUnsaturatedFat Cholesterol:(NSString*)cholesterol Sodium:(NSString*)sodium Potassium:(NSString*)potassium TotalCarbohydrate:(NSString*)totalCarbohydrate DietaryFiber:(NSString*)dietaryFiber Sugars:(NSString*)sugars Protein:(NSString*)protein VitaminA:(NSString*)vitaminA VitaminC:(NSString*)vitaminC Calcium:(NSString*)calcium Iron:(NSString*)iron;
-(void)deleteConsumptionWithConsumeID:(NSString*)consumeID;

-(NSArray*)favoriteList;
-(void)addFavoriteWithFoodID:(NSString*)foodID WithFoodName:(NSString*)foodName;
-(void)deleteFavoriteWithFoodID:(NSString*)foodID;

-(NSArray*)recentList;

@end
