//
//  PlotColor.m
//  PerfectSleep
//
//  Created by Huang Purong on 2/4/14.
//  Copyright (c) 2014 Huang Purong. All rights reserved.
//

#import "PlotColor.h"

@interface PlotColor()

@property(nonatomic, readwrite)NSMutableDictionary* colorList;

@end


@implementation PlotColor

-(id)initColorList
{
    self = [super init];
    
    if(self)
    {
        self.colorList = [[NSMutableDictionary alloc]initWithObjectsAndKeys:@"ON",@"yellow", @"ON",@"green", @"ON",@"red", @"ON",@"blue", @"ON",@"purple", nil];
    }
    return self;
}

-(CPTColor*)returnAvailableColor
{
    if([[self.colorList objectForKey:@"yellow"]isEqualToString:@"ON"])
    {
        [self.colorList setValue:@"OFF" forKey:@"yellow"];
        return [CPTColor yellowColor];
    }
    
    if([[self.colorList objectForKey:@"green"]isEqualToString:@"ON"])
    {
        [self.colorList setValue:@"OFF" forKey:@"green"];
        return [CPTColor greenColor];
    }
    
    if([[self.colorList objectForKey:@"red"]isEqualToString:@"ON"])
    {
        [self.colorList setValue:@"OFF" forKey:@"red"];
        return [CPTColor redColor];
    }
    
    if([[self.colorList objectForKey:@"blue"]isEqualToString:@"ON"])
    {
        [self.colorList setValue:@"OFF" forKey:@"blue"];
        return [CPTColor blueColor];
    }

    if([[self.colorList objectForKey:@"purple"]isEqualToString:@"ON"])
    {
        [self.colorList setValue:@"OFF" forKey:@"purple"];
        return [CPTColor purpleColor];
    }

    return nil;
}

-(void)resetStateOfColor:(CPTColor*)color
{
    if([color isEqual:[CPTColor yellowColor]])
        [self.colorList setValue:@"ON" forKey:@"yellow"];
    
    if([color isEqual:[CPTColor greenColor]])
        [self.colorList setValue:@"ON" forKey:@"green"];
    
    if([color isEqual:[CPTColor redColor]])
        [self.colorList setValue:@"ON" forKey:@"red"];
    
    if([color isEqual:[CPTColor blueColor]])
        [self.colorList setValue:@"ON" forKey:@"blue"];
    
    if([color isEqual:[CPTColor purpleColor]])
        [self.colorList setValue:@"ON" forKey:@"purple"];
}

@end
