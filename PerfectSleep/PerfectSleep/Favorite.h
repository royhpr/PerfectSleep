//
//  Favorite.h
//  PerfectSleep
//
//  Created by RoyHPR on 4/4/14.
//  Copyright (c) 2014 Huang Purong. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Favorite : NSObject

@property(nonatomic, readwrite)NSString* foodID;
@property(nonatomic, readwrite)NSString* foodName;

-(id)initWithFoodID:(NSString*)foodID :(NSString*)foodName;

@end
