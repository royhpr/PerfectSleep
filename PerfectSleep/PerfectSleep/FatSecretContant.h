//
//  Contant.h
//  PerfectSleep
//
//  Created by Huang Purong on 2/11/13.
//  Copyright (c) 2013 Huang Purong. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FatSecretContant : NSObject

/******Extra Punctuation*******/
extern NSString* EQUAL;
extern NSString* AMPHERSEN;
extern NSString* QUESITON_MARK;
/******End Extra Punctuation***/


/******Common*******************/
extern int MAX_RESULT;
extern int FIRST_PAGE;
/******End Common****************/



/***Required parameters**********/
//name
extern NSString* OAUTH_CUSTOMER_KEY;
extern NSString* OAUTH_SHARED_FATSECRET;
extern NSString* OAUTH_SIGNATURE_METHOD;
extern NSString* OAUTH_VERSION;
extern NSString* OAUTH_TIME_STAMPT;
extern NSString* OAUTH_NONCE;

//value
extern NSString* CUSTOMER_KEY;
extern NSString* SHARED_FATSECRET;
extern NSString* SIGNATURE_METHOD;
extern NSString* VERSION;

extern NSString* EMPTY_ACCESS_SECRET;
/****End Required Parameters*****/



/****Http methods and URL*********/
extern NSString* HTTP_METHOD_GET;
extern NSString* HTTP_METHOD_POST;

extern NSString* REQUEST_URL;
/*****End*************************/

/*****Search Food Parameters******/
//name
extern NSString* OAUTH_METHOD;
extern NSString* OAUTH_SEARCH_EXPRESSION;
extern NSString* OAUTH_SIGNATURE;
extern NSString* OAUTH_PAGE_NUMBER;

//value
extern NSString* METHOD_FOOD_SEARCH;
extern NSString* METHOD_GET_FOOD;
/*****End Search Food Parameters**/

/********XML parser**********/
//search food
extern NSString* TOTAL_RESULT;
extern NSString* FOOD_SECTION;
extern NSString* FOOD_ID;
extern NSString* FOOD_NAME;
extern NSString* FOOD_TYPE;
extern NSString* FOOD_URL;
extern NSString* FOOD_DESCRIPTION;


//get food
extern NSString* SERVINGS_SECTION;
extern NSString* SINGLE_SERVING_SECTION;
extern NSString* FOOD_ID;
extern NSString* FOOD_NAME;
extern NSString* FOOD_TYPE;
extern NSString* BRAND_NAME;
extern NSString* FOOD_URL;

extern NSString* SERVING_ID;
extern NSString* SERVING_DESCRIPTION;
extern NSString* SERVING_URL;
extern NSString* METRIC_SERVING_AMOUNT;
extern NSString* METRIC_SERVING_UNIT;
extern NSString* NUMBER_OF_UNITS;
extern NSString* MEASUREMENT_DESCRIPTION;

extern NSString* CALORIES;
extern NSString* CARBONHYDRATE;
extern NSString* PROTAIN;
extern NSString* FAT;
extern NSString* SATUATED_FAT;
extern NSString* POLY_UNSATUATED_FAT;
extern NSString* MONOUN_UNSATUATED_FAT;
extern NSString* TRANS_FAT;
extern NSString* CHOLESTORAL;
extern NSString* SODIUM;
extern NSString* POTASSIUM;
extern NSString* FIBER;
extern NSString* SUGAR;
extern NSString* VITAMIN_A;
extern NSString* VITAMIN_C;
extern NSString* CALCIUM;
extern NSString* IRON;

/********End XML parser******/


@end
