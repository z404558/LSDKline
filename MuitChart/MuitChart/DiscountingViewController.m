//
//  DiscountingViewController.m
//  MuitChart
//
//  Created by MacFor_Eric_Liu on 15/12/14.
//  Copyright © 2015年 Eric_Liu. All rights reserved.
//

#import "DiscountingViewController.h"
#import "SHLineGraphView.h"
#import "SHPlot.h"
#import "TimeShareViewController.h"

@interface DiscountingViewController ()

@property (nonatomic,assign) CGFloat kLineWidth; // k线的宽度 用来计算可存放K线实体的个数，也可以由此计算出起始日期和结束日期的时间段
@property (nonatomic,assign) int kCount; // k线中实体的总数 通过 xWidth / kLineWidth 计算而来
@property (nonatomic,assign) CGFloat kLinePadding;





@end

@implementation DiscountingViewController
{

    SHLineGraphView *_lineGraph_View;
    
    SHPlot *_plot1;
    
    NSMutableDictionary *all_Dic;

}

-(id)init{
    self = [super init];
    return self;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        [self data];

    }
    return self;
}
-(void)data
{
    NSError*error;
    //获取文件路径
    NSString *filePath = [[NSBundle mainBundle]pathForResource:@"DiscountFile"ofType:@"json"];
    //    根据文件路径读取数据
    NSData *jdata = [[NSData alloc]initWithContentsOfFile:filePath];
    //格式化成json数据
    id jsonObject = [NSJSONSerialization JSONObjectWithData:jdata options:kNilOptions error:&error];
    
    all_Dic = [[NSMutableDictionary alloc] initWithDictionary:jsonObject];
    
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.title = @"折线";
    
    UIButton *nextButton = [UIButton buttonWithType:UIButtonTypeCustom];
    nextButton.frame = CGRectMake(10, 74, 80, 40);
    nextButton.backgroundColor = [UIColor redColor];
    [nextButton setTitle:@"下一页" forState:UIControlStateNormal];
    [nextButton addTarget:self action:@selector(nextButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:nextButton];
    
    //initate the graph view
    _lineGraph_View = [[SHLineGraphView alloc] initWithFrame:CGRectMake(0, 158, self.view.frame.size.width-10, self.view.frame.size.height/3)];
    _lineGraph_View.backgroundColor = [UIColor yellowColor];
    
    UIImageView *image = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height/3)];
    image.image = [UIImage imageNamed:@"22.jpg"];
    [_lineGraph_View addSubview:image];
    //set the main graph area theme attributes
    
    /**
     *  theme attributes dictionary. you can specify graph theme releated attributes in this dictionary. if this property is
     *  nil, then a default theme setting is applied to the graph.
     */
    NSDictionary *_themeAttributes_Dic = @{
                                           kXAxisLabelColorKey : [UIColor whiteColor], // X轴的示数
                                           kXAxisLabelFontKey : [UIFont fontWithName:@"TrebuchetMS" size:10], // X轴的示数大小
                                           kYAxisLabelColorKey : [UIColor whiteColor], // Y轴的示数
                                           kYAxisLabelFontKey : [UIFont fontWithName:@"TrebuchetMS" size:10], // Y轴的示数大小
                                           kYAxisLabelSideMarginsKey : @20, // Y轴离左侧的距离
                                           kPlotBackgroundLineColorKye : [UIColor colorWithRed:0.48 green:0.48 blue:0.49 alpha:0.2]  // 图表的底色横线
                                           };
    _lineGraph_View.themeAttributes = _themeAttributes_Dic;
    
    //set the line graph attributes
    
    /**
     *  the maximum y-value possible in the graph. make sure that the y-value is not in the plotting points is not greater
     *  then this number. otherwise the graph plotting will show wrong results.
     */
    _lineGraph_View.yAxisRange = @(20);
    
    /**
     *  y-axis values are calculated according to the yAxisRange passed. so you do not have to pass the explicit labels for
     *  y-axis, but if you want to put any suffix to the calculated y-values, you can mention it here (e.g. K, M, Kg ...)
     */
    _lineGraph_View.yAxisSuffix = @"￥"; // 单位
    
    /**
     *  an Array of dictionaries specifying the key/value pair where key is the object which will identify a particular
     *  x point on the x-axis line. and the value is the label which you want to show on x-axis against that point on x-axis.
     *  the keys are important here as when plotting the actual points on the graph, you will have to use the same key to
     *  specify the point value for that x-axis point.
     */
    
    
    NSMutableArray *X_data_Arr = [[all_Dic objectForKey:@"data"] objectForKey:@"date_data"]; // X轴的所有日期数组
    NSMutableArray *floatPoint_Arr = [[all_Dic objectForKey:@"data"] objectForKey:@"detail_data"]; // 浮动的所有数组
    NSMutableArray *set_dateArr = [NSMutableArray array];
    NSMutableArray *set_pointArr = [NSMutableArray array];
    
    for (int i = 0; i < X_data_Arr.count; i++) {
        [set_dateArr addObject:[NSDictionary dictionaryWithObject:X_data_Arr[i] forKey:@(i+1)]]; // 为X轴生成包含多个字典的数字
        [set_pointArr addObject:[NSDictionary dictionaryWithObject:[floatPoint_Arr[i] objectForKey:@"open"] forKey:@(i+1)]]; // 为浮动点生成包含多个字典的数组
    }
    
    _lineGraph_View.xAxisValues = set_dateArr; // 为X轴赋值
    _plot1 = [[SHPlot alloc] init]; // 初始化浮动的点
    _plot1.plottingValues = set_pointArr; // 为浮动的点赋值
    
