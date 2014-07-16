//
//  DietDiaryDB.m
//  PerfectSleep
//
//  Created by RoyHPR on 4/4/14.
//  Copyright (c) 2014 Huang Purong. All rights reserved.
//

#import "DietDiaryDB.h"

@implementation DietDiaryDB

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

+(DietDiaryDB*)database
{
    static DietDiaryDB* _database;
    if(_database == nil)
    {
        _database = [[DietDiaryDB alloc]init];
    }
    return _database;
}

#pragma - mark All about consumption
-(NSArray*)consumeIDList
{
    NSMutableArray* IDList = [[NSMutableArray alloc]init];
    NSString *query = @"SELECT ConsumeID FROM Consumption ORDER BY CAST(ConsumeID as integer) ASC";
    sqlite3_stmt* statement;
    [self openDB];
    if (sqlite3_prepare_v2(_prePopulatedDB, [query UTF8String], -1, &statement, nil) == SQLITE_OK)
    {
        while (sqlite3_step(statement) == SQLITE_ROW)
        {
            char* consumeID = (char *) sqlite3_column_text(statement, 0);
            NSString* newConsumeID = [[NSString alloc] initWithUTF8String:consumeID];
            [IDList addObject:newConsumeID];
        }
        sqlite3_finalize(statement);
        sqlite3_close(_prePopulatedDB);
    }
    return IDList;
}

-(NSArray*)consumptionListBetweenStartDate:(NSDate*)startDate EndDate:(NSDate*)endDate
{
    NSMutableArray* currentFoodList = [[NSMutableArray alloc] init];
    NSString* query = @"SELECT * FROM Consumption WHERE ConsumeDate BETWEEN ? AND ? ORDER BY ConsumeDate ASC";
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
            char* consumeID = (char *) sqlite3_column_text(statement, 0);
            char* foodID = (char *) sqlite3_column_text(statement, 1);
            char* servingID = (char*)sqlite3_column_text(statement, 2);
            char* foodName = (char *) sqlite3_column_text(statement, 3);
            char* servingNumber = (char *) sqlite3_column_text(statement, 4);
            char* servingSize = (char *) sqlite3_column_text(statement, 5);
            char* consumeDate = (char *) sqlite3_column_text(statement, 6);
            char* calories = (char *)sqlite3_column_text(statement, 7);
            char* totalFats = (char*)sqlite3_column_text(statement, 8);
            char* saturatedFat = (char*)sqlite3_column_text(statement, 9);
            char* polyUnsaturatedFat = (char*)sqlite3_column_text(statement, 10);
            char* monounUnsaturatedFat = (char*)sqlite3_column_text(statement, 11);
            char* cholesterol = (char*)sqlite3_column_text(statement, 12);
            char* sodium = (char*)sqlite3_column_text(statement, 13);
            char* potassium = (char*)sqlite3_column_text(statement, 14);
            char* totalCarbohydrate = (char*)sqlite3_column_text(statement, 15);
            char* dietaryFiber = (char*)sqlite3_column_text(statement, 16);
            char* sugars = (char*)sqlite3_column_text(statement, 17);
            char* protein = (char*)sqlite3_column_text(statement, 18);
            char* vitaminA = (char*)sqlite3_column_text(statement, 19);
            char* vitaminC = (char*)sqlite3_column_text(statement, 20);
            char* calcium = (char*)sqlite3_column_text(statement, 21);
            char* iron = (char*)sqlite3_column_text(statement, 22);
            
            NSString* newConsumeID = [[NSString alloc] initWithUTF8String:consumeID];
            NSString* newFoodID = [[NSString alloc] initWithUTF8String:foodID];
            NSString* newServingID = [[NSString alloc]initWithUTF8String:servingID];
            NSString* newFoodName = [[NSString alloc] initWithUTF8String:foodName];
            NSString* newServingNumber = [[NSString alloc] initWithUTF8String:servingNumber];
            NSString* newServingSize = [[NSString alloc] initWithUTF8String:servingSize];
            NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
            [dateFormat setDateFormat:@"MMMM dd, yyyy"];
            NSDate* newConsumeDate = [dateFormat dateFromString:[NSString stringWithUTF8String:consumeDate]];
            NSString* newCalories = [[NSString alloc]initWithUTF8String:calories];
            NSString* newTotalFats = [[NSString alloc]initWithUTF8String:totalFats];
            NSString* newSaturatedFat = [[NSString alloc]initWithUTF8String:saturatedFat];
            NSString* newPolyUnsaturatedFat = [[NSString alloc]initWithUTF8String:polyUnsaturatedFat];
            NSString* newMonounUnsaturatedFat = [[NSString alloc]initWithUTF8String:monounUnsaturatedFat];
            NSString* newCholesterol = [[NSString alloc]initWithUTF8String:cholesterol];
            NSString* newSodium = [[NSString alloc]initWithUTF8String:sodium];
            NSString* newPotassium = [[NSString alloc]initWithUTF8String:potassium];
            NSString* newTotalCarbohydrate = [[NSString alloc]initWithUTF8String:totalCarbohydrate];
            NSString* newDietaryFiber = [[NSString alloc]initWithUTF8String:dietaryFiber];
            NSString* newSugars = [[NSString alloc]initWithUTF8String:sugars];
            NSString* newProtein = [[NSString alloc]initWithUTF8String:protein];
            NSString* newVitaminA = [[NSString alloc]initWithUTF8String:vitaminA];
            NSString* newVitaminC = [[NSString alloc]initWithUTF8String:vitaminC];
            NSString* newCalcium = [[NSString alloc]initWithUTF8String:calcium];
            NSString* newIron = [[NSString alloc]initWithUTF8String:iron];
            
            ConsumedFood* currentFood = [[ConsumedFood alloc]initWith:newConsumeID :newFoodID :newServingID :newFoodName :newServingNumber :newServingSize :newConsumeDate :newCalories :newTotalFats :newSaturatedFat :newPolyUnsaturatedFat :newMonounUnsaturatedFat :newCholesterol :newSodium :newPotassium :newTotalCarbohydrate :newDietaryFiber :newSugars :newProtein :newVitaminA :newVitaminC :newCalcium :newIron];
            [currentFoodList addObject:currentFood];
        }
        sqlite3_finalize(statement);
        sqlite3_close(_prePopulatedDB);
    }
    return currentFoodList;
}

