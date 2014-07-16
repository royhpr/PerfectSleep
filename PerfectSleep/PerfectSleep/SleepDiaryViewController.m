//
//  SleepDiaryViewController.m
//  PerfectSleep
//
//  Created by Huang Purong on 3/3/14.
//  Copyright (c) 2014 Huang Purong. All rights reserved.
//

#import "SleepDiaryViewController.h"

@interface SleepDiaryViewController ()

@property(strong, nonatomic)UIView* coverView;
@property(strong, nonatomic)UIView* topBarView;

@property(strong, nonatomic)UIDatePicker* datePicker;
@property(strong, nonatomic)UIPickerView* durationPicker;
@property(strong, nonatomic)UIPickerView* countPicker;
@property(strong, nonatomic)UIPickerView* alcoholPicker;
@property(strong, nonatomic)UIPickerView* activityPicker;
@property(strong, nonatomic)UITableView* settingTableView;
@property(strong, nonatomic)UIImageView* alcoholImageView;

@property(strong, nonatomic)UIView* bedTimeTile;
@property(strong, nonatomic)UIView* timeToFallAsleepTile;
@property(strong, nonatomic)UIView* timesOfWakeupTile;
@property(strong, nonatomic)UIView* durationOfAwakeningTile;
@property(strong, nonatomic)UIView* wakeUpTimeTile;
@property(strong, nonatomic)UIView* turnOutLightTile;
@property(strong, nonatomic)UIView* finalAwakeningTile;
@property(strong, nonatomic)UIView* lastTimeBigMealTile;
@property(strong, nonatomic)UIView* lateEveningActivityTile;
@property(strong, nonatomic)UIView* lateEveningAlcoholTile;
@property(strong, nonatomic)UIView* moodTile;
@property(strong, nonatomic)UIView* selfReportedSleepQualityTile;

@property(nonatomic, readwrite)NSString* currentMood;

@property(strong, nonatomic)UIButton* currentDateButton;
@property(strong, nonatomic)UIButton* bedTimeButton;
@property(strong, nonatomic)UIButton* timeToFallAsleepButton;
@property(strong, nonatomic)UIButton* timesOfWakeupButton;
@property(strong, nonatomic)UIButton* durationOfAwakeningButton;
@property(strong, nonatomic)UIButton* wakeUpTimeButton;
@property(strong, nonatomic)UIButton* turnOutLightButton;
@property(strong, nonatomic)UIButton* finalAwakeningButton;
@property(strong, nonatomic)UIButton* lastTimeBigMealButton;
@property(strong, nonatomic)UIButton* lateEveningActivityButton;
@property(strong, nonatomic)UIButton* lateEveningAlcoholButton;

@property(nonatomic, readwrite)float yAxisValue;
@property(nonatomic, readwrite)int tagIndex;
@property(nonatomic, readwrite)NSMutableArray* alcoholServingList;
@property(nonatomic, readwrite)NSMutableArray* activityList;
@property(nonatomic, readwrite)NSMutableArray* durationCountHourList;
@property(nonatomic, readwrite)NSMutableArray* durationCountMinuteList;
@property(nonatomic, readwrite)NSMutableArray* countList;
@property(nonatomic, readwrite)NSMutableArray* alcoholNumberList;
@property(nonatomic, readwrite)NSMutableArray* alcoholFractionList;
@property(nonatomic, readwrite)NSMutableArray* settingList;
@property(nonatomic, readwrite)NSMutableArray* switchStates;

@property(nonatomic, readwrite)LoggedSleep* selectedSleep;

@end

@implementation SleepDiaryViewController

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
    
    //Set up setting
    _setting = [[SleepDiaryDB database]currentSleepSetting];
    
    //Initialize left and right date arrow
    [self initializeLeftRightArrows];
    
    //Initialize date string interaction
    [self initializeDateString];
    
    //Initialize default sleep-related items
    self.yAxisValue = 0.0;
    self.tagIndex = 1;
    [self initializeDefaultSleepRelatedItems];
    
    //Initialize lists
    [self intializeDurationList];
    [self initializeCountList];
    [self initializeAlcoholNumberList];
    [self initializeAlcoholFractionList];
    [self initializeAlcoholServingList];
    [self initializeActivityList];
    
    //Current date
    [self updateCurrentDateTimeDisplay:[NSDate date] ForLabel:self.currentDate];
    
    //Register keyboard notification
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
}

-(void)intializeDurationList
{
    self.durationCountHourList = [[NSMutableArray alloc]init];
    for(int i=0; i<25; i++)
    {
        [self.durationCountHourList addObject:[NSString stringWithFormat:@"%d", i]];
    }
    self.durationCountMinuteList = [[NSMutableArray alloc]init];
    for(int i=0; i<60; i++)
    {
        [self.durationCountMinuteList addObject:[NSString stringWithFormat:@"%d", i]];
    }
}

-(void)initializeActivityList
{
    self.activityList = [[NSMutableArray alloc]initWithObjects:@"Work on computer", @"Read", @"TV/Movie", @"Walk", @"Sports", @"Relax", @"Laugh", @"Others", nil];
}

-(void)initializeCountList
{
    self.countList = [[NSMutableArray alloc]init];
    for(int i=0; i<25; i++)
    {
        [self.countList addObject:[NSString stringWithFormat:@"%d", i]];
    }
}

-(void)initializeAlcoholNumberList
{
    self.alcoholNumberList = [[NSMutableArray alloc]init];
    for(int i=0; i<50; i++)
    {
        [self.alcoholNumberList addObject:[NSString stringWithFormat:@"%d", i]];
    }
}

-(void)initializeAlcoholFractionList
{
    self.alcoholFractionList = [[NSMutableArray alloc]initWithObjects:@"-", @"1/4", @"1/2", @"3/4", nil];
}

-(void)initializeAlcoholServingList
{
    self.alcoholServingList = [[NSMutableArray alloc]initWithObjects:@"100ml SPARKLING WINE", @"100ml WINE",@"425ml LIGHT BEER", @"285ml REGULAR BEER", @"60ml FORTIFIED WINE", @"30ml SPIRITS", nil];
}

-(void)initializeSettingAndSaveNavBarItems
{
    UIBarButtonItem* saveButton = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemSave target:self action:@selector(saveParametersToDB)];
    
    UIBarButtonItem* trashButton = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemTrash target:self action:@selector(removeParametersFromDB)];
    
    UIImage* image = [UIImage imageNamed:@"sleepdiarysetting.png"];
    UIImageView* sleepSettingImageView = [[UIImageView alloc]initWithImage:image];
    [sleepSettingImageView setFrame:CGRectZero];
    sleepSettingImageView.frame = CGRectMake(sleepSettingImageView.frame.origin.x, sleepSettingImageView.frame.origin.y, 40.0, 40.0);
    [sleepSettingImageView setUserInteractionEnabled:YES];
    UITapGestureRecognizer* singleTap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(viewSleepDiarySetting)];
    [singleTap setNumberOfTapsRequired:1];
    [singleTap setNumberOfTouchesRequired:1];
    [sleepSettingImageView addGestureRecognizer:singleTap];
    [sleepSettingImageView setUserInteractionEnabled:YES];
    
    UIBarButtonItem* sleepSettingButton = [[UIBarButtonItem alloc]initWithCustomView:sleepSettingImageView];
    self.navigationItem.rightBarButtonItems = [NSArray arrayWithObjects:saveButton, trashButton, sleepSettingButton, nil];
}

-(void)initializeSettingAndAddNavBarItems
{
    UIBarButtonItem* addButton = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addSleepLogToDB)];
    
    UIImage* image = [UIImage imageNamed:@"sleepdiarysetting.png"];
    UIImageView* sleepSettingImageView = [[UIImageView alloc]initWithImage:image];
    [sleepSettingImageView setFrame:CGRectZero];
    sleepSettingImageView.frame = CGRectMake(sleepSettingImageView.frame.origin.x, sleepSettingImageView.frame.origin.y, 40.0, 40.0);
    [sleepSettingImageView setUserInteractionEnabled:YES];
    UITapGestureRecognizer* singleTap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(viewSleepDiarySetting)];
    [singleTap setNumberOfTapsRequired:1];
    [singleTap setNumberOfTouchesRequired:1];
    [sleepSettingImageView addGestureRecognizer:singleTap];
    [sleepSettingImageView setUserInteractionEnabled:YES];
    
    UIBarButtonItem* sleepSettingButton = [[UIBarButtonItem alloc]initWithCustomView:sleepSettingImageView];
    self.navigationItem.rightBarButtonItems = [NSArray arrayWithObjects:addButton, sleepSettingButton, nil];
}

-(void)initializeLeftRightArrows
{
    UITapGestureRecognizer* singleLeftTap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(reduceDayByOne)];
    [singleLeftTap setNumberOfTapsRequired:1];
    [singleLeftTap setNumberOfTouchesRequired:1];
    [self.leftDateImageView addGestureRecognizer:singleLeftTap];
    
    UITapGestureRecognizer* singleRightTap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(increaseDayByOne)];
    [singleRightTap setNumberOfTapsRequired:1];
    [singleRightTap setNumberOfTouchesRequired:1];
    [self.rightDateImageView addGestureRecognizer:singleRightTap];
    
    [self enableRightArrow:NO];
}

-(void)enableRightArrow:(BOOL)enable
{
    if(enable)
    {
        [self.rightDateImageView setImage:[UIImage imageNamed:@"right.png"]];
        [self.rightDateImageView setUserInteractionEnabled:YES];
    }
    else
    {
        UIImage* greyOutImage = [self convertImageToGrayScale:[UIImage imageNamed:@"right.png"]];
        [self.rightDateImageView setImage:greyOutImage];
        [self.rightDateImageView setUserInteractionEnabled:NO];
    }
}

- (UIImage *)convertImageToGrayScale:(UIImage *)image
{
    // Create image rectangle with current image width/height
    CGRect imageRect = CGRectMake(0, 0, image.size.width, image.size.height);
    
    // Grayscale color space
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceGray();
    
    // Create bitmap content with current image size and grayscale colorspace
    CGContextRef context = CGBitmapContextCreate(nil, image.size.width, image.size.height, 8, 0, colorSpace, (CGBitmapInfo)kCGImageAlphaNone);
    
    // Draw image into current context, with specified rectangle
    // using previously defined context (with grayscale colorspace)
    CGContextDrawImage(context, imageRect, [image CGImage]);
    
    /* changes start here */
    // Create bitmap image info from pixel data in current context
    CGImageRef grayImage = CGBitmapContextCreateImage(context);
    
    // release the colorspace and graphics context
    CGColorSpaceRelease(colorSpace);
    CGContextRelease(context);
    
    // make a new alpha-only graphics context
    context = CGBitmapContextCreate(nil, image.size.width, image.size.height, 8, 0, nil, (CGBitmapInfo)kCGImageAlphaOnly);
    
    // draw image into context with no colorspace
    CGContextDrawImage(context, imageRect, [image CGImage]);
    
    // create alpha bitmap mask from current context
    CGImageRef mask = CGBitmapContextCreateImage(context);
    
    // release graphics context
    CGContextRelease(context);
    
    // make UIImage from grayscale image with alpha mask
    UIImage *grayScaleImage = [UIImage imageWithCGImage:CGImageCreateWithMask(grayImage, mask) scale:image.scale orientation:image.imageOrientation];
    
    // release the CG images
    CGImageRelease(grayImage);
    CGImageRelease(mask);
    
    // return the new grayscale image
    return grayScaleImage;
}

