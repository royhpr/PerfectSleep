//
//  FatSecretAccessor.m
//  PerfectSleep
//
//  Created by Huang Purong on 1/11/13.
//  Copyright (c) 2013 Huang Purong. All rights reserved.
//

#import "FatSecretAccessor.h"

@interface FatSecretAccessor()

@end


@implementation FatSecretAccessor

-(id)initBySettingStaticParameters
{
    if(self = [super init])
    {
        self.requestURL = REQUEST_URL;
        
        //basic
        self.paraCustomerKey = [[Parameter alloc]init];
        [self.paraCustomerKey setName:OAUTH_CUSTOMER_KEY];
        [self.paraCustomerKey setValue:CUSTOMER_KEY];
        
        //basic
        self.paraSignatureMethod = [[Parameter alloc]init];
        [self.paraSignatureMethod setName:OAUTH_SIGNATURE_METHOD];
        [self.paraSignatureMethod setValue:SIGNATURE_METHOD];
        
        //basic
        self.paraVersion = [[Parameter alloc]init];
        [self.paraVersion setName:OAUTH_VERSION];
        [self.paraVersion setValue:VERSION];
        
        //basic
        self.paraTimeStamp = [[Parameter alloc]init];
        [self.paraTimeStamp setName:OAUTH_TIME_STAMPT];
        
        //basic
        self.paraNonce = [[Parameter alloc]init];
        [self.paraNonce setName:OAUTH_NONCE];
    }
    
    return self;
}

-(NSString*)generateParameterStringWithSortedParameterList:(NSMutableArray*)sortedParameterList
{
    //Generate name=value pair and concentenate each pair by '&'
    NSMutableArray* sortedParametersForSearchWithNameEqualValueFormat = [[NSMutableArray alloc]init];
    for(Parameter* currentParameter in sortedParameterList)
    {
        [sortedParametersForSearchWithNameEqualValueFormat addObject:[currentParameter combineNameValue]];
    }
    
    return [sortedParametersForSearchWithNameEqualValueFormat componentsJoinedByString:AMPHERSEN];
}

-(NSString*)generateSignatureValueWithParameterString:(NSString*)concantenatedParameterString
{
    //Generate signature base string
    NSMutableString* signatureBaseString = [NSMutableString stringWithString:[RFC3986Encoder urlencode:self.httpMethod]];
    [signatureBaseString appendString:AMPHERSEN];
    [signatureBaseString appendString:[RFC3986Encoder urlencode:self.requestURL]];
    [signatureBaseString appendString:AMPHERSEN];
    [signatureBaseString appendString:[RFC3986Encoder urlencode:concantenatedParameterString]];
    
    //Genereate signature key
    NSString* key = [NSString stringWithFormat:@"%@&%@",
					 SHARED_FATSECRET,
					 EMPTY_ACCESS_SECRET];
    
    //Sign request
    NSData* signature = [self HMAC_SHA1:signatureBaseString : key];
    
    //Encoded base64 string
	NSString* base64Signature = [signature base64EncodedString];
    
    //Escaped RFC3986
    NSString* base64WithRFC3986EscapedSignature = [RFC3986Encoder urlencode:base64Signature];
    
    return base64WithRFC3986EscapedSignature;
}

//-(void)SendGetRequestWithHTTPBody:(NSString*)httpBody
//{
//    //Generate URL string
//    NSMutableString* URLString = [NSMutableString stringWithString:self.requestURL];
//    [URLString appendString:QUESITON_MARK];
//    [URLString appendString:httpBody];
//    
//    //Make request
////    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
////    [request setHTTPMethod:HTTP_METHOD_GET];
////    [request setURL:[NSURL URLWithString:URLString]];
////    
////    NSError *error = [[NSError alloc] init];
////    NSHTTPURLResponse *responseCode = nil;
////    
////    NSData *ResponseData = [NSURLConnection sendSynchronousRequest:request returningResponse:&responseCode error:&error];
////    
////    if([responseCode statusCode] != 200)
////    {
////        NSLog(@"Error getting %@, HTTP status code %li", URLString, (long)[responseCode statusCode]);
////        return nil;
////    }
//    self.parser = nil;
//    self.parser = [[XMLParser alloc]loadXMLByURL:URLString WithType:SearchFood];
//}

-(NSString*)generateURLString:(NSString*)httpBody
{
    //Generate URL string
    NSMutableString* URLString = [NSMutableString stringWithString:self.requestURL];
    [URLString appendString:QUESITON_MARK];
    [URLString appendString:httpBody];
    
    return URLString;
}

-(NSData*)HMAC_SHA1:(NSString*)data : (NSString*) key
{
	unsigned char buf[CC_SHA1_DIGEST_LENGTH];
	CCHmac(kCCHmacAlgSHA1, [key UTF8String], [key length], [data UTF8String], [data length], buf);
	return [NSData dataWithBytes:buf length:CC_SHA1_DIGEST_LENGTH];
}

-(NSMutableArray*)sortArrayInlexicographicalOrder: (NSMutableArray*)arrayPendingForSort
{
    NSMutableArray *sortedArray;
    sortedArray = [NSMutableArray arrayWithArray:[arrayPendingForSort sortedArrayUsingComparator:^NSComparisonResult(id a, id b)
    {
        Parameter* first = (Parameter*)a;
        Parameter* second = (Parameter*)b;
        NSComparisonResult result = [first.name compare:second.name];
        
        switch (result)
        {
            case NSOrderedAscending:
                
                return NSOrderedAscending;
                
            case NSOrderedDescending:
                
                return NSOrderedDescending;
                
            case NSOrderedSame:
                
                return [first.value compare:second.value];
            default:
                break;
        }

    }]];
    
    return sortedArray;
}

-(NSString *)randomString
{
	CFUUIDRef u = CFUUIDCreate(kCFAllocatorDefault);
	CFStringRef s = CFUUIDCreateString(kCFAllocatorDefault, u);
	CFRelease(u);
	return (__bridge NSString *)s;
}

@end