//Add consumption
-(void)addConsumptionWithConsumeID:(NSString*)consumeID FoodID:(NSString*)foodID ServingID:(NSString*)servingID FoodName:(NSString*)foodName ServingNumber:(NSString*)servingNumber ServingSize:(NSString*)servingSize ConsumeDate:(NSDate*)consumeDate Calories:(NSString*)calories TotalFats:(NSString*)totalFats saturatedFat:(NSString*)saturatedFat polyUnsaturatedFat:(NSString*)polyUnsaturatedFat MonounUnsaturatedFat:(NSString*)monounUnsaturatedFat Cholesterol:(NSString*)cholesterol Sodium:(NSString*)sodium Potassium:(NSString*)potassium TotalCarbohydrate:(NSString*)totalCarbohydrate DietaryFiber:(NSString*)dietaryFiber Sugars:(NSString*)sugars Protein:(NSString*)protein VitaminA:(NSString*)vitaminA VitaminC:(NSString*)vitaminC Calcium:(NSString*)calcium Iron:(NSString*)iron
{
    NSString *query = @"INSERT INTO Consumption VALUES (?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)";
    sqlite3_stmt* statement;
    [self openDB];
    if (sqlite3_prepare_v2(_prePopulatedDB, [query UTF8String], -1, &statement, nil) == SQLITE_OK)
    {
        sqlite3_bind_text( statement, 1,[consumeID UTF8String], -1, SQLITE_TRANSIENT);
        sqlite3_bind_text( statement, 2,[foodID UTF8String], -1, SQLITE_TRANSIENT);
        sqlite3_bind_text( statement, 3,[servingID UTF8String], -1, SQLITE_TRANSIENT);
        sqlite3_bind_text( statement, 4,[foodName UTF8String], -1, SQLITE_TRANSIENT);
        sqlite3_bind_text( statement, 5,[servingNumber UTF8String], -1, SQLITE_TRANSIENT);
        sqlite3_bind_text( statement, 6,[servingSize UTF8String], -1, SQLITE_TRANSIENT);
        NSDateFormatter* dateFormat = [[NSDateFormatter alloc] init];
        [dateFormat setDateFormat:@"MMMM dd, yyyy"];
        NSString* dateString=[dateFormat stringFromDate:consumeDate];
        sqlite3_bind_text( statement, 7,[dateString UTF8String], -1, SQLITE_TRANSIENT);
        sqlite3_bind_text( statement, 8,[calories UTF8String], -1, SQLITE_TRANSIENT);
        sqlite3_bind_text( statement, 9,[totalFats UTF8String], -1, SQLITE_TRANSIENT);
        sqlite3_bind_text( statement, 10,[saturatedFat UTF8String], -1, SQLITE_TRANSIENT);
        sqlite3_bind_text( statement, 11,[polyUnsaturatedFat UTF8String], -1, SQLITE_TRANSIENT);
        sqlite3_bind_text( statement, 12,[monounUnsaturatedFat UTF8String], -1, SQLITE_TRANSIENT);
        sqlite3_bind_text( statement, 13,[cholesterol UTF8String], -1, SQLITE_TRANSIENT);
        sqlite3_bind_text( statement, 14,[sodium UTF8String], -1, SQLITE_TRANSIENT);
        sqlite3_bind_text( statement, 15,[potassium UTF8String], -1, SQLITE_TRANSIENT);
        sqlite3_bind_text( statement, 16,[totalCarbohydrate UTF8String], -1, SQLITE_TRANSIENT);
        sqlite3_bind_text( statement, 17,[dietaryFiber UTF8String], -1, SQLITE_TRANSIENT);
        sqlite3_bind_text( statement, 18,[sugars UTF8String], -1, SQLITE_TRANSIENT);
        sqlite3_bind_text( statement, 19,[protein UTF8String], -1, SQLITE_TRANSIENT);
        sqlite3_bind_text( statement, 20,[vitaminA UTF8String], -1, SQLITE_TRANSIENT);
        sqlite3_bind_text( statement, 21,[vitaminC UTF8String], -1, SQLITE_TRANSIENT);
        sqlite3_bind_text( statement, 22,[calcium UTF8String], -1, SQLITE_TRANSIENT);
        sqlite3_bind_text( statement, 23,[iron UTF8String], -1, SQLITE_TRANSIENT);
    }
    
    if(sqlite3_step(statement) != SQLITE_DONE )
    {
        NSLog( @"Insert Consumption Error: %s", sqlite3_errmsg(_prePopulatedDB));
    }
    sqlite3_finalize(statement);
    sqlite3_close(_prePopulatedDB);
}