-(void)initializeDateString
{
    UITapGestureRecognizer* singleTap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(showDateCoverView:)];
    [singleTap setNumberOfTapsRequired:1];
    [singleTap setNumberOfTouchesRequired:1];
    [self.currentDate addGestureRecognizer:singleTap];
}

-(void)initializeDefaultSleepRelatedItems
{
    //Initialize bed time block
    [self initializeBedTimeBlock];
    
    //Initialize fall asleep time block
    [self initializeFallAsleepTimeBlock];
    
    //Initialize wake-up times block
    [self initializeAmountOfWakeupBlock];
    
    //Initialize total-awakening hours block
    [self initializeTotalAwakeninguHoursBlock];
    
    //Initialize get-out-of-bed time block
    [self initializeGetUpTimeBlock];
    
    //Initialize additonal blocks
    [self initializeAdditonalBolocks];
}

-(void)initializeAdditonalBolocks
{
    if(_setting.isTimeOfTurningOutLight)
    {
        [self initializeTurnOutLightBlock];
    }
    
    if(_setting.isTimeOfFinalAwakening)
    {
        [self initializeFinalAwakeningTimeBlock];
    }
    
    if(_setting.isTimeOfLastBigMeal)
    {
        [self initializeLastTimeBigMealBlock];
    }
    
    if(_setting.isActivityAtLateEvening)
    {
        [self initializeEveningActivityBlock];
    }
    
    if(_setting.isAlcoholAtLateEvening)
    {
        [self initializeEveningAlcoholBlock];
    }
    
    if(_setting.isMood)
    {
        [self initializeMoodBlcok];
    }
    
    if(_setting.isSelfReportedSleepQuality)
    {
        [self initializeSleepQualityBlock];
    }
}

-(void)initializeBedTimeBlock
{
    NSString* questionText = @"What time did you go to bed at the night?";
    NSString* answerText = @"Not Set";
    self.bedTimeTile = [self returnNewTileWithCategory:@"default"];
    UILabel* question = [self returnQuestionLabelWithTitle:questionText];
    UILabel* answer = [self returnAnswerLabelWithString:answerText];
    [self addGestureRecognizerForAnswer:answer WithTile:self.bedTimeTile];
    
    [self.bedTimeTile addSubview:question];
    [self.bedTimeTile addSubview:answer];
    [self.mainScrollView addSubview:self.bedTimeTile];
}

-(void)initializeFallAsleepTimeBlock
{
    NSString* questionText = @"How long did it take you to fall asleep?";
    NSString* answerText = @"Not Set";
    self.timeToFallAsleepTile = [self returnNewTileWithCategory:@"default"];
    UILabel* question = [self returnQuestionLabelWithTitle:questionText];
    UILabel* answer = [self returnAnswerLabelWithString:answerText];
    [self addGestureRecognizerForAnswer:answer WithTile:self.timeToFallAsleepTile];
    
    [self.timeToFallAsleepTile addSubview:question];
    [self.timeToFallAsleepTile addSubview:answer];
    [self.mainScrollView addSubview:self.timeToFallAsleepTile];
}

-(void)initializeAmountOfWakeupBlock
{
    NSString* questionText = @"How many times did you wake up during the night?";
    NSString* answerText = @"Not Set";
    self.timesOfWakeupTile = [self returnNewTileWithCategory:@"default"];
    UILabel* question = [self returnQuestionLabelWithTitle:questionText];
    UILabel* answer = [self returnAnswerLabelWithString:answerText];
    [self addGestureRecognizerForAnswer:answer WithTile:self.timesOfWakeupTile];
    
    [self.timesOfWakeupTile addSubview:question];
    [self.timesOfWakeupTile addSubview:answer];
    [self.mainScrollView addSubview:self.timesOfWakeupTile];
}

-(void)initializeTotalAwakeninguHoursBlock
{
    NSString* questionText = @"In total, How long did these awakening last?";
    NSString* answerText = @"Not Set";
    self.durationOfAwakeningTile = [self returnNewTileWithCategory:@"default"];
    UILabel* question = [self returnQuestionLabelWithTitle:questionText];
    UILabel* answer = [self returnAnswerLabelWithString:answerText];
    [self addGestureRecognizerForAnswer:answer WithTile:self.durationOfAwakeningTile];
    
    [self.durationOfAwakeningTile addSubview:question];
    [self.durationOfAwakeningTile addSubview:answer];
    [self.mainScrollView addSubview:self.durationOfAwakeningTile];
}

-(void)initializeGetUpTimeBlock
{
    NSString* questionText = @"What time did you get up of bed for the day?";
    NSString* answerText = @"Not Set";
    self.wakeUpTimeTile = [self returnNewTileWithCategory:@"default"];
    UILabel* question = [self returnQuestionLabelWithTitle:questionText];
    UILabel* answer = [self returnAnswerLabelWithString:answerText];
    [self addGestureRecognizerForAnswer:answer WithTile:self.wakeUpTimeTile];
    
    [self.wakeUpTimeTile addSubview:question];
    [self.wakeUpTimeTile addSubview:answer];
    [self.mainScrollView addSubview:self.wakeUpTimeTile];
}

-(void)initializeTurnOutLightBlock
{
    NSString* questionText = @"What time did you turn out the light?";
    NSString* answerText = @"Not Set";
    self.turnOutLightTile = [self returnNewTileWithCategory:@"others"];
    self.turnOutLightTile.tag = self.tagIndex;
    self.tagIndex = self.tagIndex + 1;
    UILabel* question = [self returnQuestionLabelWithTitle:questionText];
    UILabel* answer = [self returnAnswerLabelWithString:answerText];
    [self addGestureRecognizerForAnswer:answer WithTile:self.turnOutLightTile];
    
    [self.turnOutLightTile addSubview:question];
    [self.turnOutLightTile addSubview:answer];
    [self.mainScrollView addSubview:self.turnOutLightTile];
}

-(void)initializeFinalAwakeningTimeBlock
{
    NSString* questionText = @"When was your last awakening?";
    NSString* answerText = @"Not Set";
    self.finalAwakeningTile = [self returnNewTileWithCategory:@"others"];
    self.finalAwakeningTile.tag = self.tagIndex;
    self.tagIndex = self.tagIndex + 1;
    UILabel* question = [self returnQuestionLabelWithTitle:questionText];
    UILabel* answer = [self returnAnswerLabelWithString:answerText];
    [self addGestureRecognizerForAnswer:answer WithTile:self.finalAwakeningTile];
    
    [self.finalAwakeningTile addSubview:question];
    [self.finalAwakeningTile addSubview:answer];
    [self.mainScrollView addSubview:self.finalAwakeningTile];
}

-(void)initializeLastTimeBigMealBlock
{
    NSString* questionText = @"What time did you eat your last big meal at the late evening?";
    NSString* answerText = @"Not Set";
    self.lastTimeBigMealTile = [self returnNewTileWithCategory:@"others"];
    self.lastTimeBigMealTile.tag = self.tagIndex;
    self.tagIndex = self.tagIndex + 1;
    UILabel* question = [self returnQuestionLabelWithTitle:questionText];
    UILabel* answer = [self returnAnswerLabelWithString:answerText];
    [self addGestureRecognizerForAnswer:answer WithTile:self.lastTimeBigMealTile];
    
    [self.lastTimeBigMealTile addSubview:question];
    [self.lastTimeBigMealTile addSubview:answer];
    [self.mainScrollView addSubview:self.lastTimeBigMealTile];
}

-(void)initializeEveningActivityBlock
{
    NSString* questionText = @"What did you do at the late evening?";
    NSString* answerText = @"Not Set";
    self.lateEveningActivityTile = [self returnNewTileWithCategory:@"others"];
    self.lateEveningActivityTile.tag = self.tagIndex;
    self.tagIndex = self.tagIndex + 1;
    UILabel* question = [self returnQuestionLabelWithTitle:questionText];
    UILabel* answer = [self returnAnswerLabelWithString:answerText];
    [self addGestureRecognizerForAnswer:answer WithTile:self.lateEveningActivityTile];
    
    [self.lateEveningActivityTile addSubview:question];
    [self.lateEveningActivityTile addSubview:answer];
    [self.mainScrollView addSubview:self.lateEveningActivityTile];
}

-(void)initializeEveningAlcoholBlock
{
    NSString* questionText = @"How much alcohol did you drink at the late evening?";
    NSString* answerText = @"Not Set";
    self.lateEveningAlcoholTile = [self returnNewTileWithCategory:@"others"];
    self.lateEveningAlcoholTile.tag = self.tagIndex;
    self.tagIndex = self.tagIndex + 1;
    UILabel* question = [self returnQuestionLabelWithTitle:questionText];
    UILabel* answer = [self returnAnswerLabelWithString:answerText];
    [self addGestureRecognizerForAnswer:answer WithTile:self.lateEveningAlcoholTile];
    
    [self.lateEveningAlcoholTile addSubview:question];
    [self.lateEveningAlcoholTile addSubview:answer];
    [self.mainScrollView addSubview:self.lateEveningAlcoholTile];
}

