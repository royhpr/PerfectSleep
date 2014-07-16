//
//  FatSecretAccessor+SearchFood.m
//  PerfectSleep
//
//  Created by Huang Purong on 5/11/13.
//  Copyright (c) 2013 Huang Purong. All rights reserved.
//

#import "FatSecretAccessor+SearchFood.h"

@implementation FatSecretAccessor (SearchFood)

-(NSMutableArray*)searchFood:(NSString*)food withPageNumber:(int)pageNumber
{    
    //Get first page result
    NSString* initialURLString = [self returnURLStringWithPageNumber:pageNumber Food:food];
    XMLParser* initialParser = [[XMLParser alloc]loadXMLByURL:initialURLString WithType:SearchFood];
    
    int pages = (int)ceil((float)[[initialParser totalNumberOfResult]intValue]/20.0);
    NSNumber* numberOfPages = [[NSNumber alloc]initWithInt:pages];
    NSMutableArray* searchResult = [[NSMutableArray alloc]initWithObjects:[initialParser foods], numberOfPages, nil];
    
    return searchResult;
}

-(NSString*)returnURLStringWithPageNumber:(int)pageNumber Food:(NSString*)food
{
    self.httpMethod = HTTP_METHOD_GET;
    
    //Initialize current time stamp and nonce(random string)
    [self.paraTimeStamp setValue:[NSString stringWithFormat:@"%d", (int)[[NSDate date] timeIntervalSince1970]]];
    
    //[self.paraNonce setValue:[self randomString]];
    [self.paraNonce setValue:[self randomString]];
    
    //Initialize extra parameters
    Parameter* paraMethod = [[Parameter alloc]init];
    [paraMethod setName:OAUTH_METHOD];
    [paraMethod setValue:METHOD_FOOD_SEARCH];
    
    Parameter* paraSearchExpression = [[Parameter alloc]init];
    [paraSearchExpression setName:OAUTH_SEARCH_EXPRESSION];
    [paraSearchExpression setValue:food];
    
    Parameter* paraPageNumber = [[Parameter alloc]init];
    [paraPageNumber setName:OAUTH_PAGE_NUMBER];
    [paraPageNumber setValue:[NSString stringWithFormat:@"%d",pageNumber]];
    
    //Generate normalized parameters list (a parameter array)
    NSMutableArray* parametersForSearch = [[NSMutableArray alloc]init];
    [parametersForSearch addObject:self.paraCustomerKey];
    [parametersForSearch addObject:self.paraNonce];
    [parametersForSearch addObject:self.paraSignatureMethod];
    [parametersForSearch addObject:self.paraTimeStamp];
    [parametersForSearch addObject:self.paraVersion];
    [parametersForSearch addObject:paraMethod];
    [parametersForSearch addObject:paraSearchExpression];
    [parametersForSearch addObject:paraPageNumber];
    
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
