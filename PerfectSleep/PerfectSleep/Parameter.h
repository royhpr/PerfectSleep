//
//  Parameter.h
//  PerfectSleep
//
//  Created by Huang Purong on 2/11/13.
//  Copyright (c) 2013 Huang Purong. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FatSecretContant.h"

@interface Parameter : NSObject

@property(nonatomic,readwrite)NSString* name;
@property(nonatomic,readwrite)NSString* value;

-(NSString*)combineNameValue;

@end
