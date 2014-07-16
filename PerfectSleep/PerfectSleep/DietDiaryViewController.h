//
//  DietDiaryViewController.h
//  PerfectSleep
//
//  Created by Huang Purong on 2/3/14.
//  Copyright (c) 2014 Huang Purong. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "constant.h"
#import "NutritionViewController.h"
#import "AddFoodViewController.h"
#import "FatSecretAccessor.h"
#import "FatSecretAccessor+GetFood.h"
#import "NutritionGeneral.h"

@interface DietDiaryViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, UIPickerViewDataSource, UIPickerViewDelegate, UIGestureRecognizerDelegate, AddFoodViewControllerDelegate, NutritionViewControllerUpdateDelegate>

@property (weak, nonatomic) IBOutlet UITableView *dietDiaryTableView;
@property (weak, nonatomic) IBOutlet UIImageView *leftDateImageView;
@property (weak, nonatomic) IBOutlet UIImageView *rightDateImageView;
@property (weak, nonatomic) IBOutlet UILabel *currentDate;

@property(nonatomic, readonly)NSMutableArray* consumedFoodItemList;

@end
