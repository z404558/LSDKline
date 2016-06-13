//
//  SquareViewController.m
//  MuitChart
//
//  Created by MacFor_Eric_Liu on 15/12/15.
//  Copyright © 2015年 Eric_Liu. All rights reserved.
//

#import "SquareViewController.h"
#import "MuitChartModule-Swift.h"
#import "DiscountingViewController.h"

@interface SquareViewController ()<ChartViewDelegate>

@property (nonatomic, strong)  BarChartView *chartView;
@property (nonatomic, strong)  UISlider *sliderX;
@property (nonatomic, strong)  UISlider *sliderY;
@property (nonatomic, strong)  UITextField *sliderTextX;
@property (nonatomic, strong)  UITextField *sliderTextY;
@property (nonatomic, strong)  NSMutableArray *valNeed;

@end

@implementation SquareViewController
{
    NSArray *valNeed;
    
    NSMutableDictionary *all_Dic;
    NSMutableArray *date_arr;
    NSArray *sortArray;
}

- (BOOL)isMovingToParentViewController NS_AVAILABLE_IOS(5_0)
{
    return YES;
}
- (BOOL)isMovingFromParentViewController NS_AVAILABLE_IOS(5_0)
{
    return YES;
}
- (void)willMoveToParentViewController:(nullable UIViewController *)parent NS_AVAILABLE_IOS(5_0)
{
    NSLog(@"__________");
}
- (void)didMoveToParentViewController:(nullable UIViewController *)parent NS_AVAILABLE_IOS(5_0)
{
    
}
- (void)addChildViewController:(UIViewController *)childController NS_AVAILABLE_IOS(5_0)
{
    
}

- (void) removeFromParentViewController NS_AVAILABLE_IOS(5_0)
{
    
}

