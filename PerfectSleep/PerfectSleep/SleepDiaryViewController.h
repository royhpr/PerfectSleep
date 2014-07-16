//
//  SleepDiaryViewController.h
//  PerfectSleep
//
//  Created by Huang Purong on 3/3/14.
//  Copyright (c) 2014 Huang Purong. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MySlider.h"
#import "constant.h"
#import "SleepSetting.h"
#import "LoggedSleep.h"
#import "SleepDiaryDB.h"

@interface SleepDiaryViewController : UIViewController<UIGestureRecognizerDelegate, UIPickerViewDataSource, UIPickerViewDelegate, UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate>

@property(nonatomic, readonly)SleepSetting* setting;

@property (weak, nonatomic) IBOutlet UIImageView *leftDateImageView;
@property (weak, nonatomic) IBOutlet UIImageView *rightDateImageView;
@property (weak, nonatomic) IBOutlet UILabel *currentDate;
@property (weak, nonatomic) IBOutlet UIScrollView *mainScrollView;

@end
