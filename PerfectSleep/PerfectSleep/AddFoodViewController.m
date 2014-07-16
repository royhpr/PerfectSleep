//
//  AddFoodViewController.m
//  PerfectSleep
//
//  Created by Huang Purong on 21/2/14.
//  Copyright (c) 2014 Huang Purong. All rights reserved.
//

#import "AddFoodViewController.h"

@interface AddFoodViewController ()

@property(nonatomic, readwrite)NSMutableArray* favoriteSwitchStates;
@property(nonatomic, readwrite)NSMutableArray* recentSwitchStates;
@property(nonatomic, readwrite)NSMutableArray* searchSwitchStates;
@property(strong, nonatomic)UIView* cover;
@property(strong, nonatomic)UIDatePicker* datePicker;
@property(strong, nonatomic)UIView* topBar;
@property(strong, nonatomic)UIButton* doneButton;

@property(nonatomic, readwrite)NSMutableArray* recentList;
@property(nonatomic, readwrite)NSMutableArray* favoriteList;
@property(nonatomic, readwrite)NSMutableArray* searchList;
@property(nonatomic, readwrite)NSMutableArray* recentTempList;
@property(nonatomic, readwrite)NSMutableArray* favoriteTempList;

@property(nonatomic, readwrite)NSString* dietType;
@property(nonatomic, readwrite)NSString* action;

@property(strong, nonatomic)UITableView* recentTableView;
@property(strong, nonatomic)UITableView* favoriteTableView;
@property(strong, nonatomic)UITableView* searchTableView;

@property(strong, nonatomic)UISearchBar* recentSearchBar;
@property(strong, nonatomic)UISearchBar* favoriteSearchBar;
@property(strong, nonatomic)UISearchBar* foodSearchBar;

@property(nonatomic, readwrite)NSMutableArray* decimalArray;
@property(nonatomic, readwrite)NSMutableArray* fractionArray;

@property(strong, nonatomic)UIView* addFoodCoverView;
@property(strong, nonatomic)UIView* addFoodTopBar;
@property(strong, nonatomic)UILabel* currentTitle;
@property(strong, nonatomic)UIButton* addFoodButton;
@property(strong, nonatomic)UILabel* servingNumberLabel;
@property(strong, nonatomic)UILabel* servingSizeLabel;
@property(strong, nonatomic)UIPickerView* servingPickerView;

@property(nonatomic, readwrite)FatSecretAccessor* fatSecreteSearcher;
@property(strong, nonatomic)UIActivityIndicatorView* spinner;
@property(strong, nonatomic)UILabel* searchFeedback;

@property(nonatomic, readwrite)int numberOfPages;
@property(nonatomic, readwrite)int currentPageNumber;
@property(nonatomic, readwrite)BOOL isInternetConnectionUp;
@property(nonatomic, readwrite)NutritionGeneral* currentFoodItem;
@property(nonatomic, readwrite)int selectedServingSizeIndex;
@property(nonatomic, readwrite)int selectedDecimalIndex;
@property(nonatomic, readwrite)int selectedFractionIndex;
@end

@implementation AddFoodViewController

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
    
    //Add recognizers to date arrows
    [self initializeDateArrow];
    
    //Add recognizer to date string
    [self addRecognizerToDateString];
    
    //Initialize date
    [self updateCurrentDateDisplay:_addDate];
    
    //Initialize switch states
    self.favoriteSwitchStates = [[NSMutableArray alloc]init];
    self.recentSwitchStates = [[NSMutableArray alloc]init];
    self.searchSwitchStates = [[NSMutableArray alloc]init];
    
    //Initialize recent, favorite and search list
    self.recentList = [[NSMutableArray alloc]initWithArray:[[DietDiaryDB database]recentList]];
    self.favoriteList = [[NSMutableArray alloc]initWithArray:[[DietDiaryDB database]favoriteList]];
    self.searchList = [[NSMutableArray alloc]init];
    self.favoriteTempList = [[NSMutableArray alloc]init];
    self.recentTempList = [[NSMutableArray alloc]init];
    
    //Initialzie switch states
    [self initializeSwitchStatesWithList:self.recentList];
    [self initializeSwitchStatesWithList:self.favoriteList];
    
    //Initialize action
    self.action = @"Favorite";
    
    //Create search bar and table view
    [self createSearchBarAndTableView];
    
    //Show or hide search bar and table view
    [self showHideSearchBarAndTableView];
    
    //Reload data in table view
    [self reloadDataInTableView];
    
    //Add spinner
    [self initializeSpinner];
    
    //Initialize fatscrete searcher
    self.fatSecreteSearcher = [[FatSecretAccessor alloc]initBySettingStaticParameters];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
}

-(void)initializeSpinner
{
    self.spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    [self.spinner setCenter:CGPointMake(self.searchTableView.frame.size.width/2.0, self.searchTableView.frame.origin.y + self.searchTableView.frame.size.height*1/3)];
    [self.spinner setHidesWhenStopped:YES];
    [self.view addSubview:self.spinner];
}

-(void)setCurrentDisplayDate:(NSDate*)date
{
    _addDate = date;
}


#pragma mark - date navigation
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
    self.cover.backgroundColor = [UIColor colorWithRed:73.0/255 green:73.0/255 blue:73.0/255 alpha:0.8];
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
    self.doneButton.frame = CGRectMake(self.topBar.frame.size.width - 80.0, 5.0, 75.0, 30.0);
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
    
    [self dismissCoverView];
}

