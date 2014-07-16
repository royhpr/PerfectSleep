//
//  DietDiaryViewController.m
//  PerfectSleep
//
//  Created by Huang Purong on 2/3/14.
//  Copyright (c) 2014 Huang Purong. All rights reserved.
//

#import "DietDiaryViewController.h"

@interface DietDiaryViewController ()

@property(nonatomic, readwrite)NSMutableArray* switchStates;
@property(strong, nonatomic)UIView* cover;
@property(strong, nonatomic)UIDatePicker* datePicker;
@property(strong, nonatomic)UIView* topBar;
@property(strong, nonatomic)UIButton* doneButton;

@property(strong, nonatomic)UIView* editCoverView;
@property(strong, nonatomic)UIView* editTopBar;
@property(strong, nonatomic)UISegmentedControl* dietTypeView;
@property(strong, nonatomic)UIButton* editDoneButton;
@property(strong, nonatomic)UILabel* servingNumberLabel;
@property(strong, nonatomic)UILabel* servingSizeLabel;
@property(strong, nonatomic)UIPickerView* servingPickerView;
@property(strong, nonatomic)UILabel* currentTitle;

@property(nonatomic, readwrite)NSMutableArray* consumedFoodItemList;

@property(nonatomic, readwrite)NSMutableArray* decimalArray;
@property(nonatomic, readwrite)NSMutableArray* fractionArray;
@property(nonatomic, readwrite)NSMutableArray* servingSizeArray;

@property(nonatomic, readwrite)FatSecretAccessor* fatSecreteSearcher;
@property(nonatomic, readwrite)NutritionGeneral* currentFoodItem;
@property(nonatomic, readwrite)ConsumedFood* selectedConsumeItem;
@property(nonatomic, readwrite)int selectedServingSizeIndex;
@property(nonatomic, readwrite)int selectedDecimalIndex;
@property(nonatomic, readwrite)int selectedFractionIndex;
@end

@implementation DietDiaryViewController

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
    
    //Set up nav bar right button
    UIBarButtonItem* addButton = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(viewAddFoodInterface)];
    self.navigationItem.rightBarButtonItem = addButton;
    
    //Add recognizers to date arrows
    [self initializeDateArrow];
    
    //Add recognizer to date string
    [self addRecognizerToDateString];
    
    //Update date string to today date
    NSDateComponents *components = [[NSCalendar currentCalendar]
                                    components:NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit
                                    fromDate:[NSDate date]];
    NSDate* todayDate = [[NSCalendar currentCalendar]
                         dateFromComponents:components];
    [self updateCurrentDateDisplay:todayDate];
    
    //Initialize fatscrete searcher
    self.fatSecreteSearcher = [[FatSecretAccessor alloc]initBySettingStaticParameters];
}

-(void)configureSwitchStates
{
    self.switchStates = [[NSMutableArray alloc]init];
    for(int i=0; i<self.consumedFoodItemList.count; i++)
    {
        [self.switchStates addObject:@"OFF"];
    }
}

-(void)initializeDateArrow
{
    //Initialize left and right date arrow
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

-(void)addRecognizerToDateString
{
    //Initialize date string interaction
    UITapGestureRecognizer* singleDateTap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(showDatePicker)];
    [singleDateTap setNumberOfTapsRequired:1];
    [singleDateTap setNumberOfTouchesRequired:1];
    [self.currentDate addGestureRecognizer:singleDateTap];
}