//Update consumption
-(void)updateConsumptionWithConsumeID:(NSString*)consumeID ServingID:(NSString*)servingID ServingNumber:(NSString*)servingNumber ServingSize:(NSString*)servingSize Calories:(NSString*)calories TotalFats:(NSString*)totalFats saturatedFat:(NSString*)saturatedFat polyUnsaturatedFat:(NSString*)polyUnsaturatedFat MonounUnsaturatedFat:(NSString*)monounUnsaturatedFat Cholesterol:(NSString*)cholesterol Sodium:(NSString*)sodium Potassium:(NSString*)potassium TotalCarbohydrate:(NSString*)totalCarbohydrate DietaryFiber:(NSString*)dietaryFiber Sugars:(NSString*)sugars Protein:(NSString*)protein VitaminA:(NSString*)vitaminA VitaminC:(NSString*)vitaminC Calcium:(NSString*)calcium Iron:(NSString*)iron
{
    NSString *query = @"UPDATE Consumption SET ServingID=?, ServingNumber=?, ServingSize=?, Calories=?, TotalFats=?, SaturatedFat=?, PolyUnsaturatedFat=?, MonounUnsaturatedFat=?, Cholesterol=?, Sodium=?, Potassium=?, TotalCarbohydrate=?, DietaryFiber=?, Sugars=?, Protein=?, VitaminA=?, VitaminC=?, Calcium=?, Iron=? WHERE ConsumeID=?";
    sqlite3_stmt* statement;
    [self openDB];
    if (sqlite3_prepare_v2(_prePopulatedDB, [query UTF8String], -1, &statement, nil) == SQLITE_OK)
    {
        sqlite3_bind_text( statement, 1,[servingID UTF8String], -1, SQLITE_TRANSIENT);
        sqlite3_bind_text( statement, 2,[servingNumber UTF8String], -1, SQLITE_TRANSIENT);
        sqlite3_bind_text( statement, 3,[servingSize UTF8String], -1, SQLITE_TRANSIENT);
        sqlite3_bind_text( statement, 4,[calories UTF8String], -1, SQLITE_TRANSIENT);
        sqlite3_bind_text( statement, 5,[totalFats UTF8String], -1, SQLITE_TRANSIENT);
        sqlite3_bind_text( statement, 6,[saturatedFat UTF8String], -1, SQLITE_TRANSIENT);
        sqlite3_bind_text( statement, 7,[polyUnsaturatedFat UTF8String], -1, SQLITE_TRANSIENT);
        sqlite3_bind_text( statement, 8,[monounUnsaturatedFat UTF8String], -1, SQLITE_TRANSIENT);
        sqlite3_bind_text( statement, 9,[cholesterol UTF8String], -1, SQLITE_TRANSIENT);
        sqlite3_bind_text( statement, 10,[sodium UTF8String], -1, SQLITE_TRANSIENT);
        sqlite3_bind_text( statement, 11,[potassium UTF8String], -1, SQLITE_TRANSIENT);
        sqlite3_bind_text( statement, 12,[totalCarbohydrate UTF8String], -1, SQLITE_TRANSIENT);
        sqlite3_bind_text( statement, 13,[dietaryFiber UTF8String], -1, SQLITE_TRANSIENT);
        sqlite3_bind_text( statement, 14,[sugars UTF8String], -1, SQLITE_TRANSIENT);
        sqlite3_bind_text( statement, 15,[protein UTF8String], -1, SQLITE_TRANSIENT);
        sqlite3_bind_text( statement, 16,[vitaminA UTF8String], -1, SQLITE_TRANSIENT);
        sqlite3_bind_text( statement, 17,[vitaminC UTF8String], -1, SQLITE_TRANSIENT);
        sqlite3_bind_text( statement, 18,[calcium UTF8String], -1, SQLITE_TRANSIENT);
        sqlite3_bind_text( statement, 19,[iron UTF8String], -1, SQLITE_TRANSIENT);
        sqlite3_bind_text( statement, 20,[consumeID UTF8String], -1, SQLITE_TRANSIENT);
    }
    
    if(sqlite3_step(statement) != SQLITE_DONE )
    {
        NSLog( @"Update Consumption Error: %s", sqlite3_errmsg(_prePopulatedDB));
    }
    sqlite3_finalize(statement);
    sqlite3_close(_prePopulatedDB);
}