-(void)removeCover
{
    [self.cover removeFromSuperview];
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

-(void)updateCurrentDateDisplay: (NSDate*)currentDate
{
    NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"MMMM dd, yyyy"];
    NSString* strDate = [dateFormatter stringFromDate:currentDate];
    
    self.currentDate.text = strDate;
    
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

-(void)animateCoverViewOutOfScreen
{
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.4];
    [self.cover setFrame:CGRectMake(self.view.frame.origin.x, self.view.frame.size.height, self.view.frame.size.width, self.view.frame.size.height)]; //notice this is ON screen!
    [UIView commitAnimations];
}

-(void)dismissCoverView
{
    [self animateCoverViewOutOfScreen];
    [self performSelector:@selector(removeCover) withObject:self afterDelay:0.4];
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

#pragma mark - navigation items
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
    
    NSIndexPath* currentIndexPath;
    NSString* state;
    
    if([self.action isEqualToString:@"Favorite"])
    {
        if(sender.on)
        {
            state = @"ON";
            if([self returnNumberOfSelectedItems] == 0)
                [self insertTrashButton];
        }
        else
        {
            state = @"OFF";
            if([self returnNumberOfSelectedItems] == 1)
                [self removeAllRightNavButtons];
        }
        currentIndexPath = [self.favoriteTableView indexPathForCell:parentCell];
        [self.favoriteSwitchStates replaceObjectAtIndex:currentIndexPath.row withObject:state];
    }
    else if([self.action isEqualToString:@"Recent"])
    {
        if(sender.on)
        {
            state = @"ON";
            if([self returnNumberOfSelectedItems] == 0)
                [self insertFavoriteButtons];
        }
        else
        {
            state = @"OFF";
            if([self returnNumberOfSelectedItems] == 1)
                [self removeAllRightNavButtons];
        }
        currentIndexPath = [self.recentTableView indexPathForCell:parentCell];
        [self.recentSwitchStates replaceObjectAtIndex:currentIndexPath.row withObject:state];
    }
    else
    {
        if(sender.on)
        {
            state = @"ON";
            if([self returnNumberOfSelectedItems] == 0)
                [self insertFavoriteButtons];
        }
        else
        {
            state = @"OFF";
            if([self returnNumberOfSelectedItems] == 1)
                [self removeAllRightNavButtons];
        }
        currentIndexPath = [self.searchTableView indexPathForCell:parentCell];
        [self.searchSwitchStates replaceObjectAtIndex:currentIndexPath.row withObject:state];
    }
}

-(int)returnNumberOfSelectedItems
{
    int count=0;
    NSMutableArray* currentSwitchStates;
    
    if([self.action isEqualToString:@"Favorite"])
    {
        currentSwitchStates = self.favoriteSwitchStates;
    }
    else if([self.action isEqualToString:@"Recent"])
    {
        currentSwitchStates = self.recentSwitchStates;
    }
    else
    {
        currentSwitchStates = self.searchSwitchStates;
    }
    
    for(NSString* currentItem in currentSwitchStates)
    {
        if([currentItem isEqualToString:@"ON"])
            count++;
    }
    return count;
}

-(void)insertFavoriteButtons
{
    UIImage* favoriteImage = [UIImage imageNamed:@"addfavorite.png"];
    UIImageView* favoriteImageView = [[UIImageView alloc]initWithImage:favoriteImage];
    [favoriteImageView setFrame:CGRectZero];
    favoriteImageView.frame = CGRectMake(favoriteImageView.frame.origin.x, favoriteImageView.frame.origin.y, 40.0, 40.0);
    [favoriteImageView setUserInteractionEnabled:YES];
    UITapGestureRecognizer* singleTap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(addSelectedItemsToFavoriteList)];
    [singleTap setNumberOfTapsRequired:1];
    [singleTap setNumberOfTouchesRequired:1];
    [favoriteImageView addGestureRecognizer:singleTap];
    
    UIBarButtonItem* favouriteButton = [[UIBarButtonItem alloc]initWithCustomView:favoriteImageView];
    self.navigationItem.rightBarButtonItem = favouriteButton;
}

-(void)insertTrashButton
{
    UIBarButtonItem* trashButton = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemTrash target:self action:@selector(removeSelectedItemsFromFavoriteList)];
    self.navigationItem.rightBarButtonItem = trashButton;
}

-(void)removeAllRightNavButtons
{
    self.navigationItem.rightBarButtonItems = nil;
}