-(void)showDatePicker
{
    //Initialize a cover view to sit on top of current views
    self.cover = [[UIView alloc]initWithFrame:CGRectMake(self.view.frame.origin.x, self.view.frame.origin.y, self.view.frame.size.width, self.view.frame.size.height)];
    self.cover.backgroundColor = [UIColor colorWithRed:73.0/255 green:73.0/255 blue:73.0/255  alpha:0.8];
    UITapGestureRecognizer* singleTap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(dismissCoverView)];
    [singleTap setNumberOfTapsRequired:1];
    [singleTap setNumberOfTouchesRequired:1];
    singleTap.delegate = self;
    [self.cover addGestureRecognizer:singleTap];
    [self.cover setUserInteractionEnabled:YES];
    
    //Add date picker to cover
    self.datePicker = [[UIDatePicker alloc]initWithFrame:CGRectMake(self.view.frame.origin.x, self.view.frame.size.height-self.view.frame.size.height * 1/3, self.view.frame.size.width, self.view.frame.size.height * 1/3)];
    [self.datePicker setBackgroundColor:[UIColor whiteColor]];
    [self.datePicker setDatePickerMode:UIDatePickerModeDate];
    [self.datePicker setDate:[self getCurrentDateDisplay]];
    [self.datePicker setMaximumDate:[NSDate date]];
    [self.cover addSubview:self.datePicker];
    
    //Add top bar to cover
    self.topBar = [[UIView alloc]initWithFrame:CGRectMake(self.datePicker.frame.origin.x, self.datePicker.frame.origin.y-40.0, self.datePicker.frame.size.width, 40.0)];
    self.topBar.backgroundColor = [UIColor orangeColor];
    [self.cover addSubview:self.topBar];
    
    //Add done button to top bar
    self.doneButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [self.doneButton addTarget:self action:@selector(selectDate) forControlEvents:UIControlEventTouchDown];
    [self.doneButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.doneButton setTitle:@"Done" forState:UIControlStateNormal];
    self.doneButton.frame = CGRectMake(self.topBar.frame.size.width - 80.0, 5.0, 70.0, 30.0);
    [[self.doneButton layer]setBorderWidth:1.0];
    [[self.doneButton layer]setBorderColor:[UIColor whiteColor].CGColor];
    [self.topBar addSubview:self.doneButton];
    
    //Show cover view
    [self.view addSubview:self.cover];
    
    //Play animation from bottom up
    [self.cover setFrame:CGRectMake( 0.0, self.view.frame.size.height, self.view.frame.size.width, self.view.frame.size.height)];
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.4];
    [self.cover setFrame:CGRectMake(self.view.frame.origin.x, self.view.frame.origin.y, self.view.frame.size.width, self.view.frame.size.height)];
    [UIView commitAnimations];
}

-(void)selectDate
{
    //Update date
    [self updateCurrentDateDisplay:self.datePicker.date];
    
    //Animate out of screen
    [self dismissCoverView];
}

-(void)animateCoverViewOutOfScreen
{
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.4];
    [self.cover setFrame:CGRectMake(self.view.frame.origin.x, self.view.frame.size.height, self.view.frame.size.width, self.view.frame.size.height)]; //notice this is ON screen!
    [UIView commitAnimations];
}

-(void)removeCover
{
    [self.cover removeFromSuperview];
}

-(void)dismissCoverView
{
    [self animateCoverViewOutOfScreen];
    [self performSelector:@selector(removeCover) withObject:self afterDelay:0.4];
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


#pragma mark - Start Date Navigation
-(NSDate*)getCurrentDateDisplay
{
    NSString *dateString = self.currentDate.text;
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"MMMM dd, yyyy"];
    NSDate *dateFromString = [[NSDate alloc] init];
    dateFromString = [dateFormatter dateFromString:dateString];
    
    return dateFromString;
}

-(void)updateCurrentDateDisplay: (NSDate*)currentDate
{
    NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"MMMM dd, yyyy"];
    NSString* strDate = [dateFormatter stringFromDate:currentDate];
    self.currentDate.text = strDate;
    
    [self updateCosumeListWithDate:currentDate];
    [self removeTrashButton];
    
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