- (void)transitionFromViewController:(UIViewController *)fromViewController toViewController:(UIViewController *)toViewController duration:(NSTimeInterval)duration options:(UIViewAnimationOptions)options animations:(void (^ __nullable)(void))animations completion:(void (^ __nullable)(BOOL finished))completion NS_AVAILABLE_IOS(5_0)
{
    
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    UIButton *nextButton = [UIButton buttonWithType:UIButtonTypeCustom];
    nextButton.frame = CGRectMake(10, 10, 80, 40);
    nextButton.backgroundColor = [UIColor redColor];
    [nextButton setTitle:@"下一页" forState:UIControlStateNormal];
    [nextButton addTarget:self action:@selector(nextButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:nextButton];
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    
    self.sliderX.hidden = YES;
    self.sliderY.hidden = YES;
    self.sliderTextX.hidden = YES;
    self.sliderTextY.hidden = YES;
    self.optionsButton.hidden = YES;
    
    self.title = @"K_Line";
    
    self.options = @[
                     @{@"key": @"toggleValues", @"label": @"Toggle Values"},
                     @{@"key": @"toggleHighlight", @"label": @"Toggle Highlight"},
                     @{@"key": @"toggleHighlightArrow", @"label": @"Toggle Highlight Arrow"},
                     @{@"key": @"animateX", @"label": @"Animate X"},
                     @{@"key": @"animateY", @"label": @"Animate Y"},
                     @{@"key": @"animateXY", @"label": @"Animate XY"},
                     @{@"key": @"toggleStartZero", @"label": @"Toggle StartZero"},
                     @{@"key": @"saveToGallery", @"label": @"Save to Camera Roll"},
                     @{@"key": @"togglePinchZoom", @"label": @"Toggle PinchZoom"},
                     @{@"key": @"toggleAutoScaleMinMax", @"label": @"Toggle auto scale min/max"},
                     ];
    
    _chartView = [[BarChartView alloc] initWithFrame:CGRectMake(10, self.view.frame.size.height - self.view.frame.size.height/3- 90, self.view.frame.size.width-20, self.view.frame.size.height/2.5)];
    _chartView.delegate = self;
    
    _chartView.descriptionText = @"";
    _chartView.noDataTextDescription = @"网络不好 请稍后再试";
    
    _chartView.drawBarShadowEnabled = NO;
    _chartView.drawValueAboveBarEnabled = YES;
    
    _chartView.maxVisibleValueCount = 60;
    _chartView.pinchZoomEnabled = NO;
    _chartView.drawGridBackgroundEnabled = NO;
    [self.view addSubview:_chartView];
    
    ChartXAxis *xAxis = _chartView.xAxis;
    xAxis.labelPosition = XAxisLabelPositionBottom;
    xAxis.labelFont = [UIFont systemFontOfSize:10.f];
    xAxis.drawGridLinesEnabled = NO;
    xAxis.spaceBetweenLabels = 2.0;
    
    ChartYAxis *leftAxis = _chartView.leftAxis;
    leftAxis.labelFont = [UIFont systemFontOfSize:10.f];
    leftAxis.labelCount = 5;
    leftAxis.valueFormatter = [[NSNumberFormatter alloc] init];
    leftAxis.valueFormatter.maximumFractionDigits = 1;
    leftAxis.valueFormatter.negativeSuffix = @" ￥";
    leftAxis.valueFormatter.positiveSuffix = @" 万";
    leftAxis.labelPosition = YAxisLabelPositionOutsideChart;
    leftAxis.spaceTop = 0.15;
    
    ChartYAxis *rightAxis = _chartView.rightAxis;
    rightAxis.enabled = NO;  // 取消右侧示数线
    rightAxis.drawGridLinesEnabled = NO;
    rightAxis.labelFont = [UIFont systemFontOfSize:10.f];
    rightAxis.labelCount = 8;
    rightAxis.valueFormatter = leftAxis.valueFormatter;
    rightAxis.spaceTop = 0.15;
    
    _chartView.legend.position = ChartLegendPositionBelowChartLeft;
    _chartView.legend.form = ChartLegendFormSquare;
    _chartView.legend.formSize = 9.0;
    _chartView.legend.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:11.f];
    _chartView.legend.xEntrySpace = 4.0;
    
    [self data];
    // 不加浮动的标注
    
    {
        for (ChartDataSet *set in _chartView.data.dataSets)
        {
            set.drawValuesEnabled = !set.isDrawValuesEnabled;
        }
        
        [_chartView setNeedsDisplay];
    }
    
    //    [_chartView animateWithXAxisDuration:3.0 yAxisDuration:3.0];  // 动画
}
-(void)data
{
    NSError*error;
    //获取文件路径
    NSString *filePath = [[NSBundle mainBundle]pathForResource:@"File"ofType:@"json"];
    //    根据文件路径读取数据
    NSData *jdata = [[NSData alloc]initWithContentsOfFile:filePath];
    //格式化成json数据
    id jsonObject = [NSJSONSerialization JSONObjectWithData:jdata options:kNilOptions error:&error];
    
    all_Dic = [[NSMutableDictionary alloc] initWithDictionary:jsonObject];
    
    
    
    
    NSMutableArray *arr = [[all_Dic objectForKey:@"data"] objectForKey:@"date_data"];
    
    int dataCount = (int)arr.count;
    
    //    [self setDatas];
    [self setDataCount:dataCount range:0];
    
}

- (void)setDataCount:(int)count range:(double)range
{
    //    NSMutableArray *xVals = [[NSMutableArray alloc] init];
    
    NSMutableArray *arr = [[all_Dic objectForKey:@"data"] objectForKey:@"date_data"];
    
    NSMutableArray *xVals = [[NSMutableArray alloc] initWithArray:arr];
    
    int dataCount = (int)arr.count;
    dataCount = count;
    
    // 顺序排序：
    NSMutableArray *detailArray = [NSMutableArray arrayWithArray:[[all_Dic objectForKey:@"data"] objectForKey:@"detail_data"]];
    NSSortDescriptor*sorter=[[NSSortDescriptor alloc]initWithKey:@"date" ascending:YES];
    NSMutableArray *sortDescriptors=[[NSMutableArray alloc]initWithObjects:&sorter count:1];
    sortArray=[detailArray sortedArrayUsingDescriptors:sortDescriptors];
    NSLog(@"sortArray==%@",sortArray);
    
    
    NSMutableArray *yVals = [[NSMutableArray alloc] init];
    
    for (int i = 0; i < count; i++)
    {

        NSNumber *vol_str = [[sortArray objectAtIndex:i] objectForKey:@"vol"];
        
        double mult = (range + 0);
        double val = [vol_str floatValue] + mult;
        
        [yVals addObject:[[BarChartDataEntry alloc] initWithValue:val xIndex:i]];
        
    }
    
    BarChartDataSet *set1 = [[BarChartDataSet alloc] initWithYVals:yVals label:@""];
    set1.barSpace = 0.35;
    [set1 setColor: [UIColor orangeColor]];
    NSMutableArray *dataSets = [[NSMutableArray alloc] init];
    [dataSets addObject:set1];
    
    BarChartData *data = [[BarChartData alloc] initWithXVals:xVals dataSets:dataSets];
    [data setValueFont:[UIFont fontWithName:@"HelveticaNeue-Light" size:10.f]];
    
    _chartView.data = data;
}