-(void)addSelectedItemsToFavoriteList
{
    NSMutableArray* addedItems = [[NSMutableArray alloc]init];
    NSMutableArray* rejectedItems = [[NSMutableArray alloc]init];
    int count = 0;
    
    if([self.action isEqualToString:@"Recent"])
    {
        count = (int)self.recentList.count;
    }
    else
    {
        count = (int)self.searchList.count;
    }
    
    for(int i=0; i<count; i++)
    {
        NSString* state;
        Food* item;

        if([self.action isEqualToString:@"Recent"])
        {
            state = [self.recentSwitchStates objectAtIndex:i];
            item = [self.recentList objectAtIndex:i];
        }
        else
        {
            state = [self.searchSwitchStates objectAtIndex:i];
            item = [self.searchList objectAtIndex:i];
        }
        
        if([state isEqualToString:@"ON"])
        {
            if(![self isItemExistInFavoriteList:item])
            {
                [self.favoriteList addObject:item];
                [self.favoriteSwitchStates addObject:@"OFF"];
                [addedItems addObject:item];
        
                //Update DB
                [[DietDiaryDB database]addFavoriteWithFoodID:item.foodID WithFoodName:item.foodName];
            }
            else
            {
                [rejectedItems addObject:item];
            }
        }
    }
    
    NSMutableString* message = [[NSMutableString alloc]init];
    if(addedItems.count > 0)
    {
        [message appendString:[[addedItems objectAtIndex:0]foodName]];
        
        for(int i=1; i<addedItems.count; i++)
        {
            NSString* item = [[addedItems objectAtIndex:i]foodName];
            [message appendString:@", "];
            [message appendString:item];
        }
        [message appendString:@" Added Successfully\n\n"];
    }
    if(rejectedItems.count > 0)
    {
        [message appendString:[[rejectedItems objectAtIndex:0]foodName]];
        for(int i=1; i<rejectedItems.count; i++)
        {
            NSString* item = [[rejectedItems objectAtIndex:i]foodName];
            [message appendString:@", "];
            [message appendString:item];
        }
        [message appendString:@" Already Exist In Favorite!"];
    }
    
    [self showAlertViewWithMessage:message];
}

-(void)showAlertViewWithMessage:(NSString*)message
{
    //alert view
    UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"" message:message delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [alert show];
}

-(void)removeSelectedItemsFromFavoriteList
{
    NSMutableArray* removeList = [[NSMutableArray alloc]init];
    for(int i=0; i<self.favoriteSwitchStates.count; i++)
    {
        if([[self.favoriteSwitchStates objectAtIndex:i] isEqualToString:@"ON"])
        {
            [removeList addObject:[self.favoriteList objectAtIndex:i]];
        }
    }
    for(Food* item in removeList)
    {
        [[DietDiaryDB database]deleteFavoriteWithFoodID:[item foodID]];
        [self.favoriteList removeObject:item];
        if(self.favoriteTempList.count != 0)
            [self.favoriteTempList removeObject:item];
    }
    [self initializeSwitchStatesWithList:self.favoriteList];
    [self reloadDataInTableView];
    [self showAlertViewWithMessage:@"Items successfully removed from favorite list!"];
}

-(BOOL)isItemExistInFavoriteList:(Food*)item
{
    for(int i=0; i<self.favoriteList.count; i++)
    {
        if([[[self.favoriteList objectAtIndex:i]foodName]isEqualToString:[item foodName]]   &&
            [[[self.favoriteList objectAtIndex:i]foodID]isEqualToString:[item foodID]])
            return YES;
    }
    return NO;
}


#pragma mark - choose operation
- (IBAction)selectChoice:(id)sender
{
    UISegmentedControl* actionSegmentController = (UISegmentedControl*)sender;
    
    switch (actionSegmentController.selectedSegmentIndex)
    {
        case 0:
            self.action = @"Favorite";
            [self removeAllRightNavButtons];
            if([self returnNumberOfSelectedItems]>0)
                [self insertTrashButton];
            self.favoriteList = [[NSMutableArray alloc]initWithArray:[[DietDiaryDB database]favoriteList]];
            break;
        case 1:
            self.action = @"Recent";
            [self removeAllRightNavButtons];
            if([self returnNumberOfSelectedItems])
                [self insertFavoriteButtons];
            self.recentList = [[NSMutableArray alloc]initWithArray:[[DietDiaryDB database]recentList]];
            [self initializeSwitchStatesWithList:self.recentList];
            break;
        case 2:
            self.action = @"Search";
            if([self returnNumberOfSelectedItems]>0)
                [self insertFavoriteButtons];
            break;
        default:
            break;
    }
    [self showHideSearchBarAndTableView];
    [self reloadDataInTableView];
}


#pragma mark - create search bar and table view
-(void)createSearchBarAndTableView
{
    self.favoriteSearchBar = [[UISearchBar alloc]initWithFrame:CGRectMake(self.view.frame.origin.x, self.choiceSegmentControl.frame.origin.y + self.choiceSegmentControl.frame.size.height + 3.0, self.view.frame.size.width, 50.0)];
    self.favoriteSearchBar.delegate = self;
    [self.favoriteSearchBar setPlaceholder:@"search favorite"];
    [self.favoriteSearchBar setHidden:YES];
    
    self.favoriteTableView = [[UITableView alloc] initWithFrame:CGRectMake(self.favoriteSearchBar.frame.origin.x, self.favoriteSearchBar.frame.origin.y + self.favoriteSearchBar.frame.size.height, self.favoriteSearchBar.frame.size.width, self.view.frame.size.height - self.favoriteSearchBar.frame.origin.y - self.favoriteSearchBar.frame.size.height) style:UITableViewStylePlain];
    self.favoriteTableView.delegate = self;
    self.favoriteTableView.dataSource = self;
    [self.favoriteTableView setHidden:YES];
    self.favoriteTableView.autoresizingMask = UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth;
    
    self.recentSearchBar = [[UISearchBar alloc]initWithFrame:self.favoriteSearchBar.frame];
    self.recentSearchBar.delegate = self;
    [self.recentSearchBar setPlaceholder:@"search recent"];
    [self.recentSearchBar setHidden:YES];
    
    self.recentTableView = [[UITableView alloc] initWithFrame:self.favoriteTableView.frame style:UITableViewStylePlain];
    self.recentTableView.delegate = self;
    self.recentTableView.dataSource = self;
    [self.recentTableView setHidden:YES];
    self.recentTableView.autoresizingMask = UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth;
    
    self.foodSearchBar = [[UISearchBar alloc]initWithFrame:self.recentSearchBar.frame];
    self.foodSearchBar.delegate = self;
    [self.foodSearchBar setPlaceholder:@"search food"];
    [self.foodSearchBar setHidden:YES];
    
    self.searchTableView = [[UITableView alloc] initWithFrame:self.recentTableView.frame style:UITableViewStylePlain];
    self.searchTableView.delegate = self;
    self.searchTableView.dataSource = self;
    [self.searchTableView setHidden:YES];
    self.searchTableView.autoresizingMask = UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth;
    
    [self.view addSubview:self.favoriteSearchBar];
    [self.view addSubview:self.favoriteTableView];
    [self.view addSubview:self.recentSearchBar];
    [self.view addSubview:self.recentTableView];
    [self.view addSubview:self.foodSearchBar];
    [self.view addSubview:self.searchTableView];
}

