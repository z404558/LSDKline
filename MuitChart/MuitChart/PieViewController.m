//
//  PieViewController.m
//  MuitChart
//
//  Created by MacFor_Eric_Liu on 15/12/17.
//  Copyright © 2015年 Eric_Liu. All rights reserved.
//

#import "PieViewController.h"
#import "KWFormView.h"
#import "KWPerson.h"
#import "changeImfor_Model.h"
#import "PieChartView.h"

#define SC_DEVICE_SIZE      [[UIScreen mainScreen] bounds].size
#define PIE_HEIGHT 180



@interface PieViewController ()<UIScrollViewDelegate,KWFormViewDataSource, KWFormViewDelegate,PieChartDelegate,UIWebViewDelegate>

@property (nonatomic, strong) NSArray *datas_Name;
@property (nonatomic, strong) NSArray *titles;
@property (nonatomic, strong) NSArray *changeImforArr;

// 饼图
@property (nonatomic,strong) NSMutableArray *valueArray;
@property (nonatomic,strong) NSMutableArray *colorArray;
@property (nonatomic,strong) PieChartView *pieChartView;
@property (nonatomic,strong) UIView *pieContainer;
@property (nonatomic)BOOL inOut;


@end

@implementation PieViewController
{
    UIAlertView *alertView_select;
    
    KWFormView *jyxx_FormView;
    KWFormView *formView_Person;
    
    UILabel *selLabel;
    
    UIScrollView *mainScrollView;
    UIImageView *shadowImgView;
}

