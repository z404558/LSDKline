//
//  FullScreenViewController.m
//  MuitChart
//
//  Created by MacFor_Eric_Liu on 16/6/1.
//  Copyright © 2016年 Eric_Liu. All rights reserved.
//

#import "FullScreenViewController.h"
#import "MuitChartModule-Swift.h"

@interface FullScreenViewController ()<ChartViewDelegate>
@property (nonatomic, strong) CombinedChartView *combined_ChartView;
@property (nonatomic, strong) BarChartView *Line_ChartView;

@end

@implementation FullScreenViewController
{
    NSMutableDictionary *all_Dic;
    NSMutableArray *arr;
    NSArray *sortArray;
    CandleChartDataSet *dayCandle_set1;
    BarChartDataSet *day_square_set1;
    NSMutableArray *xVals;
    NSString *current_Str;
    UILabel *currentLabel;
    UIView *tipperView;
    NSMutableArray *open_Arr;
    double avg_double;
    NSMutableArray *mColors;
}
-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];
    [[self navigationController] setNavigationBarHidden:YES];
    // 数据请求
    [self data];
}
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor whiteColor];
    self.title = @"FullScreen";
    currentLabel = [[UILabel alloc] init];
    
    tipperView = [[UIView alloc] init];
    //    tipperView.frame = CGRectMake(0, 0, 375, 667);
    tipperView.transform = CGAffineTransformMakeRotation((90.0f * M_PI) / 180.0f);
    tipperView.frame = CGRectMake(-375+64+20, 0, 667, 667);
    tipperView.layer.backgroundColor = [UIColor whiteColor].CGColor;
    [self.view addSubview:tipperView];
    
    _combined_ChartView = [[CombinedChartView alloc] init];
    CGRect frame = self.view.frame;
    frame.origin = CGPointMake(30, 44);
    frame.size = CGSizeMake(667 - 30, 260);
    _combined_ChartView.frame = frame;
    _combined_ChartView.delegate = self;
    _combined_ChartView.drawOrder = @[
                                        @(CombinedChartDrawOrderBar),
                                        @(CombinedChartDrawOrderBubble),
                                        @(CombinedChartDrawOrderCandle),
                                        @(CombinedChartDrawOrderLine),
                                        @(CombinedChartDrawOrderScatter)
                                        ];
    _combined_ChartView.backgroundColor = [UIColor clearColor]; // 图的区域
    _combined_ChartView.descriptionText = @"";
    _combined_ChartView.noDataTextDescription = @"网络不好 请稍后再试";
    _combined_ChartView.maxVisibleValueCount = 60;
    _combined_ChartView.tag = 100;
    _combined_ChartView.pinchZoomEnabled = NO;  // X,Y 轴同时ZOOM
    _combined_ChartView.scaleYEnabled = NO;  // 禁止Y轴ZOOM
    _combined_ChartView.drawGridBackgroundEnabled = NO;  // 滑动背景
    [tipperView addSubview:_combined_ChartView];
    
    NSError*error;
    //获取文件路径
    NSString *filePath = [[NSBundle mainBundle]pathForResource:@"File"ofType:@"json"];
    //根据文件路径读取数据
    NSData *jdata = [[NSData alloc]initWithContentsOfFile:filePath];
    //格式化成json数据
    id jsonObject = [NSJSONSerialization JSONObjectWithData:jdata options:kNilOptions error:&error];
    all_Dic = [[NSMutableDictionary alloc] initWithDictionary:jsonObject];
    arr = [[all_Dic objectForKey:@"data"] objectForKey:@"date_data"];

    ChartXAxis *xAxis = _combined_ChartView.xAxis;
    xAxis.labelPosition = XAxisLabelPositionBottom;  // X轴的显示位置
    xAxis.wordWrapWidthPercent = 50;
    //    xAxis.labelFont = [UIFont systemFontOfSize:22];
    //    xAxis.labelRotationAngle = 22;  // X轴的数值侧显示系数
    //    xAxis.spaceBetweenLabels = 4.0;  // 线线的间隔
    xAxis.drawGridLinesEnabled = YES;  // 背景竖线
    
    ChartYAxis *leftAxis = _combined_ChartView.leftAxis;
    leftAxis.labelCount = 5; // Y轴指示数量
    //    leftAxis.axisLineColor = [UIColor redColor]; // 最左侧Y轴的线色
    //    leftAxis.labelTextColor = [UIColor redColor];  // 左侧指示的颜色
    leftAxis.gridColor = [UIColor darkTextColor];  // 背景横状线条颜色
    leftAxis.spaceTop = 0.1;  // 距离顶部的高度
    leftAxis.drawGridLinesEnabled = NO;  // 背景横线
    leftAxis.drawAxisLineEnabled = YES;  // 左侧的竖线
    leftAxis.labelPosition = 1;
    
    // 数据请求
    [self data];
    NSString *aaa = [NSString stringWithFormat:@"%@", [open_Arr firstObject]];
    avg_double = [aaa doubleValue];
    ChartLimitLine *ll1 = [[ChartLimitLine alloc] initWithLimit:avg_double label:@""];
    ll1.lineWidth = 0.6;
    ll1.lineDashLengths = @[@5.f, @5.f];
    ll1.labelPosition = ChartLimitLabelPositionRightTop;
    ll1.valueFont = [UIFont systemFontOfSize:10.0];
    [leftAxis removeAllLimitLines];
    [leftAxis addLimitLine:ll1];
    
    leftAxis.startAtZeroEnabled = NO;
    leftAxis.gridLineDashLengths = @[@5.f, @5.f];
    //    leftAxis.drawLimitLinesBehindDataEnabled = NO;
    
    ChartYAxis *rightAxis = _combined_ChartView.rightAxis;
    rightAxis.enabled = NO;  // 取消右侧示数线
    
    _combined_ChartView.legend.enabled = YES;
    _combined_ChartView.legend.formSize = 0;
    _combined_ChartView.drawBordersEnabled = YES;  // 给表添加边框
    
    CombinedChartData *data = [[CombinedChartData alloc] initWithXVals:arr];
    data.lineData = [self generateLineData];
    //    data.barData = [self generateBarData];
    //    data.bubbleData = [self generateBubbleData];
    //    data.scatterData = [self generateScatterData];
    data.candleData = [self generateCandleData_Combined];
    _combined_ChartView.data = data;
    
    // 柱状图
    _Line_ChartView = [[BarChartView alloc] init];
    CGRect frame_Line = self.view.frame;
    frame_Line.origin = CGPointMake(30, _combined_ChartView.frame.size.height + 15);
    frame_Line.size = CGSizeMake(667 - 30, 135);
    _Line_ChartView.frame = frame_Line;
    _Line_ChartView.delegate = self;
    
    // 数据请求
    [self data];
    
    _Line_ChartView.descriptionText = @"";
    _Line_ChartView.noDataTextDescription = @"网络不好 请稍后再试!";
    _Line_ChartView.tag = 200;
    _Line_ChartView.drawBarShadowEnabled = NO;
    _Line_ChartView.scaleYEnabled = NO;  // 禁止Y轴ZOOM
    _Line_ChartView.drawValueAboveBarEnabled = YES;
    //    _Line_ChartView.maxVisibleValueCount = 60;
    //    _Line_ChartView.pinchZoomEnabled = NO;
    _Line_ChartView.drawGridBackgroundEnabled = NO;
    [tipperView addSubview:_Line_ChartView];
    
    ChartXAxis *square_xAxis = _Line_ChartView.xAxis;
    square_xAxis.labelPosition = XAxisLabelPositionBottom;
    square_xAxis.labelFont = [UIFont systemFontOfSize:10.f];
    square_xAxis.drawGridLinesEnabled = NO;
    square_xAxis.spaceBetweenLabels = 2.0;
    
    ChartYAxis *square_leftAxis = _Line_ChartView.leftAxis;
    square_leftAxis.labelFont = [UIFont systemFontOfSize:10.f];
    square_leftAxis.labelCount = 5;
    square_leftAxis.valueFormatter = [[NSNumberFormatter alloc] init];
    square_leftAxis.valueFormatter.maximumFractionDigits = 1;
    square_leftAxis.valueFormatter.negativeSuffix = @" ￥";
    square_leftAxis.valueFormatter.positiveSuffix = @" 万";
    square_leftAxis.labelPosition = 1;
    square_leftAxis.spaceTop = 0.15;
    
    ChartYAxis *square_rightAxis = _Line_ChartView.rightAxis;
    square_rightAxis.enabled = NO;  // 取消右侧示数线
    square_rightAxis.drawGridLinesEnabled = NO;
    square_rightAxis.labelFont = [UIFont systemFontOfSize:10.f];
    square_rightAxis.labelCount = 8;
    square_rightAxis.valueFormatter = square_rightAxis.valueFormatter;
    square_rightAxis.spaceTop = 0.15;
    
    _Line_ChartView.legend.position = ChartLegendPositionBelowChartLeft;
    _Line_ChartView.legend.form = ChartLegendFormSquare;
    _Line_ChartView.legend.formSize = 0;
    _Line_ChartView.pinchZoomEnabled = NO;
    _Line_ChartView.legend.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:11.f];
    _Line_ChartView.legend.xEntrySpace = 4.0;
    _Line_ChartView.drawBordersEnabled = YES;  // 给表添加边框
    
    // 不加浮动的标注
    {
        for (ChartDataSet *set in _combined_ChartView.data.dataSets)
        {
            set.drawValuesEnabled = !set.isDrawValuesEnabled;
        }
        
        [_combined_ChartView setNeedsDisplay];
    }
    {
        for (ChartDataSet *set in _Line_ChartView.data.dataSets)
        {
            set.drawValuesEnabled = !set.isDrawValuesEnabled;
        }
        [_Line_ChartView setNeedsDisplay];
    }
    [_combined_ChartView animateWithXAxisDuration:2.0];
    [_Line_ChartView animateWithXAxisDuration:2.0];
    
    UIButton *backButton = [UIButton buttonWithType:UIButtonTypeCustom];
    backButton.frame = CGRectMake(667-80, 15, 70, 30);
    backButton.backgroundColor = [UIColor redColor];
    [backButton setTitle:@"返回竖屏" forState:UIControlStateNormal];
    UIFont *cfont = [UIFont boldSystemFontOfSize:17];
    backButton.titleLabel.font = cfont;
    [backButton addTarget:self action:@selector(backButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [tipperView addSubview:backButton];
    
//    CGAffineTransform rotation = CGAffineTransformMakeRotation(M_PI / 2);
////    rotation = CGAffineTransformTranslate(rotation, 0, 0);
//    [_combined_ChartView setTransform:rotation];
//    [_Line_ChartView setTransform:rotation];
}
-(void)backButtonClicked:(UIButton *)sender
{
    [self dismissModalViewControllerAnimated:YES];

    //    [UIView animateWithDuration:0.1f animations:^{
    //        tipperView.transform = CGAffineTransformIdentity;
    //    } completion:^(BOOL finished) {
    //
    //    }];
}
-(void)data
{
    NSError*error;
    //获取文件路径
    NSString *filePath = [[NSBundle mainBundle]pathForResource:@"File"ofType:@"json"];
    //根据文件路径读取数据
    NSData *jdata = [[NSData alloc]initWithContentsOfFile:filePath];
    //格式化成json数据
    id jsonObject = [NSJSONSerialization JSONObjectWithData:jdata options:kNilOptions error:&error];
    all_Dic = [[NSMutableDictionary alloc] initWithDictionary:jsonObject];
    NSMutableArray *arr1 = [[all_Dic objectForKey:@"data"] objectForKey:@"date_data"];
    int dataCount = (int)arr1.count;
    [self setDataCount:dataCount range:0];
}
- (void)setDataCount:(int)count range:(double)range
{
    NSMutableArray *arr2 = [[all_Dic objectForKey:@"data"] objectForKey:@"date_data"];
    xVals = [[NSMutableArray alloc] initWithArray:arr2];
    int dataCount = (int)arr2.count;
    dataCount = count;
    // 顺序排序：
    NSMutableArray *detailArray = [NSMutableArray arrayWithArray:[[all_Dic objectForKey:@"data"] objectForKey:@"detail_data"]];
    NSSortDescriptor*sorter=[[NSSortDescriptor alloc]initWithKey:@"date" ascending:YES];
    NSMutableArray *sortDescriptors=[[NSMutableArray alloc]initWithObjects:&sorter count:1];
    sortArray=[detailArray sortedArrayUsingDescriptors:sortDescriptors];
    //    NSLog(@"sortArray==%@",sortArray);
    NSMutableArray *yVals1 = [[NSMutableArray alloc] init];
    NSMutableArray *square_yVals = [[NSMutableArray alloc] init];
    open_Arr = [[NSMutableArray alloc] init];
    mColors = [[NSMutableArray alloc]init];
    for (int i = 0; i < count; i++)
    {
        NSNumber *increase_str = [[sortArray objectAtIndex:i] objectForKey:@"increase"];  // 1.3%
        NSNumber *open_str = [[sortArray objectAtIndex:i] objectForKey:@"open"];  // 13.89
        NSNumber *high_str = [[sortArray objectAtIndex:i] objectForKey:@"high"];  // 14.14
        NSNumber *low_str = [[sortArray objectAtIndex:i] objectForKey:@"low"]; //  13.89
        NSNumber *close_str = [[sortArray objectAtIndex:i] objectForKey:@"close"];;  // 14.07
        
        double mult = ([increase_str floatValue] );
        double high = [high_str floatValue] ;
        double low = [low_str floatValue] ;
        double open = [open_str floatValue] ;
        double close = [close_str floatValue];
        [yVals1 addObject:[[CandleChartDataEntry alloc] initWithXIndex:i shadowH: high shadowL: low open:open close:close]];
        // 柱状图
        NSNumber *vol_str = [[sortArray objectAtIndex:i] objectForKey:@"vol"];
        double val = [vol_str floatValue] + mult;
        [square_yVals addObject:[[BarChartDataEntry alloc] initWithValue:val/10000 xIndex:i]];
        
        // 开盘价
        [open_Arr addObject:open_str];
        
        if (close >= open) {
            [mColors addObject:[UIColor colorWithRed:191.0/255.0 green:31.0/255.0 blue:45.0/255.0 alpha:1.0f]];
        } else {
            [mColors addObject:[UIColor colorWithRed:84.0/255.0 green:185.0/255.0 blue:28.0/255.0 alpha:1.0f]];
        }
    }
    // 柱状图
    day_square_set1 = [[BarChartDataSet alloc] initWithYVals:square_yVals label:@""];
    day_square_set1.barSpace = 0.3;
    day_square_set1.colors = mColors;
    day_square_set1.drawValuesEnabled = NO;  // 关闭浮动的显示数值
    NSMutableArray *dataSets = [[NSMutableArray alloc] init];
    [dataSets addObject:day_square_set1];
    BarChartData *square_data = [[BarChartData alloc] initWithXVals:xVals dataSets:dataSets];
    [square_data setValueFont:[UIFont fontWithName:@"HelveticaNeue-Light" size:10.f]];
    _Line_ChartView.data = square_data;
}
- (CandleChartData *)generateCandleData_Combined
{
    NSError*error;
    //获取文件路径
    NSString *filePath = [[NSBundle mainBundle]pathForResource:@"File"ofType:@"json"];
    //根据文件路径读取数据
    NSData *jdata = [[NSData alloc]initWithContentsOfFile:filePath];
    //格式化成json数据
    id jsonObject = [NSJSONSerialization JSONObjectWithData:jdata options:kNilOptions error:&error];
    all_Dic = [[NSMutableDictionary alloc] initWithDictionary:jsonObject];
    arr = [[all_Dic objectForKey:@"data"] objectForKey:@"date_data"];
    // 顺序排序：
    NSMutableArray *detailArray = [NSMutableArray arrayWithArray:[[all_Dic objectForKey:@"data"] objectForKey:@"detail_data"]];
    NSSortDescriptor*sorter=[[NSSortDescriptor alloc]initWithKey:@"date" ascending:YES];
    NSMutableArray *sortDescriptors=[[NSMutableArray alloc]initWithObjects:&sorter count:1];
    sortArray=[detailArray sortedArrayUsingDescriptors:sortDescriptors];
    int dataCount = (int)arr.count;
    NSMutableArray *yVals1 = [[NSMutableArray alloc] init];
    for (int i = 0; i < dataCount; i++)
    {
        NSNumber *open_str = [[sortArray objectAtIndex:i] objectForKey:@"open"];  // 13.89
        NSNumber *high_str = [[sortArray objectAtIndex:i] objectForKey:@"high"];  // 14.14
        NSNumber *low_str = [[sortArray objectAtIndex:i] objectForKey:@"low"]; //  13.89
        NSNumber *close_str = [[sortArray objectAtIndex:i] objectForKey:@"close"];;  // 14.07
        double high = [high_str floatValue] ;
        double low = [low_str floatValue] ;
        double open = [open_str floatValue] ;
        double close = [close_str floatValue];
        [yVals1 addObject:[[CandleChartDataEntry alloc] initWithXIndex:i shadowH: high shadowL: low open:open close:close]];
    }
    CandleChartData *d = [[CandleChartData alloc] init];
    CandleChartDataSet *set = [[CandleChartDataSet alloc] initWithYVals:yVals1 label:@""];
    //    [set setColor:[UIColor colorWithRed:80/255.f green:80/255.f blue:80/255.f alpha:1.f]];
    //    set.valueFont = [UIFont systemFontOfSize:10.f];
    //    [set setDrawValuesEnabled:YES];
    //    set.decreasingColor = UIColor.cyanColor;
    //    set.decreasingFilled = YES;
    //    set.increasingColor = UIColor.redColor; // 下跌
    //    set.increasingFilled = YES;
    //    set.shadowColorSameAsCandle = YES; // 高线与蜡烛同色
    //    [set setHighlightEnabled:NO];  // 取消选中效果
    //    set.drawHorizontalHighlightIndicatorEnabled = NO;  // 横状高亮条
    //    set.drawVerticalHighlightIndicatorEnabled = NO;  // 竖状高亮条
    //    set.bodySpace = 0.3;
    
    set.axisDependency = AxisDependencyLeft;
    [set setColor:UIColor.clearColor]; //左下小格子的颜色
    //    set1.valueTextColor = [UIColor brownColor];  // 浮动数字的颜色
    set.shadowColor = UIColor.darkGrayColor; // 高线
    set.shadowWidth = 0.9;
    set.colors = ChartColorTemplates.increaseORcrease;
    //    set.decreasingColor = RGB_Color(84, 185, 28); // 下跌
    set.decreasingColor = [UIColor colorWithRed:83.0/255.0 green:185.0/255.0 blue:28.0/255.0 alpha:1.0f];
    set.decreasingFilled = YES;
    [set setHighlightEnabled:NO];  // 取消选中效果
    set.drawHorizontalHighlightIndicatorEnabled = NO;  // 横状高亮条
    set.drawVerticalHighlightIndicatorEnabled = NO;  // 竖状高亮条
    set.drawValuesEnabled = YES;  // 关闭浮动的显示数值
    set.increasingColor = [UIColor colorWithRed:0.749 green:0.122 blue:0.000 alpha:1.000]; // 上涨
    set.increasingFilled = YES;
    
    set.bodySpace = 0.1;   /// the space that is left out on the left and right side of each candle, default: 0.1 (10%), max 0.45, min 0.0
    set.shadowColorSameAsCandle = YES; // 高线与蜡烛同色
    [d addDataSet:set];
    return d;
}
- (LineChartData *)generateLineData
{
    NSError*error;
    //获取文件路径
    NSString *filePath = [[NSBundle mainBundle]pathForResource:@"File"ofType:@"json"];
    //根据文件路径读取数据
    NSData *jdata = [[NSData alloc]initWithContentsOfFile:filePath];
    //格式化成json数据
    id jsonObject = [NSJSONSerialization JSONObjectWithData:jdata options:kNilOptions error:&error];
    all_Dic = [[NSMutableDictionary alloc] initWithDictionary:jsonObject];
    arr = [[all_Dic objectForKey:@"data"] objectForKey:@"date_data"];
    // 顺序排序：
    NSMutableArray *detailArray = [NSMutableArray arrayWithArray:[[all_Dic objectForKey:@"data"] objectForKey:@"detail_data"]];
    NSSortDescriptor*sorter=[[NSSortDescriptor alloc]initWithKey:@"date" ascending:YES];
    NSMutableArray *sortDescriptors=[[NSMutableArray alloc]initWithObjects:&sorter count:1];
    sortArray=[detailArray sortedArrayUsingDescriptors:sortDescriptors];
    int dataCount = (int)arr.count;
    LineChartData *d = [[LineChartData alloc] init];
    NSMutableArray *entries = [[NSMutableArray alloc] init];
    for (int index = 0; index < dataCount; index++)
    {
        NSNumber *open_str = [[sortArray objectAtIndex:index] objectForKey:@"low"];
        double open = [open_str floatValue] ;
        [entries addObject:[[ChartDataEntry alloc] initWithValue:open xIndex:index]];
    }
    LineChartDataSet *set = [[LineChartDataSet alloc] initWithYVals:entries label:@""];
    [set setColor:[UIColor colorWithRed:240/255.f green:238/255.f blue:70/255.f alpha:1.f]];
    set.lineWidth = 1;
    set.drawCubicEnabled = NO;  // 平滑线条
    set.drawFilledEnabled = YES; // 区域颜色
    set.drawCirclesEnabled = NO;
    set.drawValuesEnabled = YES;
    //    set.valueFont = [UIFont systemFontOfSize:10.f];
    //    set.valueTextColor = [UIColor colorWithRed:240/255.f green:238/255.f blue:70/255.f alpha:1.f];
    set.axisDependency = AxisDependencyLeft;
    [d addDataSet:set];
    return d;
}
#pragma mark - ChartViewDelegate
- (void)chartValueSelected:(ChartViewBase * __nonnull)chartView entry:(ChartDataEntry * __nonnull)entry dataSetIndex:(NSInteger)dataSetIndex highlight:(ChartHighlight * __nonnull)highlight
{
    NSLog(@"chartValueSelected");
    double Str = entry.value;
    current_Str = [NSString stringWithFormat:@"%.2f", Str];
    currentLabel.frame = CGRectMake(280, 10, 60, 40);
    currentLabel.text = current_Str;
    currentLabel.backgroundColor = [UIColor clearColor];
    [tipperView addSubview:currentLabel];
    
}
- (void)chartValueNothingSelected:(ChartViewBase * __nonnull)chartView
{
    NSLog(@"chartValueNothingSelected");
}
- (void)computeAxisWithYMin:(double)yMin yMax:(double)yMax
{
    //    NSLog(@"=======%f____%f",yMin,yMax);
}
// 缩放方法
- (void)chartScaled:(ChartViewBase * __nonnull)chartView scaleX:(CGFloat)scaleX scaleY:(CGFloat)scaleY
{
    if (chartView.tag == 100) {
        [_combined_ChartView setVisibleXRangeMinimum:5];
        [_Line_ChartView zoom:scaleX scaleY:scaleY x:_Line_ChartView.centerOffsets.x y:_Line_ChartView.centerOffsets.y];
    }
    if (chartView.tag == 200) {
        [_Line_ChartView setVisibleXRangeMinimum:5];
        [_combined_ChartView zoom:scaleX scaleY:scaleY x:_combined_ChartView.centerOffsets.x y:_combined_ChartView.centerOffsets.y];
    }
}
// 平移视图
- (void)chartTranslated:(ChartViewBase * __nonnull)chartView dX:(CGFloat)dX dY:(CGFloat)dY
{
    if (chartView.tag == 100) {
        [_Line_ChartView.viewPortHandler refreshWithNewMatrix:chartView.viewPortHandler.touchMatrix chart:_Line_ChartView invalidate:NO];
    }
    if (chartView.tag == 200) {
        [_combined_ChartView.viewPortHandler refreshWithNewMatrix:chartView.viewPortHandler.touchMatrix chart:_combined_ChartView invalidate:NO];
    }
}

- (void)didReceiveMemoryWarning {
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