-(void)initializeMoodBlcok
{
    NSString* questionText = @"How do you feel upon getting up of the bed?";
    self.moodTile = [self returnNewTileWithCategory:@"others"];
    self.moodTile.tag = self.tagIndex;
    self.tagIndex = self.tagIndex + 1;
    UILabel* question = [self returnQuestionLabelWithTitle:questionText];
    
    UISegmentedControl* moodSegmentControl = [[UISegmentedControl alloc]initWithItems:[NSArray arrayWithObjects:@"", @"", @"", nil]];
    moodSegmentControl.frame = CGRectMake((self.moodTile.frame.size.width-250.0)/2.0, self.moodTile.frame.size.height - 40.0 - 15.0, 250.0, 40.0);
    [moodSegmentControl setTintColor:[UIColor orangeColor]];
    [moodSegmentControl addTarget:self action:@selector(moodValueChanged:) forControlEvents: UIControlEventValueChanged];
    
    UIImage* great;
    UIImage* soso;
    UIImage* awful;
    
    if ([UIImage instancesRespondToSelector:@selector(imageWithRenderingMode:)])
    {
        great = [[UIImage imageNamed:@"great.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
        soso = [[UIImage imageNamed:@"soso.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
        awful = [[UIImage imageNamed:@"awful.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    }
    else
    {
        great = [UIImage imageNamed:@"great.png"];
        soso = [UIImage imageNamed:@"soso.png"];
        awful = [UIImage imageNamed:@"awful.png"];
    }
    
    [moodSegmentControl setImage:great forSegmentAtIndex:0];
    [moodSegmentControl setImage:soso forSegmentAtIndex:1];
    [moodSegmentControl setImage:awful forSegmentAtIndex:2];
    
    [self.moodTile addSubview:question];
    [self.moodTile addSubview:moodSegmentControl];
    [self.mainScrollView addSubview:self.moodTile];
}

-(void)initializeSleepQualityBlock
{
    NSString* questionText = @"How do you rate your sleep quality?";
    self.selfReportedSleepQualityTile = [self returnNewTileWithCategory:@"others"];
    self.selfReportedSleepQualityTile.tag = self.tagIndex;
    self.tagIndex = self.tagIndex + 1;
    UILabel* question = [self returnQuestionLabelWithTitle:questionText];
    
    CGRect frame = CGRectMake((self.selfReportedSleepQualityTile.frame.size.width - 280.0)/2.0, self.selfReportedSleepQualityTile.frame.size.height-45.0, 280.0, 10.0);
    MySlider* selfReportedSleepQualitySlider = [[MySlider alloc] initWithFrame:frame];
    [selfReportedSleepQualitySlider addTarget:self action:@selector(sliderAction:) forControlEvents:UIControlEventAllEvents];
    [selfReportedSleepQualitySlider setBackgroundColor:[UIColor orangeColor]];
    selfReportedSleepQualitySlider.minimumValue = 0.0;
    selfReportedSleepQualitySlider.maximumValue = 60.0;
    selfReportedSleepQualitySlider.continuous = YES;
    selfReportedSleepQualitySlider.value = 60.0;
    
    //Labels
    UILabel* poorLabel = [[UILabel alloc]initWithFrame:CGRectMake(selfReportedSleepQualitySlider.frame.origin.x, self.selfReportedSleepQualityTile.frame.size.height-25.0, 40.0, 20.0)];
    [poorLabel setBackgroundColor:[UIColor clearColor]];
    [poorLabel setTextColor:[UIColor orangeColor]];
    [poorLabel setTextAlignment:NSTextAlignmentCenter];
    [poorLabel setText:@"Poor"];
    [poorLabel setFont:[UIFont boldSystemFontOfSize:13.0]];
    [poorLabel sizeToFit];
    
    UILabel* moderateLabel = [[UILabel alloc]initWithFrame:CGRectMake(poorLabel.frame.origin.x + 70.0, self.selfReportedSleepQualityTile.frame.size.height-25.0, 40.0, 20.0)];
    [moderateLabel setBackgroundColor:[UIColor clearColor]];
    [moderateLabel setTextColor:[UIColor orangeColor]];
    [moderateLabel setTextAlignment:NSTextAlignmentCenter];
    [moderateLabel setText:@"Moderate"];
    [moderateLabel setFont:[UIFont boldSystemFontOfSize:13.0]];
    [moderateLabel sizeToFit];
    
    UILabel* goodLabel = [[UILabel alloc]initWithFrame:CGRectMake(moderateLabel.frame.origin.x + moderateLabel.frame.size.width/2.0 + 65.0, self.selfReportedSleepQualityTile.frame.size.height-25.0, 40.0, 20.0)];
    [goodLabel setBackgroundColor:[UIColor clearColor]];
    [goodLabel setTextColor:[UIColor orangeColor]];
    [goodLabel setTextAlignment:NSTextAlignmentCenter];
    [goodLabel setText:@"Good"];
    [goodLabel setFont:[UIFont boldSystemFontOfSize:13.0]];
    [goodLabel sizeToFit];
    
    UILabel* perfectLabel = [[UILabel alloc]initWithFrame:CGRectMake(goodLabel.frame.origin.x + goodLabel.frame.size.width/2.0 + 60.0, self.selfReportedSleepQualityTile.frame.size.height-25.0, 40.0, 20.0)];
    [perfectLabel setBackgroundColor:[UIColor clearColor]];
    [perfectLabel setTextColor:[UIColor orangeColor]];
    [perfectLabel setTextAlignment:NSTextAlignmentCenter];
    [perfectLabel setText:@"Perfect"];
    [perfectLabel setFont:[UIFont boldSystemFontOfSize:13.0]];
    [perfectLabel sizeToFit];
    
    [self.selfReportedSleepQualityTile addSubview:question];
    [self.selfReportedSleepQualityTile addSubview:selfReportedSleepQualitySlider];
    [self.selfReportedSleepQualityTile addSubview:poorLabel];
    [self.selfReportedSleepQualityTile addSubview:moderateLabel];
    [self.selfReportedSleepQualityTile addSubview:goodLabel];
    [self.selfReportedSleepQualityTile addSubview:perfectLabel];
    [self.mainScrollView addSubview:self.selfReportedSleepQualityTile];
}

-(UIView*)returnNewTileWithCategory:(NSString*)cat
{
    UIView* tile = [[UIView alloc]initWithFrame:CGRectMake(0.0, self.yAxisValue, self.view.frame.size.width, 120.0)];
    tile.userInteractionEnabled = YES;
    
    if([cat isEqualToString:@"others"])
    {
        [tile addGestureRecognizer:[self returnTileSwipeLeftGestureRecognizer]];
        [tile addGestureRecognizer:[self returnTileSwipeRightGestureRecognizer]];
        
        UIGraphicsBeginImageContext(tile.frame.size);
        [[UIImage imageNamed:@"otherssleeptile.png"] drawInRect:tile.bounds];
        UIImage* image = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        tile.backgroundColor = [UIColor colorWithPatternImage:image];
    }
    else
    {
        UIGraphicsBeginImageContext(tile.frame.size);
        [[UIImage imageNamed:@"defaultsleeptile.png"] drawInRect:tile.bounds];
        UIImage* image = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        tile.backgroundColor = [UIColor colorWithPatternImage:image];
    }
    
    self.yAxisValue = self.yAxisValue + tile.frame.size.height + 10.0;
    self.mainScrollView.contentSize = CGSizeMake(tile.frame.size.width, tile.frame.origin.y + tile.frame.size.height);
    
    return tile;
}

-(UILabel*)returnQuestionLabelWithTitle:(NSString*)title
{
    NSString* text = title;
    CGSize referenceSize = CGSizeMake(self.view.frame.size.width-40.0, 40.0);
    UILabel* question = [[UILabel alloc]init];
    [question setFont:[UIFont boldSystemFontOfSize:18.0]];
    question.text = text;
    [question setNumberOfLines:0];
    [question setBackgroundColor:[UIColor clearColor]];
    [question setTextColor:[UIColor whiteColor]];
    [question setTextAlignment:NSTextAlignmentJustified];
    [question setLineBreakMode:NSLineBreakByWordWrapping];
    CGSize calculatedSize = [question sizeThatFits:referenceSize];
    question.frame = CGRectMake(20.0, 20.0, calculatedSize.width, calculatedSize.height);
    
    return question;
}

-(UILabel*)returnAnswerLabelWithString:(NSString*)text
{
    UILabel* answer = [[UILabel alloc]init];
    [answer setFont:[UIFont systemFontOfSize:18.0]];
    answer.text = text;
    [answer setNumberOfLines:0];
    [answer setBackgroundColor:[UIColor clearColor]];
    [answer setTextColor:[UIColor orangeColor]];
    [answer setTextAlignment:NSTextAlignmentCenter];
    [answer setLineBreakMode:NSLineBreakByWordWrapping];
    [answer setUserInteractionEnabled:YES];
    answer.frame = CGRectMake((self.view.frame.size.width-250.0)/2.0, 120.0 - 40.0 - 20.0, 250.0, 40.0);
    
    return  answer;
}

-(void)addActivityTextFieldToTileWithContent:(NSString*)text
{
    UILabel* answer = [[self.lateEveningActivityTile subviews]objectAtIndex:1];
    UILabel* question = [[self.lateEveningActivityTile subviews]objectAtIndex:0];
    answer.frame = CGRectMake(question.frame.origin.x, answer.frame.origin.y, 70.0, answer.frame.size.height);
    
    UITextField* textField = [[UITextField alloc] initWithFrame:CGRectMake(answer.frame.origin.x + answer.frame.size.width, answer.frame.origin.y, 150.0, answer.frame.size.height)];
    [textField setFont:[UIFont systemFontOfSize:18.0]];
    [textField setBackgroundColor:[UIColor whiteColor]];
    [textField setBorderStyle:UITextBorderStyleRoundedRect];
    [textField setReturnKeyType:UIReturnKeyDone];
    textField.delegate = self;
    if(text != nil)
        textField.text = text;
    [self.lateEveningActivityTile addSubview:textField];
}

-(void)removeActivityTextField
{
    UITextField* textField = [[self.lateEveningActivityTile subviews]objectAtIndex:2];
    UILabel* answer = [[self.lateEveningActivityTile subviews]objectAtIndex:1];
    [textField removeFromSuperview];
    answer.frame = CGRectMake((self.lateEveningActivityTile.frame.size.width - 250.0)/2.0, answer.frame.origin.y, 250.0, answer.frame.size.height);
}

-(void)addGestureRecognizerForAnswer:(UILabel*)label WithTile:(UIView*)tile
{
    if([tile isEqual:self.bedTimeTile] ||
       [tile isEqual:self.wakeUpTimeTile] ||
       [tile isEqual:self.turnOutLightTile] ||
       [tile isEqual:self.finalAwakeningTile] ||
       [tile isEqual:self.lastTimeBigMealTile])
    {
        UITapGestureRecognizer* singleTap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(showTimeCoverView:)];
        [singleTap setNumberOfTapsRequired:1];
        [singleTap setNumberOfTouchesRequired:1];
        [label addGestureRecognizer:singleTap];
    }
    else if([tile isEqual:self.timeToFallAsleepTile] ||
            [tile isEqual:self.durationOfAwakeningTile])
    {
        UITapGestureRecognizer* singleTap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(showDurationCoverView:)];
        [singleTap setNumberOfTapsRequired:1];
        [singleTap setNumberOfTouchesRequired:1];
        [label addGestureRecognizer:singleTap];
    }
    else if([tile isEqual:self.timesOfWakeupTile])
    {
        UITapGestureRecognizer* singleTap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(showTimesOfWakeUpCoverView:)];
        [singleTap setNumberOfTapsRequired:1];
        [singleTap setNumberOfTouchesRequired:1];
        [label addGestureRecognizer:singleTap];
    }
    else if([tile isEqual:self.lateEveningAlcoholTile])
    {
        UITapGestureRecognizer* singleTap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(showAlcoholCoverView:)];
        [singleTap setNumberOfTapsRequired:1];
        [singleTap setNumberOfTouchesRequired:1];
        [label addGestureRecognizer:singleTap];
    }
    else //activity
    {
        UITapGestureRecognizer* singleTap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(showActivityCoverView:)];
        [singleTap setNumberOfTapsRequired:1];
        [singleTap setNumberOfTouchesRequired:1];
        [label addGestureRecognizer:singleTap];
    }
}

-(UISwipeGestureRecognizer*)returnTileSwipeRightGestureRecognizer
{
    UISwipeGestureRecognizer* swipeRightRecognizer = [[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(swipeRightToRemoveTile:)];
    swipeRightRecognizer.direction = UISwipeGestureRecognizerDirectionRight;
    
    return swipeRightRecognizer;
}

-(UISwipeGestureRecognizer*)returnTileSwipeLeftGestureRecognizer
{
    UISwipeGestureRecognizer* swipeLeftRecognizer = [[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(swipeLeftToRemoveTile:)];
    swipeLeftRecognizer.direction = UISwipeGestureRecognizerDirectionLeft;
    
    return swipeLeftRecognizer;
}

-(void)removeTileFromView:(UIView*)tile
{
    int tag = (int)tile.tag;
    double y = tile.frame.origin.y;
    
    if([tile isEqual:self.turnOutLightTile])
        [_setting setIsTimeOfTurningOutLight:NO];
    else if([tile isEqual:self.finalAwakeningTile])
        [_setting setIsTimeOfFinalAwakening:NO];
    else if([tile isEqual:self.lastTimeBigMealTile])
        [_setting setIsTimeOfLastBigMeal:NO];
    else if([tile isEqual:self.lateEveningActivityTile])
        [_setting setIsActivityAtLateEvening:NO];
    else if([tile isEqual:self.lateEveningAlcoholTile])
        [_setting setIsAlcoholAtLateEvening:NO];
    else if([tile isEqual:self.moodTile])
        [_setting setIsMood:NO];
    else
        [_setting setIsSelfReportedSleepQuality:NO];
    
    [[SleepDiaryDB database]updateSleepSettingWithSetting:_setting];
    [tile removeFromSuperview];
    [self rePositionViewsBelowCurrentView:tag WithYPosition:y];
}

-(void)rePositionViewsBelowCurrentView:(int)tag WithYPosition:(double)y;
{
    UIView* currentTile = [self.mainScrollView viewWithTag:tag];
    UIView* nextTile = [self.mainScrollView viewWithTag:tag + 1];
    
    if(currentTile == nil && nextTile == nil)
    {
        self.yAxisValue = y;
        self.tagIndex = tag;
        self.mainScrollView.contentSize = CGSizeMake(self.mainScrollView.frame.size.width, y);
        return;
    }
    
    int oldTag = (int)nextTile.tag;
    double oldY = nextTile.frame.origin.y;
    nextTile.tag = tag;
    nextTile.frame = CGRectMake(nextTile.frame.origin.x, y, nextTile.frame.size.width, nextTile.frame.size.height);
    
    [self rePositionViewsBelowCurrentView:oldTag WithYPosition:oldY];
}

-(void)animateTileRightToLeft:(UIView*)tile
{
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.4];
    [tile setFrame:CGRectMake(-self.view.frame.size.width, tile.frame.origin.y, tile.frame.size.width, tile.frame.size.height)];
    [UIView commitAnimations];
    
    [self performSelector:@selector(removeTileFromView:) withObject:tile afterDelay:0.4];
}

-(void)animateTileLeftToRight:(UIView*)tile
{
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.4];
    [tile setFrame:CGRectMake(self.view.frame.size.width, tile.frame.origin.y, tile.frame.size.width, tile.frame.size.height)];
    [UIView commitAnimations];
    
    [self performSelector:@selector(removeTileFromView:) withObject:tile afterDelay:0.4];
}

-(void)swipeRightToRemoveTile:(UISwipeGestureRecognizer*)sender
{
    UIView* tile = (UIView*)sender.view;
    
    [self animateTileLeftToRight:tile];
}

-(void)swipeLeftToRemoveTile:(UISwipeGestureRecognizer*)sender
{
    UIView* tile = (UIView*)sender.view;
    
    [self animateTileRightToLeft:tile];
}

-(void)moodValueChanged:(UISegmentedControl*)segmentControl
{
    switch (segmentControl.selectedSegmentIndex)
    {
        case 0:
            self.currentMood = @"great";
            [self.selectedSleep setMood:@"great"];
            break;
            
        case 1:
            self.currentMood = @"soso";
            [self.selectedSleep setMood:@"soso"];
            break;
            
        case 2:
            self.currentMood = @"awful";
            [self.selectedSleep setMood:@"awful"];
            break;
            
        default:
            break;
    }
}

-(void)sliderAction:(id)sender
{
    MySlider* slider = (MySlider*)sender;
    double value = slider.value - 20.0;
    
    if(value < 0.0)
    {
        [slider setValue:0.0 animated:NO];
        [self.selectedSleep setSelfReportedSleepQuality:@"0.0"];
    }
    else if(value >= 0.0 && value<=19.9)
    {
        [slider setValue:20.0 animated:NO];
        [self.selectedSleep setSelfReportedSleepQuality:@"20.0"];
    }
    else if(value >= 20.0 && value <= 29.9)
    {
        [slider setValue:40.0 animated:NO];
        [self.selectedSleep setSelfReportedSleepQuality:@"40.0"];
    }
    else
    {
        [slider setValue:60.0 animated:NO];
        [self.selectedSleep setSelfReportedSleepQuality:@"60.0"];
    }
}

#pragma mark - cover views
-(void)showDateCoverView:(UIGestureRecognizer*)recognizer
{
    //Initialize date cover view
    [self initializeCoverView];
    
    //Add top bar to cover
    [self addTopbarToCoverView];
    
    //Add done button to top bar
    [self addDateDoneButtonToTopBar];
    
    //Add date picker
    [self addDatePickerToCoverView];
    
    //Set date picker
    [self.datePicker setMaximumDate:[NSDate date]];
    
    [self.view addSubview:self.coverView];
    
    [self animateCoverViewBottomUp];
}

-(void)showTimeCoverView:(UIGestureRecognizer*)recognizer
{
    UILabel* label = (UILabel*)recognizer.view;
    
    //Initialize date cover view
    [self initializeCoverView];
    
    //Add top bar to cover
    [self addTopbarToCoverView];
    
    //Add done button to top bar
    [self addDonebuttonToTopBarWithCurrentLable:label];
    
    //Add date picker to date cover
    [self addTimePickerToCoverViewWithTile:label];
    if(![label.text isEqualToString:@"Not Set"])
    {
        [self.datePicker setDate:[self getCurrentTimeDisplayWithText:label.text]];
    }
    
    //Add cover to view
    [self.view addSubview:self.coverView];
    
    //Animate the cover view bottom up
    [self animateCoverViewBottomUp];
}

-(void)showDurationCoverView:(UIGestureRecognizer*)recognizer
{
    UILabel* label = (UILabel*)recognizer.view;
    NSArray* textList = [label.text componentsSeparatedByString:@" "];
    
    //Initialize date cover view
    [self initializeCoverView];
    
    //Add top bar to cover
    [self addTopbarToCoverView];
    
    //Add done button to top bar
    [self addDonebuttonToTopBarWithCurrentLable:label];
    
    //Add duration picker to cover view
    [self addDurationPickerToCoverViewWithCurrentLabel:label];
    if(![label.text isEqualToString:@"Not Set"])
    {
        [self.durationPicker selectRow:[[textList objectAtIndex:0]intValue] inComponent:0 animated:YES];
        [self.durationPicker selectRow:[[textList objectAtIndex:2]intValue] inComponent:2 animated:YES];
    }
    
    //Add cover view to self.view
    [self.view addSubview:self.coverView];
    
    //Animate the cover view
    [self animateCoverViewBottomUp];
}

-(void)showTimesOfWakeUpCoverView:(UIGestureRecognizer*)recognizer
{
    UILabel* label = (UILabel*)recognizer.view;
    NSArray* textList = [label.text componentsSeparatedByString:@" "];
    
    //Initialize date cover view
    [self initializeCoverView];
    
    //Add top bar to cover
    [self addTopbarToCoverView];
    
    //Add done button to top bar
    [self addDonebuttonToTopBarWithCurrentLable:label];
    
    //Add count picker to cover view
    [self addCountPickerToCoverView];
    if(![label.text isEqualToString:@"Not Set"])
    {
        [self.countPicker selectRow:[[textList objectAtIndex:0]intValue] inComponent:0 animated:YES];
    }
    
    //Add cover view to self.view
    [self.view addSubview:self.coverView];
    
    //Animate the cover view
    [self animateCoverViewBottomUp];
}

-(void)showAlcoholCoverView:(UIGestureRecognizer*)recognizer
{
    UILabel* label = (UILabel*)recognizer.view;
    
    //Initialize date cover view
    [self initializeCoverView];
    
    //Add top bar to cover
    [self addTopbarToCoverView];
    
    //Add done button to top bar
    [self addDonebuttonToTopBarWithCurrentLable:label];
    
    //Add count picker to cover view
    [self addAlcoholPickerToCoverView];
    
    //Add image preview to cover view
    [self addAlcoholPreviewImageViewToCoverView];
    
    //Select picker view
    if(![label.text isEqualToString:@"Not Set"])
    {
        [self selectAlcoholPickerWithText:label.text];
    }
    
    //Add cover view to self.view
    [self.view addSubview:self.coverView];
    
    //Animate the cover view
    [self animateCoverViewBottomUp];
}

-(void)showActivityCoverView:(UIGestureRecognizer*)recognizer
{
    UILabel* label = (UILabel*)recognizer.view;
    
    //Initialize date cover view
    [self initializeCoverView];
    
    //Add top bar to cover
    [self addTopbarToCoverView];
    
    //Add done button to top bar
    [self addDonebuttonToTopBarWithCurrentLable:label];
    
    //Add count picker to cover view
    [self addActivityPickerToCoverView];
    
    //Select activity picker
    if(![label.text isEqualToString:@"Not Set"])
    {
        [self selectActivityPickerWithText:label.text];
    }
    
    //Add cover view to self.view
    [self.view addSubview:self.coverView];
    
    //Animate the cover view
    [self animateCoverViewBottomUp];
}

-(void)selectActivityPickerWithText:(NSString*)text
{
    for(int i=0; i<self.activityList.count; i++)
    {
        NSString* item = [self.activityList objectAtIndex:i];
        if([item isEqualToString:text])
        {
            [self.activityPicker selectRow:i inComponent:0 animated:YES];
            break;
        }
    }
}

-(void)selectAlcoholPickerWithText:(NSString*)text
{
    NSArray* textList = [text componentsSeparatedByString:@" "];
    NSString* serving;
    NSString* fraction;
    BOOL isFraction=NO;
    
    if(textList.count == 1)
    {
        return;
    }
    else if([[textList objectAtIndex:2]rangeOfString:@"ml"].location == NSNotFound)
    {
        fraction = [textList objectAtIndex:0];
        if ([fraction rangeOfString:@"/"].location == NSNotFound)
        {
            [self.alcoholPicker selectRow:[fraction intValue] inComponent:0 animated:YES];
        }
        else
        {
            isFraction = YES;
        }
        if(textList.count == 3)
            serving = [NSString stringWithFormat:@"%@ %@", [textList objectAtIndex:1], [textList objectAtIndex:2]];
        else
            serving = [NSString stringWithFormat:@"%@ %@ %@", [textList objectAtIndex:1], [textList objectAtIndex:2], [textList objectAtIndex:3]];
    }
    else
    {
        [self.alcoholPicker selectRow:[[textList objectAtIndex:0]intValue] inComponent:0 animated:YES];
        fraction = [textList objectAtIndex:1];
        isFraction = YES;
        
        if(textList.count == 4)
            serving = [NSString stringWithFormat:@"%@ %@", [textList objectAtIndex:2], [textList objectAtIndex:3]];
        else
            serving = [NSString stringWithFormat:@"%@ %@ %@", [textList objectAtIndex:2], [textList objectAtIndex:3], [textList objectAtIndex:4]];
    }
    if(isFraction)
    {
        if([fraction isEqualToString:@"1/4"])
        {
            [self.alcoholPicker selectRow:1 inComponent:1 animated:YES];
        }
        else if([fraction isEqualToString:@"1/2"])
        {
            [self.alcoholPicker selectRow:2 inComponent:1 animated:YES];
        }
        else
        {
            [self.alcoholPicker selectRow:3 inComponent:1 animated:YES];
        }
    }
    for(int i=0; i<self.alcoholServingList.count; i++)
    {
        NSString* item = [self.alcoholServingList objectAtIndex:i];
        if([item isEqualToString:serving])
        {
            [self.alcoholPicker selectRow:i inComponent:2 animated:YES];
            break;
        }
    }
}


#pragma mark - nav bar call back methods
-(void)saveParametersToDB
{
    if([self isAllTileFilled])
    {
        [[SleepDiaryDB database]updateLoggedSleepOnDate:[self getCurrentDateDisplay] WithSleep:self.selectedSleep];
        [self showAlertViewWithText:@"Changes saved successfully!" WithTitle:@""];
    }
    else
        [self showAlertViewWithText:@"Please fill all tiles!" WithTitle:@"Changes Not Saved"];
        
}

-(void)addSleepLogToDB
{
    if([self isAllTileFilled])
    {
        [[SleepDiaryDB database]insertLoggedSleepWith:self.selectedSleep];
        [self showAlertViewWithText:@"Sleep parameters added successfully!" WithTitle:@""];
        [self initializeSettingAndSaveNavBarItems];
    }
    else
        [self showAlertViewWithText:@"Please fill all tiles!" WithTitle:@"Changes Not Added"];
}

-(void)removeParametersFromDB
{
    [[SleepDiaryDB database]removeLoggedSleepOnDate:[self getCurrentDateDisplay]];
    [self showAlertViewWithText:@"Sleep log removed successfully!" WithTitle:@""];
    self.selectedSleep = [[LoggedSleep alloc]init];
    [self resetAnswersOfTiles];
    [self initializeSettingAndAddNavBarItems];
}

-(void)viewSleepDiarySetting
{
    [self initializeCoverView];
    [self addSettingTabelViewToCoverView];
    [self.view addSubview:self.coverView];
    [self animateCoverViewBottomUp];
}

-(BOOL)isAllTileFilled
{
    if(self.selectedSleep.bedTime == nil ||
       self.selectedSleep.durationOfFallingAsleep == nil ||
       self.selectedSleep.numberOfWakeup == nil ||
       self.selectedSleep.totalDurationOfWakeup == nil ||
       self.selectedSleep.timeOfGettingUp == nil)
    {
        return NO;
    }
    
    for(int i=1; i<self.tagIndex; i++)
    {
        UIView* currentTile = [self.mainScrollView viewWithTag:i];
        id currentAnswer = [[currentTile subviews]objectAtIndex:1];
        
        if([currentAnswer isKindOfClass:[UISegmentedControl class]])
        {
            if([currentAnswer selectedSegmentIndex]==-1)
                return NO;
        }
        else if([currentAnswer isKindOfClass:[UILabel class]])
        {
            if([[(UILabel*)currentAnswer text]isEqualToString:@"Not Set"])
                return NO;
        }
    }
    
    return YES;
}

-(void)showAlertViewWithText:(NSString*)message WithTitle:(NSString*)title
{
    //alert view
    UIAlertView* alert = [[UIAlertView alloc] initWithTitle:title message:message delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [alert show];
}


#pragma mark - all about cover view
-(void)initializeCoverView
{
    self.coverView = [[UIView alloc]initWithFrame:CGRectMake(self.view.frame.origin.x, self.view.frame.origin.y, self.view.frame.size.width, self.view.frame.size.height)];
    self.coverView.backgroundColor = [UIColor colorWithRed:73.0/255 green:73.0/255 blue:73.0/255 alpha:0.9];
    
    UITapGestureRecognizer* singleTap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(dismissCoverView)];
    [singleTap setNumberOfTapsRequired:1];
    [singleTap setNumberOfTouchesRequired:1];
    singleTap.delegate = self;
    [self.coverView addGestureRecognizer:singleTap];
    [self.coverView setUserInteractionEnabled:YES];
}

-(void)addTopbarToCoverView
{
    self.topBarView = [[UIView alloc]initWithFrame:CGRectMake(self.coverView.frame.origin.x, self.coverView.frame.size.height*3/5, self.coverView.frame.size.width, 40.0)];
    self.topBarView.backgroundColor = [UIColor orangeColor];
    [self.coverView addSubview:self.topBarView];
}

-(void)addDateDoneButtonToTopBar
{
    self.currentDateButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [self.currentDateButton setTitle:@"Done" forState:UIControlStateNormal];
    self.currentDateButton.frame = CGRectMake(self.topBarView.frame.size.width - 80.0, 5.0, 75.0, 30.0);
    [self.currentDateButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [[self.currentDateButton layer]setBorderColor:[UIColor whiteColor].CGColor];
    [[self.currentDateButton layer]setBorderWidth:1.0];
    
    [self.currentDateButton addTarget:self action:@selector(updateLabel:) forControlEvents:UIControlEventTouchDown];
    [self.topBarView addSubview:self.currentDateButton];
}

-(void)addDonebuttonToTopBarWithCurrentLable:(UILabel*)label
{
    UIButton* doneButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [doneButton setTitle:@"Done" forState:UIControlStateNormal];
    doneButton.frame = CGRectMake(self.topBarView.frame.size.width - 80.0, 5.0, 75.0, 30.0);
    [doneButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [[doneButton layer]setBorderColor:[UIColor whiteColor].CGColor];
    [[doneButton layer]setBorderWidth:1.0];
    
    UIView* tile = [label superview];
    
    if([tile isDescendantOfView:self.bedTimeTile])
    {
        self.bedTimeButton = doneButton;
        [self.bedTimeButton addTarget:self action:@selector(updateLabel:) forControlEvents:UIControlEventTouchDown];
        [self.topBarView addSubview:self.bedTimeButton];
    }
    else if([tile isDescendantOfView:self.timeToFallAsleepTile])
    {
        self.timeToFallAsleepButton = doneButton;
        [self.timeToFallAsleepButton addTarget:self action:@selector(updateLabel:) forControlEvents:UIControlEventTouchDown];
        [self.topBarView addSubview:self.timeToFallAsleepButton];
    }
    else if([tile isDescendantOfView:self.timesOfWakeupTile])
    {
        self.timesOfWakeupButton = doneButton;
        [self.timesOfWakeupButton addTarget:self action:@selector(updateLabel:) forControlEvents:UIControlEventTouchDown];
        [self.topBarView addSubview:self.timesOfWakeupButton];
    }
    else if([tile isDescendantOfView:self.durationOfAwakeningTile])
    {
        self.durationOfAwakeningButton = doneButton;
        [self.durationOfAwakeningButton addTarget:self action:@selector(updateLabel:) forControlEvents:UIControlEventTouchDown];
        [self.topBarView addSubview:self.durationOfAwakeningButton];
    }
    else if([tile isDescendantOfView:self.wakeUpTimeTile])
    {
        self.wakeUpTimeButton = doneButton;
        [self.wakeUpTimeButton addTarget:self action:@selector(updateLabel:) forControlEvents:UIControlEventTouchDown];
        [self.topBarView addSubview:self.wakeUpTimeButton];
    }
    else if([tile isDescendantOfView:self.turnOutLightTile])
    {
        self.turnOutLightButton = doneButton;
        [self.turnOutLightButton addTarget:self action:@selector(updateLabel:) forControlEvents:UIControlEventTouchDown];
        [self.topBarView addSubview:self.turnOutLightButton];
    }
    else if([tile isDescendantOfView:self.finalAwakeningTile])
    {
        self.finalAwakeningButton = doneButton;
        [self.finalAwakeningButton addTarget:self action:@selector(updateLabel:) forControlEvents:UIControlEventTouchDown];
        [self.topBarView addSubview:self.finalAwakeningButton];
    }
    else if([tile isDescendantOfView:self.lastTimeBigMealTile])
    {
        self.lastTimeBigMealButton = doneButton;
        [self.lastTimeBigMealButton addTarget:self action:@selector(updateLabel:) forControlEvents:UIControlEventTouchDown];
        [self.topBarView addSubview:self.lastTimeBigMealButton];
    }
    else if([tile isDescendantOfView:self.lateEveningActivityTile])
    {
        self.lateEveningActivityButton = doneButton;
        [self.lateEveningActivityButton addTarget:self action:@selector(updateLabel:) forControlEvents:UIControlEventTouchDown];
        [self.topBarView addSubview:self.lateEveningActivityButton];
    }
    else
    {
        self.lateEveningAlcoholButton = doneButton;
        [self.lateEveningAlcoholButton addTarget:self action:@selector(updateLabel:) forControlEvents:UIControlEventTouchDown];
        [self.topBarView addSubview:self.lateEveningAlcoholButton];
    }
}

-(void)addDatePickerToCoverView
{
    self.datePicker = [[UIDatePicker alloc]initWithFrame:CGRectMake(self.coverView.frame.origin.x, self.topBarView.frame.origin.y + self.topBarView.frame.size.height, self.coverView.frame.size.width, self.coverView.frame.size.height-self.topBarView.frame.origin.y-self.topBarView.frame.size.height)];
    [self.datePicker setBackgroundColor:[UIColor whiteColor]];
    
    [self.datePicker setDatePickerMode:UIDatePickerModeDate];
    [self.datePicker setDate:[self getCurrentDateDisplay]];
    [self.coverView addSubview:self.datePicker];
}

-(void)addTimePickerToCoverViewWithTile:(UILabel*)label
{
    self.datePicker = [[UIDatePicker alloc]initWithFrame:CGRectMake(self.coverView.frame.origin.x, self.topBarView.frame.origin.y + self.topBarView.frame.size.height, self.coverView.frame.size.width, self.coverView.frame.size.height-self.topBarView.frame.origin.y-self.topBarView.frame.size.height)];
    [self.datePicker setBackgroundColor:[UIColor whiteColor]];
    [self.datePicker setDatePickerMode:UIDatePickerModeDateAndTime];
    [self.datePicker setMaximumDate:[NSDate date]];
    [self.coverView addSubview:self.datePicker];
}

-(void)addDurationPickerToCoverViewWithCurrentLabel:(UILabel*)label
{
    self.durationPicker = [[UIPickerView alloc]initWithFrame:CGRectMake(self.coverView.frame.origin.x, self.topBarView.frame.origin.y + self.topBarView.frame.size.height, self.coverView.frame.size.width, self.coverView.frame.size.height-self.topBarView.frame.origin.y-self.topBarView.frame.size.height)];
    [self.durationPicker setBackgroundColor:[UIColor whiteColor]];
    self.durationPicker.delegate = self;
    [self.coverView addSubview:self.durationPicker];
}

-(void)addCountPickerToCoverView
{
    self.countPicker = [[UIPickerView alloc]initWithFrame:CGRectMake(self.coverView.frame.origin.x, self.topBarView.frame.origin.y + self.topBarView.frame.size.height, self.coverView.frame.size.width, self.coverView.frame.size.height-self.topBarView.frame.origin.y-self.topBarView.frame.size.height)];
    [self.countPicker setBackgroundColor:[UIColor whiteColor]];
    self.countPicker.delegate =self;
    [self.coverView addSubview:self.countPicker];
}

-(void)addAlcoholPickerToCoverView
{
    self.alcoholPicker = [[UIPickerView alloc]initWithFrame:CGRectMake(self.coverView.frame.origin.x, self.topBarView.frame.origin.y + self.topBarView.frame.size.height, self.coverView.frame.size.width, self.coverView.frame.size.height-self.topBarView.frame.origin.y-self.topBarView.frame.size.height)];
    [self.alcoholPicker setBackgroundColor:[UIColor whiteColor]];
    self.alcoholPicker.delegate = self;
    [self.coverView addSubview:self.alcoholPicker];
}

-(void)addActivityPickerToCoverView
{
    self.activityPicker = [[UIPickerView alloc]initWithFrame:CGRectMake(self.coverView.frame.origin.x, self.topBarView.frame.origin.y + self.topBarView.frame.size.height, self.coverView.frame.size.width, self.coverView.frame.size.height-self.topBarView.frame.origin.y-self.topBarView.frame.size.height)];
    [self.activityPicker setBackgroundColor:[UIColor whiteColor]];
    self.activityPicker.delegate = self;
    [self.coverView addSubview:self.activityPicker];
}

-(void)addSettingTabelViewToCoverView
{
    self.settingTableView = [[UITableView alloc] initWithFrame:CGRectMake(self.coverView.frame.origin.x, self.coverView.frame.size.height*3/5, self.coverView.frame.size.width, self.coverView.frame.size.height*2/5) style:UITableViewStylePlain];
    self.settingTableView.delegate = self;
    self.settingTableView.dataSource = self;
    [self.settingTableView setBackgroundColor:[UIColor clearColor]];
    self.settingTableView.autoresizingMask = UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth;
    [self initializeSettingList];
    [self initializeSwitchStates];
    [self.settingTableView reloadData];
    [self.coverView addSubview:self.settingTableView];
}

-(void)addAlcoholPreviewImageViewToCoverView
{
    UIImage* image = [UIImage imageNamed:@"sparklingwine.png"];
    self.alcoholImageView = [[UIImageView alloc]initWithImage:image];
    [self.alcoholImageView setBackgroundColor:[UIColor clearColor]];
    self.alcoholImageView.frame = CGRectMake((self.coverView.frame.size.width-image.size.width/1.2)/2.0, self.topBarView.frame.origin.y - image.size.height/1.2 - 5.0, image.size.width/1.2, image.size.height/1.2);
    [self.coverView addSubview:self.alcoholImageView];
}

-(NSInteger)returnCurrentAlcoholServingIndexWithText:(NSString*)text
{
    for(int i=0; i<self.alcoholServingList.count; i++)
    {
        if([[self.alcoholServingList objectAtIndex:i]isEqualToString:text])
        {
            return i;
        }
    }
    return -1;
}

-(NSInteger)returnCurrentActivityIndexWithText:(NSString*)text
{
    for(int i=0; i<self.activityList.count; i++)
    {
        if([[self.activityList objectAtIndex:i]isEqualToString:text])
        {
            return i;
        }
    }
    return -1;
}

-(void)animateCoverViewBottomUp
{
    [self.coverView setFrame:CGRectMake( 0.0, self.view.frame.size.height, self.view.frame.size.width, self.view.frame.size.height)];
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.4];
    [self.coverView setFrame:CGRectMake(self.view.frame.origin.x, self.view.frame.origin.y, self.view.frame.size.width, self.view.frame.size.height)];
    [UIView commitAnimations];
}

-(void)animateDateCoverViewUpBottom
{
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.4];
    [self.coverView setFrame:CGRectMake(self.view.frame.origin.x, self.view.frame.size.height, self.view.frame.size.width, self.view.frame.size.height)];
    [UIView commitAnimations];
}

-(void)removeCoverView
{
    [self.coverView removeFromSuperview];
    self.coverView = nil;
}

-(void)dismissCoverView
{
    [self animateDateCoverViewUpBottom];
    [self performSelector:@selector(removeCoverView) withObject:self afterDelay:0.4];
}

-(void)initializeSettingList
{
    self.settingList = [[NSMutableArray alloc]initWithObjects:@"Time Of Turning Off Light", @"Time Of Final Awakening", @"Time Of Last Big Meal", @"Activity At Late Evening", @"Intake Of Alcohol At Late Evening", @"Mood At The Time Of Getting Up", @"Self-Reported Sleep Quality", nil];
}

-(void)initializeSwitchStates
{
    self.switchStates = [[NSMutableArray alloc]init];
    
    if(_setting.isTimeOfTurningOutLight)
        [self.switchStates addObject:@"ON"];
    else
        [self.switchStates addObject:@"OFF"];
    
    if(_setting.isTimeOfFinalAwakening)
        [self.switchStates addObject:@"ON"];
    else
        [self.switchStates addObject:@"OFF"];
    
    if (_setting.isTimeOfLastBigMeal)
        [self.switchStates addObject:@"ON"];
    else
        [self.switchStates addObject:@"OFF"];
    
    if(_setting.isActivityAtLateEvening)
        [self.switchStates addObject:@"ON"];
    else
        [self.switchStates addObject:@"OFF"];
    
    if(_setting.isAlcoholAtLateEvening)
        [self.switchStates addObject:@"ON"];
    else
        [self.switchStates addObject:@"OFF"];
    
    if(_setting.isMood)
        [self.switchStates addObject:@"ON"];
    else
        [self.switchStates addObject:@"OFF"];
    
    if(_setting.isSelfReportedSleepQuality)
        [self.switchStates addObject:@"ON"];
    else
        [self.switchStates addObject:@"OFF"];
}

-(void)stateChanged:(UISwitch*)sender
{
    UITableViewCell* parentCell;
    
    if(SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0"))
    {
        parentCell = (UITableViewCell*)[[[sender superview]superview]superview];
    }
    else
    {
        parentCell = (UITableViewCell*)[[sender superview]superview];
    }
    
    NSIndexPath* currentIndexPath = [self.settingTableView indexPathForCell:parentCell];
    NSString* factor = [(UILabel*)[parentCell.contentView viewWithTag:2] text];
    
    if(sender.on)
    {
        [self.switchStates replaceObjectAtIndex:currentIndexPath.row withObject:@"ON"];
    }
    else
    {
        [self.switchStates replaceObjectAtIndex:currentIndexPath.row withObject:@"OFF"];
    }
    [self updateFlagWithTileName:factor WithValue:sender.on];
}

-(void)updateFlagWithTileName:(NSString*)name WithValue:(BOOL)value
{
    if([name isEqualToString:@"Time Of Turning Off Light"])
        [_setting setIsTimeOfTurningOutLight:value];
    else if([name isEqualToString:@"Time Of Final Awakening"])
        [_setting setIsTimeOfFinalAwakening:value];
    else if([name isEqualToString:@"Time Of Last Big Meal"])
        [_setting setIsTimeOfLastBigMeal:value];
    else if([name isEqualToString:@"Activity At Late Evening"])
        [_setting setIsActivityAtLateEvening:value];
    else if([name isEqualToString:@"Intake Of Alcohol At Late Evening"])
        [_setting setIsAlcoholAtLateEvening:value];
    else if([name isEqualToString:@"Mood At The Time Of Getting Up"])
        [_setting setIsMood:value];
    else
        [_setting setIsSelfReportedSleepQuality:value];
    
    [[SleepDiaryDB database]updateSleepSettingWithSetting:_setting];
    [self refreshAdditionalBlocks];
}

-(void)refreshAdditionalBlocks
{
    [self removeAllAdditionalBlock];
    [self initializeAdditonalBolocks];
    [self updateAddictionalTilesInterfaceWithSleep:self.selectedSleep];
}

-(void)removeAllAdditionalBlock
{
    for(int i=1; i<self.tagIndex; i++)
    {
        UIView* tile = [self.mainScrollView viewWithTag:i];
        if (tile != nil)
        {
            self.yAxisValue = self.yAxisValue - tile.frame.size.height - 10.0;
            [tile removeFromSuperview];
        }
        else
            break;
    }
    self.mainScrollView.contentSize = CGSizeMake(self.mainScrollView.frame.size.width, self.yAxisValue);
    self.tagIndex = 1;
}


#pragma mark - date picker call back method
-(void)updateLabel:(id)sender
{
    UIButton* button = (UIButton*)sender;
    
    if([button isDescendantOfView:self.currentDateButton])
    {
        [self updateCurrentDateTimeDisplay:self.datePicker.date ForLabel:self.currentDate];
    }
    else if([button isDescendantOfView:self.bedTimeButton])
    {
        UILabel* answer = (UILabel*)[self.bedTimeTile.subviews objectAtIndex:1];
        [self updateCurrentDateTimeDisplay:self.datePicker.date ForLabel:answer];
        [self.selectedSleep setBedTime:self.datePicker.date];
    }
    else if([button isDescendantOfView:self.timeToFallAsleepButton])
    {
        NSInteger selectedHourRow = [self.durationPicker selectedRowInComponent:0];
        NSMutableString* result = [NSMutableString stringWithFormat:@"%d", (int)(selectedHourRow)];
        [result appendString:@" Hours"];
        NSInteger selectedMinuteRow = [self.durationPicker selectedRowInComponent:2];
        [result appendString:[NSString stringWithFormat:@" %d", (int)(selectedMinuteRow)]];
        [result appendString:@" Minutes"];
        
        UILabel* answer = (UILabel*)[self.timeToFallAsleepTile.subviews objectAtIndex:1];
        [self updateOtherLabelsDisplay:result ForLabel:answer];
        [self.selectedSleep setDurationOfFallingAsleep:result];
    }
    else if([button isDescendantOfView:self.timesOfWakeupButton])
    {
        NSInteger selectedRow = [self.countPicker selectedRowInComponent:0];
        NSMutableString* selectedRowString = [NSMutableString stringWithFormat:@"%d", (int)(selectedRow)];
        [selectedRowString appendString:@" Times"];
        UILabel* answer = (UILabel*)[self.timesOfWakeupTile.subviews objectAtIndex:1];
        [self updateOtherLabelsDisplay:selectedRowString ForLabel:answer];
        [self.selectedSleep setNumberOfWakeup:selectedRowString];
    }
    else if([button isDescendantOfView:self.durationOfAwakeningButton])
    {
        NSInteger selectedHourRow = [self.durationPicker selectedRowInComponent:0];
        NSMutableString* result = [NSMutableString stringWithFormat:@"%d", (int)(selectedHourRow)];
        [result appendString:@" Hours"];
        NSInteger selectedMinuteRow = [self.durationPicker selectedRowInComponent:2];
        [result appendString:[NSString stringWithFormat:@" %d", (int)(selectedMinuteRow)]];
        [result appendString:@" Minutes"];
        
        UILabel* answer = (UILabel*)[self.durationOfAwakeningTile.subviews objectAtIndex:1];
        [self updateOtherLabelsDisplay:result ForLabel:answer];
        [self.selectedSleep setTotalDurationOfWakeup:result];
    }
    else if([button isDescendantOfView:self.wakeUpTimeButton])
    {
        UILabel* answer = (UILabel*)[self.wakeUpTimeTile.subviews objectAtIndex:1];
        [self updateCurrentDateTimeDisplay:self.datePicker.date ForLabel:answer];
        [self.selectedSleep setTimeOfGettingUp:self.datePicker.date];
    }
    else if([button isDescendantOfView:self.turnOutLightButton])
    {
        UILabel* answer = (UILabel*)[self.turnOutLightTile.subviews objectAtIndex:1];
        [self updateCurrentDateTimeDisplay:self.datePicker.date ForLabel:answer];
        [self.selectedSleep setTimeOfTurningOutTheLight:self.datePicker.date];
    }
    else if([button isDescendantOfView:self.finalAwakeningButton])
    {
        UILabel* answer = (UILabel*)[self.finalAwakeningTile.subviews objectAtIndex:1];
        [self updateCurrentDateTimeDisplay:self.datePicker.date ForLabel:answer];
        [self.selectedSleep setTimeOfFinalAwakening:self.datePicker.date];
    }
    else if([button isDescendantOfView:self.lastTimeBigMealButton])
    {
        UILabel* answer = (UILabel*)[self.lastTimeBigMealTile.subviews objectAtIndex:1];
        [self updateCurrentDateTimeDisplay:self.datePicker.date ForLabel:answer];
        [self.selectedSleep setTimeOfEatingLastBigMeal:self.datePicker.date];
    }
    else if([button isDescendantOfView:self.lateEveningActivityButton])
    {
        NSInteger selectedRow = [self.activityPicker selectedRowInComponent:0];
        NSString* selectedItem = [self.activityList objectAtIndex:selectedRow];
        UILabel* answer = (UILabel*)[self.lateEveningActivityTile.subviews objectAtIndex:1];
        [self updateOtherLabelsDisplay:selectedItem ForLabel:answer];
        
        if([selectedItem isEqualToString:@"Others"])
        {
            [self addActivityTextFieldToTileWithContent:self.selectedSleep.activityInLateEvening];
        }
        else
        {
            [self.selectedSleep setActivityInLateEvening:selectedItem];
            if([self.lateEveningActivityTile subviews].count == 3)
                [self removeActivityTextField];
        }
    }
    else
    {
        NSInteger selectedRow_0 = [self.alcoholPicker selectedRowInComponent:0];
        NSInteger selectedRow_1 = [self.alcoholPicker selectedRowInComponent:1];
        NSInteger selectedRow_2 = [self.alcoholPicker selectedRowInComponent:2];
        NSString* integer = [self.alcoholNumberList objectAtIndex:selectedRow_0];
        NSString* fraction = [self.alcoholFractionList objectAtIndex:selectedRow_1];
        NSMutableString* selectedRowString = [NSMutableString stringWithString:@""];
        if(![integer isEqualToString:@"0"])
        {
            [selectedRowString appendString:[NSString stringWithFormat:@"%d",(int)selectedRow_0]];
            [selectedRowString appendString:@" "];
        }
        if(![fraction isEqualToString:@"-"])
        {
            [selectedRowString appendString:[self.alcoholFractionList objectAtIndex:selectedRow_1]];
            [selectedRowString appendString:@" "];
        }
        if(![integer isEqualToString:@"0"] || ![fraction isEqualToString:@"-"])
        {
            [selectedRowString appendString:[self.alcoholServingList objectAtIndex:selectedRow_2]];
        }
        else
        {
            [selectedRowString appendString:@"0"];
        }
        UILabel* answer = (UILabel*)[self.lateEveningAlcoholTile.subviews objectAtIndex:1];
        [self updateOtherLabelsDisplay:selectedRowString ForLabel:answer];
        [self.selectedSleep setAlcoholInLateEvening:selectedRowString];
    }
    
    [self dismissCoverView];
}

-(NSDate*)getCurrentDateDisplay
{
    NSString *dateString = self.currentDate.text;
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"MMMM dd, yyyy"];
    NSDate *dateFromString = [[NSDate alloc] init];
    dateFromString = [dateFormatter dateFromString:dateString];
    
    return dateFromString;
}

-(NSDate*)getCurrentTimeDisplayWithText:(NSString*)text
{
    NSString *dateString = text;
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"MMMM dd, yyyy hh:mm a"];
    NSDate *dateFromString = [[NSDate alloc] init];
    dateFromString = [dateFormatter dateFromString:dateString];
    
    return dateFromString;
}

-(void)updateCurrentDateTimeDisplay: (NSDate*)currentDate ForLabel:(UILabel*)label
{
    NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
    
    if([label isEqual:self.currentDate])
    {
        [dateFormatter setDateFormat:@"MMMM dd, yyyy"];
        label.text = [dateFormatter stringFromDate:currentDate];
        [self resetAnswersOfTiles];
        [self updateTileInterface];
        
        NSDateComponents *components = [[NSCalendar currentCalendar]
                                        components:NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit
                                        fromDate:[NSDate date]];
        NSDate* todayDate = [[NSCalendar currentCalendar]
                             dateFromComponents:components];
        if([currentDate compare:todayDate] == NSOrderedAscending)
        {
            if(!self.rightDateImageView.userInteractionEnabled)
                [self enableRightArrow:YES];
        }
        else
        {
            if(self.rightDateImageView.userInteractionEnabled)
                [self enableRightArrow:NO];
        }
    }
    else
    {
        [dateFormatter setDateFormat:@"MMMM dd, yyyy hh:mm a"];
        label.text = [dateFormatter stringFromDate:currentDate];
    }
}

-(void)updateOtherLabelsDisplay:(NSString*)text ForLabel:(UILabel*)label
{
    label.text = text;
}

#pragma mark - date navigation by left and right arrows
-(void)reduceDayByOne
{
    NSDate* currentDate = [self getCurrentDateDisplay];
    NSDate* reducedDate = [currentDate dateByAddingTimeInterval:60*60*24*(-1)];
    [self updateCurrentDateTimeDisplay:reducedDate ForLabel:self.currentDate];
    
    NSDateComponents *components = [[NSCalendar currentCalendar]
                                    components:NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit
                                    fromDate:[NSDate date]];
    NSDate* todayDate = [[NSCalendar currentCalendar]
                         dateFromComponents:components];
    if([reducedDate compare:todayDate] == NSOrderedAscending)
    {
        if(!self.rightDateImageView.userInteractionEnabled)
            [self enableRightArrow:YES];
    }
}

-(void)increaseDayByOne
{
    NSDate* currentDate = [self getCurrentDateDisplay];
    NSDate* increasedDate = [currentDate dateByAddingTimeInterval:60*60*24*1];
    [self updateCurrentDateTimeDisplay:increasedDate ForLabel:self.currentDate];
    
    NSDateComponents *components = [[NSCalendar currentCalendar]
                                    components:NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit
                                    fromDate:[NSDate date]];
    NSDate* todayDate = [[NSCalendar currentCalendar]
                         dateFromComponents:components];
    if([increasedDate compare:todayDate] == NSOrderedSame)
    {
        if(self.rightDateImageView.userInteractionEnabled)
            [self enableRightArrow:NO];
    }
}

-(void)resetAnswersOfTiles
{
    [(UILabel*)[[self.bedTimeTile subviews]objectAtIndex:1] setText:@"Not Set"];
    [(UILabel*)[[self.timeToFallAsleepTile subviews]objectAtIndex:1] setText:@"Not Set"];
    [(UILabel*)[[self.timesOfWakeupTile subviews]objectAtIndex:1] setText:@"Not Set"];
    [(UILabel*)[[self.durationOfAwakeningTile subviews]objectAtIndex:1] setText:@"Not Set"];
    [(UILabel*)[[self.wakeUpTimeTile subviews]objectAtIndex:1] setText:@"Not Set"];
    
    for(int i=1; i<self.tagIndex; i++)
    {
        UIView* currentTile = [self.mainScrollView viewWithTag:i];
        id currentAnswer = [[currentTile subviews]objectAtIndex:1];
        if([currentAnswer isKindOfClass:[UISegmentedControl class]])
        {
            [currentAnswer setSelectedSegmentIndex:-1];
        }
        else if([currentAnswer isKindOfClass:[MySlider class]])
        {
            [currentAnswer setValue:0.0 animated:NO];
        }
        else
        {
            [(UILabel*)currentAnswer setText:@"Not Set"];
            
            if([currentTile isEqual:self.lateEveningActivityTile])
            {
                if(currentTile.subviews.count==3)
                    [self removeActivityTextField];
            }
        }
    }
}

-(void)updateTileInterface
{
    self.selectedSleep = [[SleepDiaryDB database]currentLoggedSleepOnDate:[self getCurrentDateDisplay]];
    if(self.selectedSleep != nil)
    {
        //Save nav button
        [self initializeSettingAndSaveNavBarItems];
        
        [self updateCurrentDateTimeDisplay:self.selectedSleep.bedTime ForLabel:(UILabel*)[[self.bedTimeTile subviews]objectAtIndex:1]];
        [self updateOtherLabelsDisplay:self.selectedSleep.durationOfFallingAsleep ForLabel:(UILabel*)[[self.timeToFallAsleepTile subviews]objectAtIndex:1]];
        [self updateOtherLabelsDisplay:self.selectedSleep.numberOfWakeup ForLabel:(UILabel*)[[self.timesOfWakeupTile subviews]objectAtIndex:1]];
        [self updateOtherLabelsDisplay:self.selectedSleep.totalDurationOfWakeup ForLabel:(UILabel*)[[self.durationOfAwakeningTile subviews]objectAtIndex:1]];
        [self updateCurrentDateTimeDisplay:self.selectedSleep.timeOfGettingUp ForLabel:(UILabel*)[[self.wakeUpTimeTile subviews]objectAtIndex:1]];
        
        [self updateAddictionalTilesInterfaceWithSleep:self.selectedSleep];
    }
    else
    {
        self.selectedSleep = [[LoggedSleep alloc]init];
        [self.selectedSleep setDate:[self getCurrentDateDisplay]];
        //Add nav button
        [self initializeSettingAndAddNavBarItems];
    }
}

-(void)updateAddictionalTilesInterfaceWithSleep:(LoggedSleep*)sleep
{
    NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"MMMM dd, yyyy hh:mm a"];
    
    if(_setting.isTimeOfTurningOutLight)
    {
        if(sleep.timeOfTurningOutTheLight != nil)
            [self updateCurrentDateTimeDisplay:sleep.timeOfTurningOutTheLight ForLabel:(UILabel*)[[self.turnOutLightTile subviews]objectAtIndex:1]];
    }
    if(_setting.isTimeOfFinalAwakening)
    {
        if(sleep.timeOfFinalAwakening != nil)
            [self updateCurrentDateTimeDisplay:sleep.timeOfFinalAwakening ForLabel:(UILabel*)[[self.finalAwakeningTile subviews]objectAtIndex:1]];
    }
    if(_setting.isTimeOfLastBigMeal)
    {
        if(sleep.timeOfEatingLastBigMeal != nil)
            [self updateCurrentDateTimeDisplay:sleep.timeOfEatingLastBigMeal ForLabel:(UILabel*)[[self.lastTimeBigMealTile subviews]objectAtIndex:1]];
    }
    if(_setting.isActivityAtLateEvening)
    {
        if(sleep.activityInLateEvening != nil)
        {
            if([self.activityList containsObject:sleep.activityInLateEvening])
            {
                [self updateOtherLabelsDisplay:sleep.activityInLateEvening ForLabel:(UILabel*)[[self.lateEveningActivityTile subviews]objectAtIndex:1]];
                if([self.lateEveningActivityTile subviews].count == 3)
                    [self removeActivityTextField];
            }
            else
            {
                [self updateOtherLabelsDisplay:@"Others" ForLabel:(UILabel*)[[self.lateEveningActivityTile subviews]objectAtIndex:1]];
                [self addActivityTextFieldToTileWithContent:self.selectedSleep.activityInLateEvening];
            }
        }
    }
    if(_setting.isAlcoholAtLateEvening)
    {
        if(sleep.alcoholInLateEvening != nil)
            [self updateOtherLabelsDisplay:sleep.alcoholInLateEvening ForLabel:(UILabel*)[[self.lateEveningAlcoholTile subviews]objectAtIndex:1]];
    }
    if(_setting.isMood)
    {
        if(sleep.mood != nil)
        {
            self.currentMood = sleep.mood;
            UISegmentedControl* moodControl = (UISegmentedControl*)[[self.moodTile subviews]objectAtIndex:1];
            if([sleep.mood isEqualToString:@"great"])
                [moodControl setSelectedSegmentIndex:0];
            else if([sleep.mood isEqualToString:@"soso"])
                [moodControl setSelectedSegmentIndex:1];
            else
                [moodControl setSelectedSegmentIndex:2];
        }
    }
    if(_setting.isSelfReportedSleepQuality)
    {
        if(sleep.selfReportedSleepQuality != nil)
        {
            MySlider* sleepQualitySlider = (MySlider*)[[self.selfReportedSleepQualityTile subviews]objectAtIndex:1];
            [sleepQualitySlider setValue:[sleep.selfReportedSleepQuality doubleValue] animated:NO];
        }
    }
}


