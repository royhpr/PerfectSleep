//
//  MainViewController.m
//  PerfectSleep
//
//  Created by Huang Purong on 21/2/14.
//  Copyright (c) 2014 Huang Purong. All rights reserved.
//

#import "MainViewController.h"

@interface MainViewController ()

@end

@implementation MainViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    //Enable all image views user interaction
    [[self dietImageView]setUserInteractionEnabled:YES];
    [[self sleepImageView]setUserInteractionEnabled:YES];
    [[self groupImageView]setUserInteractionEnabled:YES];
    [[self patternImageView]setUserInteractionEnabled:YES];
    
    //Set up tap recognizer
    UITapGestureRecognizer* viewDiet = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapToViewDietDiary)];
    [viewDiet setNumberOfTapsRequired:1];
    [viewDiet setNumberOfTouchesRequired:1];
    
    UITapGestureRecognizer* viewSleep = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapToViewSleepDiary)];
    [viewSleep setNumberOfTapsRequired:1];
    [viewSleep setNumberOfTouchesRequired:1];
    
    UITapGestureRecognizer* viewGroup = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapToViewStudyGroup)];
    [viewGroup setNumberOfTapsRequired:1];
    [viewGroup setNumberOfTouchesRequired:1];
    
    UITapGestureRecognizer* viewPattern = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapToViewMyPattern)];
    [viewPattern setNumberOfTapsRequired:1];
    [viewPattern setNumberOfTouchesRequired:1];
    
    //Assign tap recognizer to image views
    [[self dietImageView]addGestureRecognizer:viewDiet];
    [[self sleepImageView]addGestureRecognizer:viewSleep];
    [[self groupImageView]addGestureRecognizer:viewGroup];
    [[self patternImageView]addGestureRecognizer:viewPattern];
}

-(void)tapToViewDietDiary
{
    [self performSegueWithIdentifier:@"FromMainToDietDiary" sender:self];
}

-(void)tapToViewSleepDiary
{
    [self performSegueWithIdentifier:@"FromMainToSleepDiary" sender:self];
}

-(void)tapToViewStudyGroup
{
    
}

-(void)tapToViewMyPattern
{
    [self performSegueWithIdentifier:@"FromMainToMyPattern" sender:self];
}

-(NSMutableArray*)returnConsumedFoodItemListOnTheDate:(NSDate*)date
{
    return [[NSMutableArray alloc]initWithArray:[[DietDiaryDB database]consumptionListBetweenStartDate:date EndDate:date]];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    
}

- (BOOL)shouldAutorotate
{
    return YES;
}

- (NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait;
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation
{
    return UIInterfaceOrientationPortrait;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