//Delete consumption
-(void)deleteConsumptionWithConsumeID:(NSString*)consumeID
{
    NSString *query = @"DELETE FROM Consumption WHERE ConsumeID=?";
    sqlite3_stmt* statement;
    [self openDB];
    if (sqlite3_prepare_v2(_prePopulatedDB, [query UTF8String], -1, &statement, nil) == SQLITE_OK)
    {
        sqlite3_bind_text( statement, 1,[consumeID UTF8String], -1, SQLITE_TRANSIENT);
    }
    
    if(sqlite3_step(statement) != SQLITE_DONE )
    {
        NSLog( @"Delete Consumption Error: %s", sqlite3_errmsg(_prePopulatedDB));
    }
    sqlite3_finalize(statement);
    sqlite3_close(_prePopulatedDB);
}


#pragma mark - All about favorite
-(NSArray*)favoriteList
{
    NSMutableArray* currentFavoriteList = [[NSMutableArray alloc] init];
    NSString *query = @"SELECT * FROM FavoriteFood ORDER BY foodID ASC";
    sqlite3_stmt* statement;
    [self openDB];
    if (sqlite3_prepare_v2(_prePopulatedDB, [query UTF8String], -1, &statement, nil) == SQLITE_OK)
    {
        while (sqlite3_step(statement) == SQLITE_ROW)
        {
            char* foodID = (char *) sqlite3_column_text(statement, 0);
            char* foodName = (char *) sqlite3_column_text(statement, 1);
            
            NSString* newFoodID = [[NSString alloc] initWithUTF8String:foodID];
            NSString* newFoodName = [[NSString alloc] initWithUTF8String:foodName];
            
            Food* currentFavorite = [[Food alloc]init];
            currentFavorite.foodID = newFoodID;
            currentFavorite.foodName = newFoodName;
            [currentFavoriteList addObject:currentFavorite];
        }
        sqlite3_finalize(statement);
        sqlite3_close(_prePopulatedDB);
    }
    else
    {
    }
    return currentFavoriteList;
}