-(void)reduceDayByOne
{
    NSDate* currentDate = [self getCurrentDateDisplay];
    NSDate* reducedDate = [currentDate dateByAddingTimeInterval:60*60*24*(-1)];
    [self updateCurrentDateDisplay:reducedDate];
    
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
    [self updateCurrentDateDisplay:increasedDate];
    
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

-(void)viewAddFoodInterface
{
    [self performSegueWithIdentifier:@"FromDietDiaryToAddFood" sender:self];
}

-(void)deleteSelectedItems
{
    NSMutableArray* removeList = [[NSMutableArray alloc]init];
    for(int i=0; i<self.switchStates.count; i++)
    {
        if([[self.switchStates objectAtIndex:i] isEqualToString:@"ON"])
        {
            [removeList addObject:[self.consumedFoodItemList objectAtIndex:i]];
        }
    }
    for(ConsumedFood* item in removeList)
    {
        [[DietDiaryDB database]deleteConsumptionWithConsumeID:[item consumeID]];
        [self.consumedFoodItemList removeObject:item];
    }
    [self configureSwitchStates];
    [self.dietDiaryTableView reloadData];
    [self removeTrashButton];
    [self showAlertViewWithMessage:@"Items successfully removed!"];
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
    
    NSIndexPath* currentIndexPath = [self.dietDiaryTableView indexPathForCell:parentCell];
    
    if(sender.on)
    {
        if([self returnNumberOfSelectedItems] == 0)
            [self insertTrashButton];
        
        [self.switchStates replaceObjectAtIndex:currentIndexPath.row withObject:@"ON"];
    }
    else
    {
        if([self returnNumberOfSelectedItems] == 1)
            [self removeTrashButton];
        
        [self.switchStates replaceObjectAtIndex:currentIndexPath.row withObject:@"OFF"];
    }
}

-(void)updateCosumeListWithDate:(NSDate*)date
{
    self.consumedFoodItemList = [[NSMutableArray alloc]initWithArray:[[DietDiaryDB database]consumptionListBetweenStartDate:date EndDate:date]];
    [self configureSwitchStates];
    [self.dietDiaryTableView reloadData];
}

-(int)returnNumberOfSelectedItems
{
    int count = 0;
    for(int i=0; i<self.switchStates.count; i++)
    {
        if([self.switchStates[i] isEqualToString:@"ON"])
            count++;
    }
    return  count;
}

-(void)insertTrashButton
{
    UIBarButtonItem* trashButton = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemTrash target:self action:@selector(deleteSelectedItems)];
    UIBarButtonItem* addButton = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(viewAddFoodInterface)];
    self.navigationItem.rightBarButtonItems = [[NSArray alloc]initWithObjects:addButton, trashButton, nil];
}

-(void)removeTrashButton
{
    UIBarButtonItem* addButton = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(viewAddFoodInterface)];
    self.navigationItem.rightBarButtonItems = [[NSArray alloc]initWithObjects:addButton, nil];
}

-(void)showAlertViewWithMessage:(NSString*)message
{
    //alert view
    UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"" message:message delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [alert show];
}


#pragma mark - select current food item
-(void)initializeCurrentFoodItemWithFoodID:(NSString*)foodID
{
    NutritionGeneral* temp = [self.fatSecreteSearcher GetFood:foodID];
    
    self.currentFoodItem = [[NutritionGeneral alloc]init];
    self.currentFoodItem.foodID = temp.foodID;
    self.currentFoodItem.foodName = temp.foodName;
    self.currentFoodItem.foodType = temp.foodType;
    self.currentFoodItem.brandName = temp.brandName;
    self.currentFoodItem.foodURL = temp.foodURL;
    self.currentFoodItem.servings = [[NSMutableArray alloc]initWithArray:temp.servings];
}

#pragma mark - Initialize Edit View
-(void)initializeServingNumberArrays
{
    self.decimalArray = [[NSMutableArray alloc]init];
    self.fractionArray = [[NSMutableArray alloc]init];
    
    //decimal array
    for(int i=0; i<5000; i++)
    {
        [self.decimalArray addObject:[NSString stringWithFormat:@"%d", i+1]];
    }
    
    //fraction array
    [self.fractionArray addObjectsFromArray:[NSArray arrayWithObjects:@"-", @"1/4", @"1/2", @"3/4", nil]];
}

-(void)initializeServingSizeArray:(NSMutableArray*)servingList
{
    self.servingSizeArray = [[NSMutableArray alloc]init];
    [self.servingSizeArray addObjectsFromArray:servingList];
}

