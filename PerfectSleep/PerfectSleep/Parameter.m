//
//  Parameter.m
//  PerfectSleep
//
//  Created by Huang Purong on 2/11/13.
//  Copyright (c) 2013 Huang Purong. All rights reserved.
//

#import "Parameter.h"

@implementation Parameter

-(NSString*)combineNameValue
{
    NSMutableString* resultString = [NSMutableString stringWithString:self.name];
    [resultString appendString:EQUAL];
    [resultString appendString:self.value];
    
    return resultString;
}

@end
