//
//  XMLParser.m
//  PerfectSleep
//
//  Created by Huang Purong on 4/11/13.
//  Copyright (c) 2013 Huang Purong. All rights reserved.
//

#import "XMLParser.h"

@interface XMLParser()

@property(nonatomic,readwrite)PaserType type;

@property (nonatomic, readwrite)NSMutableArray* foods;
@property(nonatomic,readwrite)NSMutableString* currentNodeContent;
@property(nonatomic,readwrite)NSXMLParser* parser;
@property(nonatomic,readwrite)Food* currentFood;
@property(nonatomic,readwrite)NSString* totalNumberOfResult;

@property(nonatomic,readwrite)NutritionGeneral* foodGeneralInfo;
@property(nonatomic,readwrite)NutritionByServingSize* currentServing;

@end

@implementation XMLParser

-(id) loadXMLByURL:(NSString *)urlString WithType:(PaserType)type
{
    self.type = type;
    if(type == SearchFood)
    {
        self.foods = [[NSMutableArray alloc] init];
    }

	NSURL* url = [NSURL URLWithString:urlString];
	NSData* data  = [[NSData alloc] initWithContentsOfURL:url];
	self.parser	= [[NSXMLParser alloc] initWithData:data];
	self.parser.delegate = self;
	[self.parser parse];
	return self;
}

//Detect start of a node
- (void) parser:(NSXMLParser *)parser didStartElement:(NSString *)elementname namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict
{
    if(self.type == SearchFood)
    {
        if ([elementname isEqualToString:FOOD_SECTION])
        {
            self.currentFood = [[Food alloc]init];
        }
    }
    else if(self.type == GetFood)
    {
        if([elementname isEqualToString:FOOD_ID])
        {
            self.foodGeneralInfo = [[NutritionGeneral alloc]init];
        }
        if([elementname isEqualToString:SERVINGS_SECTION])
        {
            self.foodGeneralInfo.servings = [[NSMutableArray alloc]init];
        }
        if([elementname isEqualToString:SINGLE_SERVING_SECTION])
        {
            self.currentServing = [[NutritionByServingSize alloc]init];
        }
    }
}

//Detect end of a node
- (void) parser:(NSXMLParser *)parser didEndElement:(NSString *)elementname namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName
{
    if(self.type == SearchFood)
    {
        [self parseResultOfSearchFood:elementname];
    }
    else if(self.type == GetFood)
    {
        [self parseResultOfGetFood:elementname];
    }
}


