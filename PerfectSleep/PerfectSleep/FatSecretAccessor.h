//
//  FatSecretAccessor.h
//  PerfectSleep
//
//  Created by Huang Purong on 1/11/13.
//  Copyright (c) 2013 Huang Purong. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CommonCrypto/CommonHMAC.h>
#import "FatSecretContant.h"
#import "Parameter.h"
#import "RFC3986Encoder.h"
#import "NSData+Base64Encoder.h"
#import "XMLParser.h"
#import "Food.h"


@interface FatSecretAccessor : NSObject

@property(nonatomic, readonly)int numberOfResult;

//Common
@property(nonatomic,readwrite)NSString* httpMethod;
@property(nonatomic,readwrite)NSString* requestURL;

//Normalized Parameters
@property(nonatomic,readwrite)Parameter* paraCustomerKey;
@property(nonatomic,readwrite)Parameter* paraSignatureMethod;
@property(nonatomic,readwrite)Parameter* paraVersion;
@property(nonatomic,readwrite)Parameter* paraTimeStamp;
@property(nonatomic,readwrite)Parameter* paraNonce;
@property(nonatomic,readwrite)Parameter* paraSharedSecret;

//Methods
-(id)initBySettingStaticParameters;


//Methods For Category
-(NSString*)generateParameterStringWithSortedParameterList:(NSMutableArray*)sortedParameterList
;
-(NSString*)generateSignatureValueWithParameterString:(NSString*)concantenatedParameterString;
-(NSString*)generateURLString:(NSString*)httpBody;
-(NSMutableArray*)sortArrayInlexicographicalOrder: (NSMutableArray*)arrayPendingForSort;
-(NSString *)randomString;
-(NSData*)HMAC_SHA1:(NSString*)data : (NSString*) key;

@end