#pragma mark - table view delegates
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.settingList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    UILabel* item=nil;
    UISwitch* indicator=nil;
    
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
        
        item = [[UILabel alloc]initWithFrame:CGRectMake(10.0, 5.0, 300.0, 30.0)];
        item.tag = 2;
        [item setBackgroundColor:[UIColor clearColor]];
        [item setNumberOfLines:1];
        [item setTextAlignment:NSTextAlignmentLeft];
        [cell.contentView addSubview:item];
        
        indicator = [[UISwitch alloc]initWithFrame:CGRectZero];
        indicator.tag = 3;
        CGRect frame = indicator.frame;
        frame.origin.x = self.settingTableView.frame.size.width - 50.0;
        frame.origin.y = 5.0;
        indicator.frame = frame;
        indicator.transform = CGAffineTransformMakeScale(0.75, 0.75);
        [indicator addTarget:self action:@selector(stateChanged:) forControlEvents:UIControlEventValueChanged];
        [cell.contentView addSubview: indicator];
    }
    else
    {
        item = (UILabel*)[cell.contentView viewWithTag:2];
        indicator = (UISwitch*)[cell.contentView viewWithTag:3];
    }
    
    item.text = [self.settingList objectAtIndex:indexPath.row];
    
    if([[self.switchStates objectAtIndex:indexPath.row]isEqualToString:@"ON"])
    {
        indicator.on = YES;
    }
    else
    {
        indicator.on = NO;
    }
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 40.0;
}

