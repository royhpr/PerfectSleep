//
//  NutritionViewController.h
//  PerfectSleep
//
//  Created by Huang Purong on 3/3/14.
//  Copyright (c) 2014 Huang Purong. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NutritionGeneral.h"
#import "DietDiaryDB.h"

@protocol NutritionViewControllerAddDelegate <NSObject>

@required
-(void)addConsumedItemToList:(ConsumedFood*)item;

@end

@protocol NutritionViewControllerUpdateDelegate <NSObject>

@required
-(void)updateConsumeListWithConsumeItem:(ConsumedFood*)item;

@end

@interface NutritionViewController : UIViewController<UITableViewDataSource, UITableViewDelegate, UIPickerViewDataSource, UIPickerViewDelegate>

@property id<NutritionViewControllerAddDelegate> addDelegate;
@property id<NutritionViewControllerUpdateDelegate> updateDelegate;
@property(nonatomic, readonly)NutritionGeneral* currentFoodItem;
@property(nonatomic, readonly)ConsumedFood* selectedConsumeItem;
@property(nonatomic, readonly)NSDate* selectedDate;
@property(nonatomic, readonly)NSString* mode;
@property (weak, nonatomic) IBOutlet UILabel *foodNameLabel;

-(void)configureCurrentFoodItemWithItem:(NutritionGeneral*)item Date:(NSDate*)date Mode:(NSString*)mode;
-(void)configureSelectedConsumeItem:(ConsumedFood*)consumeItem;
@end
