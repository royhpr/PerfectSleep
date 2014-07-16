//
//  Favorite.m
//  PerfectSleep
//
//  Created by RoyHPR on 4/4/14.
//  Copyright (c) 2014 Huang Purong. All rights reserved.
//

#import "Favorite.h"

@implementation Favorite

-(id)initWithFoodID:(NSString*)foodID :(NSString*)foodName
{
    if(self = [super init])
    {
        _foodID = foodID;
        _foodName = foodName;
    }
    
    return self;
}

@end
