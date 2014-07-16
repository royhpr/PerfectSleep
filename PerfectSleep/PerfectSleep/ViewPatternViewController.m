//
//  ViewPatternViewController.m
//  PerfectSleep
//
//  Created by Huang Purong on 19/3/14.
//  Copyright (c) 2014 Huang Purong. All rights reserved.
//

#import "ViewPatternViewController.h"

@interface ViewPatternViewController ()

@property(strong, nonatomic)UIView* coverView;
@property(strong, nonatomic)UIView* topBarView;

@property(strong, nonatomic)UIDatePicker* datePicker;
@property(strong, nonatomic)UITableView* trendFactorTableView;

@property(strong, nonatomic)UIButton* fromDateDoneButton;
@property(strong, nonatomic)UIButton* toDateDoneButton;

@property(strong, nonatomic)UILabel* nutritionLabel;
@property(strong, nonatomic)UILabel* sleepRelatedLabel;

@property(nonatomic, readwrite)NSMutableArray* nutritionList;
@property(nonatomic, readwrite)NSMutableArray* sleepRelatedList;

@property(nonatomic, readwrite)PlotColor* color;
@property(nonatomic, readwrite)NSMutableDictionary* plotDataList;

@property(nonatomic, readwrite)NSTimeInterval oneday;
@property(nonatomic, readwrite)NSDate* refDate;
@property(nonatomic, readwrite)NSMutableArray* xValueList;
@property(nonatomic, readwrite)NSMutableArray* yValueList;

@property (nonatomic, strong) CPTGraphHostingView* hostView;

@property(nonatomic, readwrite)NSMutableArray* nutritionSwitchStates;
@property(nonatomic, readwrite)NSMutableArray* sleepRelatedSwitchStates;

@property(nonatomic, readwrite)int labelOffset;

@end

@implementation ViewPatternViewController

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
    
    //Initialize factors
    self.nutritionList = [[NSMutableArray alloc]init];
    [self.nutritionList addObject:@"Calories"];
    [self.nutritionList addObject:@"Total Fats"];
    [self.nutritionList addObject:@"Saturated Fat"];
    [self.nutritionList addObject:@"Polyunsaturated Fat"];
    [self.nutritionList addObject:@"Monoununsaturated Fat"];
    [self.nutritionList addObject:@"Cholesterol"];
    [self.nutritionList addObject:@"Sodium"];
    [self.nutritionList addObject:@"Potassium"];
    [self.nutritionList addObject:@"Total Carbohydrate"];
    [self.nutritionList addObject:@"Dietary Fiber"];
    [self.nutritionList addObject:@"Sugars"];
    [self.nutritionList addObject:@"Protein"];
    [self.nutritionList addObject:@"Vitamin A"];
    [self.nutritionList addObject:@"Vitamin C"];
    [self.nutritionList addObject:@"Calcium"];
    [self.nutritionList addObject:@"Iron"];
    
    self.sleepRelatedList = [[NSMutableArray alloc]initWithObjects:@"Calculated Sleep Duration", @"Bed Time", @"Time of turning out the light", @"Duration of falling asleep", @"Number of wake-up", @"Total duration of wake-up", @"Time of getting up", @"Time of eating last big meal", @"Acitivity in late evening", @"Alcohol in late evening", @"Mood upon getting up", @"Self-report sleep Quality", @"Time of final awakening", nil];
    
    //Initialize date string
    [self initializeDateStringWith:self.fromDate];
    [self initializeDateStringWith:self.toDate];
    
    //Initialize right left arrow
    [self initializeLeftRightArrowsWithLeftView:self.leftFromDateImageView WithRightView:self.rightFromDateImageView];
    [self initializeLeftRightArrowsWithLeftView:self.leftToDateImageView WithRightView:self.rightToDateImageView];
    [self enableFromRightArrow:NO];
    [self enableToRightArrow:NO];
    
    //Initialize switch states
    [self initializeSwitchStates];
    
    //Initialize parameter for graph
    self.oneday = 24 * 60 * 60;
    self.plotDataList = [[NSMutableDictionary alloc]initWithCapacity:5];
    self.color = [[PlotColor alloc]initColorList];
    self.refDate = [self getCurrentDateDisplayWithText:self.fromDate.text];
    
    //Set up nav bar right button
    UIImageView* trendImageView = [[UIImageView alloc]initWithFrame:CGRectZero];
    trendImageView.frame = CGRectMake(trendImageView.frame.origin.x, trendImageView.frame.origin.y, 30.0, 30.0);
    [trendImageView setImage:[UIImage imageNamed:@"trend.png"]];
    [trendImageView setUserInteractionEnabled:YES];
    UITapGestureRecognizer* trendSingleTap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(showFactorCoverView:)];
    [trendSingleTap setNumberOfTapsRequired:1];
    [trendSingleTap setNumberOfTouchesRequired:1];
    [trendImageView addGestureRecognizer:trendSingleTap];
    
    UIImageView* legendImageView = [[UIImageView alloc]initWithFrame:CGRectZero];
    legendImageView.frame = CGRectMake(legendImageView.frame.origin.x, legendImageView.frame.origin.y, 30.0, 30.0);
    [legendImageView setImage:[UIImage imageNamed:@"legend.png"]];
    [legendImageView setUserInteractionEnabled:YES];
    UITapGestureRecognizer* legendSingleTap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(displayHideLegend:)];
    [legendSingleTap setNumberOfTapsRequired:1];
    [legendSingleTap setNumberOfTouchesRequired:1];
    [legendImageView addGestureRecognizer:legendSingleTap];
    
    UIBarButtonItem* legendButton = [[UIBarButtonItem alloc]initWithCustomView:legendImageView];
    UIBarButtonItem* trendButton = [[UIBarButtonItem alloc]initWithCustomView:trendImageView];
    
    self.navigationItem.rightBarButtonItems = [NSArray arrayWithObjects:trendButton, legendButton, nil];
}

