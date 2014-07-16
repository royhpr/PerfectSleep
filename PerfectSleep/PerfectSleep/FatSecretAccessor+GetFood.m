//
//  FatSecretAccessor+GetFood.m
//  PerfectSleep
//
//  Created by Huang Purong on 5/11/13.
//  Copyright (c) 2013 Huang Purong. All rights reserved.
//

#import "FatSecretAccessor+GetFood.h"

@implementation FatSecretAccessor (GetFood)

-(NutritionGeneral*)GetFood:(NSString*)foodID
{
    //Get first page result
    NSString* initialURLString = [self returnURLStringWithFoodID:foodID];
    XMLParser* initialParser = [[XMLParser alloc]loadXMLByURL:initialURLString WithType:GetFood];
    
    return initialParser.foodGeneralInfo;
}

-(NSString*)returnURLStringWithFoodID:(NSString*)foodID
{
    self.httpMethod = HTTP_METHOD_GET;
    
    //Initialize current time stamp and nonce(random string)
    [self.paraTimeStamp setValue:[NSString stringWithFormat:@"%d", (int)[[NSDate date] timeIntervalSince1970]]];
    
    //[self.paraNonce setValue:[self randomString]];
    [self.paraNonce setValue:[self randomString]];
    
    //Initialize extra parameters
    Parameter* paraMethod = [[Parameter alloc]init];
    [paraMethod setName:OAUTH_METHOD];
    [paraMethod setValue:METHOD_GET_FOOD];
    
    Parameter* paraFoodID = [[Parameter alloc]init];
    [paraFoodID setName:FOOD_ID];
    [paraFoodID setValue:foodID];
    
    //Generate normalized parameters list (a parameter array)
    NSMutableArray* parametersForSearch = [[NSMutableArray alloc]init];
    [parametersForSearch addObject:self.paraCustomerKey];
    [parametersForSearch addObject:self.paraNonce];
    [parametersForSearch addObject:self.paraSignatureMethod];
    [parametersForSearch addObject:self.paraTimeStamp];
    [parametersForSearch addObject:self.paraVersion];
    [parametersForSearch addObject:paraMethod];
    [parametersForSearch addObject:paraFoodID];
    
    //Sort the array in lexicographical order
    NSMutableArray* sortedParametersForSearch = [self sortArrayInlexicographicalOrder:parametersForSearch];
    
    //Generate parameter string (parameters concentenated with '&')
    NSString* stringWithConcentenatedParameters = [self generateParameterStringWithSortedParameterList:sortedParametersForSearch];
    
    //Generate signature value
    NSString* signatureValue = [self generateSignatureValueWithParameterString:stringWithConcentenatedParameters];
    
    //Create Signature Parameter
    Parameter* paraSignature = [[Parameter alloc]init];
    [paraSignature setName:OAUTH_SIGNATURE];
    [paraSignature setValue:signatureValue];
    
    //Generate Http Body
    [sortedParametersForSearch addObject:paraSignature];
    NSString* httpBody = [self generateParameterStringWithSortedParameterList:sortedParametersForSearch];
    
    return [self generateURLString:httpBody];
}

@end
