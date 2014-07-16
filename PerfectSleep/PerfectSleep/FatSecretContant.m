//
//  Contant.m
//  PerfectSleep
//
//  Created by Huang Purong on 2/11/13.
//  Copyright (c) 2013 Huang Purong. All rights reserved.
//

#import "FatSecretContant.h"

/******Extra Punctuation*******/
NSString* EQUAL = @"=";
NSString* AMPHERSEN = @"&";
NSString* QUESITON_MARK = @"?";


/******End Extra Punctuation***/


/******Common*******************/
int MAX_RESULT = 20;
int FIRST_PAGE = 0;
/******End Common****************/



/***Required parameters**********/
//name
NSString* OAUTH_CUSTOMER_KEY = @"oauth_consumer_key";
NSString* OAUTH_SHARED_FATSECRET = @" ";
NSString* OAUTH_SIGNATURE_METHOD = @"oauth_signature_method";
NSString* OAUTH_VERSION = @"oauth_version";
NSString* OAUTH_TIME_STAMPT = @"oauth_timestamp";
NSString* OAUTH_NONCE = @"oauth_nonce";

//value
NSString* CUSTOMER_KEY = @"4fed2e612eed415d853303cb4e836302";
NSString* SHARED_FATSECRET = @"90f7cfde8b9c4528adeaee7ba87dce45";
NSString* SIGNATURE_METHOD = @"HMAC-SHA1";
NSString* VERSION = @"1.0";

NSString* EMPTY_ACCESS_SECRET = @"";
/****End Required Parameters*****/


/****Http methods and URL*********/
NSString* HTTP_METHOD_GET = @"GET";
NSString* HTTP_METHOD_POST = @"POST";
NSString* REQUEST_URL = @"http://platform.fatsecret.com/rest/server.api";
/*****End*************************/


/*****Search Food Parameters******/
//name
NSString* OAUTH_METHOD = @"method";
NSString* OAUTH_SEARCH_EXPRESSION = @"search_expression";
NSString* OAUTH_SIGNATURE = @"oauth_signature";
NSString* OAUTH_PAGE_NUMBER = @"page_number";

//value
NSString* METHOD_FOOD_SEARCH = @"foods.search";
NSString* METHOD_GET_FOOD = @"food.get";
/*****End Search Food Parameters**/


/********XML parser**********/
//search food
NSString* TOTAL_RESULT = @"total_results";
NSString* FOOD_SECTION = @"food";
NSString* FOOD_ID = @"food_id";
NSString* FOOD_NAME = @"food_name";
NSString* FOOD_TYPE = @"food_type";
NSString* FOOD_URL = @"food_url";
NSString* FOOD_DESCRIPTION = @"food_description";


//get food
NSString* SERVINGS_SECTION = @"servings";
NSString* SINGLE_SERVING_SECTION = @"serving";
NSString* BRAND_NAME = @"brand_name";

NSString* SERVING_ID = @"serving_id";
NSString* SERVING_DESCRIPTION = @"serving_description";
NSString* SERVING_URL = @"serving_url";
NSString* METRIC_SERVING_AMOUNT = @"metric_serving_amount";
NSString* METRIC_SERVING_UNIT = @"metric_serving_unit";
NSString* NUMBER_OF_UNITS = @"number_of_units";
NSString* MEASUREMENT_DESCRIPTION = @"measurement_description";

NSString* CALORIES = @"calories";
NSString* CARBONHYDRATE = @"carbohydrate";
NSString* PROTAIN = @"protein";
NSString* FAT = @"fat";
NSString* SATUATED_FAT = @"saturated_fat";
NSString* POLY_UNSATUATED_FAT = @"polyunsaturated_fat";
NSString* MONOUN_UNSATUATED_FAT = @"monounsaturated_fat";
NSString* TRANS_FAT = @"trans_fat";
NSString* CHOLESTORAL = @"cholesterol";
NSString* SODIUM = @"sodium";
NSString* POTASSIUM = @"potassium";
NSString* FIBER = @"fiber";
NSString* SUGAR = @"sugar";
NSString* VITAMIN_A = @"vitamin_a";
NSString* VITAMIN_C = @"vitamin_c";
NSString* CALCIUM = @"calcium";
NSString* IRON = @"iron";
/********End XML parser******/


@implementation FatSecretContant

@end