-(void)enableFromRightArrow:(BOOL)enable
{
    if(enable)
    {
        [self.rightFromDateImageView setImage:[UIImage imageNamed:@"right.png"]];
        [self.rightFromDateImageView setUserInteractionEnabled:YES];
    }
    else
    {
        UIImage* greyOutImage = [self convertImageToGrayScale:[UIImage imageNamed:@"right.png"]];
        [self.rightFromDateImageView setImage:greyOutImage];
        [self.rightFromDateImageView setUserInteractionEnabled:NO];
    }
}

-(void)enableToRightArrow:(BOOL)enable
{
    if(enable)
    {
        [self.rightToDateImageView setImage:[UIImage imageNamed:@"right.png"]];
        [self.rightToDateImageView setUserInteractionEnabled:YES];
    }
    else
    {
        UIImage* greyOutImage = [self convertImageToGrayScale:[UIImage imageNamed:@"right.png"]];
        [self.rightToDateImageView setImage:greyOutImage];
        [self.rightToDateImageView setUserInteractionEnabled:NO];
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

#pragma mark - UIViewController lifecycle methods
-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    self.labelOffset = 10.0;
    [self configureHostView];
    [self configureGraphWithHostView];
    [self addGraphLegend];
}

#pragma mark - Chart behavior
-(void)configureHostView
{
    self.hostView = [(CPTGraphHostingView *) [CPTGraphHostingView alloc] initWithFrame:self.mainScrollView.bounds];
    self.hostView.allowPinchScaling = YES;
    [self.mainScrollView addSubview:self.hostView];
}

-(void)configureGraphWithHostView
{
    // 1 - Create the graph
    CPTGraph* graph = [[CPTXYGraph alloc] initWithFrame:self.hostView.bounds];
    [graph applyTheme:[CPTTheme themeNamed:kCPTDarkGradientTheme]];
    self.hostView.hostedGraph = graph;
    
    // 2 - Set graph title
    graph.title = @"Pattern";
    
    // 3 - Set graph title
    CPTMutableTextStyle *titleStyle = [CPTMutableTextStyle textStyle];
    titleStyle.color = [CPTColor whiteColor];
    titleStyle.fontName = @"Helvetica-Bold";
    titleStyle.fontSize = 16.0f;
    graph.titleTextStyle = titleStyle;
    graph.titlePlotAreaFrameAnchor = CPTRectAnchorTop;
    graph.titleDisplacement = CGPointMake(0.0f, 20.0f);
    
    // 4 - Set padding for plot area
    [graph.plotAreaFrame setPaddingLeft:50.0f];
    [graph.plotAreaFrame setPaddingBottom:30.0f];
    
    // 5 - Enable user interactions for plot space
    CPTXYPlotSpace *plotSpace = (CPTXYPlotSpace *) graph.defaultPlotSpace;
    plotSpace.allowsUserInteraction = YES;
}

-(void)addPlotToPlotSpaceWithIdentifier:(NSString*)indentifier WithColor:(CPTColor*)color WithXList:(NSMutableArray*)xValueList WithYList:(NSMutableArray*)yValueList
{
    // 1 - Get graph and plot space
    CPTXYPlotSpace* plotSpace = (CPTXYPlotSpace *) self.hostView.hostedGraph.defaultPlotSpace;
    CPTGraph* graph = self.hostView.hostedGraph;
    
    // 2 - Create the plot
    CPTScatterPlot* plot = [[CPTScatterPlot alloc] init];
    plot.dataSource = self;
    plot.identifier = indentifier;
    [graph addPlot:plot toPlotSpace:plotSpace];
    
    // 3 - Add legend
    [graph.legend addPlot:plot];
    
    // 4 - Set up plot space
    plotSpace.xRange = [CPTPlotRange plotRangeWithLocation:CPTDecimalFromFloat(0.0f) length:CPTDecimalFromFloat(self.oneday)];
    plotSpace.yRange = [CPTPlotRange plotRangeWithLocation:CPTDecimalFromFloat(0.0f) length:CPTDecimalFromFloat(5.0f)];
    [self configureGlobalRanges];
    [plotSpace scaleToFitPlots:[graph allPlots]];
    
    // 5 - Create styles and symbols
    CPTMutableLineStyle* lineStyle = [plot.dataLineStyle mutableCopy];
    lineStyle.lineWidth = 2.5;
    lineStyle.lineColor = color;
    plot.dataLineStyle = lineStyle;
    
    CPTMutableLineStyle* symbolLineStyle = [CPTMutableLineStyle lineStyle];
    symbolLineStyle.lineColor = color;
    CPTPlotSymbol* symbol = [CPTPlotSymbol ellipsePlotSymbol];
    symbol.fill = [CPTFill fillWithColor:color];
    symbol.lineStyle = symbolLineStyle;
    symbol.size = CGSizeMake(6.0f, 6.0f);
    plot.plotSymbol = symbol;
    
    //Data point label position
    plot.labelOffset = self.labelOffset;
    plot.labelRotation = 19.3;
    self.labelOffset = self.labelOffset - 5.0;
    
    if(self.labelOffset == -15)
        self.labelOffset = 10.0;
}

-(void)configureHostViewAxes
{
    // 1 - Create styles
    CPTMutableTextStyle *axisTitleStyle = [CPTMutableTextStyle textStyle];
    axisTitleStyle.color = [CPTColor whiteColor];
    axisTitleStyle.fontName = @"Helvetica-Bold";
    axisTitleStyle.fontSize = 12.0f;
    CPTMutableLineStyle *axisLineStyle = [CPTMutableLineStyle lineStyle];
    axisLineStyle.lineWidth = 2.0f;
    axisLineStyle.lineColor = [CPTColor whiteColor];
    CPTMutableTextStyle *axisTextStyle = [[CPTMutableTextStyle alloc] init];
    axisTextStyle.color = [CPTColor whiteColor];
    axisTextStyle.fontName = @"Helvetica-Bold";
    axisTextStyle.fontSize = 11.0f;
    
    // 2 - Get axis set
    CPTXYAxisSet *axisSet = (CPTXYAxisSet *) self.hostView.hostedGraph.axisSet;
    
    // 3 - Configure x-axis
    CPTMutableLineStyle* gridLineStyle = [CPTMutableLineStyle lineStyle];
    gridLineStyle.lineColor = [CPTColor orangeColor];
    gridLineStyle.lineWidth = 0.5;
    
    CPTMutableLineStyle *lineStyle = [CPTMutableLineStyle lineStyle];
    lineStyle.lineColor = [CPTColor blackColor];
    lineStyle.lineWidth = 2.0f;
    
    axisSet.xAxis.majorIntervalLength = CPTDecimalFromFloat(self.oneday);
    axisSet.xAxis.minorTicksPerInterval = 0;
    axisSet.xAxis.orthogonalCoordinateDecimal = CPTDecimalFromString(@"0"); //added for date, adjust x line
    axisSet.xAxis.majorTickLineStyle = lineStyle;
    axisSet.xAxis.minorTickLineStyle = lineStyle;
    axisSet.xAxis.axisLineStyle = lineStyle;
    axisSet.xAxis.minorTickLength = 5.0f;
    axisSet.xAxis.majorTickLength = 7.0f;
    axisSet.xAxis.labelOffset = 3.0f;
    //axisSet.xAxis.majorGridLineStyle = gridLineStyle;
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
    dateFormatter.dateStyle = kCFDateFormatterShortStyle;
    CPTTimeFormatter *timeFormatter = [[CPTTimeFormatter alloc] initWithDateFormatter:dateFormatter];
    timeFormatter.referenceDate = self.refDate;
    axisSet.xAxis.labelFormatter = timeFormatter;
    
    // 4 - Configure y-axis
    axisSet.yAxis.majorIntervalLength = CPTDecimalFromString(@"0.5");
    axisSet.yAxis.minorTicksPerInterval = 2;
    axisSet.yAxis.orthogonalCoordinateDecimal = CPTDecimalFromFloat(0.0); // added for date, adjusts y line
    axisSet.yAxis.majorTickLineStyle = lineStyle;
    axisSet.yAxis.minorTickLineStyle = lineStyle;
    axisSet.yAxis.axisLineStyle = lineStyle;
    axisSet.yAxis.minorTickLength = 5.0f;
    axisSet.yAxis.majorTickLength = 7.0f;
    axisSet.yAxis.labelOffset = 3.0f;
    //axisSet.yAxis.majorGridLineStyle = gridLineStyle;
    
//    axisSet.yAxis.hidden = YES;
//    for (CPTAxisLabel* axisLabel in axisSet.yAxis.axisLabels)
//    {
//        axisLabel.contentLayer.hidden = YES;
//    }
}

-(void)addGraphLegend
{
    CPTGraph* graph = self.hostView.hostedGraph;
    
    graph.legend = [CPTLegend legendWithGraph:graph];
    graph.legend.fill = [CPTFill fillWithColor:[CPTColor darkGrayColor]];
    graph.legend.cornerRadius = 5.0;
    graph.legend.swatchSize = CGSizeMake(15.0, 15.0);
    graph.legendAnchor = CPTRectAnchorTopRight;
    graph.legendDisplacement = CGPointMake(0.0, 0.0);
}

-(void)removeGraphLegend
{
    self.hostView.hostedGraph.legend = nil;
}

-(void)initializeDateStringWith:(UILabel*)label
{
    UITapGestureRecognizer* singleTap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(showDateCoverView:)];
    [singleTap setNumberOfTapsRequired:1];
    [singleTap setNumberOfTouchesRequired:1];
    
    [label addGestureRecognizer:singleTap];
    
    if([label isEqual:self.fromDate])
        [self updateCurrentDateTimeDisplay:[NSDate date] ForLabel:label];
    else
        [self updateCurrentDateTimeDisplay:[NSDate date] ForLabel:label];
}

