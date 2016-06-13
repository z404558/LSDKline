//
//  TimeShareViewController.m
//  MuitChart
//
//  Created by MacFor_Eric_Liu on 15/12/16.
//  Copyright © 2015年 Eric_Liu. All rights reserved.
//

#import "TimeShareViewController.h"
#import "MuitChartModule-Swift.h"
#import "PieViewController.h"

@interface CubicLineSampleFillFormatter : NSObject <ChartFillFormatter>
{
    
}
@end

@implementation CubicLineSampleFillFormatter


- (CGFloat)getFillLinePositionWithDataSet:(LineChartDataSet *)dataSet dataProvider:(id<LineChartDataProvider>)dataProvider
{
    return -10.f;
}

@end

@interface TimeShareViewController ()<ChartViewDelegate>

@property (nonatomic, strong)  LineChartView *chartView;
@property (nonatomic, strong)  UISlider *sliderX;
@property (nonatomic, strong)  UISlider *sliderY;
@property (nonatomic, strong)  UITextField *sliderTextX;
@property (nonatomic, strong)  UITextField *sliderTextY;

@end

@implementation TimeShareViewController
{
    NSArray *valNeed;
    
    NSMutableDictionary *all_Dic;
    NSMutableArray *date_arr;
    NSArray *sortArray;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    self.title = @"分时";

    
    UIButton *nextButton = [UIButton buttonWithType:UIButtonTypeCustom];
    nextButton.frame = CGRectMake(10, 10, 80, 40);
    nextButton.backgroundColor = [UIColor redColor];
    [nextButton setTitle:@"下一页" forState:UIControlStateNormal];
    [nextButton addTarget:self action:@selector(nextButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:nextButton];
    
    self.sliderX.hidden = YES;
    self.sliderY.hidden = YES;
    self.sliderTextX.hidden = YES;
    self.sliderTextY.hidden = YES;
    
    
    self.options = @[
                     @{@"key": @"toggleValues", @"label": @"Toggle Values"},
                     @{@"key": @"toggleFilled", @"label": @"Toggle Filled"},
                     @{@"key": @"toggleCircles", @"label": @"Toggle Circles"},
                     @{@"key": @"toggleCubic", @"label": @"Toggle Cubic"},
                     @{@"key": @"toggleHighlight", @"label": @"Toggle Highlight"},
                     @{@"key": @"toggleStartZero", @"label": @"Toggle StartZero"},
                     @{@"key": @"animateX", @"label": @"Animate X"},
                     @{@"key": @"animateY", @"label": @"Animate Y"},
                     @{@"key": @"animateXY", @"label": @"Animate XY"},
                     @{@"key": @"saveToGallery", @"label": @"Save to Camera Roll"},
                     @{@"key": @"togglePinchZoom", @"label": @"Toggle PinchZoom"},
                     @{@"key": @"toggleAutoScaleMinMax", @"label": @"Toggle auto scale min/max"},
                     ];
    
    _chartView = [[LineChartView alloc] initWithFrame:CGRectMake(10, 64, self.view.frame.size.width-20, self.view.frame.size.height/2.5)];
    _chartView.delegate = self;
    
    [_chartView setViewPortOffsetsWithLeft:40.f top:20.f right:0.f bottom:0.f]; // 上 左  下  右
    //    _chartView.backgroundColor = [UIColor colorWithRed:104/255.f green:241/255.f blue:175/255.f alpha:1.f];
    _chartView.backgroundColor = [UIColor whiteColor];
    
    _chartView.descriptionText = @"";  // 右下单位的描述
    _chartView.noDataTextDescription = @"You need to provide data for the chart.";
    
    _chartView.dragEnabled = YES;
    [_chartView setScaleEnabled:YES];
    _chartView.pinchZoomEnabled = NO;
    _chartView.drawGridBackgroundEnabled = NO;  // 指示处的背景色
    
    _chartView.xAxis.enabled = YES;
    [self.view addSubview:_chartView];
    
    ChartYAxis *yAxis = _chartView.leftAxis;
    yAxis.labelPosition = XAxisLabelPositionBothSided;  // y轴示数显示在外部
    yAxis.labelFont = [UIFont fontWithName:@"HelveticaNeue-Light" size:12.f];
    [yAxis setLabelCount:6 force:NO];
    yAxis.startAtZeroEnabled = NO;
    yAxis.labelTextColor = UIColor.lightGrayColor;
    yAxis.drawGridLinesEnabled = NO;
    yAxis.drawAxisLineEnabled = YES;  // 背景横线
    yAxis.gridColor = [UIColor colorWithRed:0.85f green:0.85f blue:0.85f alpha:1.00f];  // 背景横状线条颜色
    yAxis.axisLineColor = [UIColor colorWithRed:0.85f green:0.85f blue:0.85f alpha:1.00f];  //  最左侧Y轴的线色
    
    
    ChartXAxis *xAxis = _chartView.xAxis;
    xAxis.labelPosition = XAxisLabelPositionBottom;  // X轴的显示位置
    xAxis.wordWrapWidthPercent = 50;
    xAxis.gridColor = [UIColor colorWithRed:0.85f green:0.85f blue:0.85f alpha:1.00f]; // 背景竖线的颜色
    //    xAxis.labelFont = [UIFont systemFontOfSize:22];
    //    xAxis.labelRotationAngle = 22;  // X轴的数值侧显示系数
    xAxis.spaceBetweenLabels = 13;  // 线线的间隔
    xAxis.drawGridLinesEnabled = YES;  // 背景竖线
    
    
    _chartView.rightAxis.enabled = YES;  // 右侧的轴线
    _chartView.legend.enabled = NO;   // 左下的小格子
    
    _sliderX.value = 44.0;
    _sliderY.value = 100.0;
    
    [self data];
    
    // 动画
    [_chartView animateWithXAxisDuration:3.0];
}



- (void)setDataCount:(int)count range:(double)range
{
    
    // 顺序排序：
    NSMutableArray *detailArray = [NSMutableArray arrayWithArray:[[all_Dic objectForKey:@"data"] objectForKey:@"detail_data"]];
    NSSortDescriptor*sorter=[[NSSortDescriptor alloc]initWithKey:@"date" ascending:YES];
    NSMutableArray *sortDescriptors=[[NSMutableArray alloc]initWithObjects:&sorter count:1];
    sortArray=[detailArray sortedArrayUsingDescriptors:sortDescriptors];
    NSLog(@"sortArray==%@",sortArray);
    
    
    NSMutableArray *now_Arr = [[NSMutableArray alloc] init];
    
    // Y 轴数据
    for (int i = 0; i < count; i++)
    {
        NSNumber *nowPrice_Y = [[sortArray objectAtIndex:i] objectForKey:@"now_price"];
        [now_Arr addObject:nowPrice_Y];
    }
    
    
    NSMutableArray *xVals = [[NSMutableArray alloc] initWithArray:now_Arr];
    
    int dataCount = (int)now_Arr.count;
    dataCount = count;
    
    
    NSMutableArray *yVals1 = [[NSMutableArray alloc] init];
    // 为曲线赋值
    for (int i = 0; i < count; i++)
    {
        
        NSNumber *nowPrice_Str = [[sortArray objectAtIndex:i] objectForKey:@"now_price"];
        
        double mult = (range + 0);
        double val = [nowPrice_Str floatValue] + mult;
        
        [yVals1 addObject:[[ChartDataEntry alloc] initWithValue:val xIndex:i]];
    }
    
    LineChartDataSet *set1 = [[LineChartDataSet alloc] initWithYVals:yVals1 label:@"DataSet 1"];
    set1.drawCubicEnabled = YES;
    set1.cubicIntensity = 0.2;
    set1.drawCirclesEnabled = NO;
    set1.lineWidth = 1.8;
    set1.circleRadius = 4.0;
    [set1 setCircleColor:UIColor.whiteColor];
    set1.highlightColor = [UIColor colorWithRed:244/255.f green:117/255.f blue:117/255.f alpha:1.f];
    [set1 setColor:[UIColor colorWithRed:0.49f green:0.72f blue:0.87f alpha:1.00f]];  // 走线的颜色
    set1.fillColor = UIColor.whiteColor;
    set1.fillAlpha = 1.f;
    set1.drawHorizontalHighlightIndicatorEnabled = NO;
    set1.fillFormatter = [[CubicLineSampleFillFormatter alloc] init];
    
    LineChartData *data = [[LineChartData alloc] initWithXVals:xVals dataSet:set1];
    [data setValueFont:[UIFont fontWithName:@"HelveticaNeue-Light" size:9.f]];
    [data setDrawValues:NO];
    
    _chartView.data = data;
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
    
    [self setDataCount:dataCount range:0];
    
}
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
    PieViewController *squareVC = [[PieViewController alloc] init];
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
