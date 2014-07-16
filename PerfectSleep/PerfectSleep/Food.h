//
//  food.h
//  PerfectSleep
//
//  Created by Huang Purong on 4/11/13.
//  Copyright (c) 2013 Huang Purong. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Food : NSObject

@property(nonatomic,readwrite)NSString* foodID;
@property(nonatomic,readwrite)NSString* foodName;
@property(nonatomic,readwrite)NSString* foodType;
@property(nonatomic,readwrite)NSString* foodURL;
@property(nonatomic,readwrite)NSString* foodDescription;

@end