-(void)initializeLeftRightArrowsWithLeftView:(UIImageView*)leftView WithRightView:(UIImageView*)rightView
{
    UITapGestureRecognizer* singleLeftTap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(reduceDayByOne:)];
    [singleLeftTap setNumberOfTapsRequired:1];
    [singleLeftTap setNumberOfTouchesRequired:1];
    [leftView addGestureRecognizer:singleLeftTap];
    
    UITapGestureRecognizer* singleRightTap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(increaseDayByOne:)];
    [singleRightTap setNumberOfTapsRequired:1];
    [singleRightTap setNumberOfTouchesRequired:1];
    [rightView addGestureRecognizer:singleRightTap];
}

-(void)reduceDayByOne:(UIGestureRecognizer*)recognizer
{
    UIImageView* view = (UIImageView*)recognizer.view;
    NSDate* currentDate;
    NSDate* reducedDate;
    
    if([view isDescendantOfView:self.leftFromDateImageView])
    {
        currentDate = [self getCurrentDateDisplayWithText:self.fromDate.text];
        reducedDate = [currentDate dateByAddingTimeInterval:60*60*24*(-1)];
        [self updateCurrentDateTimeDisplay:reducedDate ForLabel:self.fromDate];
        
        if([reducedDate compare:[self getCurrentDateDisplayWithText:self.toDate.text]] == NSOrderedAscending)
        {
            if(!self.rightFromDateImageView.userInteractionEnabled)
                [self enableFromRightArrow:YES];
        }
    }
    else
    {
        currentDate = [self getCurrentDateDisplayWithText:self.toDate.text];
        reducedDate = [currentDate dateByAddingTimeInterval:60*60*24*(-1)];
        [self updateCurrentDateTimeDisplay:reducedDate ForLabel:self.toDate];
        
        NSDateComponents *components = [[NSCalendar currentCalendar]
                                        components:NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit
                                        fromDate:[NSDate date]];
        NSDate* todayDate = [[NSCalendar currentCalendar]
                             dateFromComponents:components];
        if([reducedDate compare:todayDate] == NSOrderedAscending)
        {
            if(!self.rightToDateImageView.userInteractionEnabled)
                [self enableToRightArrow:YES];
        }
    }
}