-(void)initializeEditCoverView
{
    self.editCoverView = [[UIView alloc]initWithFrame:CGRectMake(self.view.frame.origin.x, self.view.frame.origin.y, self.view.frame.size.width, self.view.frame.size.height)];
    self.editCoverView.backgroundColor = [UIColor colorWithRed:73.0/255 green:73.0/255 blue:73.0/255 alpha:0.8];
    
    UITapGestureRecognizer* singleTap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(dismissEditCoverView)];
    [singleTap setNumberOfTapsRequired:1];
    [singleTap setNumberOfTouchesRequired:1];
    singleTap.delegate = self;
    
    [self.editCoverView addGestureRecognizer:singleTap];
    [self.editCoverView setUserInteractionEnabled:YES];
}

-(void)addTopBarToEditCoverView
{
    self.editTopBar = [[UIView alloc]initWithFrame:CGRectMake(self.editCoverView.frame.origin.x, self.editCoverView.frame.size.height * 3/5, self.editCoverView.frame.size.width, 50.0)];
    self.editTopBar.backgroundColor = [UIColor orangeColor];
    [self.editCoverView addSubview:self.editTopBar];
}

-(void)addTitleView
{
    self.currentTitle = [[UILabel alloc]initWithFrame:CGRectMake(5.0, 5.0, self.editTopBar.frame.size.width-65.0, 40.0)];
    self.currentTitle.text = self.selectedConsumeItem.foodName;
    self.currentTitle.font = [UIFont systemFontOfSize:20.0];
    self.currentTitle.numberOfLines = 2;
    self.currentTitle.baselineAdjustment = UIBaselineAdjustmentAlignBaselines;
    self.currentTitle.adjustsFontSizeToFitWidth = YES;
    self.currentTitle.minimumScaleFactor = 10.0f/12.0f;
    self.currentTitle.clipsToBounds = YES;
    self.currentTitle.backgroundColor = [UIColor clearColor];
    self.currentTitle.textColor = [UIColor whiteColor];
    self.currentTitle.textAlignment = NSTextAlignmentLeft;
    
    UITapGestureRecognizer* singleTap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(viewNutritionView)];
    [singleTap setNumberOfTapsRequired:1];
    [singleTap setNumberOfTouchesRequired:1];
    [self.currentTitle addGestureRecognizer:singleTap];
    [self.currentTitle setUserInteractionEnabled:YES];

    [self.editTopBar addSubview:self.currentTitle];
}

-(void)addDoneButtonToEditCoverView
{
    self.editDoneButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [self.editDoneButton addTarget:self action:@selector(selectServingNumberAndSize) forControlEvents:UIControlEventTouchDown];
    [self.editDoneButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.editDoneButton setTitle:@"Done" forState:UIControlStateNormal];
    self.editDoneButton.frame = CGRectMake(self.editTopBar.frame.size.width - 60.0, 10.0, 55.0, 30.0);
    [[self.editDoneButton layer]setBorderWidth:1.0];
    [[self.editDoneButton layer]setBorderColor:[UIColor whiteColor].CGColor];
    [self.editTopBar addSubview:self.editDoneButton];
}

-(void)addHeaderToComponentOfPickerView
{
    self.servingNumberLabel = [[UILabel alloc]initWithFrame:CGRectMake(self.editTopBar.frame.origin.x, self.editTopBar.frame.origin.y+self.editTopBar.frame.size.height, self.view.frame.size.width*2/6, self.editTopBar.frame.size.height - 10.0)];
    [self.servingNumberLabel setBackgroundColor:[UIColor grayColor]];
    [self.servingNumberLabel setFont:[UIFont boldSystemFontOfSize:11.0]];
    [[self.servingNumberLabel layer]setBorderWidth:0.1];
    self.servingNumberLabel.text = @"SERVING NUMBER";
    [self.servingNumberLabel setTextAlignment:NSTextAlignmentCenter];
    [self.editCoverView addSubview:self.servingNumberLabel];
    
    self.servingSizeLabel = [[UILabel alloc]initWithFrame:CGRectMake(self.servingNumberLabel.frame.origin.x + self.servingNumberLabel.frame.size.width, self.servingNumberLabel.frame.origin.y, self.view.frame.size.width*4/6, self.servingNumberLabel.frame.size.height)];
    [self.servingSizeLabel setBackgroundColor:[UIColor grayColor]];
    [self.servingSizeLabel setFont:[UIFont boldSystemFontOfSize:11.0]];
    [[self.servingSizeLabel layer]setBorderWidth:0.1];
    self.servingSizeLabel.text = @"SERVING SIZE";
    [self.servingSizeLabel setTextAlignment:NSTextAlignmentCenter];
    [self.editCoverView addSubview:self.servingSizeLabel];
}

