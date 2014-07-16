//
//  NutritionViewController.m
//  PerfectSleep
//
//  Created by Huang Purong on 3/3/14.
//  Copyright (c) 2014 Huang Purong. All rights reserved.
//

#import "NutritionViewController.h"

@interface NutritionViewController ()

@property(strong, readwrite)UILabel* servingNumberLabel;
@property(strong, readwrite)UILabel* servingSizeLabel;
@property(strong, readwrite)UIPickerView* servingPickerView;
@property(strong, readwrite)UITableView* nutritionTableView;

@property(nonatomic, readwrite)NutritionGeneral* currentFoodItem;
@property(nonatomic, readwrite)ConsumedFood* selectedConsumeItem;
@property(nonatomic, readwrite)NSDate* selectedDate;
@property(nonatomic, readwrite)NSString* mode;

@property(nonatomic, readwrite)NSMutableArray* nutritionArray;
@property(nonatomic, readwrite)NSMutableArray* intackeArray;

@property(nonatomic, readwrite)NSMutableArray* decimalArray;
@property(nonatomic, readwrite)NSMutableArray* fractionArray;

@property(nonatomic, readwrite)int selectedServingSizeIndex;
@property(nonatomic, readwrite)int selectedDecimalIndex;
@property(nonatomic, readwrite)int selectedFractionIndex;

@end

@implementation NutritionViewController

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
	
    self.foodNameLabel.text = self.currentFoodItem.foodName;
    
    if([self.mode isEqualToString:@"Add"])
    {
        UIBarButtonItem* addButton = [[UIBarButtonItem alloc]initWithTitle:@"Add" style:UIBarButtonItemStylePlain target:self action:@selector(addItemToConsumeList)];
        
        self.navigationItem.rightBarButtonItem = addButton;
    }
    else
    {
        UIBarButtonItem* saveButton = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemSave target:self action:@selector(updateItemToConsumeList)];
        
        self.navigationItem.rightBarButtonItem = saveButton;
    }
}

-(void)viewDidAppear:(BOOL)animated
{
    self.servingNumberLabel = [[UILabel alloc]initWithFrame:CGRectMake(self.foodNameLabel.frame.origin.x, self.foodNameLabel.frame.origin.y+self.foodNameLabel.frame.size.height, self.view.frame.size.width*2/6, self.foodNameLabel.frame.size.height)];
    [self.servingNumberLabel setBackgroundColor:[UIColor grayColor]];
    [self.servingNumberLabel setFont:[UIFont boldSystemFontOfSize:11.0]];
    [[self.servingNumberLabel layer]setBorderWidth:0.1];
    self.servingNumberLabel.text = @"SERVING NUMBER";
    [self.servingNumberLabel setTextAlignment:NSTextAlignmentCenter];
    [self.view addSubview:self.servingNumberLabel];
    
    self.servingSizeLabel = [[UILabel alloc]initWithFrame:CGRectMake(self.servingNumberLabel.frame.origin.x + self.servingNumberLabel.frame.size.width, self.servingNumberLabel.frame.origin.y, self.view.frame.size.width*4/6, self.servingNumberLabel.frame.size.height)];
    [self.servingSizeLabel setBackgroundColor:[UIColor grayColor]];
    [self.servingSizeLabel setFont:[UIFont boldSystemFontOfSize:11.0]];
    [[self.servingSizeLabel layer]setBorderWidth:0.1];
    self.servingSizeLabel.text = @"SERVING SIZE";
    [self.servingSizeLabel setTextAlignment:NSTextAlignmentCenter];
    [self.view addSubview:self.servingSizeLabel];
    
    self.servingPickerView = [[UIPickerView alloc]initWithFrame:CGRectMake(self.servingNumberLabel.frame.origin.x, self.servingNumberLabel.frame.origin.y+self.servingNumberLabel.frame.size.height, self.foodNameLabel.frame.size.width, self.view.frame.size.height*1/4)];
    [self.servingPickerView setBackgroundColor:[UIColor whiteColor]];
    self.servingPickerView.delegate = self;
    self.servingPickerView.dataSource = self;
    if([self.mode isEqualToString:@"Update"])
    {
        [self selectServingPickerView];
        [self initializeIntakeArrayWithServingID:[self.servingPickerView selectedRowInComponent:2]];
    }
    [self.view addSubview:self.servingPickerView];
    
    self.nutritionTableView = [[UITableView alloc] initWithFrame:CGRectMake(self.servingPickerView.frame.origin.x, self.servingPickerView.frame.origin.y + self.servingPickerView.frame.size.height, self.servingPickerView.frame.size.width, self.view.frame.size.height - self.servingPickerView.frame.origin.y - self.servingPickerView.frame.size.height) style:UITableViewStylePlain];
    self.nutritionTableView.delegate = self;
    self.nutritionTableView.dataSource = self;
    self.nutritionTableView.autoresizingMask = UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth;
    [self.nutritionTableView reloadData];
    [self.view addSubview:self.nutritionTableView];
}

