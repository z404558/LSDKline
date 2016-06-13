//
//  changeImfor_Model.h
//  hello
//
//  Created by MacFor_Eric_Liu on 15/11/26.
//  Copyright © 2015年 Eric_Liu. All rights reserved.
//

#import "KWPerson.h"

@implementation KWPerson
+ (NSArray *)personsWithDictArray:(NSArray *)dicts
{
    NSMutableArray *temp = [@[] mutableCopy];
    for (NSDictionary *dict in dicts) {
        KWPerson *person = [self personWithDict:dict];
        [temp addObject:person];
    }
    return [temp copy];
}

+ (instancetype)personWithDict:(NSDictionary *)dict
{
    KWPerson *person = [[KWPerson alloc] init];
    person.name = dict[@"name"];
    person.sex = dict[@"sex"];
    person.age = [dict[@"age"] integerValue];
    return person;
}
@end
