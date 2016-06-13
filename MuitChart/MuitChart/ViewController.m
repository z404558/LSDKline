//
//  ViewController.m
//  MuitChart
//
//  Created by MacFor_Eric_Liu on 15/12/12.
//  Copyright © 2015年 Eric_Liu. All rights reserved.
//

#import "ViewController.h"
#import "MuitChartModule-Swift.h"
#import "SquareViewController.h"
#import "PictureShow_ViewController.h"
#import "ManyPicViewController.h"
#import "FullScreenViewController.h"

@interface ViewController ()<ChartViewDelegate>

@property (nonatomic, strong) CombinedChartView *day_Candle_chartView;
@property (nonatomic, strong) BarChartView *dayK_squareView;

@end

@implementation ViewController
{
    NSMutableDictionary *all_Dic;
    NSArray *sortArray;
    CandleChartDataSet *dayCandle_set1;
    BarChartDataSet *day_square_set1;
    NSMutableArray *xVals;
    NSMutableArray *arr;
    NSString *current_Str;
    UILabel *currentLabel;
    NSMutableArray *open_Arr;
    double avg_double;
    NSMutableArray *mColors;
}
-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];
    // 数据请求
    [self data];
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    UIButton *nextButton = [UIButton buttonWithType:UIButtonTypeCustom];
    nextButton.frame = CGRectMake(10, 10, 80, 40);
    nextButton.backgroundColor = [UIColor greenColor];
    [nextButton setImage:[UIImage imageNamed:@"new"] forState:0];
    nextButton.imageEdgeInsets = UIEdgeInsetsMake(-40, 0, 0, -130);
    [nextButton setTitle:@"全屏" forState:UIControlStateNormal];
    [nextButton addTarget:self action:@selector(nextButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:nextButton];
    self.view.backgroundColor = [UIColor whiteColor];
    currentLabel = [[UILabel alloc] init];
    self.title = @"联 动";
    
    _day_Candle_chartView = [[CombinedChartView alloc] initWithFrame:CGRectMake(0, 64, self.view.frame.size.width-0, self.view.frame.size.height/2.5)];
    _day_Candle_chartView.delegate = self;
    _day_Candle_chartView.drawOrder = @[
                                        @(CombinedChartDrawOrderBar),
                                        @(CombinedChartDrawOrderBubble),
                                        @(CombinedChartDrawOrderCandle),
                                        @(CombinedChartDrawOrderLine),
                                        @(CombinedChartDrawOrderScatter)
                                        ];
    _day_Candle_chartView.backgroundColor = [UIColor clearColor]; // 图的区域
    _day_Candle_chartView.descriptionText = @"";
    _day_Candle_chartView.noDataTextDescription = @"网络不好 请稍后再试";
    _day_Candle_chartView.maxVisibleValueCount = 60;
    _day_Candle_chartView.tag = 100;
    _day_Candle_chartView.pinchZoomEnabled = NO;  // X,Y 轴同时ZOOM
    _day_Candle_chartView.scaleYEnabled = NO;  // 禁止Y轴ZOOM
    _day_Candle_chartView.drawGridBackgroundEnabled = NO;  // 滑动背景
    [self.view addSubview:_day_Candle_chartView];
    
    ChartXAxis *xAxis = _day_Candle_chartView.xAxis;
    xAxis.labelPosition = XAxisLabelPositionBottom;  // X轴的显示位置
    xAxis.wordWrapWidthPercent = 50;
    //    xAxis.labelFont = [UIFont systemFontOfSize:22];
//    xAxis.labelRotationAngle = 22;  // X轴的数值侧显示系数
    //    xAxis.spaceBetweenLabels = 4.0;  // 线线的间隔
    xAxis.drawGridLinesEnabled = YES;  // 背景竖线
    
    ChartYAxis *leftAxis = _day_Candle_chartView.leftAxis;
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
    ll1.lineWidth = 0.8;
    ll1.lineDashLengths = @[@5.f, @5.f];
    ll1.labelPosition = ChartLimitLabelPositionRightTop;
    ll1.valueFont = [UIFont systemFontOfSize:10.0];
    [leftAxis removeAllLimitLines];
    [leftAxis addLimitLine:ll1];

    leftAxis.startAtZeroEnabled = NO;
    leftAxis.gridLineDashLengths = @[@5.f, @5.f];
//    leftAxis.drawLimitLinesBehindDataEnabled = NO;
    
    ChartYAxis *rightAxis = _day_Candle_chartView.rightAxis;
    rightAxis.enabled = NO;  // 取消右侧示数线
    
    NSError*error;
    //获取文件路径
    NSString *filePath = [[NSBundle mainBundle]pathForResource:@"File"ofType:@"json"];
    //根据文件路径读取数据
    NSData *jdata = [[NSData alloc]initWithContentsOfFile:filePath];
    //格式化成json数据
    id jsonObject = [NSJSONSerialization JSONObjectWithData:jdata options:kNilOptions error:&error];
    all_Dic = [[NSMutableDictionary alloc] initWithDictionary:jsonObject];
    arr = [[all_Dic objectForKey:@"data"] objectForKey:@"date_data"];
    
    CombinedChartData *data = [[CombinedChartData alloc] initWithXVals:arr];
    data.lineData = [self generateLineData];
    //    data.barData = [self generateBarData];
    //    data.bubbleData = [self generateBubbleData];
    //    data.scatterData = [self generateScatterData];
    data.candleData = [self generateCandleData_Candle];
    _day_Candle_chartView.data = data;
    
    _day_Candle_chartView.legend.enabled = YES;
    _day_Candle_chartView.legend.formSize = 0;
    _day_Candle_chartView.drawBordersEnabled = YES;  // 给表添加边框
    
    // 柱状图
    _dayK_squareView = [[BarChartView alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height - self.view.frame.size.height/3-140, self.view.frame.size.width-0, self.view.frame.size.height/4)];
    _dayK_squareView.delegate = self;
    _dayK_squareView.descriptionText = @"";
    _dayK_squareView.noDataTextDescription = @"网络不好 请稍后再试!";
    _dayK_squareView.tag = 200;
    _dayK_squareView.drawBarShadowEnabled = NO;
    _dayK_squareView.scaleYEnabled = NO;  // 禁止Y轴ZOOM
    _dayK_squareView.drawValueAboveBarEnabled = YES;
//    _dayK_squareView.maxVisibleValueCount = 60;
//    _squareView.pinchZoomEnabled = NO;
    _dayK_squareView.drawGridBackgroundEnabled = NO;
    [self.view addSubview:_dayK_squareView];
    
    ChartXAxis *square_xAxis = _dayK_squareView.xAxis;
    square_xAxis.labelPosition = XAxisLabelPositionBottom;
    square_xAxis.labelFont = [UIFont systemFontOfSize:10.f];
    square_xAxis.drawGridLinesEnabled = NO;
    square_xAxis.spaceBetweenLabels = 2.0;
    
    ChartYAxis *square_leftAxis = _dayK_squareView.leftAxis;
    square_leftAxis.labelFont = [UIFont systemFontOfSize:10.f];
    square_leftAxis.labelCount = 5;
    square_leftAxis.valueFormatter = [[NSNumberFormatter alloc] init];
    square_leftAxis.valueFormatter.maximumFractionDigits = 1;
    square_leftAxis.valueFormatter.negativeSuffix = @" ￥";
    square_leftAxis.valueFormatter.positiveSuffix = @" 万";
    square_leftAxis.labelPosition = 1;
    square_leftAxis.spaceTop = 0.15;
    
    ChartYAxis *square_rightAxis = _dayK_squareView.rightAxis;
    square_rightAxis.enabled = NO;  // 取消右侧示数线
    square_rightAxis.drawGridLinesEnabled = NO;
    square_rightAxis.labelFont = [UIFont systemFontOfSize:10.f];
    square_rightAxis.labelCount = 8;
    square_rightAxis.valueFormatter = square_rightAxis.valueFormatter;
    square_rightAxis.spaceTop = 0.15;
    
    _dayK_squareView.legend.position = ChartLegendPositionBelowChartLeft;
    _dayK_squareView.legend.form = ChartLegendFormSquare;
    _dayK_squareView.legend.formSize = 0;
    _dayK_squareView.pinchZoomEnabled = NO;
    _dayK_squareView.legend.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:11.f];
    _dayK_squareView.legend.xEntrySpace = 4.0;
    _dayK_squareView.drawBordersEnabled = YES;  // 给表添加边框

    // 不加浮动的标注
    {
        for (ChartDataSet *set in _day_Candle_chartView.data.dataSets)
        {
            set.drawValuesEnabled = !set.isDrawValuesEnabled;
        }
        
        [_day_Candle_chartView setNeedsDisplay];
    }
    {
        for (ChartDataSet *set in _dayK_squareView.data.dataSets)
        {
            set.drawValuesEnabled = !set.isDrawValuesEnabled;
        }
        [_dayK_squareView setNeedsDisplay];
    }
    [_day_Candle_chartView animateWithXAxisDuration:2.0];
    [_dayK_squareView animateWithXAxisDuration:2.0];

    UILabel *allLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, 410, self.view.frame.size.width-30, 200)];