//    _lineGraph_View.xAxisValues = [[all_Dic objectForKey:@"data"] objectForKey:@"date_data"];
    
    //create a new plot object that you want to draw on the `_lineGraph`
    
    //set the plot attributes
    
    /**
     *  Array of dictionaries, where the key is the same as the one which you specified in the `xAxisValues` in `SHLineGraphView`,
     *  the value is the number which will determine the point location along the y-axis line. make sure the values are not
     *  greater than the `yAxisRange` specified in `SHLineGraphView`.
     */
    
//    NSMutableArray *hrhr = [[[[all_Dic objectForKey:@"data"] objectForKey:@"detail_data"] objectAtIndex:0] objectForKey:@"open"];
//    NSMutableArray *arr_hehe = [NSMutableArray arrayWithObjects:@"40",@"20",@"30",@"90",@"50",@"70", nil];
//    
//    _plot1.plottingValues = @[
//                              @{ @1 : [arr_hehe objectAtIndex:0] },
//                              @{ @2 : [arr_hehe objectAtIndex:1] },
//                              @{ @3 : [arr_hehe objectAtIndex:2] },
//                              @{ @4 : [arr_hehe objectAtIndex:3] },
//                              @{ @5 : [arr_hehe objectAtIndex:4] }
//                              
//                              ];
    
    
    
    /**
     *  this is an optional array of `NSString` that specifies the labels to show on the particular points. when user clicks on
     *  a particular points, a popover view is shown and will show the particular label on for that point, that is specified
     *  in this array.
     */
//    NSArray *arr = @[@"1", @"2", @"3", @"4", @"5", @"6" , @"7" , @"8", @"9", @"10", @"11", @"12"];
//    _plot1.plottingPointsLabels = arr; // 显示每个节点
    
    //set plot theme attributes
    
    /**
     *  the dictionary which you can use to assing the theme attributes of the plot. if this property is nil, a default theme
     *  is applied selected and the graph is plotted with those default settings.
     */
    
    
    
    
    NSDictionary *_plotThemeAttributes = @{
                                           kPlotFillColorKey : [UIColor colorWithRed:0.47 green:0.75 blue:0.78 alpha:0.5], // 内部填充色
                                           kPlotStrokeWidthKey : @1.0,  // 线条的宽度
                                           kPlotStrokeColorKey : [UIColor whiteColor], // 走线的颜色
                                           kPlotPointFillColorKey : [UIColor whiteColor],  // 线条拐点的颜色
                                           kPlotPointValueFontKey : [UIFont fontWithName:@"TrebuchetMS" size:0.0]
                                           };
    
    _plot1.plotThemeAttributes = _plotThemeAttributes;

    
    
    [_lineGraph_View addPlot:_plot1];
    
    //You can as much `SHPlots` as you can in a `SHLineGraphView`
    
    [_lineGraph_View setupTheView];
    
    
    [self.view addSubview:_lineGraph_View];
    
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    
}

- (BOOL)shouldAutorotate
{
    return YES;
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation
{
    return UIInterfaceOrientationLandscapeLeft;
}


- (NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskLandscapeLeft | UIInterfaceOrientationMaskLandscapeRight;
}
-(void)nextButtonClicked:(UIButton *)sender
{
    TimeShareViewController *squareVC = [[TimeShareViewController alloc] init];
    [self.navigationController pushViewController:squareVC animated:YES];
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