-(void)addPickerViewToEditCoverView
{
    self.servingPickerView = [[UIPickerView alloc]initWithFrame:CGRectMake(self.servingNumberLabel.frame.origin.x, self.servingNumberLabel.frame.origin.y+self.servingNumberLabel.frame.size.height, self.editTopBar.frame.size.width, self.editCoverView.frame.size.height - self.servingNumberLabel.frame.origin.y - self.servingNumberLabel.frame.size.height)];
    [self.servingPickerView setBackgroundColor:[UIColor whiteColor]];

    self.servingPickerView.dataSource = self;
    self.servingPickerView.delegate = self;
    [self.editCoverView addSubview:self.servingPickerView];
}

-(void)selectServingPickerView
{
    NSArray* servingNumberArray = [self.selectedConsumeItem.servingNumber componentsSeparatedByString:@"+"];
    int decimalIndex = [[servingNumberArray objectAtIndex:0]intValue] - 1;
    int fractionIndex;
    int servingSizeIndex;
    
    if(servingNumberArray.count == 1)
        fractionIndex = 0;
    else
    {
        NSString* fraction = [servingNumberArray objectAtIndex:0];
        if([fraction isEqualToString:@"1/4"])
            fractionIndex = 1;
        else if([fraction isEqualToString:@"1/2"])
            fractionIndex = 2;
        else
            fractionIndex = 3;
    }
    
    for(int i=0; i<self.currentFoodItem.servings.count; i++)
    {
        NSString* currentServingID = [[self.currentFoodItem.servings objectAtIndex:i]servingID];
        if([currentServingID isEqualToString:self.selectedConsumeItem.servingID])
            servingSizeIndex = i;
    }
    [self.servingPickerView selectRow:decimalIndex inComponent:0 animated:YES];
    [self.servingPickerView selectRow:fractionIndex inComponent:1 animated:YES];
    [self.servingPickerView selectRow:servingSizeIndex inComponent:2 animated:YES];
}

-(void)animateEditCoverViewFromBottomToTop
{
    [self.editCoverView setFrame:CGRectMake( 0.0, self.view.frame.size.height, self.view.frame.size.width, self.view.frame.size.height)];
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.4];
    [self.editCoverView setFrame:CGRectMake(self.view.frame.origin.x, self.view.frame.origin.y, self.view.frame.size.width, self.view.frame.size.height)];
    [UIView commitAnimations];
}

-(void)animateEditCoverViewFromTopToBottom
{
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.4];
    [self.editCoverView setFrame:CGRectMake(self.view.frame.origin.x, self.view.frame.size.height, self.view.frame.size.width, self.view.frame.size.height)];
    [UIView commitAnimations];
}

