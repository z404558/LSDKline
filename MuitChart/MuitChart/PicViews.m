//
//  PicViews.m
//  MuitChart
//
//  Created by MacFor_Eric_Liu on 16/4/14.
//  Copyright © 2016年 Eric_Liu. All rights reserved.
//

#import "PicViews.h"
#import "ManyPicViewController.h"

#define APP_WIDTH [UIScreen mainScreen].bounds.size.width
#define APP_HEIGHT [UIScreen mainScreen].bounds.size.height

#define APP_HEIGHT_LAYLOUT (APP_HEIGHT - 64)
#define PADDING_SCREEN_WIDTH  15 // 距离屏幕宽

#define  SCREEN_HEIGHT [[UIScreen mainScreen] bounds].size.height  //获取屏幕高度
#define  SCREEN_WIDTH  [[UIScreen mainScreen] bounds].size.width   //获取屏幕宽度

@implementation PicViews
{
    UIImageView *pic_1;
    UIImageView *pic_2;
    UIImageView *pic_2_1;
    float view_height;
}
- (void)layoutSubviews{
    [super layoutSubviews];
    UIButton *button = [[UIButton alloc] init];
    [button addTarget:self action:@selector(click:) forControlEvents:(UIControlEventTouchUpInside)];
    button.frame = self.frame;
//    button.backgroundColor = [UIColor orangeColor];
    [self addSubview:button];
}
- (void)setImageView:(NSDictionary *)dict{
    int num_column = [[dict objectForKey:@"rowTotal"] intValue];
    NSArray *content_arr = [dict objectForKey:@"content"];
    float height = 0.0;
    NSMutableArray *arr =[ NSMutableArray array];
    [arr addObject:@"0"];
    for (int i = 0; i < num_column; i++) {
        UIView *view = [UIView new];
        view.backgroundColor = [UIColor clearColor];
        [self addSubview:view];
        float heights = 0.0;
        float num_line =  [[NSString stringWithFormat:@"%@", [content_arr objectAtIndex:i]] floatValue];
        for (int j = 0; j < num_line; j ++) {
            UIImageView *imageView = [UIImageView new];
            imageView.image = [UIImage imageNamed:@"10.JPG"]; // 获取资源
            heights = ((SCREEN_WIDTH/num_line)*9)/16.0;
            float width = (heights *16)/9.0;
            imageView.frame = CGRectMake(width*j + 5*j, 0 ,width, heights);
            [view addSubview:imageView];
        }
        NSString *str = [NSString stringWithFormat:@"%f",heights];
        [arr addObject:str];
        if (i == 0) {
            height = 0;
        }
        if (i > 0) {
         height =  [arr[i] floatValue] + [arr[i - 1] floatValue];
        }
        view.frame = CGRectMake(0, height+5*i, SCREEN_WIDTH, heights);
    }
}
- (void)click:(UIButton *)button{
    self.block(@"");
}
- (void)drawRect:(CGRect)rect {

}
@end
