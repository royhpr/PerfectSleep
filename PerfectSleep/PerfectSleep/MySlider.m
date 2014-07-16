//
//  MySlider.m
//  PerfectSleep
//
//  Created by Huang Purong on 27/3/14.
//  Copyright (c) 2014 Huang Purong. All rights reserved.
//

#import "MySlider.h"

#define THUMB_SIZE 30
#define EFFECTIVE_THUMB_SIZE 30

@implementation MySlider

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (BOOL) pointInside:(CGPoint)point withEvent:(UIEvent*)event {
    CGRect bounds = self.bounds;
    bounds = CGRectInset(bounds, -10, -8);
    return CGRectContainsPoint(bounds, point);
}

- (BOOL) beginTrackingWithTouch:(UITouch*)touch withEvent:(UIEvent*)event {
    CGRect bounds = self.bounds;
    float thumbPercent = (self.value - self.minimumValue) / (self.maximumValue - self.minimumValue);
    float thumbPos = THUMB_SIZE + (thumbPercent * (bounds.size.width - (2 * THUMB_SIZE)));
    CGPoint touchPoint = [touch locationInView:self];
    return (touchPoint.x >= (thumbPos - EFFECTIVE_THUMB_SIZE) &&
            touchPoint.x <= (thumbPos + EFFECTIVE_THUMB_SIZE));
}

@end