-(void)selectServingNumberAndSize
{
    //Update database with new serving number and serving size
    NSString* servingID = [[[self.currentFoodItem servings]objectAtIndex:self.selectedServingSizeIndex]servingID];
    NSMutableString* servingNumber = [NSMutableString stringWithString:[self.decimalArray objectAtIndex:self.selectedDecimalIndex]];
    if(![[self.fractionArray objectAtIndex:self.selectedFractionIndex]isEqualToString:@"-"])
    {
        [servingNumber appendString:@"+"];
        [servingNumber appendString:[self.fractionArray objectAtIndex:self.selectedFractionIndex]];
    }
    NSString* servingSize = [[[self.currentFoodItem servings]objectAtIndex:self.selectedServingSizeIndex]servingDescription];
    
    NSString* calories = [[[self.currentFoodItem servings]objectAtIndex:self.selectedServingSizeIndex]calories];
    calories = calories == nil ? @"0" : calories;
    NSString* totalFats = [[[self.currentFoodItem servings]objectAtIndex:self.selectedServingSizeIndex]fat];
    totalFats = totalFats == nil ? @"0" : totalFats;
    NSString* saturatedFat = [[[self.currentFoodItem servings]objectAtIndex:self.selectedServingSizeIndex]saturatedFat];
    saturatedFat = saturatedFat == nil ? @"0" : saturatedFat;
    NSString* polyUnsaturatedFat = [[[self.currentFoodItem servings]objectAtIndex:self.selectedServingSizeIndex]polyUnsaturatedFat];
    polyUnsaturatedFat = polyUnsaturatedFat == nil ? @"0" : polyUnsaturatedFat;
    NSString* monounUnsaturatedFat = [[[self.currentFoodItem servings]objectAtIndex:self.selectedServingSizeIndex]monounsaturatedFat];
    monounUnsaturatedFat = monounUnsaturatedFat == nil ? @"0" : monounUnsaturatedFat;
    NSString* cholesterol = [[[self.currentFoodItem servings]objectAtIndex:self.selectedServingSizeIndex]cholesterol];
    cholesterol = cholesterol == nil ? @"0" : cholesterol;
    NSString* sodium = [[[self.currentFoodItem servings]objectAtIndex:self.selectedServingSizeIndex]sodium];
    sodium = sodium == nil ? @"0" : sodium;
    NSString* potassium = [[[self.currentFoodItem servings]objectAtIndex:self.selectedServingSizeIndex]potassium];
    potassium = potassium == nil ? @"0" : potassium;
    NSString* totalCarbohydrate = [[[self.currentFoodItem servings]objectAtIndex:self.selectedServingSizeIndex]carbohydrate];
    totalCarbohydrate = totalCarbohydrate == nil ? @"0" : totalCarbohydrate;
    NSString* dietaryFiber = [[[self.currentFoodItem servings]objectAtIndex:self.selectedServingSizeIndex]fiber];
    dietaryFiber = dietaryFiber == nil ? @"0" : dietaryFiber;
    NSString* sugars = [[[self.currentFoodItem servings]objectAtIndex:self.selectedServingSizeIndex]sugar];
    sugars = sugars == nil ? @"0" : sugars;
    NSString* protein = [[[self.currentFoodItem servings]objectAtIndex:self.selectedServingSizeIndex]protein];
    protein = protein == nil ? @"0" : protein;
    NSString* vitaminA = [[[self.currentFoodItem servings]objectAtIndex:self.selectedServingSizeIndex]vitaminA];
    vitaminA = vitaminA == nil ? @"0" : vitaminA;
    NSString* vitaminC = [[[self.currentFoodItem servings]objectAtIndex:self.selectedServingSizeIndex]vitaminC];
    vitaminC = vitaminC == nil ? @"0" : vitaminC;
    NSString* calcium = [[[self.currentFoodItem servings]objectAtIndex:self.selectedServingSizeIndex]calcium];
    calcium = calcium == nil ? @"0" : calcium;
    NSString* iron = [[[self.currentFoodItem servings]objectAtIndex:self.selectedServingSizeIndex]iron];
    iron = iron == nil ? @"0" : iron;
    
    [[DietDiaryDB database]updateConsumptionWithConsumeID:self.selectedConsumeItem.consumeID ServingID:servingID ServingNumber:servingNumber ServingSize:servingSize Calories:calories TotalFats:totalFats saturatedFat:saturatedFat polyUnsaturatedFat:polyUnsaturatedFat MonounUnsaturatedFat:monounUnsaturatedFat Cholesterol:cholesterol Sodium:sodium Potassium:potassium TotalCarbohydrate:totalCarbohydrate DietaryFiber:dietaryFiber Sugars:sugars Protein:protein VitaminA:vitaminA VitaminC:vitaminC Calcium:calcium Iron:iron];

    ConsumedFood* item = [[ConsumedFood alloc]initWith:self.selectedConsumeItem.consumeID :self.currentFoodItem.foodID :servingID :self.currentFoodItem.foodName :servingNumber :servingSize :self.selectedConsumeItem.consumeDate :calories :totalFats :saturatedFat :polyUnsaturatedFat :monounUnsaturatedFat :cholesterol :sodium :potassium :totalCarbohydrate :dietaryFiber :sugars :protein :vitaminA :vitaminC :calcium :iron];
    
    [self updateConsumeListWithConsumeItem:item];
    
    //Dismiss edit view
    [self animateEditCoverViewFromTopToBottom];
    [self performSelector:@selector(removeEditCoverView) withObject:self afterDelay:0.4];
}