-(void)increaseDayByOne:(UIGestureRecognizer*)recognizer
{
    UIImageView* view = (UIImageView*)recognizer.view;
    NSDate* currentDate;
    NSDate* increasedDate;
    
    if([view isDescendantOfView:self.rightFromDateImageView])
    {
        currentDate = [self getCurrentDateDisplayWithText:self.fromDate.text];
        increasedDate = [currentDate dateByAddingTimeInterval:60*60*24*(1)];
        [self updateCurrentDateTimeDisplay:increasedDate ForLabel:self.fromDate];
        
        if([increasedDate compare:[self getCurrentDateDisplayWithText:self.toDate.text]] == NSOrderedSame)
        {
            if(self.rightFromDateImageView.userInteractionEnabled)
                [self enableFromRightArrow:NO];
        }
    }
    else
    {
        currentDate = [self getCurrentDateDisplayWithText:self.toDate.text];
        increasedDate = [currentDate dateByAddingTimeInterval:60*60*24*(1)];
        [self updateCurrentDateTimeDisplay:increasedDate ForLabel:self.toDate];
        
        NSDateComponents *components = [[NSCalendar currentCalendar]
                                        components:NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit
                                        fromDate:[NSDate date]];
        NSDate* todayDate = [[NSCalendar currentCalendar]
                             dateFromComponents:components];
        if([increasedDate compare:todayDate] == NSOrderedSame)
        {
            if(self.rightToDateImageView.userInteractionEnabled)
                [self enableToRightArrow:NO];
        }
    }
}

-(NSDate*)getCurrentDateDisplayWithText:(NSString*)text
{
    NSString *dateString = text;
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"MMMM dd, yyyy"];
    NSDate *dateFromString = [[NSDate alloc] init];
    dateFromString = [dateFormatter dateFromString:dateString];
    
    return dateFromString;
}

-(void)updateCurrentDateTimeDisplay: (NSDate*)currentDate ForLabel:(UILabel*)label
{
    NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"MMMM dd, yyyy"];
    label.text = [dateFormatter stringFromDate:currentDate];
    if([label isDescendantOfView:self.fromDate] || [label isDescendantOfView:self.toDate])
    {
        if(self.hostView != nil)
        {
            NSMutableDictionary* temp = [self.plotDataList mutableCopy];
            for (NSString* key in temp)
            {
                PlotData* currentData = [temp objectForKey:key];
                PlotData* newData = [[PlotData alloc]initWithIdentifierIndex:currentData.identifierIndex Category:currentData.category StartDate:[self getCurrentDateDisplayWithText:self.fromDate.text] EndDate:[self getCurrentDateDisplayWithText:self.toDate.text]];
                newData.delegate = self;
                [newData setPlotDataParameters];
                
                [self.plotDataList setObject:newData forKey:key];
            }
        
            [self configureGlobalRanges];
            [self.hostView.hostedGraph reloadData];
            [self configureHostViewAxes];
        }
    }
    
    if([label isDescendantOfView:self.fromDate])
    {
        if([currentDate compare:[self getCurrentDateDisplayWithText:self.toDate.text]] == NSOrderedAscending)
        {
            if(!self.rightFromDateImageView.userInteractionEnabled)
                [self enableFromRightArrow:YES];
        }
        else
        {
            if(self.rightFromDateImageView.userInteractionEnabled)
                [self enableFromRightArrow:NO];
        }
    }
    else
    {
        NSDateComponents *components = [[NSCalendar currentCalendar]
                                        components:NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit
                                        fromDate:[NSDate date]];
        NSDate* todayDate = [[NSCalendar currentCalendar]
                             dateFromComponents:components];
        if([currentDate compare:todayDate] == NSOrderedAscending)
        {
            if(!self.rightToDateImageView.userInteractionEnabled)
                [self enableToRightArrow:YES];
        }
        else
        {
            if(self.rightToDateImageView.userInteractionEnabled)
                [self enableToRightArrow:NO];
        }
    }
}