- (void) parser:(NSXMLParser *)parser foundCharacters:(NSString *)string
{
	self.currentNodeContent = (NSMutableString *) [string stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
}

//Parse Get Food Reply
-(void)parseResultOfGetFood:(NSString*)elementname
{
    if([elementname isEqualToString:FOOD_ID])
    {
        [self.foodGeneralInfo setFoodID:self.currentNodeContent];
    }
    if([elementname isEqualToString:FOOD_NAME])
    {
        [self.foodGeneralInfo setFoodName:self.currentNodeContent];
    }
    if([elementname isEqualToString:FOOD_TYPE])
    {
        [self.foodGeneralInfo setFoodType:self.currentNodeContent];
    }
    if([elementname isEqualToString:FOOD_URL])
    {
        [self.foodGeneralInfo setFoodURL:self.currentNodeContent];
    }

    
    if([elementname isEqualToString:SERVING_ID])
    {
        [self.currentServing setServingID:self.currentNodeContent];
    }
    if([elementname isEqualToString:SERVING_DESCRIPTION])
    {
        [self.currentServing setServingDescription:self.currentNodeContent];
    }
    if([elementname isEqualToString:SERVING_URL])
    {
        [self.currentServing setServingURL:self.currentNodeContent];
    }
    if([elementname isEqualToString:METRIC_SERVING_AMOUNT])
    {
        [self.currentServing setMetricServingAmount:self.currentNodeContent];
    }
    if([elementname isEqualToString:METRIC_SERVING_UNIT])
    {
        [self.currentServing setMetricServingUnit:self.currentNodeContent];
    }
    if([elementname isEqualToString:NUMBER_OF_UNITS])
    {
        [self.currentServing setNumberOfUnits:self.currentNodeContent];
    }
    if([elementname isEqualToString:MEASUREMENT_DESCRIPTION])
    {
        [self.currentServing setMeasurementDescription:self.currentNodeContent];
    }
    if([elementname isEqualToString:CALORIES])
    {
        [self.currentServing setCalories:self.currentNodeContent];
    }
    if([elementname isEqualToString:CARBONHYDRATE])
    {
        [self.currentServing setCarbohydrate:self.currentNodeContent];
    }
    if([elementname isEqualToString:PROTAIN])
    {
        [self.currentServing setProtein:self.currentNodeContent];
    }
    if([elementname isEqualToString:FAT])
    {
        [self.currentServing setFat:self.currentNodeContent];
    }
    if([elementname isEqualToString:SATUATED_FAT])
    {
        [self.currentServing setSaturatedFat:self.currentNodeContent];
    }
    if([elementname isEqualToString:POLY_UNSATUATED_FAT])
    {
        [self.currentServing setPolyUnsaturatedFat:self.currentNodeContent];
    }
    if([elementname isEqualToString:MONOUN_UNSATUATED_FAT])
    {
        [self.currentServing setMonounsaturatedFat:self.currentNodeContent];
    }
    if([elementname isEqualToString:TRANS_FAT])
    {
        [self.currentServing setTransFat:self.currentNodeContent];
    }
    if([elementname isEqualToString:CHOLESTORAL])
    {
        [self.currentServing setCholesterol:self.currentNodeContent];
    }
    if([elementname isEqualToString:SODIUM])
    {
        [self.currentServing setSodium:self.currentNodeContent];
    }
    if([elementname isEqualToString:POTASSIUM])
    {
        [self.currentServing setPotassium:self.currentNodeContent];
    }
    if([elementname isEqualToString:FIBER])
    {
        [self.currentServing setFiber:self.currentNodeContent];
    }
    if([elementname isEqualToString:SUGAR])
    {
        [self.currentServing setSugar:self.currentNodeContent];
    }
    if([elementname isEqualToString:VITAMIN_A])
    {
        [self.currentServing setVitaminA:self.currentNodeContent];
    }
    if([elementname isEqualToString:VITAMIN_C])
    {
        [self.currentServing setVitaminC:self.currentNodeContent];
    }
    if([elementname isEqualToString:CALCIUM])
    {
        [self.currentServing setCalcium:self.currentNodeContent];
    }
    if([elementname isEqualToString:IRON])
    {
        [self.currentServing setIron:self.currentNodeContent];
    }
    
    if([elementname isEqualToString:SINGLE_SERVING_SECTION])
    {
        [self.foodGeneralInfo.servings addObject:self.currentServing];
        self.currentServing = nil;
        self.currentNodeContent = nil;
    }
}

//Parse search food reply
- (void)parseResultOfSearchFood:(NSString *)elementname
{
    if([elementname isEqualToString:TOTAL_RESULT])
    {
        self.totalNumberOfResult = self.currentNodeContent;
    }
    
    if([elementname isEqualToString:FOOD_ID])
    {
        [self.currentFood setFoodID:self.currentNodeContent];
    }
    
    if([elementname isEqualToString:FOOD_NAME])
    {
        [self.currentFood setFoodName:self.currentNodeContent];
    }
    
    if([elementname isEqualToString:FOOD_TYPE])
    {
        [self.currentFood setFoodType:self.currentNodeContent];
    }
    
    if([elementname isEqualToString:FOOD_URL])
    {
        [self.currentFood setFoodURL:self.currentNodeContent];
    }
    
    if([elementname isEqualToString:FOOD_DESCRIPTION])
    {
        [self.currentFood setFoodDescription:self.currentNodeContent];
    }
    
    if([elementname isEqualToString:FOOD_SECTION])
    {
        [self.foods addObject:self.currentFood];
        self.currentFood = nil;
        self.currentNodeContent = nil;
    }
}

@end