-(void)showHideSearchBarAndTableView
{
    if([self.action isEqualToString:@"Favorite"])
    {
        [self.recentSearchBar setHidden:YES];
        [self.recentSearchBar setUserInteractionEnabled:NO];
        [self.recentTableView setHidden:YES];
        [self.recentTableView setUserInteractionEnabled:NO];
        
        [self.foodSearchBar setHidden:YES];
        [self.foodSearchBar setUserInteractionEnabled:NO];
        [self.searchTableView setHidden:YES];
        [self.searchTableView setUserInteractionEnabled:NO];
        
        [self.favoriteSearchBar setHidden:NO];
        [self.favoriteSearchBar setUserInteractionEnabled:YES];
        [self.favoriteTableView setHidden:NO];
        [self.favoriteTableView setUserInteractionEnabled:YES];
    }
    else if([self.action isEqualToString:@"Recent"])
    {
        [self.favoriteSearchBar setHidden:YES];
        [self.favoriteSearchBar setUserInteractionEnabled:NO];
        [self.favoriteTableView setHidden:YES];
        [self.favoriteTableView setUserInteractionEnabled:NO];
        
        [self.foodSearchBar setHidden:YES];
        [self.foodSearchBar setUserInteractionEnabled:NO];
        [self.searchTableView setHidden:YES];
        [self.searchTableView setUserInteractionEnabled:NO];
        
        [self.recentSearchBar setHidden:NO];
        [self.recentSearchBar setUserInteractionEnabled:YES];
        [self.recentTableView setHidden:NO];
        [self.recentTableView setUserInteractionEnabled:YES];
    }
    else
    {
        [self.recentSearchBar setHidden:YES];
        [self.recentSearchBar setUserInteractionEnabled:NO];
        [self.recentTableView setHidden:YES];
        [self.recentTableView setUserInteractionEnabled:NO];
        
        [self.favoriteSearchBar setHidden:YES];
        [self.favoriteSearchBar setUserInteractionEnabled:NO];
        [self.favoriteTableView setHidden:YES];
        [self.favoriteTableView setUserInteractionEnabled:NO];
        
        [self.foodSearchBar setHidden:NO];
        [self.foodSearchBar setUserInteractionEnabled:YES];
        [self.searchTableView setHidden:NO];
        [self.searchTableView setUserInteractionEnabled:YES];
    }
}

-(void)reloadDataInTableView
{
    if([self.action isEqualToString:@"Favorite"])
    {
        [self.favoriteTableView reloadData];
    }
    else if([self.action isEqualToString:@"Recent"])
    {
        [self.recentTableView reloadData];
    }
    else
    {
        [self.searchTableView reloadData];
    }
}

-(void)addSearchFeedbackView
{
    self.searchFeedback = [[UILabel alloc]initWithFrame:CGRectMake((self.view.frame.size.width - 200.0)/2.0, self.foodSearchBar.frame.origin.y + self.foodSearchBar.frame.size.height + 80.0, 200.0, 30.0)];
    [self.searchFeedback setBackgroundColor:[UIColor clearColor]];
    [self.searchFeedback setTextAlignment:NSTextAlignmentCenter];
    [self.searchFeedback setTextColor:[UIColor whiteColor]];
    [self.searchFeedback setFont:[UIFont systemFontOfSize:15.0]];
    [self.searchFeedback setHidden:YES];
    
    [self.view addSubview:self.searchFeedback];
}

-(void)initializeSwitchStatesWithList:(NSMutableArray*)list
{
    if([list isEqual:self.favoriteList])
    {
        [self.favoriteSwitchStates removeAllObjects];
        for(int i=0; i<list.count; i++)
        {
            [self.favoriteSwitchStates addObject:@"OFF"];
        }
    }
    else if([list isEqual:self.recentList])
    {
        [self.recentSwitchStates removeAllObjects];
        for(int i=0; i<list.count; i++)
        {
            [self.recentSwitchStates addObject:@"OFF"];
        }
    }
    else
    {
        [self.searchSwitchStates removeAllObjects];
        for(int i=0; i<list.count; i++)
        {
            [self.searchSwitchStates addObject:@"OFF"];
        }
    }
}

#pragma mark - test internet connection
-(BOOL)isConnectedToInternet
{
    Reachability *reachability = [Reachability reachabilityForInternetConnection];
    NetworkStatus internetStatus = [reachability currentReachabilityStatus];
    if (internetStatus == NotReachable)
    {
        return NO;
    }
    else
    {
        return  YES;
    }
}

