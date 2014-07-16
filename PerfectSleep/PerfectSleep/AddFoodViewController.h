//
//  AddFoodViewController.h
//  PerfectSleep
//
//  Created by Huang Purong on 21/2/14.
//  Copyright (c) 2014 Huang Purong. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FatSecretAccessor.h"
#import "FatSecretAccessor+SearchFood.h"
#import "FatSecretAccessor+GetFood.h"
#import "NutritionGeneral.h"
#import "Food.h"
#import "constant.h"
#import "NutritionViewController.h"
#import "Reachability.h"
#import "DietDiaryDB.h"
#import "Favorite.h"

@protocol AddFoodViewControllerDelegate <NSObject>

@required
-(void)addConsumptionToList:(ConsumedFood*)consumedItem WithDate:(NSDate*)date;

@end

@interface AddFoodViewController : UIViewController<UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate, UIPickerViewDataSource, UIPickerViewDelegate, UIScrollViewDelegate, UIGestureRecognizerDelegate, NutritionViewControllerAddDelegate>

@property id<AddFoodViewControllerDelegate> delegate;
@property (weak, nonatomic) IBOutlet UILabel *currentDate;
@property (weak, nonatomic) IBOutlet UISegmentedControl *choiceSegmentControl;
@property (weak, nonatomic) IBOutlet UIImageView *leftDateImageView;
@property (weak, nonatomic) IBOutlet UIImageView *rightDateImageView;
@property(nonatomic, readonly)NSDate* addDate;


- (IBAction)selectChoice:(id)sender;
-(void)setCurrentDisplayDate:(NSDate*)date;

@end
