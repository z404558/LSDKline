//
//  PicViews.h
//  MuitChart
//
//  Created by MacFor_Eric_Liu on 16/4/14.
//  Copyright © 2016年 Eric_Liu. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^clickImage)(NSString *str );

@interface PicViews : UIView

- (void)setImageView:(NSDictionary *)dict;

@property(nonatomic,copy)clickImage block;

@end