#pragma mark - search
- (void)filterContentForSearchText:(NSString*)searchText
{
    NSMutableArray* tempList;
    if([self.action isEqualToString:@"Favorite"])
    {
        [self.favoriteList removeAllObjects];
        tempList = self.favoriteTempList;
    }
    else if([self.action isEqualToString:@"Recent"])
    {
        [self.recentList removeAllObjects];
        tempList = self.recentTempList;
    }
    
    for(Food* item in tempList)
    {
        if ([[[item foodName]lowercaseString]rangeOfString:[searchText lowercaseString]].location != NSNotFound)
        {
            if([self.action isEqualToString:@"Favorite"])
            {
                [self.favoriteList addObject:item];
            }
            else if([self.action isEqualToString:@"Recent"])
            {
                [self.recentList addObject:item];
            }
        }
    }
    
    if([self.action isEqualToString:@"Favorite"])
    {
        [self initializeSwitchStatesWithList:self.favoriteList];
    }
    else if([self.action isEqualToString:@"Recent"])
    {
        [self initializeSwitchStatesWithList:self.recentList];
    }
    [self reloadDataInTableView];
}

-(void)loadNextTwentyItems
{
    self.currentPageNumber++;
    
    NSMutableArray* result = [self.fatSecreteSearcher searchFood:[self.foodSearchBar.text lowercaseString] withPageNumber:self.currentPageNumber];
    [self.searchList addObjectsFromArray:[result objectAtIndex:0]];
    
    for(int i=0; i<[[result objectAtIndex:0]count]; i++)
    {
        [self.searchSwitchStates addObject:@"OFF"];
    }
    
    if([self.action isEqualToString:@"Search"])
        [self reloadDataInTableView];
}


#pragma mark - add food view
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

-(void)initializeAddFoodCoverView
{
    self.addFoodCoverView = [[UIView alloc]initWithFrame:CGRectMake(self.view.frame.origin.x, self.view.frame.origin.y, self.view.frame.size.width, self.view.frame.size.height)];
    self.addFoodCoverView.backgroundColor = [UIColor colorWithRed:73.0/255 green:73.0/255 blue:73.0/255 alpha:0.8];
    
    UITapGestureRecognizer* singleTap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(dismissAddFoodCoverView)];
    [singleTap setNumberOfTapsRequired:1];
    [singleTap setNumberOfTouchesRequired:1];
    singleTap.delegate = self;
    
    [self.addFoodCoverView addGestureRecognizer:singleTap];
    [self.addFoodCoverView setUserInteractionEnabled:YES];
}

-(void)addTopBarToAddFoodCoverView
{
    self.addFoodTopBar = [[UIView alloc]initWithFrame:CGRectMake(self.addFoodCoverView.frame.origin.x, self.addFoodCoverView.frame.size.height * 3/5, self.addFoodCoverView.frame.size.width, 50.0)];
    self.addFoodTopBar.backgroundColor = [UIColor orangeColor];
    [self.addFoodCoverView addSubview:self.addFoodTopBar];
}

-(void)addTitleViewToAddFoodTopBarWithTitle:(NSString*)title;
{
    self.currentTitle = [[UILabel alloc]initWithFrame:CGRectMake(5.0, 5.0, self.addFoodTopBar.frame.size.width - 65.0, 40.0)];
    self.currentTitle.text = title;
    self.currentTitle.font = [UIFont systemFontOfSize:20.0];
    self.currentTitle.numberOfLines = 2;
    self.currentTitle.baselineAdjustment = UIBaselineAdjustmentAlignBaselines;
    self.currentTitle.adjustsFontSizeToFitWidth = YES;
    self.currentTitle.minimumScaleFactor = 10.0f/12.0f;
    self.currentTitle.clipsToBounds = YES;
    self.currentTitle.backgroundColor = [UIColor clearColor];
    self.currentTitle.textColor = [UIColor whiteColor];
    self.currentTitle.textAlignment = NSTextAlignmentLeft;
    
    UITapGestureRecognizer* singleTap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(viewNutritionFact)];
    [singleTap setNumberOfTapsRequired:1];
    [singleTap setNumberOfTouchesRequired:1];
    [self.currentTitle addGestureRecognizer:singleTap];
    [self.currentTitle setUserInteractionEnabled:YES];
    
    [self.addFoodTopBar addSubview:self.currentTitle];
}

-(void)addDoneButtonToAddFoodTopBar
{
    self.addFoodButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [self.addFoodButton addTarget:self action:@selector(addFoodItemToDiary) forControlEvents:UIControlEventTouchDown];
    [self.addFoodButton setTitle:@"Add" forState:UIControlStateNormal];
    self.addFoodButton.frame = CGRectMake(self.addFoodTopBar.frame.size.width - 60.0, 10.0, 55.0, 30.0);
    [[self.addFoodButton layer]setBorderWidth:1.0];
    [[self.addFoodButton layer]setBorderColor:[UIColor whiteColor].CGColor];
    [self.addFoodButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.addFoodTopBar addSubview:self.addFoodButton];
}