-(void)configureCurrentFoodItemWithItem:(NutritionGeneral*)item Date:(NSDate*)date Mode:(NSString*)mode
{
    self.mode = mode;
    self.selectedDate = date;
    self.currentFoodItem = [[NutritionGeneral alloc]init];
    self.currentFoodItem.foodID = item.foodID;
    self.currentFoodItem.foodName = item.foodName;
    self.currentFoodItem.foodType = item.foodType;
    self.currentFoodItem.brandName = item.brandName;
    self.currentFoodItem.foodURL = item.foodURL;
    self.currentFoodItem.servings = [[NSMutableArray alloc]initWithArray:item.servings];
    
    //initialize serving number arrays
    [self initializeServingNumberArrays];
    
    //initialize nutrition array
    [self initializeNutritionArray];
    
    //initialize intake array
    self.intackeArray = [[NSMutableArray alloc]init];
    [self initializeIntakeArrayWithServingID:0];
}

-(void)configureSelectedConsumeItem:(ConsumedFood*)consumeItem
{
    self.selectedConsumeItem = consumeItem;
}

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

-(void)initializeNutritionArray
{
    self.nutritionArray = [[NSMutableArray alloc]init];
    
    [self.nutritionArray addObject:@"Calories"];
    [self.nutritionArray addObject:@"Total Fats"];
    [self.nutritionArray addObject:@"Saturated Fat"];
    [self.nutritionArray addObject:@"Polyunsaturated Fat"];
    [self.nutritionArray addObject:@"Monoununsaturated Fat"];
    [self.nutritionArray addObject:@"Cholesterol"];
    [self.nutritionArray addObject:@"Sodium"];
    [self.nutritionArray addObject:@"Potassium"];
    [self.nutritionArray addObject:@"Total Carbohydrate"];
    [self.nutritionArray addObject:@"Dietary Fiber"];
    [self.nutritionArray addObject:@"Sugars"];
    [self.nutritionArray addObject:@"Protein"];
    [self.nutritionArray addObject:@"Vitamin A"];
    [self.nutritionArray addObject:@"Vitamin C"];
    [self.nutritionArray addObject:@"Calcium"];
    [self.nutritionArray addObject:@"Iron"];
}

