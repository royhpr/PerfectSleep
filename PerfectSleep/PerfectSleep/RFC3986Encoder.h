//
//  RFC3986Encoder.h
//  PerfectSleep
//
//  Created by Huang Purong on 1/11/13.
//  Copyright (c) 2013 Huang Purong. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RFC3986Encoder : NSObject

+(NSString *) urlencode: (NSString *) url;

@end