//add favorite
-(void)addFavoriteWithFoodID:(NSString*)foodID WithFoodName:(NSString*)foodName
{
    NSString *query = @"insert into FavoriteFood (foodID, foodName) VALUES (?,?)";
    sqlite3_stmt* statement;
    [self openDB];
    if (sqlite3_prepare_v2(_prePopulatedDB, [query UTF8String], -1, &statement, nil) == SQLITE_OK)
    {
        sqlite3_bind_text( statement, 1,[foodID UTF8String], -1, SQLITE_TRANSIENT);
        sqlite3_bind_text( statement, 2,[foodName UTF8String], -1, SQLITE_TRANSIENT);
    }
    else
    {
        NSLog(@"could not prepare statemnt: %s\n", sqlite3_errmsg(_prePopulatedDB));
    }
    
    if(sqlite3_step(statement) != SQLITE_DONE )
    {
        NSLog( @"Insert Favorite Error: %s", sqlite3_errmsg(_prePopulatedDB));
    }
    sqlite3_finalize(statement);
    sqlite3_close(_prePopulatedDB);
}

//delete favorite
-(void)deleteFavoriteWithFoodID:(NSString*)foodID
{
    NSString *query = @"DELETE FROM FavoriteFood WHERE FoodID=?";
    sqlite3_stmt* statement;
    [self openDB];
    if (sqlite3_prepare_v2(_prePopulatedDB, [query UTF8String], -1, &statement, nil) == SQLITE_OK)
    {
        sqlite3_bind_text(statement, 1,[foodID UTF8String], -1, SQLITE_TRANSIENT);
    }
    
    if(sqlite3_step(statement) != SQLITE_DONE )
    {
        NSLog( @"Delete Favorite Error: %s", sqlite3_errmsg(_prePopulatedDB));
    }
    sqlite3_finalize(statement);
    sqlite3_close(_prePopulatedDB);
}

#pragma mark - recent list
-(NSArray*)recentList
{
    NSMutableArray* currentRecentList = [[NSMutableArray alloc] init];
    NSString* query = @"SELECT foodID,foodName FROM Consumption ORDER BY ConsumeDate DESC LIMIT 20";
    sqlite3_stmt* statement;
    [self openDB];
    if (sqlite3_prepare_v2(_prePopulatedDB, [query UTF8String], -1, &statement, nil) == SQLITE_OK)
    {
        while (sqlite3_step(statement) == SQLITE_ROW)
        {
            char* foodID = (char *) sqlite3_column_text(statement, 0);
            char* foodName = (char *) sqlite3_column_text(statement, 1);
            
            NSString* newFoodID = [[NSString alloc] initWithUTF8String:foodID];
            NSString* newFoodName = [[NSString alloc] initWithUTF8String:foodName];
            
            Food* currentFood = [[Food alloc]init];
            currentFood.foodID = newFoodID;
            currentFood.foodName = newFoodName;
            [currentRecentList addObject:currentFood];
        }
        sqlite3_finalize(statement);
        sqlite3_close(_prePopulatedDB);
    }
    else
    {
        NSLog(@"Error: %s", sqlite3_errmsg(_prePopulatedDB));
    }
    return currentRecentList;
}


@end