- (UIView *) tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UILabel* headerView = [[UILabel alloc] initWithFrame:CGRectMake(0.0, 0.0, self.settingTableView.bounds.size.width, 40)];
    [headerView setBackgroundColor:[UIColor orangeColor]];
    [headerView setTextColor:[UIColor whiteColor]];
    
    headerView.text = @"ADDITIONAL FACTORS";
    
    return headerView;
}


#pragma mark - UIGestureRecognizer delegate methods
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    if ([touch.view isDescendantOfView:self.topBarView])
        return NO;
    
    if([touch.view isDescendantOfView:self.datePicker] ||
       [touch.view isDescendantOfView:self.durationPicker] ||
       [touch.view isDescendantOfView:self.countPicker] ||
       [touch.view isDescendantOfView:self.alcoholPicker] ||
       [touch.view isDescendantOfView:self.activityPicker] ||
       [touch.view isDescendantOfView:self.settingTableView])
        return NO;
    
    return YES;
}


#pragma mark - picker view delegate methods
-(NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    if([pickerView isDescendantOfView:self.durationPicker])
    {
        return 4;
    }
    else if([pickerView isDescendantOfView:self.countPicker])
    {
        return 2;
    }
    else if([pickerView isDescendantOfView:self.alcoholPicker])
    {
        return 3;
    }
    else
    {
        return 1;
    }
}