-(void)addHeaderToComponentOfPickerView
{
    self.servingNumberLabel = [[UILabel alloc]initWithFrame:CGRectMake(self.addFoodTopBar.frame.origin.x, self.addFoodTopBar.frame.origin.y+self.addFoodTopBar.frame.size.height, self.view.frame.size.width*2/6, self.addFoodTopBar.frame.size.height - 10.0)];
    [self.servingNumberLabel setBackgroundColor:[UIColor grayColor]];
    [self.servingNumberLabel setFont:[UIFont boldSystemFontOfSize:11.0]];
    [[self.servingNumberLabel layer]setBorderWidth:0.1];
    self.servingNumberLabel.text = @"SERVING NUMBER";
    [self.servingNumberLabel setTextAlignment:NSTextAlignmentCenter];
    [self.addFoodCoverView addSubview:self.servingNumberLabel];
    
    self.servingSizeLabel = [[UILabel alloc]initWithFrame:CGRectMake(self.servingNumberLabel.frame.origin.x + self.servingNumberLabel.frame.size.width, self.servingNumberLabel.frame.origin.y, self.view.frame.size.width*4/6, self.servingNumberLabel.frame.size.height)];
    [self.servingSizeLabel setBackgroundColor:[UIColor grayColor]];
    [self.servingSizeLabel setFont:[UIFont boldSystemFontOfSize:11.0]];
    [[self.servingSizeLabel layer]setBorderWidth:0.1];
    self.servingSizeLabel.text = @"SERVING SIZE";
    [self.servingSizeLabel setTextAlignment:NSTextAlignmentCenter];
    [self.addFoodCoverView addSubview:self.servingSizeLabel];
}

-(void)addPickerViewToAddFoodCoverView
{
    self.servingPickerView = [[UIPickerView alloc]initWithFrame:CGRectMake(self.servingNumberLabel.frame.origin.x, self.servingNumberLabel.frame.origin.y+self.servingNumberLabel.frame.size.height, self.addFoodTopBar.frame.size.width, self.addFoodCoverView.frame.size.height - self.servingNumberLabel.frame.origin.y - self.servingNumberLabel.frame.size.height)];
    self.servingPickerView.backgroundColor = [UIColor whiteColor];
    self.servingPickerView.dataSource = self;
    self.servingPickerView.delegate = self;
    [self.addFoodCoverView addSubview:self.servingPickerView];
}

-(void)animateAddFoodCoverViewFromBottomToTop
{
    [self.addFoodCoverView setFrame:CGRectMake( 0.0, self.view.frame.size.height, self.view.frame.size.width, self.view.frame.size.height)];
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.4];
    [self.addFoodCoverView setFrame:CGRectMake(self.view.frame.origin.x, self.view.frame.origin.y, self.view.frame.size.width, self.view.frame.size.height)];
    [UIView commitAnimations];
}

-(void)animateAddFoodCoverViewFromTopToBottom
{
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.4];
    [self.addFoodCoverView setFrame:CGRectMake(self.view.frame.origin.x, self.view.frame.size.height, self.view.frame.size.width, self.view.frame.size.height)];
    [UIView commitAnimations];
}

-(void)removeAddFoodCoverView
{
    [self.addFoodCoverView removeFromSuperview];
}

-(void)addFoodItemToDiary
{
    //Update database with new serving number and serving size
    NSString* availableID = [self generateNextConsumptionIDWithIDList:[[DietDiaryDB database]consumeIDList]];
    NSString* foodID = self.currentFoodItem.foodID;
    NSString* servingID = [[[self.currentFoodItem servings]objectAtIndex:self.selectedServingSizeIndex]servingID];
    NSString* foodName = self.currentFoodItem.foodName;
    NSMutableString* servingNumber = [NSMutableString stringWithString:[self.decimalArray objectAtIndex:self.selectedDecimalIndex]];
    if(![[self.fractionArray objectAtIndex:self.selectedFractionIndex]isEqualToString:@"-"])
    {
        [servingNumber appendString:@"+"];
        [servingNumber appendString:[self.fractionArray objectAtIndex:self.selectedFractionIndex]];
    }
    NSString* servingSize = [[[self.currentFoodItem servings]objectAtIndex:self.selectedServingSizeIndex]servingDescription];
    NSDate* consumeDate = [self getCurrentDateDisplay];
    
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
    
    [[DietDiaryDB database]addConsumptionWithConsumeID:availableID FoodID:foodID ServingID:servingID FoodName:foodName ServingNumber:servingNumber ServingSize:servingSize ConsumeDate:consumeDate Calories:calories TotalFats:totalFats saturatedFat:saturatedFat polyUnsaturatedFat:polyUnsaturatedFat MonounUnsaturatedFat:monounUnsaturatedFat Cholesterol:cholesterol Sodium:sodium Potassium:potassium TotalCarbohydrate:totalCarbohydrate DietaryFiber:dietaryFiber Sugars:sugars Protein:protein VitaminA:vitaminA VitaminC:vitaminC Calcium:calcium Iron:iron];
    
    ConsumedFood* item = [[ConsumedFood alloc]initWith:availableID :foodID :servingID :foodName :servingNumber :servingSize :consumeDate :calories :totalFats :saturatedFat :polyUnsaturatedFat :monounUnsaturatedFat :cholesterol :sodium :potassium :totalCarbohydrate :dietaryFiber :sugars :protein :vitaminA :vitaminC :calcium :iron];
    
    //delegate method to tell diet diary list
    [self.delegate addConsumptionToList:item WithDate:[self getCurrentDateDisplay]];
    
    //Dismiss edit view
    [self dismissAddFoodCoverView];
}

-(NSString*)generateNextConsumptionIDWithIDList:(NSArray*)list
{
    int availableID = 1;
    
    if(list.count==0)
        return [NSString stringWithFormat:@"%d", availableID];
    
    for(NSString* item in list)
    {
        int currentInt = [item intValue];
        if(availableID == currentInt)
            availableID++;
        else
            break;
    }
    return [NSString stringWithFormat:@"%d", availableID];
}

