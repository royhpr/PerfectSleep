//
//  ConsumedFood.h
//  PerfectSleep
//
//  Created by RoyHPR on 4/4/14.
//  Copyright (c) 2014 Huang Purong. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ConsumedFood : NSObject

@property(nonatomic, readwrite)NSString* consumeID;
@property(nonatomic, readwrite)NSString* foodID;
@property(nonatomic, readwrite)NSString* servingID;
@property(nonatomic, readwrite)NSString* foodName;
@property(nonatomic, readwrite)NSString* servingNumber;
@property(nonatomic, readwrite)NSString* servingSize;
@property(nonatomic, readwrite)NSDate* consumeDate;

@property(nonatomic, readwrite)NSString* calories;
@property(nonatomic, readwrite)NSString* totalFats;
@property(nonatomic, readwrite)NSString* saturatedFat;
@property(nonatomic, readwrite)NSString* polyUnsaturatedFat;
@property(nonatomic, readwrite)NSString* monounUnsaturatedFat;
@property(nonatomic, readwrite)NSString* cholesterol;
@property(nonatomic, readwrite)NSString* sodium;
@property(nonatomic, readwrite)NSString* pottasium;
@property(nonatomic, readwrite)NSString* totalCarbohydrate;
@property(nonatomic, readwrite)NSString* dietaryFiber;
@property(nonatomic, readwrite)NSString* sugars;
@property(nonatomic, readwrite)NSString* protein;
@property(nonatomic, readwrite)NSString* vitaminA;
@property(nonatomic, readwrite)NSString* vitaminC;
@property(nonatomic, readwrite)NSString* calcium;
@property(nonatomic, readwrite)NSString* iron;

-(id)initWith:(NSString*)consumeID :(NSString*)foodID :(NSString*)servingID :(NSString*)foodName :(NSString*)servingNumber :(NSString*)servingSize :(NSDate*)consumeDate :(NSString*)calories :(NSString*)totalFats :(NSString*)saturatedFat :(NSString*)polyUnsaturatedFat :(NSString*)monounUnsaturatedFat :(NSString*)cholesterol :(NSString*)sodium :(NSString*)pottasium :(NSString*)totalCarbohydrate :(NSString*)dietaryFiber :(NSString*)sugars :(NSString*)protein :(NSString*)vitaminA :(NSString*)vitaminC :(NSString*)calcium :(NSString*)iron;

@end
