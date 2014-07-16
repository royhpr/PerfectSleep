//
//  NSData+Base64Encoder.h
//  PerfectSleep
//
//  Created by Huang Purong on 4/11/13.
//  Copyright (c) 2013 Huang Purong. All rights reserved.
//

#import <Foundation/Foundation.h>

@class NSString;

@interface NSData (Base64Encoder)

+ (NSData *) dataFromBase64String: (NSString *) base64String;
- (id) initWithBase64String: (NSString *) base64String;
- (NSString *) base64EncodedString;

@end