-(void)dismissAddFoodCoverView
{
    [self animateAddFoodCoverViewFromTopToBottom];
    [self performSelector:@selector(removeAddFoodCoverView) withObject:self afterDelay:0.4];
}

-(void)viewNutritionFact
{
    [self performSegueWithIdentifier:@"FromAddFoodToNutritionFact" sender:self];
}


#pragma mark - delegate method from Nutrition View Controller
-(void)addConsumedItemToList:(ConsumedFood*)item
{
    [self.delegate addConsumptionToList:item WithDate:[self getCurrentDateDisplay]];
}


#pragma mark - Table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if([tableView isEqual:self.favoriteTableView])
        return self.favoriteList.count;
    else if([tableView isEqual:self.recentTableView])
        return self.recentList.count;
    else
        return self.searchList.count;
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
        name = [[UILabel alloc]initWithFrame:CGRectZero];
        name.tag = 2;
        [name setFont:[UIFont systemFontOfSize:15.0]];
        [name setBackgroundColor:[UIColor clearColor]];
        [name setNumberOfLines:2];
        [cell.contentView addSubview:name];
        
        //Initialize indicator
        indicator = [[UISwitch alloc]initWithFrame:CGRectZero];
        indicator.tag = 3;
        indicator.transform = CGAffineTransformMakeScale(0.75, 0.75);
        CGRect frame = indicator.frame;
        frame.origin.x = cell.contentView.frame.size.width - 50.0;
        frame.origin.y = (cell.contentView.frame.size.height - frame.size.height) / 2;
        indicator.frame = frame;
        [indicator addTarget:self action:@selector(stateChanged:) forControlEvents:UIControlEventValueChanged];
        [cell.contentView addSubview:indicator];
    }
    
    name = (UILabel*)[cell.contentView viewWithTag:2];
    indicator = (UISwitch*)[cell.contentView viewWithTag:3];
    NSString* title;
    NSString* state;
    if([tableView isEqual:self.favoriteTableView])
    {
        title = [[self.favoriteList objectAtIndex:indexPath.row]foodName];
        state = [self.favoriteSwitchStates objectAtIndex:indexPath.row];
    }
    else if([tableView isEqual:self.recentTableView])
    {
        title = [[self.recentList objectAtIndex:indexPath.row]foodName];
        state = [self.recentSwitchStates objectAtIndex:indexPath.row];
    }
    else
    {
        title = [[self.searchList objectAtIndex:indexPath.row]foodName];
        state = [self.searchSwitchStates objectAtIndex:indexPath.row];
    }
    
    if([state isEqualToString:@"ON"])
    {
        indicator.on = YES;
    }
    else
    {
        indicator.on = NO;
    }
    
    name.text = title;
    [name sizeToFit];
    [name setFrame:CGRectMake(5.0, (cell.contentView.frame.size.height - name.frame.size.height)/2.0, cell.contentView.frame.size.width-50.0, name.frame.size.height)];

    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 40.0;
}

#pragma mark - Table view delegate methods
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    //Resign responder
    if([self.action isEqualToString:@"Favorite"])
        [self.favoriteSearchBar resignFirstResponder];
    else if([self.action isEqualToString:@"Recent"])
        [self.recentSearchBar resignFirstResponder];
    else
        [self.foodSearchBar resignFirstResponder];
    
    Food* selectedFood;
    if([self.action isEqualToString:@"Favorite"])
    {
        selectedFood = [self.favoriteList objectAtIndex:indexPath.row];
    }
    else if([self.action isEqualToString:@"Recent"])
    {
        selectedFood = [self.recentList objectAtIndex:indexPath.row];
    }
    else
    {
        selectedFood = [self.searchList objectAtIndex:indexPath.row];
    }
    
    //Initialize cover view data
    [self initializeServingNumberArrays];
    
    //Initialize current food item
    [self initializeCurrentFoodItemWithFoodID:[selectedFood foodID]];
    
    //Initialize cover view
    [self initializeAddFoodCoverView];
    
    //Add top bar to cover
    [self addTopBarToAddFoodCoverView];
    
    //Add title to top bar
    [self addTitleViewToAddFoodTopBarWithTitle:[selectedFood foodName]];
    
    //Add done button
    [self addDoneButtonToAddFoodTopBar];
    
    //Add component headers of picker view
    [self addHeaderToComponentOfPickerView];
    
    //Add picker view
    [self addPickerViewToAddFoodCoverView];
    
    //Add cover view to super view
    [self.view addSubview:self.addFoodCoverView];
    
    //Play animation botton up
    [self animateAddFoodCoverViewFromBottomToTop];
}