-(void)initializeIntakeArrayWithServingID:(int)servingID
{
    [self.intackeArray removeAllObjects];
    
    NSMutableString* calories;
    if([[[self.currentFoodItem servings]objectAtIndex:servingID]calories] != nil)
    {
        calories = [NSMutableString stringWithString:[[[self.currentFoodItem servings]objectAtIndex:servingID]calories]];
        [calories appendString:@" kcal"];
    }
    else
    {
        calories = [NSMutableString stringWithString:@"-"];
    }
    
    NSMutableString* fat;
    if([[[self.currentFoodItem servings]objectAtIndex:servingID]fat] != nil)
    {
        fat = [NSMutableString stringWithString:[[[self.currentFoodItem servings]objectAtIndex:servingID]fat]];
        [fat appendString:@" grams"];
    }
    else
    {
        fat = [NSMutableString stringWithString:@"-"];
    }
    
    NSMutableString* saturated_fat;
    if([[[self.currentFoodItem servings]objectAtIndex:servingID]saturatedFat] != nil)
    {
        saturated_fat = [NSMutableString stringWithString:[[[self.currentFoodItem servings]objectAtIndex:servingID]saturatedFat]];
        [saturated_fat appendString:@" grams"];
    }
    else
    {
        saturated_fat = [NSMutableString stringWithString:@"-"];
    }
    
    NSMutableString* polyUnsaturated_fat;
    if([[[self.currentFoodItem servings]objectAtIndex:servingID]polyUnsaturatedFat] != nil)
    {
        polyUnsaturated_fat = [NSMutableString stringWithString:[[[self.currentFoodItem servings]objectAtIndex:servingID]polyUnsaturatedFat]];
        [polyUnsaturated_fat appendString:@" grams"];
    }
    else
    {
        polyUnsaturated_fat = [NSMutableString stringWithString:@"-"];
    }
    
    NSMutableString* monounUnsaturated_fat;
    if([[[self.currentFoodItem servings]objectAtIndex:servingID]monounsaturatedFat] != nil)
    {
        monounUnsaturated_fat = [NSMutableString stringWithString:[[[self.currentFoodItem servings]objectAtIndex:servingID]monounsaturatedFat]];
        [monounUnsaturated_fat appendString:@" grams"];
    }
    else
    {
        monounUnsaturated_fat = [NSMutableString stringWithString:@"-"];
    }
    
    NSMutableString* cholesterol;
    if([[[self.currentFoodItem servings]objectAtIndex:servingID]cholesterol] != nil)
    {
        cholesterol = [NSMutableString stringWithString:[[[self.currentFoodItem servings]objectAtIndex:servingID]cholesterol]];
        [cholesterol appendString:@" milligrams"];
    }
    else
    {
        cholesterol = [NSMutableString stringWithString:@"-"];
    }
    
    NSMutableString* sodium;
    if([[[self.currentFoodItem servings]objectAtIndex:servingID]sodium] != nil)
    {
        sodium = [NSMutableString stringWithString:[[[self.currentFoodItem servings]objectAtIndex:servingID]sodium]];
        [sodium appendString:@" milligrams"];
    }
    else
    {
        sodium = [NSMutableString stringWithString:@"-"];
    }
    
    NSMutableString* potassium;
    if([[[self.currentFoodItem servings]objectAtIndex:servingID]potassium] != nil)
    {
        potassium = [NSMutableString stringWithString:[[[self.currentFoodItem servings]objectAtIndex:servingID]potassium]];
        [potassium appendString:@" milligrams"];
    }
    else
    {
        potassium = [NSMutableString stringWithString:@"-"];
    }
    
    NSMutableString* carbohydrate;
    if([[[self.currentFoodItem servings]objectAtIndex:servingID]carbohydrate] != nil)
    {
        carbohydrate = [NSMutableString stringWithString:[[[self.currentFoodItem servings]objectAtIndex:servingID]carbohydrate]];
        [carbohydrate appendString:@" grams"];
    }
    else
    {
        carbohydrate = [NSMutableString stringWithString:@"-"];
    }
    
    NSMutableString* fiber;
    if([[[self.currentFoodItem servings]objectAtIndex:servingID]fiber] != nil)
    {
        fiber = [NSMutableString stringWithString:[[[self.currentFoodItem servings]objectAtIndex:servingID]fiber]];
        [fiber appendString:@" grams"];
    }
    else
    {
        fiber = [NSMutableString stringWithString:@"-"];
    }
    
    NSMutableString* sugar;
    if([[[self.currentFoodItem servings]objectAtIndex:servingID]sugar] != nil)
    {
        sugar = [NSMutableString stringWithString:[[[self.currentFoodItem servings]objectAtIndex:servingID]sugar]];
        [sugar appendString:@" grams"];
    }
    else
    {
        sugar = [NSMutableString stringWithString:@"-"];
    }
    
    NSMutableString* protein;
    if([[[self.currentFoodItem servings]objectAtIndex:servingID]protein] != nil)
    {
        protein = [NSMutableString stringWithString:[[[self.currentFoodItem servings]objectAtIndex:servingID]protein]];
        [protein appendString:@" grams"];
    }
    else
    {
        protein = [NSMutableString stringWithString:@"-"];
    }
    
    NSMutableString* vitaminA;
    if([[[self.currentFoodItem servings]objectAtIndex:servingID]vitaminA] != nil)
    {
        vitaminA = [NSMutableString stringWithString:[[[self.currentFoodItem servings]objectAtIndex:servingID]vitaminA]];
        [vitaminA appendString:@" %"];
    }
    else
    {
        vitaminA = [NSMutableString stringWithString:@"-"];
    }
    
    NSMutableString* vitaminC;
    if([[[self.currentFoodItem servings]objectAtIndex:servingID]vitaminC] != nil)
    {
        vitaminC = [NSMutableString stringWithString:[[[self.currentFoodItem servings]objectAtIndex:servingID]vitaminC]];
        [vitaminC appendString:@" %"];
    }
    else
    {
        vitaminC = [NSMutableString stringWithString:@"-"];
    }
    
    NSMutableString* calcium;
    if([[[self.currentFoodItem servings]objectAtIndex:servingID]calcium] != nil)
    {
        calcium = [NSMutableString stringWithString:[[[self.currentFoodItem servings]objectAtIndex:servingID]calcium]];
        [calcium appendString:@" %"];
    }
    else
    {
        calcium = [NSMutableString stringWithString:@"-"];
    }
    
    NSMutableString* iron;
    if([[[self.currentFoodItem servings]objectAtIndex:servingID]iron] != nil)
    {
        iron = [NSMutableString stringWithString:[[[self.currentFoodItem servings]objectAtIndex:servingID]iron]];
        [iron appendString:@" %"];
    }
    else
    {
        iron = [NSMutableString stringWithString:@"-"];
    }
    
    [self.intackeArray addObject:calories];
    [self.intackeArray addObject:fat];
    [self.intackeArray addObject:saturated_fat];
    [self.intackeArray addObject:polyUnsaturated_fat];
    [self.intackeArray addObject:monounUnsaturated_fat];
    [self.intackeArray addObject:cholesterol];
    [self.intackeArray addObject:sodium];
    [self.intackeArray addObject:potassium];
    [self.intackeArray addObject:carbohydrate];
    [self.intackeArray addObject:fiber];
    [self.intackeArray addObject:sugar];
    [self.intackeArray addObject:protein];
    [self.intackeArray addObject:vitaminA];
    [self.intackeArray addObject:vitaminC];
    [self.intackeArray addObject:calcium];
    [self.intackeArray addObject:iron];
}