//- (void)optionTapped:(NSString *)key
//{
//    if ([key isEqualToString:@"toggleValues"])
//    {
//        for (ChartDataSet *set in _chartView.data.dataSets)
//        {
//            set.drawValuesEnabled = !set.isDrawValuesEnabled;
//        }
//
//        [_chartView setNeedsDisplay];
//    }
//
//    if ([key isEqualToString:@"toggleHighlight"])
//    {
//        _chartView.data.highlightEnabled = !_chartView.data.isHighlightEnabled;
//        [_chartView setNeedsDisplay];
//    }
//
//    if ([key isEqualToString:@"toggleHighlightArrow"])
//    {
//        _chartView.drawHighlightArrowEnabled = !_chartView.isDrawHighlightArrowEnabled;
//
//        [_chartView setNeedsDisplay];
//    }
//
//    if ([key isEqualToString:@"toggleStartZero"])
//    {
//        _chartView.leftAxis.startAtZeroEnabled = !_chartView.leftAxis.isStartAtZeroEnabled;
//        _chartView.rightAxis.startAtZeroEnabled = !_chartView.rightAxis.isStartAtZeroEnabled;
//
//        [_chartView notifyDataSetChanged];
//    }
//
//    if ([key isEqualToString:@"animateX"])
//    {
//        [_chartView animateWithXAxisDuration:3.0];
//    }
//
//    if ([key isEqualToString:@"animateY"])
//    {
//        [_chartView animateWithYAxisDuration:3.0];
//    }
//
//    if ([key isEqualToString:@"animateXY"])
//    {
//        [_chartView animateWithXAxisDuration:3.0 yAxisDuration:3.0];
//    }
//
//    if ([key isEqualToString:@"saveToGallery"])
//    {
//        [_chartView saveToCameraRoll];
//    }
//
//    if ([key isEqualToString:@"togglePinchZoom"])
//    {
//        _chartView.pinchZoomEnabled = !_chartView.isPinchZoomEnabled;
//
//        [_chartView setNeedsDisplay];
//    }
//
//    if ([key isEqualToString:@"toggleAutoScaleMinMax"])
//    {
//        _chartView.autoScaleMinMaxEnabled = !_chartView.isAutoScaleMinMaxEnabled;
//        [_chartView notifyDataSetChanged];
//    }
//}

#pragma mark - Actions
//
//- (IBAction)slidersValueChanged:(id)sender
//{
//    _sliderTextX.text = [@((int)_sliderX.value + 1) stringValue];
//    _sliderTextY.text = [@((int)_sliderY.value) stringValue];
//
//    [self setDataCount:(_sliderX.value + 1) range:_sliderY.value];
//}

#pragma mark - ChartViewDelegate

- (void)chartValueSelected:(ChartViewBase * __nonnull)chartView entry:(ChartDataEntry * __nonnull)entry dataSetIndex:(NSInteger)dataSetIndex highlight:(ChartHighlight * __nonnull)highlight
{
    NSLog(@"chartValueSelected");
}

- (void)chartValueNothingSelected:(ChartViewBase * __nonnull)chartView
{
    NSLog(@"chartValueNothingSelected");
}
-(void)nextButtonClicked:(UIButton *)sender
{
    DiscountingViewController *squareVC = [[DiscountingViewController alloc] init];
    [self.navigationController pushViewController:squareVC animated:YES];
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