- (void)viewDidAppear:(BOOL)animated
{
    [self.pieChartView reloadChart];
}
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.title = @"饼图 表格";
    
    self.navigationController.navigationBar.tintColor = [UIColor blueColor];
    self.navigationController.navigationBar.tintColor = [UIColor colorWithWhite:0.8 alpha:1.0];
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    self.automaticallyAdjustsScrollViewInsets = NO;
    mainScrollView = [[UIScrollView alloc] init];
    mainScrollView.frame = CGRectMake(0, -64, SC_DEVICE_SIZE.width, SC_DEVICE_SIZE.height);
    mainScrollView.delegate = self;
    mainScrollView.contentSize = CGSizeMake(0, 700);
    
    [self.view addSubview:mainScrollView];
    
    // 交易信息
    UILabel *jyxx_Label = [[UILabel alloc] initWithFrame:CGRectMake(20, 74, SC_DEVICE_SIZE.width, 30)];
    jyxx_Label.text = @"交易信息";
    jyxx_Label.font = [UIFont boldSystemFontOfSize:17.5];
    [mainScrollView addSubview:jyxx_Label];
    
    NSArray *jyxx_datasArr = [NSArray arrayWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"changeImfor" ofType:@"plist"]];
    self.changeImforArr = [changeImfor_Model changeImforWithDictArray:jyxx_datasArr];
    self.titles = @[@"转让形式",@"公告日期",@"变动日期",];
    jyxx_FormView = [[KWFormView alloc] initWithFrame:CGRectMake(-1, 105, SC_DEVICE_SIZE.width + 2, 0)];
    jyxx_FormView.delegate = self;
    jyxx_FormView.dataSource = self;
    [mainScrollView addSubview:jyxx_FormView];
    
    
    
    NSArray *datasArr = [NSArray arrayWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"datas" ofType:@"plist"]];
    self.datas_Name = [KWPerson personsWithDictArray:datasArr];
    self.titles = @[@"姓名",@"性别", @"年龄"];
    formView_Person = [[KWFormView alloc] initWithFrame:CGRectMake(10, 475, self.view.frame.size.width - 20, 0)];
    formView_Person.delegate = self;
    formView_Person.dataSource = self;
    [mainScrollView addSubview:formView_Person];
 
    self.view.backgroundColor = [self colorFromHexRGB:@"f3f3f3"];
    
    
    self.inOut = YES;
    self.valueArray = [[NSMutableArray alloc] initWithObjects:
                       [NSNumber numberWithInt:20],
                       [NSNumber numberWithInt:30],
                       [NSNumber numberWithInt:12],
                       [NSNumber numberWithInt:18],
                       [NSNumber numberWithInt:31],
                       [NSNumber numberWithInt:24],
                       nil];
    
    self.colorArray = [NSMutableArray arrayWithObjects:
                       [UIColor colorWithHue:((0/8)%20)/20.0+0.02 saturation:(0%8+3)/10.0 brightness:91/100.0 alpha:1],
                       [UIColor colorWithHue:((1/8)%20)/20.0+0.02 saturation:(1%8+3)/10.0 brightness:91/100.0 alpha:1],
                       [UIColor colorWithHue:((2/8)%20)/20.0+0.02 saturation:(2%8+3)/10.0 brightness:91/100.0 alpha:1],
                       [UIColor colorWithHue:((3/8)%20)/20.0+0.02 saturation:(3%8+3)/10.0 brightness:91/100.0 alpha:1],
                       [UIColor colorWithHue:((4/8)%20)/20.0+0.02 saturation:(4%8+3)/10.0 brightness:91/100.0 alpha:1],
                       [UIColor colorWithHue:((5/8)%20)/20.0+0.02 saturation:(5%8+3)/10.0 brightness:91/100.0 alpha:1],
                       nil];
    
    
    //add shadow img
    
    UIImage *shadowImg = [UIImage imageNamed:@"shadow.png"];
    shadowImgView = [[UIImageView alloc]initWithImage:shadowImg];
    
    CGRect pieFrame = CGRectMake((self.view.frame.size.width - PIE_HEIGHT) / 2, 230-0, PIE_HEIGHT, PIE_HEIGHT);
    shadowImgView.frame = CGRectMake(30, pieFrame.origin.y + PIE_HEIGHT*0.92, shadowImg.size.width/2, shadowImg.size.height/2);
    [mainScrollView addSubview:shadowImgView];
    
    
    // 整个圆盘
    self.pieContainer = [[UIView alloc]initWithFrame:pieFrame];
    self.pieChartView = [[PieChartView alloc]initWithFrame:self.pieContainer.bounds withValue:self.valueArray withColor:self.colorArray];
    self.pieChartView.delegate = self;
    //    self.pieChartView.backgroundColor = [UIColor yellowColor];
    //    self.pieContainer.backgroundColor = [UIColor orangeColor];
    [self.pieContainer addSubview:self.pieChartView];
    
    
    //    [self.pieChartView setAmountText:@"-2456.0"];
    
    [mainScrollView addSubview:self.pieContainer];
    
    //数据框
    UIImageView *selView = [[UIImageView alloc]init];
    selView.image = [UIImage imageNamed:@"select.png"];
    selView.frame = CGRectMake((self.view.frame.size.width - selView.image.size.width/2)/2, self.pieContainer.frame.origin.y + self.pieContainer.frame.size.height, selView.image.size.width/2, selView.image.size.height/2);
    //    [self.view addSubview:selView];
    
    // 数据框 Label
    selLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 24, selView.image.size.width/2, 21)];
    selLabel.backgroundColor = [UIColor greenColor];
    selLabel.textAlignment = NSTextAlignmentCenter;
    selLabel.font = [UIFont systemFontOfSize:17];
    selLabel.textColor = [UIColor whiteColor];
    [selView addSubview:selLabel];
    
    
    [self.pieChartView setTitleText:@"所占比重"];
    
}

#pragma mark - formView dataSource
- (NSInteger)numberOfRowsInFormView:(KWFormView *)formView
{
    
    if (formView == jyxx_FormView) {
        return self.changeImforArr.count + 1;
    }
    return self.datas_Name.count + 1;
}

- (NSInteger)formViewColumnsInRow:(KWFormView *)formView
{
    return 3;
}

- (NSString *)formView:(KWFormView *)formView textForColumn:(NSInteger)column inRow:(NSInteger)row
{
    if (!row) {
        return self.titles[column];
    }
    else{
        if (formView == jyxx_FormView) {
            changeImfor_Model *changeImfor = self.changeImforArr[row-1];
            if (column == 0) {
                return changeImfor.zrxs_Str;
            }else if (column == 1) {
                return [NSString stringWithFormat:@"%ld",(long)changeImfor.ggrq_Int];
            }else{
                return [NSString stringWithFormat:@"%ld",(long)changeImfor.bdrq_Int];
            }
        }
        
        KWPerson *person = self.datas_Name[row - 1];
        if (column == 0) {
            return person.name;
        }else if (column == 1) {
            return person.sex;
        }else{
            return [NSString stringWithFormat:@"%ld",(long)person.age];
        }
        
    }
}

