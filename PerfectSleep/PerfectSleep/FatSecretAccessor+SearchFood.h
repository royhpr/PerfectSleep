//
//  FatSecretAccessor+SearchFood.h
//  PerfectSleep
//
//  Created by Huang Purong on 5/11/13.
//  Copyright (c) 2013 Huang Purong. All rights reserved.
//

#import "FatSecretAccessor.h"

@interface FatSecretAccessor (SearchFood)

-(NSMutableArray*)searchFood:(NSString*)food withPageNumber:(int)pageNumber;

@end