-(void)updateConsumeListWithConsumeItem:(ConsumedFood*)item
{
    NSString* consumeID = item.consumeID;
    int index = -1;
    
    for(int i=0; i<self.consumedFoodItemList.count; i++)
    {
        ConsumedFood* currentItem = [self.consumedFoodItemList objectAtIndex:i];
        
        if(currentItem.consumeID == consumeID)
        {
            index = i;
            break;
        }
    }
    
    if(index != -1)
    {
        [self.consumedFoodItemList replaceObjectAtIndex:index withObject:item];
        self.selectedConsumeItem = item;
        [self.dietDiaryTableView reloadData];
    }
    
    if(self.servingPickerView != nil)
        [self selectServingPickerView];
}

-(void)viewNutritionView
{
    [self performSegueWithIdentifier:@"FromDietDiaryToNutrition" sender:self];
}

-(void)removeEditCoverView
{
    [self.editCoverView removeFromSuperview];
}

-(void)dismissEditCoverView
{
    [self animateEditCoverViewFromTopToBottom];
    [self performSelector:@selector(removeEditCoverView) withObject:self afterDelay:0.4];
}


#pragma mark - Table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.consumedFoodItemList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    UISwitch* indicator = nil;
    UILabel* name = nil;
    
    if(cell==nil)
    {
        //Initialize cell
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        
        //Initialize food name lable
        name = [[UILabel alloc]initWithFrame:CGRectMake(10.0, (cell.contentView.frame.size.height-50.0)/2.0, cell.contentView.frame.size.width-60.0, 80.0)];
        name.tag = 2;
        [name setFont:[UIFont systemFontOfSize:15.0]];
        [name setBackgroundColor:[UIColor clearColor]];
        [name setNumberOfLines:0];
        [name setLineBreakMode:NSLineBreakByWordWrapping];
        [cell.contentView addSubview:name];
        
        //Initialize indicator
        indicator = [[UISwitch alloc]initWithFrame:CGRectZero];
        indicator.tag = 3;
        CGRect frame = indicator.frame;
        frame.origin.x = cell.contentView.frame.size.width - 60.0;
        frame.origin.y = (90.0 - frame.size.height)/2.0;
        indicator.frame = frame;
        [indicator addTarget:self action:@selector(stateChanged:) forControlEvents:UIControlEventValueChanged];
        [cell.contentView addSubview:indicator];
    }
    else
    {
        name = (UILabel*)[cell.contentView viewWithTag:2];
        indicator = (UISwitch*)[cell.contentView viewWithTag:3];
    }
    
    ConsumedFood* currentFood = [self.consumedFoodItemList objectAtIndex:indexPath.row];
    NSMutableString* title = [NSMutableString stringWithString:[currentFood foodName]];
    [title appendString:@"\n"];
    [title appendString:@"Serving number: "];
    [title appendString:[currentFood servingNumber]];
    [title appendString:@"\n"];
    [title appendString:@"Serving size: "];
    [title appendString:[currentFood servingSize]];
    name = (UILabel*)[cell.contentView viewWithTag:2];
    name.text = title;
    CGSize referenceSize = CGSizeMake(cell.contentView.frame.size.width-60.0, 80.0);
    CGSize calculatedSize = [name sizeThatFits:referenceSize];
    name.frame = CGRectMake(name.frame.origin.x, (90.0 - calculatedSize.height)/2.0, calculatedSize.width, calculatedSize.height);
    
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
    return 90;
}

