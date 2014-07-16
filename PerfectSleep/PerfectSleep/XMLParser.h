//
//  XMLParser.h
//  PerfectSleep
//
//  Created by Huang Purong on 4/11/13.
//  Copyright (c) 2013 Huang Purong. All rights reserved.
//


#import <Foundation/Foundation.h>
#import "Food.h"
#import "NutritionGeneral.h"
#import "FatSecretContant.h"

typedef enum
{
    SearchFood,
    GetFood
}PaserType;

@interface XMLParser : NSObject <NSXMLParserDelegate>

@property(nonatomic,readonly)PaserType type;

//Search Food
@property(nonatomic,readonly)NSMutableArray* foods;
@property(nonatomic,readonly)NSMutableString* currentNodeContent;
@property(nonatomic,readonly)NSXMLParser* parser;
@property(nonatomic,readonly)Food* currentFood;
@property(nonatomic,readonly)NSString* totalNumberOfResult;


//Get Food
@property(nonatomic,readonly)NutritionGeneral* foodGeneralInfo;
@property(nonatomic,readonly)NutritionByServingSize* currentServing;

-(id) loadXMLByURL:(NSString *)urlString WithType:(PaserType)type;

@end
