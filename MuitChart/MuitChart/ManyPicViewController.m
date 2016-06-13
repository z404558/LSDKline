//
//  ManyPicViewController.m
//  MuitChart
//
//  Created by MacFor_Eric_Liu on 16/4/14.
//  Copyright © 2016年 Eric_Liu. All rights reserved.
//

#import "ManyPicViewController.h"
#import "PictureShow_ViewController.h"
#import "PicViews.h"

@interface ManyPicViewController ()

@end

@implementation ManyPicViewController
{
    PicViews *picView;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor whiteColor];
    self.navigationController.navigationBarHidden = YES;
    
    __weak ManyPicViewController *weakSelf = self;
    void (^clickImageBlock)(NSString *str) = ^(NSString *str) {
        NSLog(@"点击图片");
        PictureShow_ViewController *picVC =  [[PictureShow_ViewController  alloc] init];
        picVC.imageArray = @[@"IMG_3217.JPG",@"7.3.JPG",@"10.JPG"];
        [weakSelf presentViewController:picVC animated:NO completion:nil];
    };
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    NSArray *array = @[@"2",@"3",@"4"];
    [dict setObject:array forKey:@"content"];
    [dict setObject:@"3" forKey:@"rowTotal"];
    picView = [[PicViews alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, self.view.frame.size.height/2)];
    picView.block = clickImageBlock;
    [picView setImageView:dict];
    picView.backgroundColor = [UIColor greenColor];
    [self.view addSubview:picView];
    
//    NSArray *testArray = [NSArray arrayWithObjects:@"2.0", @"2.3", @"3.0", @"4.0",@"10",nil];
//    
//    NSNumber *sum1 = [testArray valueForKeyPath:@"@sum.floatValue"];
//    
//    NSNumber *avg1 = [testArray valueForKeyPath:@"@avg.floatValue"];
//    NSNumber* max1=[testArray valueForKeyPath:@"@max.floatValue"];
//    NSNumber* min1=[testArray valueForKeyPath:@"@min.floatValue"];
//    NSLog(@"%@ %@ %@ %@",sum1,avg1,max1,min1);
  
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