-(void)configureGlobalRanges
{
    CPTXYPlotSpace* plotSpace = (CPTXYPlotSpace *) self.hostView.hostedGraph.defaultPlotSpace;
    
    if(plotSpace.globalXRange == nil || plotSpace.globalYRange == nil)
    {
        //Check if plot list contains any plot data
        if(![self isPlotDataListContainNonEmptyData])
        {
            [self initializeGlobalRangesByDefault];
        }
        else
        {
            [self initializeGlobalRangesInNormalWay];
        }
    }
    else
    {
        [self initializeGlobalRangesByComparison];
    }
}

-(void)initializeGlobalRangesByDefault
{
    CPTXYPlotSpace* plotSpace = (CPTXYPlotSpace *) self.hostView.hostedGraph.defaultPlotSpace;
    
    plotSpace.globalXRange = [CPTPlotRange plotRangeWithLocation:CPTDecimalFromFloat(0.0f) length:CPTDecimalFromFloat(self.oneday)];
    plotSpace.globalYRange = [CPTPlotRange plotRangeWithLocation:CPTDecimalFromCGFloat(0.0f) length:CPTDecimalFromFloat(1.0f)];
}

-(void)initializeGlobalRangesInNormalWay
{
    NSArray* maximumArray = [self getMaximumValues];
    NSDecimalNumber* xMaxValue = (NSDecimalNumber*)[maximumArray objectAtIndex:0];
    //NSDecimalNumber* yMaxValue = (NSDecimalNumber*)[maximumArray objectAtIndex:1];
    CPTXYPlotSpace* plotSpace = (CPTXYPlotSpace *) self.hostView.hostedGraph.defaultPlotSpace;
    
    plotSpace.globalXRange = [CPTPlotRange plotRangeWithLocation:CPTDecimalFromFloat(0.0f) length:[xMaxValue decimalValue]];
    plotSpace.globalYRange = [CPTPlotRange plotRangeWithLocation:CPTDecimalFromFloat(0.0f) length:CPTDecimalFromFloat(6.0f)];
}

-(void)initializeGlobalRangesByComparison
{
    CPTXYPlotSpace* plotSpace = (CPTXYPlotSpace *) self.hostView.hostedGraph.defaultPlotSpace;
    NSDecimalNumber* xRange = [NSDecimalNumber decimalNumberWithDecimal:plotSpace.globalXRange.length];
    NSDecimalNumber* yRange = [NSDecimalNumber decimalNumberWithDecimal:plotSpace.globalYRange.length];
    NSArray* maximumArray = [self getMaximumValues];
    NSDecimalNumber* xMaxValue = (NSDecimalNumber*)[maximumArray objectAtIndex:0];
    NSDecimalNumber* yMaxValue = (NSDecimalNumber*)[maximumArray objectAtIndex:1];
    
    if([xRange compare:xMaxValue] == NSOrderedAscending)
        plotSpace.globalXRange = [CPTPlotRange plotRangeWithLocation:CPTDecimalFromFloat(0.0) length:[xMaxValue decimalValue]];
    if([yRange compare:yMaxValue] == NSOrderedAscending)
        plotSpace.globalYRange = [CPTPlotRange plotRangeWithLocation:CPTDecimalFromFloat(0.0) length:CPTDecimalFromFloat(6.0f)];
}

-(NSArray*)getMaximumValues
{
    NSDecimalNumber* yMax = [NSDecimalNumber decimalNumberWithString:[NSString stringWithFormat:@"%f",0.0f]];
    NSDecimalNumber* xMax = [NSDecimalNumber decimalNumberWithString:[NSString stringWithFormat:@"%f",0.0f]];
    for(NSString* key in self.plotDataList.allKeys)
    {
        PlotData* currentData = [self.plotDataList objectForKey:key];
        NSDecimalNumber* yMaxValue = (NSDecimalNumber*)[currentData.yValueList valueForKeyPath:@"@max.self"];
        NSDecimalNumber* xMaxValue = (NSDecimalNumber*)[currentData.xValueList valueForKeyPath:@"@max.self"];
        if ([yMaxValue compare:yMax] == NSOrderedDescending)
            yMax = yMaxValue;
        if([xMaxValue compare:xMax] == NSOrderedDescending)
            xMax = xMaxValue;
    }
    NSDecimalNumber* xMax_1 = [xMax decimalNumberByAdding:[NSDecimalNumber decimalNumberWithString:[NSString stringWithFormat:@"%f", self.oneday]]];
    NSDecimalNumber* yMax_1 = [yMax decimalNumberByAdding:[NSDecimalNumber decimalNumberWithString:[NSString stringWithFormat:@"%f",1.0]]];
    
    return [[NSArray alloc]initWithObjects:xMax_1, yMax_1, nil];
}

-(BOOL)isPlotDataListContainNonEmptyData
{
    for(NSString* key in self.plotDataList.allKeys)
    {
        PlotData* currentData = [self.plotDataList objectForKey:key];
        if(currentData.dateList.count > 0)
            return YES;
    }
    return NO;
}