//    allLabel.backgroundColor = [UIColor yellowColor];
    allLabel.numberOfLines = 0;
    allLabel.textAlignment = 1;
    allLabel.text = @"场景：红涨绿跌;\n上图蜡烛图为日、周K、月K；\n线条表示MA5、MA10、MA20均线；\n下图柱状图为成交量统计。";
    [self fuwenbenLabel:allLabel FontNumber:[UIFont boldSystemFontOfSize:18] AndRange:NSMakeRange(0, 2) AndColor:[UIColor redColor]];
//    [self fuwenbenLabel:allLabel FontNumber:[UIFont boldSystemFontOfSize:18] AndRange:NSMakeRange(3, 2) AndColor:[UIColor redColor]];
    [self.view addSubview:allLabel];
}
//设置不同字体颜色
-(void)fuwenbenLabel:(UILabel *)labell FontNumber:(id)font AndRange:(NSRange)range AndColor:(UIColor *)vaColor
{
    NSMutableAttributedString *str = [[NSMutableAttributedString alloc] initWithString:labell.text];
    //设置字号
    [str addAttribute:NSFontAttributeName value:font range:range];
    //设置文字颜色
    [str addAttribute:NSForegroundColorAttributeName value:vaColor range:range];
    labell.attributedText = str;
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
//    [day_square_set1 setColor: [UIColor orangeColor]];
    day_square_set1.drawValuesEnabled = NO;  // 关闭浮动的显示数值
    NSMutableArray *dataSets = [[NSMutableArray alloc] init];
    [dataSets addObject:day_square_set1];
    BarChartData *square_data = [[BarChartData alloc] initWithXVals:xVals dataSets:dataSets];
    [square_data setValueFont:[UIFont fontWithName:@"HelveticaNeue-Light" size:10.f]];
    _dayK_squareView.data = square_data;
}
- (CandleChartData *)generateCandleData_Candle
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
    set.drawValuesEnabled = YES;  // 关闭浮动的显示数值
    set.drawCubicEnabled = NO;  // 平滑线条
    set.drawFilledEnabled = YES; // 区域颜色
    set.drawCirclesEnabled = NO;
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
    currentLabel.frame = CGRectMake(300, 10, 60, 40);
    currentLabel.text = current_Str;
    currentLabel.backgroundColor = [UIColor clearColor];
    [self.view addSubview:currentLabel];
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
        [_day_Candle_chartView setVisibleXRangeMinimum:5];
        [_dayK_squareView zoom:scaleX scaleY:scaleY x:_dayK_squareView.centerOffsets.x y:_dayK_squareView.centerOffsets.y];
    }
    if (chartView.tag == 200) {
        [_dayK_squareView setVisibleXRangeMinimum:5];
        [_day_Candle_chartView zoom:scaleX scaleY:scaleY x:_day_Candle_chartView.centerOffsets.x y:_day_Candle_chartView.centerOffsets.y];
    }
}
// 平移视图
- (void)chartTranslated:(ChartViewBase * __nonnull)chartView dX:(CGFloat)dX dY:(CGFloat)dY
{
    if (chartView.tag == 100) {
        [_dayK_squareView.viewPortHandler refreshWithNewMatrix:chartView.viewPortHandler.touchMatrix chart:_dayK_squareView invalidate:NO];
    }
    if (chartView.tag == 200) {
        [_day_Candle_chartView.viewPortHandler refreshWithNewMatrix:chartView.viewPortHandler.touchMatrix chart:_day_Candle_chartView invalidate:NO];
    }
}
-(void)nextButtonClicked:(UIButton *)sender
{
//    SquareViewController *squareVC = [[SquareViewController alloc] init];
//    PictureShow_ViewController *squareVC = [[PictureShow_ViewController alloc] init];
//    ManyPicViewController *squareVC = [[ManyPicViewController alloc] init];
    FullScreenViewController *squareVC = [[FullScreenViewController alloc] init];
    [self presentViewController:squareVC animated:YES completion:nil];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
@end
