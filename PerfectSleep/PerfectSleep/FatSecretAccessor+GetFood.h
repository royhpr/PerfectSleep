//
//  FatSecretAccessor+GetFood.h
//  PerfectSleep
//
//  Created by Huang Purong on 5/11/13.
//  Copyright (c) 2013 Huang Purong. All rights reserved.
//

#import "FatSecretAccessor.h"
#import "NutritionGeneral.h"

@interface FatSecretAccessor (GetFood)

-(NutritionGeneral*)GetFood:(NSString*)foodID;

@end
