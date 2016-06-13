//
//  changeImfor_Model.h
//  hello
//
//  Created by MacFor_Eric_Liu on 15/11/26.
//  Copyright © 2015年 Eric_Liu. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface KWPerson : NSObject
@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *sex;
@property (nonatomic, assign) NSInteger age;
+ (instancetype)personWithDict:(NSDictionary *)dict;
+ (NSArray *)personsWithDictArray:(NSArray *)dicts;
@end