#pragma mark -  date string call back method
-(void)showDateCoverView:(UIGestureRecognizer*)recognizer
{
    UILabel* label = (UILabel*)recognizer.view;
    
    [self initializeCoverView];
    
    [self addTopbarToCoverView];
    
    if([label isDescendantOfView:self.fromDate])
    {
        [self addDonebuttonToCoverViewWithObject:self.fromDate];
        [self addDatePickerToCoverViewWithLabel:self.fromDate];
        [self.datePicker setMaximumDate:[NSDate date]];
    }
    else
    {
        [self addDonebuttonToCoverViewWithObject:self.toDate];
        [self addDatePickerToCoverViewWithLabel:self.toDate];
        [self.datePicker setMinimumDate:[self getCurrentDateDisplayWithText:self.fromDate.text]];
    }
    [self.view addSubview:self.coverView];
    [self animateCoverViewBottomUp];
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
    self.topBarView = [[UIView alloc]initWithFrame:CGRectMake(self.coverView.frame.origin.x, self.coverView.frame.size.height*1.2/3, self.coverView.frame.size.width, 40.0)];
    self.topBarView.backgroundColor = [UIColor orangeColor];
    [self.coverView addSubview:self.topBarView];
}

-(void)addDonebuttonToCoverViewWithObject:(id)sender
{
    UIButton* doneButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [doneButton setTitle:@"Done" forState:UIControlStateNormal];
    doneButton.frame = CGRectMake(self.topBarView.frame.size.width - 80.0, 5.0, 75.0, 30.0);
    [doneButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [[doneButton layer]setBorderColor:[UIColor whiteColor].CGColor];
    [[doneButton layer]setBorderWidth:1.0];

    if([sender isDescendantOfView:self.fromDate])
    {
        self.fromDateDoneButton = doneButton;
        [self.fromDateDoneButton addTarget:self action:@selector(updateDateLabel:) forControlEvents:UIControlEventTouchDown];
        [self.topBarView addSubview:doneButton];
    }
    else
    {
        self.toDateDoneButton = doneButton;
        [self.toDateDoneButton addTarget:self action:@selector(updateDateLabel:) forControlEvents:UIControlEventTouchDown];
        [self.topBarView addSubview:doneButton];
    }
}

-(void)addDatePickerToCoverViewWithLabel:(UILabel*)label
{
    self.datePicker = [[UIDatePicker alloc]initWithFrame:CGRectMake(self.coverView.frame.origin.x, self.topBarView.frame.origin.y + self.topBarView.frame.size.height, self.coverView.frame.size.width, self.coverView.frame.size.height-self.topBarView.frame.origin.y-self.topBarView.frame.size.height)];
    [self.datePicker setBackgroundColor:[UIColor whiteColor]];
    [self.datePicker setDatePickerMode:UIDatePickerModeDate];
    
    [self.datePicker setDate:[self getCurrentDateDisplayWithText:label.text]];
    [self.coverView addSubview:self.datePicker];
}

-(void)updateDateLabel:(id)sender
{
    UIButton* button = (UIButton*)sender;
    
    if([button isDescendantOfView:self.fromDateDoneButton])
    {
        [self updateCurrentDateTimeDisplay:self.datePicker.date ForLabel:self.fromDate];
    }
    else
    {
        [self updateCurrentDateTimeDisplay:self.datePicker.date ForLabel:self.toDate];
    }
    [self dismissCoverView];
}

-(void)addTrendToInterface:(id)sender
{
    [self dismissCoverView];
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


#pragma - mark nav bar call back methods
- (IBAction)backToMain:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)showFactorCoverView:(id)sender
{
    if(self.coverView == nil)
    {
        //Initialize date cover view
        [self initializeCoverView];
        
        //Add top bar to cover
        //[self addTopbarToCoverView];
        
        //Add done button to top bar
        //[self addDonebuttonToCoverViewWithObject:self.addTrendButton];
        
        //Add header
        //[self addHeaderToComponentOfPickerView];
        
        //Add count picker to cover view
        [self addTableViewToCoverView];
        
        //Add cover view to self.view
        [self.view addSubview:self.coverView];
        
        //Animate the cover view
        [self animateCoverViewBottomUp];
    }
    else
    {
        [self dismissCoverView];
    }
}

-(void)displayHideLegend:(id)sender
{
    if(self.hostView.hostedGraph.legend == nil)
    {
        [self addGraphLegend];
    }
    else
    {
        [self removeGraphLegend];
    }
}

-(void)addHeaderToComponentOfPickerView
{
    self.nutritionLabel = [[UILabel alloc]initWithFrame:CGRectMake(self.topBarView.frame.origin.x, self.topBarView.frame.origin.y+self.topBarView.frame.size.height, self.coverView.frame.size.width*1/2, self.topBarView.frame.size.height - 10.0)];
    [self.nutritionLabel setBackgroundColor:[UIColor grayColor]];
    [self.nutritionLabel setFont:[UIFont boldSystemFontOfSize:20.0]];
    [[self.nutritionLabel layer]setBorderWidth:0.1];
    self.nutritionLabel.text = @"NUTRITIONS";
    [self.nutritionLabel setTextAlignment:NSTextAlignmentCenter];
    [self.coverView addSubview:self.nutritionLabel];
    
    self.sleepRelatedLabel = [[UILabel alloc]initWithFrame:CGRectMake(self.nutritionLabel.frame.origin.x + self.nutritionLabel.frame.size.width, self.nutritionLabel.frame.origin.y, self.coverView.frame.size.width*1/2, self.nutritionLabel.frame.size.height)];
    [self.sleepRelatedLabel setBackgroundColor:[UIColor grayColor]];
    [self.sleepRelatedLabel setFont:[UIFont boldSystemFontOfSize:20.0]];
    [[self.sleepRelatedLabel layer]setBorderWidth:0.1];
    self.sleepRelatedLabel.text = @"OTHER FACTORS";
    [self.sleepRelatedLabel setTextAlignment:NSTextAlignmentCenter];
    [self.coverView addSubview:self.sleepRelatedLabel];
}

-(void)addTableViewToCoverView
{
    self.trendFactorTableView = [[UITableView alloc] initWithFrame:CGRectMake(self.coverView.frame.origin.x, self.coverView.frame.size.height*2/5, self.coverView.frame.size.width, self.coverView.frame.size.height*3/5) style:UITableViewStylePlain];
    [self.trendFactorTableView setBackgroundColor:[UIColor clearColor]];
    self.trendFactorTableView.delegate = self;
    self.trendFactorTableView.dataSource = self;
    self.trendFactorTableView.autoresizingMask = UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth;
    [self.trendFactorTableView reloadData];
    [self.coverView addSubview:self.trendFactorTableView];
}

-(void)initializeSwitchStates
{
    self.nutritionSwitchStates = [[NSMutableArray alloc]init];
    self.sleepRelatedSwitchStates =[[NSMutableArray alloc]init];
     
    for(int i=0; i<self.nutritionList.count; i++)
    {
        [self.nutritionSwitchStates addObject:@"OFF"];
    }
    for(int i=0; i<self.sleepRelatedList.count; i++)
    {
        [self.sleepRelatedSwitchStates addObject:@"OFF"];
    }
    //[self.sleepRelatedSwitchStates replaceObjectAtIndex:0 withObject:@"ON"];
}

#pragma - mark enable / disable trends
-(void)stateChanged:(UISwitch*)sender
{
    if([self returnNumberOfTrendsInTheView] == 5 && sender.on)
    {
        [sender setOn:NO animated:NO];
        [self showMaximumAlertView];
    }
    else
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
        
        NSIndexPath* currentIndexPath = [self.trendFactorTableView indexPathForCell:parentCell];
        NSString* currentIdentifier;
        
        if(currentIndexPath.section == 0)
        {
            currentIdentifier = [self.nutritionList objectAtIndex:currentIndexPath.row];
            if(sender.on)
            {
                [self.nutritionSwitchStates replaceObjectAtIndex:currentIndexPath.row withObject:@"ON"];
                [self addPlotWithIdentifier:currentIdentifier Index:(int)currentIndexPath.row Category:@"Nutrition"];
            }
            else
            {
                [self.nutritionSwitchStates replaceObjectAtIndex:currentIndexPath.row withObject:@"OFF"];
                [self removePlotWithIdentifier:currentIdentifier];
            }
        }
        else
        {
            currentIdentifier = [self.sleepRelatedList objectAtIndex:currentIndexPath.row];
            if(sender.on)
            {
                [self.sleepRelatedSwitchStates replaceObjectAtIndex:currentIndexPath.row withObject:@"ON"];
                [self addPlotWithIdentifier:currentIdentifier Index:(int)currentIndexPath.row Category:@"Others"];
            }
            else
            {
                [self.sleepRelatedSwitchStates replaceObjectAtIndex:currentIndexPath.row withObject:@"OFF"];
                [self removePlotWithIdentifier:currentIdentifier];
            }
        }
    }
}

