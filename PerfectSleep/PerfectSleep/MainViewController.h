//
//  MainViewController.h
//  PerfectSleep
//
//  Created by Huang Purong on 21/2/14.
//  Copyright (c) 2014 Huang Purong. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DietDiaryViewController.h"
#import "SleepDiaryViewController.h"
#import "Food.h"
#import "DietDiaryDB.h"

@interface MainViewController : UIViewController
@property (weak, nonatomic) IBOutlet UIImageView *dietImageView;
@property (weak, nonatomic) IBOutlet UIImageView *sleepImageView;
@property (weak, nonatomic) IBOutlet UIImageView *groupImageView;
@property (weak, nonatomic) IBOutlet UIImageView *patternImageView;


@end
