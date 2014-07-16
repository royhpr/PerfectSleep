//
//  PlotColor.h
//  PerfectSleep
//
//  Created by Huang Purong on 2/4/14.
//  Copyright (c) 2014 Huang Purong. All rights reserved.
//

#import "CPTColor.h"

@interface PlotColor : NSObject

-(id)initColorList;
-(CPTColor*)returnAvailableColor;
-(void)resetStateOfColor:(CPTColor*)color;

@end
