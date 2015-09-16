//
//  BaseMode.h
//  Go2
//
//  Created by IF on 14-9-29.
//  Copyright (c) 2014年 zhilifang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <objc/runtime.h>
@interface BaseMode : NSObject
//源数据为字典，执行set方法
- (void)parseDictionary:(NSDictionary *)dicData;

- (instancetype)initWithDictionary: (NSDictionary *) data;
+ (instancetype)modelWithDictionary: (NSDictionary *) data;

#pragma 返回属性和字典key的映射关系
-(NSDictionary *) propertyMapDic;
@end