-(NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    if([pickerView isDescendantOfView:self.durationPicker])
    {
        switch (component)
        {
            case 0:
                return self.durationCountHourList.count;
            case 1:
                return 1;
            case 2:
                return self.durationCountMinuteList.count;
            case 3:
                return 1;
            default:
                return -1;
        }
    }
    else if([pickerView isDescendantOfView:self.countPicker])
    {
        switch (component)
        {
            case 0:
                return self.countList.count;
            case 1:
                return 1;
            default:
                return -1;
        }
    }
    else if([pickerView isDescendantOfView:self.alcoholPicker])
    {
        switch (component)
        {
            case 0:
                return self.alcoholNumberList.count;
            case 1:
                return self.alcoholFractionList.count;
            case 2:
                return self.alcoholServingList.count;
            default:
                return -1;
        }
    }
    else
    {
        return self.activityList.count;
    }
}

- (CGFloat)pickerView:(UIPickerView *)pickerView widthForComponent:(NSInteger)component
{
    if([pickerView isDescendantOfView:self.durationPicker])
    {
        return self.view.frame.size.width*1/4;
    }
    else if([pickerView isDescendantOfView:self.countPicker])
    {
        switch (component)
        {
            case 0:
                return self.view.frame.size.width*1/5;
            case 1:
                return self.view.frame.size.width*4/5;
            default:
                return -1;
                break;
        }
    }
    else if([pickerView isDescendantOfView:self.alcoholPicker])
    {
        switch (component)
        {
            case 0:
                return self.view.frame.size.width*1/9;
            case 1:
                return self.view.frame.size.width*1/9;
            case 2:
                return self.view.frame.size.width*7/9;
            default:
                return -1;
                break;
        }
    }
    else
    {
        return self.view.frame.size.width;
    }
}