-(void)addPlotWithIdentifier:(NSString*)currentIdentifier Index:(int)index Category:(NSString*)category
{
    PlotData* newData = [[PlotData alloc]initWithIdentifierIndex:index Category:category StartDate:[self getCurrentDateDisplayWithText:self.fromDate.text] EndDate:[self getCurrentDateDisplayWithText:self.toDate.text]];
    newData.delegate = self;
    [newData setPlotDataParameters];
    
    [self.plotDataList setObject:newData forKey:currentIdentifier];
    PlotData* temp = [self.plotDataList objectForKey:currentIdentifier];
    NSMutableArray* xList = [temp xValueList];
    NSMutableArray* yList = [temp yValueList];

    [self addPlotToPlotSpaceWithIdentifier:currentIdentifier WithColor:[self.color returnAvailableColor] WithXList:xList WithYList:yList];
    [self configureHostViewAxes];//Update axis label display
}

-(void)removePlotWithIdentifier:(NSString*)currentIdentifier
{
    CPTScatterPlot* currentPlot = (CPTScatterPlot*)[self.hostView.hostedGraph plotWithIdentifier:currentIdentifier];
    [self.color resetStateOfColor:currentPlot.dataLineStyle.lineColor];
    
    [self.plotDataList removeObjectForKey:currentIdentifier];
    [self.hostView.hostedGraph removePlotWithIdentifier:currentIdentifier];
    [self.hostView.hostedGraph.legend removePlotWithIdentifier:currentIdentifier];
}

-(int)returnNumberOfTrendsInTheView
{
    int count = 0;
    for(NSString* item in self.nutritionSwitchStates)
    {
        if([item isEqualToString:@"ON"])
            count++;
    }
    for(NSString* item in self.sleepRelatedSwitchStates)
    {
        if([item isEqualToString:@"ON"])
            count++;
    }
    
    return count;
}

-(void)showMaximumAlertView
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@""
                                                    message:@"Only maximum of 5 trends is allowed!"
                                                   delegate:self
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles:nil];
    [alert show];
    
    [self performSelector:@selector(dismissAlertView:) withObject:alert afterDelay:3];
}

-(void)dismissAlertView:(id)sender
{
    UIAlertView* currentAlert = (UIAlertView*)sender;
    [currentAlert dismissWithClickedButtonIndex:-1 animated:YES];
}

#pragma mark - PlotData Delegate Methods
-(NSDate*)getReferenceDateFromPattern
{
    return self.refDate;
}

-(void)updateReferenceDateToPatternWithDate:(NSDate*)date
{
    self.refDate = date;
}