#pragma mark - Table view delegate methods
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    //Initialize cover view data
    [self initializeServingNumberArrays];
    
    //Initialize current food item
    [self initializeCurrentFoodItemWithFoodID:[[self.consumedFoodItemList objectAtIndex:indexPath.row]foodID]];
    
    //Initialize selected consume item
    self.selectedConsumeItem = [self.consumedFoodItemList objectAtIndex:indexPath.row];
    
    //Initialize cover view
    [self initializeEditCoverView];
    
    //Add top bar to cover
    [self addTopBarToEditCoverView];
    
    //Add title to top bar
    [self addTitleView];
    
    //Add done button
    [self addDoneButtonToEditCoverView];
    
    //Add component headers of picker view
    [self addHeaderToComponentOfPickerView];
    
    //Add picker view
    [self addPickerViewToEditCoverView];
    
    //Select picker view serving number and serving size
    [self selectServingPickerView];
    
    //Add cover view to super view
    [self.view addSubview:self.editCoverView];
    
    //Play animation bottom up
    [self animateEditCoverViewFromBottomToTop];
}

#pragma mark - picker view data source
-(NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 3;
}

-(NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    if(component==0)
    {
        return self.decimalArray.count;
    }
    else if(component==1)
    {
        return self.fractionArray.count;
    }
    else
    {
        return [[self.currentFoodItem servings]count];
    }
}

- (CGFloat)pickerView:(UIPickerView *)pickerView widthForComponent:(NSInteger)component
{
    switch (component)
    {
        case 0:
            return self.view.frame.size.width*1/6;
        case 1:
            return self.view.frame.size.width*1/6;
        case 2:
            return self.view.frame.size.width*4/6;
        default:
            return 0;
    }
}

- (UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view
{
    UILabel* pickerLabel = (UILabel*)view;
    NSString* title;
    
    if (pickerLabel == nil)
    {
        CGRect frame;
        if(component==0)
        {
            frame = CGRectMake(0.0, 0.0, self.view.frame.size.width*1/6, 30);
        }
        else if(component==1)
        {
            frame = CGRectMake(0.0, 0.0, self.view.frame.size.width*1/6, 30);
        }
        else
        {
            frame = CGRectMake(0.0, 0.0, self.view.frame.size.width*4/6, 30);
        }
        
        pickerLabel = [[UILabel alloc] initWithFrame:frame];
        [pickerLabel setTextAlignment:NSTextAlignmentCenter];
        [pickerLabel setBackgroundColor:[UIColor clearColor]];
        [pickerLabel setFont:[UIFont fontWithName:@"Times New Roman" size:18.0]];
    }
    
    if(component==0)
    {
        title = [self.decimalArray objectAtIndex:row];
    }
    else if(component==1)
    {
        title = [self.fractionArray objectAtIndex:row];
    }
    else
    {
        title = [[[self.currentFoodItem servings]objectAtIndex:row]servingDescription];
    }
    
    [pickerLabel setText:title];
    return pickerLabel;
}

-(void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    if(component==0)
    {
        self.selectedDecimalIndex = (int)row;
    }
    else if(component==1)
    {
        self.selectedFractionIndex = (int)row;
    }
    else
    {
        self.selectedServingSizeIndex = (int)row;
    }
}

#pragma mark - Add Food delegate method
-(void)addConsumptionToList:(ConsumedFood*)consumedItem WithDate:(NSDate*)date
{
    if([[self getCurrentDateDisplay] compare:date] == NSOrderedSame)
    {
        [self.consumedFoodItemList addObject:consumedItem];
        [self.switchStates addObject:@"OFF"];
        [self.dietDiaryTableView reloadData];
    }
}

#pragma mark - gesture delegate methods
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    if ([touch.view isDescendantOfView:self.editTopBar] || [touch.view isDescendantOfView:self.topBar])
        return NO;
    
    if([touch.view isDescendantOfView:self.datePicker] || [touch.view isDescendantOfView:self.servingPickerView])
        return NO;
    
    return YES;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"FromDietDiaryToNutrition"])
    {
        NutritionViewController* nutritionController = [segue destinationViewController];
        nutritionController.updateDelegate = self;
        [nutritionController configureCurrentFoodItemWithItem:self.currentFoodItem Date:[self getCurrentDateDisplay] Mode:@"Update"];
        [nutritionController configureSelectedConsumeItem:self.selectedConsumeItem];
    }
    
    if([[segue identifier]isEqualToString:@"FromDietDiaryToAddFood"])
    {
        AddFoodViewController* addFoodController = [segue destinationViewController];
        addFoodController.delegate = self;
        [addFoodController setCurrentDisplayDate:[self getCurrentDateDisplay]];
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