- (UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view
{
    UILabel* pickerLabel = (UILabel*)view;
    NSString* title;
    
    if (pickerLabel == nil)
    {
        pickerLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        [pickerLabel setTextAlignment:NSTextAlignmentCenter];
        [pickerLabel setBackgroundColor:[UIColor clearColor]];
        [pickerLabel setFont:[UIFont fontWithName:@"Times New Roman" size:20.0]];
    }
    
    if([pickerView isDescendantOfView:self.durationPicker])
    {
        switch (component)
        {
            case 0:
                title = [self.durationCountHourList objectAtIndex:row];
                break;
            case 1:
                title = @"Hours";
                break;
            case 2:
                title = [self.durationCountMinuteList objectAtIndex:row];
                break;
            case 3:
                title = @"Minutes";
                break;
            default:
                title = @"";
                break;
        }
        [pickerLabel setFrame:CGRectMake(0.0, 0.0, self.view.frame.size.width*1/4, 30)];
    }
    else if([pickerView isDescendantOfView:self.countPicker])
    {
        switch (component)
        {
            case 0:
                title = [self.countList objectAtIndex:row];
                [pickerLabel setFrame:CGRectMake(0.0, 0.0, self.view.frame.size.width*1/5, 30)];
                break;
            case 1:
                title = @"Times";
                [pickerLabel setFrame:CGRectMake(0.0, 0.0, self.view.frame.size.width*4/5, 30)];
                break;
            default:
                title = @"";
                break;
        }
    }
    else if([pickerView isDescendantOfView:self.alcoholPicker])
    {
        switch (component)
        {
            case 0:
                title = [self.alcoholNumberList objectAtIndex:row];
                [pickerLabel setFrame:CGRectMake(0.0, 0.0, self.view.frame.size.width*1/9, 30)];
                break;
            case 1:
                title = [self.alcoholFractionList objectAtIndex:row];
                [pickerLabel setFrame:CGRectMake(0.0, 0.0, self.view.frame.size.width*1/9, 30)];
                break;
            case 2:
                title = [self.alcoholServingList objectAtIndex:row];
                [pickerLabel setFrame:CGRectMake(0.0, 0.0, self.view.frame.size.width*7/5, 30)];
                break;
            default:
                title = @"";
                break;
        }
    }
    else
    {
        title = [self.activityList objectAtIndex:row];
        [pickerLabel setFrame:CGRectMake(0.0, 0.0, self.view.frame.size.width, 30)];
    }
    
    [pickerLabel setText:title];
    return pickerLabel;
}

-(void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    if([pickerView isDescendantOfView:self.alcoholPicker])
    {
        if(component==2)
        {
            UIImage* image;
            switch (row)
            {
                case 0:
                    image = [UIImage imageNamed:@"sparklingwine.png"];
                    break;
                case 1:
                    image = [UIImage imageNamed:@"wine.png"];
                    break;
                case 2:
                    image = [UIImage imageNamed:@"lightbeer.png"];
                    break;
                case 3:
                    image = [UIImage imageNamed:@"regularbeer.png"];
                    break;
                case 4:
                    image = [UIImage imageNamed:@"fortifiedwine.png"];
                    break;
                case 5:
                    image = [UIImage imageNamed:@"spirits.png"];
                    break;
                    
                default:
                    image = [UIImage imageNamed:@"sparklingwine.png"];
                    break;
            }
            [self.alcoholImageView setImage:image];
            self.alcoholImageView.frame = CGRectMake((self.coverView.frame.size.width-image.size.width/1.2)/2.0, self.topBarView.frame.origin.y - image.size.height/1.2 - 5.0, image.size.width/1.2, image.size.height/1.2);
        }
    }
}

#pragma mark - keyboard call back
- (void)keyboardWillShow:(NSNotification *)notification
{
    [self.mainScrollView setContentOffset:CGPointMake(self.mainScrollView.frame.origin.x, self.lateEveningActivityTile.frame.origin.y) animated:YES];
}

- (void)keyboardWillHide:(NSNotification *)notification
{
    [self.mainScrollView setContentOffset:CGPointMake(0.0, 0.0) animated:YES];
}


#pragma mark - UITextfield delegates
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    NSString *rawString = [textField text];
    NSCharacterSet *whitespace = [NSCharacterSet whitespaceAndNewlineCharacterSet];
    NSString *trimmed = [rawString stringByTrimmingCharactersInSet:whitespace];
    if ([trimmed length] != 0)
    {
        [self.selectedSleep setActivityInLateEvening:textField.text];
    }
}

- (BOOL)shouldAutorotate
{
    return NO;
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
