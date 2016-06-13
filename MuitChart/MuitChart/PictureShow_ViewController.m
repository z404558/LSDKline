//
//  PictureShow_ViewController.m
//  MuitChart
//
//  Created by MacFor_Eric_Liu on 16/4/11.
//  Copyright © 2016年 Eric_Liu. All rights reserved.
//

#import "PictureShow_ViewController.h"
#import "VIPhotoView.h"

@interface PictureShow_ViewController ()<UIGestureRecognizerDelegate>

@end

@implementation PictureShow_ViewController
{
    UIButton *backbutton;
    UILabel *showPic_Label;
    
    BOOL isShow_hidden;
    
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    
    float width = self.view.frame.size.width;
    UIScrollView *scrollView = [[UIScrollView alloc] init];
    scrollView.frame = self.view.frame;
    [self.view addSubview:scrollView];
    
    for (int i = 0; i < self.imageArray.count; i++) {
    
        NSString *imageName = self.imageArray[i];
        UIImage *images = [UIImage imageNamed:imageName];
    
    CGRect rect = CGRectMake((width)*i, 0, self.view.frame.size.width, self.view.frame.size.height);
    
    VIPhotoView *photiView = [[VIPhotoView alloc] initWithFrame:rect andImage:images];
    photiView.autoresizingMask = (1 << 6) - 1;
    [scrollView addSubview:photiView];
    
    }
    scrollView.pagingEnabled = YES;
    scrollView.contentSize = CGSizeMake((width + 5)* self.imageArray.count, 0);
    self.navigationController.navigationBarHidden = YES;


    UITapGestureRecognizer* singleRecognizer;
    singleRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(SingleTap:)];
    singleRecognizer.numberOfTapsRequired = 1;
    [self.view addGestureRecognizer:singleRecognizer];
    
    
    backbutton = [UIButton buttonWithType:(UIButtonTypeSystem)];
    backbutton.frame = CGRectMake(20, 30, 23, 23);
//    button.backgroundColor = [UIColor redColor];
    backbutton.hidden = YES;
    [backbutton setBackgroundImage:[UIImage imageNamed:@"hehe.png"] forState:UIControlStateNormal];
    [backbutton addTarget:self action:@selector(leftBackAction:) forControlEvents:(UIControlEventTouchUpInside)];
    backbutton.tag = 200;
    [self.view addSubview:backbutton];
    
    showPic_Label = [[UILabel alloc] init];
    showPic_Label.numberOfLines = 0;
    
    showPic_Label.hidden = YES;
    isShow_hidden = YES;
    showPic_Label.font = [UIFont systemFontOfSize:15];
    showPic_Label.textAlignment = NSTextAlignmentCenter;
//    CGSize size = [self sizeWithString:showPic_Label.text font:showPic_Label.font];
    showPic_Label.frame = CGRectMake(0, self.view.frame.size.height - 100, self.view.frame.size.width, 50);
    showPic_Label.backgroundColor = [UIColor redColor];
    showPic_Label.text = @"从父视图中移除";
    [self.view addSubview:showPic_Label];
    
}

- (CGSize)sizeWithString:(NSString *)string font:(UIFont *)font
{
    CGRect rect = [string boundingRectWithSize:CGSizeMake(self.view.bounds.size.width, self.view.bounds.size.height)//限制最大的宽度和高度
                                       options:NSStringDrawingTruncatesLastVisibleLine | NSStringDrawingUsesFontLeading  |NSStringDrawingUsesLineFragmentOrigin//采用换行模式
                                    attributes:@{NSFontAttributeName: font}//传人的字体字典
                                       context:nil];
    
    return rect.size;
}
-(void)SingleTap:(UITapGestureRecognizer*)recognizer
{
    
    if (isShow_hidden == YES) {
        showPic_Label.hidden = NO;
        isShow_hidden = NO;
        backbutton.hidden = NO;
    }else{
    
        showPic_Label.hidden = YES;
        isShow_hidden = YES;
        backbutton.hidden = YES;
        
    
    }

}
- (void)leftBackAction:(UIButton *)button
{
    
    [self.navigationController popViewControllerAnimated:YES];
    self.navigationController.navigationBarHidden = NO;
    backbutton.showsTouchWhenHighlighted = YES;
    
    [self dismissViewControllerAnimated:NO completion:nil];

}
//- (void)viewDidLayoutSubviews
//{
//    [super viewDidLayoutSubviews];
//    NSLog(@"%@", NSStringFromCGRect([[[self.view subviews] lastObject] frame]));
//}
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