- (void)addItemToConsumeList
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
    NSDate* consumeDate = self.selectedDate;
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
    [self.addDelegate addConsumedItemToList:item];
    
    //Dismiss edit view
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)updateItemToConsumeList
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
    
    [self.updateDelegate updateConsumeListWithConsumeItem:item];
    
    //Dismiss edit view
    [self.navigationController popViewControllerAnimated:YES];
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


#pragma mark - Table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 16;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    UILabel* nutrition=nil;
    UILabel* intake=nil;
    
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
        
        nutrition = [[UILabel alloc]initWithFrame:CGRectZero];
        nutrition.tag = 2;
        [cell.contentView addSubview:nutrition];

        intake = [[UILabel alloc]initWithFrame:CGRectZero];
        intake.tag = 3;
        [cell.contentView addSubview:intake];
    }
    else
    {
        nutrition = (UILabel*)[cell.contentView viewWithTag:2];
        intake = (UILabel*)[cell.contentView viewWithTag:3];
    }
    
    nutrition.text = [self.nutritionArray objectAtIndex:indexPath.row];
    [nutrition setBackgroundColor:[UIColor clearColor]];
    [nutrition setNumberOfLines:1];
    [nutrition setTextAlignment:NSTextAlignmentLeft];
    
    intake.text = [self.intackeArray objectAtIndex:indexPath.row];
    [intake setBackgroundColor:[UIColor clearColor]];
    [intake setNumberOfLines:1];
    [intake setTextAlignment:NSTextAlignmentRight];
    
    if(![[self.nutritionArray objectAtIndex:indexPath.row]isEqualToString:@"Saturated Fat"] &&
       ![[self.nutritionArray objectAtIndex:indexPath.row]isEqualToString:@"Polyunsaturated Fat"] &&
       ![[self.nutritionArray objectAtIndex:indexPath.row]isEqualToString:@"Monoununsaturated Fat"] &&
       ![[self.nutritionArray objectAtIndex:indexPath.row]isEqualToString:@"Dietary Fiber"] &&
       ![[self.nutritionArray objectAtIndex:indexPath.row]isEqualToString:@"Sugars"] &&
       ![[self.nutritionArray objectAtIndex:indexPath.row]isEqualToString:@"Sugars"])
    {
        
        [nutrition setFont:[UIFont boldSystemFontOfSize:18.0]];
        [nutrition sizeToFit];
        nutrition.frame = CGRectMake(10.0, 5.0, cell.contentView.frame.size.width*6/10, 30.0);
    
        [intake setFont:[UIFont boldSystemFontOfSize:18.0]];
        [intake sizeToFit];
        intake.frame = CGRectMake(cell.contentView.frame.size.width*6/10, 5.0, cell.contentView.frame.size.width*4/10, 30.0);
    }
    else
    {
        [nutrition setFont:[UIFont systemFontOfSize:15.0]];
        [nutrition sizeToFit];
        nutrition.frame = CGRectMake(20.0, 5.0, cell.contentView.frame.size.width*6/10, 30.0);
        
        [intake setFont:[UIFont systemFontOfSize:15.0]];
        [intake sizeToFit];
        intake.frame = CGRectMake(nutrition.frame.origin.x+nutrition.frame.size.width, 5.0, cell.contentView.frame.size.width-nutrition.frame.origin.x-nutrition.frame.size.width, 30.0);
    }
    
    return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return @"NUTRITION FACT PER SERVING SIZE";
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 40.0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 40.0;
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
        self.selectedDecimalIndex = row;
    }
    else if(component==1)
    {
        self.selectedFractionIndex = row;
    }
    else
    {
        [self initializeIntakeArrayWithServingID:(int)row];
        [self.nutritionTableView reloadData];
        self.selectedServingSizeIndex = row;
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
