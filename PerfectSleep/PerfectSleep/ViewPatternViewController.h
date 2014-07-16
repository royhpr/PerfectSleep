//
//  ViewPatternViewController.h
//  PerfectSleep
//
//  Created by Huang Purong on 19/3/14.
//  Copyright (c) 2014 Huang Purong. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CorePlotHeaders/CorePlot-CocoaTouch.h"
#import "constant.h"
#import "PlotData.h"
#import "PlotColor.h"

@interface ViewPatternViewController : UIViewController<UIGestureRecognizerDelegate, CPTPlotDataSource, UITableViewDataSource, UITableViewDelegate, PlotDataDelegate>

@property (weak, nonatomic) IBOutlet UIImageView *leftFromDateImageView;
@property (weak, nonatomic) IBOutlet UIImageView *rightFromDateImageView;
@property (weak, nonatomic) IBOutlet UILabel *fromDate;
@property (weak, nonatomic) IBOutlet UIImageView *leftToDateImageView;
@property (weak, nonatomic) IBOutlet UIImageView *rightToDateImageView;
@property (weak, nonatomic) IBOutlet UILabel *toDate;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *addTrendButton;
@property (weak, nonatomic) IBOutlet UIScrollView *mainScrollView;

- (IBAction)backToMain:(id)sender;
- (IBAction)showFactorCoverView:(id)sender;

@end