- (UIColor *)formView:(KWFormView *)formView colorOfColumn:(NSInteger)column inRow:(NSInteger)row
{
    if (row == 0) {
        return [UIColor purpleColor];
    }
    if (column == 1) {
        if (row % 2) {
            return [UIColor orangeColor];
        }
        return [UIColor redColor];
    }else{
        if (row % 2) {
            return [UIColor redColor];
        }
        return [UIColor orangeColor];
    }
}

// 内部文字颜色
- (UIColor *)formView:(KWFormView *)formView contentColorOfColumn:(NSInteger)column inRow:(NSInteger)row
{
    return [UIColor darkTextColor];
}

// 加外部边框
- (UIColor *)formViewBorderColor:(KWFormView *)formView
{
    return [UIColor blackColor];
}

- (CGFloat)formView:(KWFormView *)formView widthForColumn:(NSInteger)column
{
    return formView.bounds.size.width / 3.f;
}

- (CGFloat)formView:(KWFormView *)formView heightForRow:(NSInteger)row
{
    if (formView == jyxx_FormView) {
        if (row == 0) {
            return 40;
        }
        return 50;
    }
    return 40 - 5;
}

- (BOOL)formView:(KWFormView *)formView addActionForColumn:(NSInteger)column inRow:(NSInteger)row
{
    return YES;
}

- (void)formView:(KWFormView *)formView didSelectColumn:(NSInteger)column inRow:(NSInteger)row
{
    NSLog(@"%@",[formView itemAtColumn:column inRow:row].currentTitle);
    
    NSString *str_select = [formView itemAtColumn:column inRow:row].currentTitle;
    
    alertView_select = [[UIAlertView alloc] initWithTitle:str_select message:nil delegate:self cancelButtonTitle:nil otherButtonTitles:nil, nil];
    [NSTimer scheduledTimerWithTimeInterval:0.5f target:self selector:@selector(performDismiss:) userInfo:nil repeats:NO];
    [alertView_select show];
}
-(void)performDismiss:(NSTimer*)timer
{
    [alertView_select dismissWithClickedButtonIndex:0 animated:NO];
}
- (UIColor *) colorFromHexRGB:(NSString *) inColorString
{
    UIColor *result = nil;
    unsigned int colorCode = 0;
    unsigned char redByte, greenByte, blueByte;
    
    if (nil != inColorString)
    {
        NSScanner *scanner = [NSScanner scannerWithString:inColorString];
        (void) [scanner scanHexInt:&colorCode]; // ignore error
    }
    redByte = (unsigned char) (colorCode >> 16);
    greenByte = (unsigned char) (colorCode >> 8);
    blueByte = (unsigned char) (colorCode); // masks off high bits
    result = [UIColor
              colorWithRed: (float)redByte / 0xff
              green: (float)greenByte/ 0xff
              blue: (float)blueByte / 0xff
              alpha:1.0];
    return result;
}

- (void)selectedFinish:(PieChartView *)pieChartView index:(NSInteger)index percent:(float)per
{
    selLabel.text = [NSString stringWithFormat:@"%2.2f%@",per*100,@"%"];
    [self.pieChartView setAmountText:selLabel.text];
}

//- (void)onCenterClick:(PieChartView *)pieChartView
//{
//    
//    
//    //   动画执行结束后 要执行的代码
//    [UIView animateWithDuration:0.5f animations:^{
//        
//        // 动画运行的速度曲线
//        [UIView setAnimationCurve:UIViewAnimationCurveEaseIn];
//        
//        self.pieContainer.alpha = 0;
//        shadowImgView.alpha = 0;
//        
//        
//    } completion:^(BOOL finished) {
//        
//        self.pieContainer.hidden = YES;
//        shadowImgView.hidden = YES;
//        NSLog(@"动画完毕");
//        
//    }];
//}



- (void)dealloc
{
    self.valueArray = nil;
    self.colorArray = nil;
    self.pieContainer = nil;
    //    self.selLabel = nil;
    selLabel = nil;
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