#pragma mark - gesture delegate methods
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    if ([touch.view isDescendantOfView:self.topBarView])
        return NO;
    
    if([touch.view isDescendantOfView:self.datePicker])
        return NO;
    
    if([touch.view isDescendantOfView:self.trendFactorTableView])
        return NO;
    
    return YES;
}


#pragma mark - UITableView delegate methods
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if(section == 0)
        return self.nutritionList.count;
    else
        return self.sleepRelatedList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if(indexPath.section == 0)
    {
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
            frame.origin.x = self.trendFactorTableView.frame.size.width - 50.0;
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
    
        item.text = [self.nutritionList objectAtIndex:indexPath.row];
        
        if([[self.nutritionSwitchStates objectAtIndex:indexPath.row]isEqualToString:@"ON"])
        {
            indicator.on = YES;
        }
        else
        {
            indicator.on = NO;
        }
    }
    else
    {
        UILabel* item=nil;
        UISwitch* indicator=nil;
        
        if (cell == nil)
        {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
            
            item = [[UILabel alloc]initWithFrame:CGRectZero];
            item.tag = 2;
            [item setBackgroundColor:[UIColor clearColor]];
            [item setNumberOfLines:1];
            [item setTextAlignment:NSTextAlignmentLeft];
            [cell.contentView addSubview:item];
            
            indicator = [[UISwitch alloc]initWithFrame:CGRectZero];
            indicator.tag = 3;
            CGRect frame = indicator.frame;
            frame.origin.x = cell.contentView.frame.size.width - 50.0;
            frame.origin.y = 5.0;
            indicator.frame = frame;
            [indicator addTarget:self action:@selector(stateChanged:) forControlEvents:UIControlEventValueChanged];

            [cell.contentView addSubview: indicator];
        }
        else
        {
            item = (UILabel*)[cell.contentView.subviews objectAtIndex:0];
            indicator = (UISwitch*)[cell.contentView.subviews objectAtIndex:1];
        }
        
        item.text = [self.sleepRelatedList objectAtIndex:indexPath.row];
        
        if([[self.sleepRelatedSwitchStates objectAtIndex:indexPath.row]isEqualToString:@"ON"])
        {
            indicator.on = YES;
        }
        else
        {
            indicator.on = NO;
        }
    }
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 40.0;
}

- (UIView *) tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UILabel* headerView = [[UILabel alloc] initWithFrame:CGRectMake(0.0, 0.0, self.trendFactorTableView.bounds.size.width, 40)];
    [headerView setBackgroundColor:[UIColor orangeColor]];
    [headerView setTextColor:[UIColor whiteColor]];
    
    if(section == 0)
    {
        headerView.text = @"NUTRITIONS";
    }
    else
    {
        headerView.text = @"OTHERS";
    }

    return headerView;
}


#pragma mark - CPTPlotDataSource methods
-(NSUInteger)numberOfRecordsForPlot:(CPTPlot *)plot
{
    PlotData* currentPlotData = [self.plotDataList objectForKey:plot.identifier];
    
    return currentPlotData.xValueList.count;
}

-(NSNumber *)numberForPlot:(CPTPlot *)plot field:(NSUInteger)fieldEnum recordIndex:(NSUInteger)index
{
    PlotData* currentPlotData = [self.plotDataList objectForKey:plot.identifier];
    NSDecimalNumber* num = [[currentPlotData.data objectAtIndex:index] objectForKey:[NSNumber numberWithInt:(int)fieldEnum]];
    
    if(fieldEnum == CPTScatterPlotFieldY)
    {
        NSDecimalNumber* max = [self getMaximumYValueOfList:currentPlotData.yValueList];
        NSDecimalNumber* limit = [NSDecimalNumber decimalNumberWithDecimal:CPTDecimalFromCGFloat(5.0)];
        
        if([max compare:limit] == NSOrderedDescending)
        {
            NSDecimalNumber* ratio = [max decimalNumberByDividingBy:[NSDecimalNumber decimalNumberWithDecimal:CPTDecimalFromCGFloat(5.0)]];
            return [num decimalNumberByDividingBy:ratio];
        }
        else
            return num;
    }
    else
        return num;
}

-(CPTLayer *)dataLabelForPlot:(CPTPlot *)plot recordIndex:(NSUInteger)index
{
    static CPTMutableTextStyle* whiteText = nil ;
    if (!whiteText)
    {
        whiteText = [[CPTMutableTextStyle alloc ] init ];
        whiteText.color = [CPTColor whiteColor];
    }
    
    CPTTextLayer* newLayer = nil ;
    NSString* identifier=( NSString *)[plot identifier];
    
    PlotData* currentPlotData = [self.plotDataList objectForKey:identifier];
    newLayer = [[CPTTextLayer alloc ]initWithText:[currentPlotData.yValueDataPointLabelList objectAtIndex:index] style:whiteText];
    
    return newLayer;
}

-(NSDecimalNumber*)getMaximumYValueOfList:(NSMutableArray*)list
{
    NSDecimalNumber* max = [NSDecimalNumber decimalNumberWithDecimal:CPTDecimalFromCGFloat(0.0)];
    for(NSDecimalNumber* item in list)
    {
        if([max compare:item] == NSOrderedAscending)
            max = item;
    }
    
    return max;
}


#pragma mark - for interface rotation
- (BOOL)shouldAutorotate
{
    return YES;
}

- (NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskLandscapeLeft;
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation
{
    return UIInterfaceOrientationLandscapeLeft;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