#pragma mark - Search bar delegate methods
-(void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar
{
    searchBar.showsCancelButton = YES;
    
    if([self.action isEqualToString:@"Favorite"])
    {
        [self.favoriteTempList removeAllObjects];
        self.favoriteTempList = [[NSMutableArray alloc]initWithArray:self.favoriteList];
        [self.favoriteList removeAllObjects];
        [self reloadDataInTableView];
    }
    else if([self.action isEqualToString:@"Recent"])
    {
        [self.recentTempList removeAllObjects];
        self.recentTempList = [[NSMutableArray alloc]initWithArray:self.recentList];
        [self.recentList removeAllObjects];
        [self reloadDataInTableView];
    }
    else
    {
        if(![self.searchTableView isHidden])
        {
            [self.searchTableView setHidden:YES];
        }
    }
}

-(void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    if([self.action isEqualToString:@"Favorite"] || [self.action isEqualToString:@"Recent"])
    {
        [self filterContentForSearchText:searchText];
    }
}

-(void)searchBarTextDidEndEditing:(UISearchBar *)searchBar
{
    searchBar.showsCancelButton = NO;
    
    if([self.action isEqualToString:@"Favorite"])
    {
        searchBar.text = @"";
        
        if(self.favoriteTempList.count != 0)
        {
            [self.favoriteList removeAllObjects];
            self.favoriteList = [[NSMutableArray alloc]initWithArray:self.favoriteTempList];
            [self initializeSwitchStatesWithList:self.favoriteList];
            [self reloadDataInTableView];
        }
    }
    else if([self.action isEqualToString:@"Recent"])
    {
        searchBar.text = @"";
        
        if(self.recentTempList.count != 0)
        {
            [self.recentList removeAllObjects];
            self.recentList = [[NSMutableArray alloc]initWithArray:self.recentTempList];
            [self initializeSwitchStatesWithList:self.recentList];
            [self reloadDataInTableView];
        }
    }
    else
    {
        if(self.isInternetConnectionUp)
        {
            if(self.searchList.count!=0)
            {
                [self.searchFeedback setHidden:YES];
                
                [self.searchTableView setHidden:NO];
                [self reloadDataInTableView];
            }
            else
            {
                [self.searchFeedback setHidden:NO];
                self.searchFeedback.text = @"No Result!";
            }
        }
        else
        {
            [self.searchFeedback setHidden:NO];
            self.searchFeedback.text = @"No Network Connection!";
        }
    }
}

-(void)searchBarCancelButtonClicked:(UISearchBar *)searchBar
{
    [searchBar resignFirstResponder];
}

-(void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    if([self.action isEqualToString:@"Search"])
    {
        if([self isConnectedToInternet])
        {
            self.isInternetConnectionUp = YES;
            [self.spinner setHidden:NO];
            [self.spinner startAnimating];
            
            NSMutableArray* result = [self.fatSecreteSearcher searchFood:[searchBar.text lowercaseString] withPageNumber:0];
            [self.searchList removeAllObjects];
            [self.searchList addObjectsFromArray: [result objectAtIndex:0]];
            [self initializeSwitchStatesWithList:self.searchList];
            
            self.numberOfPages = [(NSNumber*)[result objectAtIndex:1]intValue];
            self.currentPageNumber = 0;
            
            [self.spinner stopAnimating];
        }
        else
        {
            self.isInternetConnectionUp = NO;
        }
    }
    [searchBar resignFirstResponder];
    [self removeAllRightNavButtons];
}

#pragma mark - picker view delegate methods
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


#pragma - mark scroll view delegate methods
- (void)scrollViewDidScroll: (UIScrollView*)scroll
{
    if([self.action isEqualToString:@"Search"] && self.currentPageNumber < self.numberOfPages)
    {
        // UITableView only moves in one direction, y axis
        CGFloat currentOffset = scroll.contentOffset.y;
        CGFloat maximumOffset = scroll.contentSize.height - scroll.frame.size.height;
        
        // Change 10.0 to adjust the distance from bottom
        if (maximumOffset - currentOffset <= 5.0)
        {
            [self loadNextTwentyItems];
        }
    }
}

#pragma mark - gesture delegate methods
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    if ([touch.view isDescendantOfView:self.addFoodTopBar])
        return NO;
    
    if([touch.view isDescendantOfView:self.servingPickerView])
        return NO;
    
    return YES;
}

#pragma mark - keyboard delegate methods
- (void)keyboardWillShow:(NSNotification *)notification
{
    CGSize keyboardSize = [[[notification userInfo] objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    
    UIEdgeInsets contentInsets;
    if (UIInterfaceOrientationIsPortrait([[UIApplication sharedApplication] statusBarOrientation]))
    {
        contentInsets = UIEdgeInsetsMake(0.0, 0.0, (keyboardSize.height), 0.0);
    }
    else
    {
        contentInsets = UIEdgeInsetsMake(0.0, 0.0, (keyboardSize.width), 0.0);
    }
    
    if([self.action isEqualToString:@"Favorite"])
    {
        self.favoriteTableView.contentInset = contentInsets;
        self.favoriteTableView.scrollIndicatorInsets = contentInsets;
    }
    
    if([self.action isEqualToString:@"Recent"])
    {
        self.recentTableView.contentInset = contentInsets;
        self.recentTableView.scrollIndicatorInsets = contentInsets;
    }
}

- (void)keyboardWillHide:(NSNotification *)notification
{
    UIEdgeInsets edge = UIEdgeInsetsMake(0, 0, 0, 0);
    
    if([self.action isEqualToString:@"Favorite"])
    {
        self.favoriteTableView.contentInset = edge;
        self.favoriteTableView.scrollIndicatorInsets = edge;
    }
    
    if([self.action isEqualToString:@"Recent"])
    {
        self.recentTableView.contentInset = edge;
        self.recentTableView.scrollIndicatorInsets = edge;
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"FromAddFoodToNutritionFact"])
    {
        NutritionViewController* nutritionController = [segue destinationViewController];
        nutritionController.addDelegate = self;
        [nutritionController configureCurrentFoodItemWithItem:self.currentFoodItem Date:[self getCurrentDateDisplay] Mode:@"Add"];
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
