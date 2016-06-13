//
//  changeImfor_Model.m
//  hello
//
//  Created by MacFor_Eric_Liu on 15/11/26.
//  Copyright © 2015年 Eric_Liu. All rights reserved.
//

#import "changeImfor_Model.h"

@implementation changeImfor_Model
+ (NSArray *)changeImforWithDictArray:(NSArray *)dicts
{
    NSMutableArray *temp = [@[] mutableCopy];
    for (NSDictionary *dict in dicts) {
        changeImfor_Model *changeImfor = [self changeImforWithDict:dict];
        [temp addObject:changeImfor];
    }
    return [temp copy];
}

+ (instancetype)changeImforWithDict:(NSDictionary *)dict
{
    changeImfor_Model *changeImfor = [[changeImfor_Model alloc] init];
    changeImfor.zrxs_Str = dict[@"zszr"];
    changeImfor.ggrq_Int = [dict[@"ggrq"] integerValue];
    changeImfor.bdrq_Int = [dict[@"bdrq"] integerValue];
    return changeImfor;
}
@end
