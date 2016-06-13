//
//  changeImfor_Model.h
//  hello
//
//  Created by MacFor_Eric_Liu on 15/11/26.
//  Copyright © 2015年 Eric_Liu. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface changeImfor_Model : NSObject

@property (nonatomic, copy) NSString *zrxs_Str;
@property (nonatomic, assign) NSInteger ggrq_Int;
@property (nonatomic, assign) NSInteger bdrq_Int;

+ (instancetype)changeImforWithDict:(NSDictionary *)dict;
+ (NSArray *)changeImforWithDictArray:(NSArray *)dicts;

@end
