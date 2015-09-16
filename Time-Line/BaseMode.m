//
//  BaseMode.m
//  Go2
//
//  Created by IF on 14-9-29.
//  Copyright (c) 2014年 zhilifang. All rights reserved.
//

#import "BaseMode.h"

@implementation BaseMode

- (void)parseDictionary:(NSDictionary *)dicData {
	NSArray *keys = [dicData allKeys];
	for (NSString *parmeValue in keys) {
		//首字母大写
		NSString *firstStr = [[parmeValue substringToIndex:1] capitalizedString];
		NSString *lastStr = [parmeValue substringFromIndex:1];
		NSString *capStr = [NSString stringWithFormat:@"%@%@", firstStr, lastStr];

		//是否存在此属性
		NSString *selectString = [NSString stringWithFormat:@"set%@:", capStr];
		SEL selector = NSSelectorFromString(selectString);
		if ([self respondsToSelector:selector]) {
			//执行set方法
			NSObject *dicValue = [dicData objectForKey:parmeValue];
			[self performSelector:selector withObject:dicValue];
		}
	}
}


- (instancetype)initWithDictionary: (NSDictionary *) data{
    {
        self = [super init];
        if (self) {
            if ([self propertyMapDic] == nil) {
                [self assginToPropertyWithDictionary:data];
            } else {
                [self assginToPropertyWithMapDictionary:data];
            }
        }
        return self;
    }
}



+ (instancetype)modelWithDictionary: (NSDictionary *) data{
    
    return [[self alloc] initWithDictionary:data];
    
}


#pragma 根据映射关系来给Model的属性赋值
-(void) assginToPropertyWithMapDictionary: (NSDictionary *) data{
    if (data == nil) {
        return;
    }
    ///获取字典和Model属性的映射关系
    NSDictionary *propertyMapDic = [self propertyMapDic];
    
    ///转化成key和property一样的字典，然后调用assginToPropertyWithDictionary方法
    NSArray *dicKey = [data allKeys];
    NSMutableDictionary *tempDic = [[NSMutableDictionary alloc] initWithCapacity:dicKey.count];
    for (int i = 0; i < dicKey.count; i ++) {
        NSString *key = dicKey[i];
        [tempDic setObject:data[key] forKey:propertyMapDic[key]];
    }
    
    [self assginToPropertyWithDictionary:tempDic];
}


#pragma mark -- 通过字符串来创建该字符串的Setter方法，并返回
- (SEL) creatSetterWithPropertyName: (NSString *) propertyName{
    //1.首字母大写
    NSString *firstStr = [[propertyName substringToIndex:1] capitalizedString];
    NSString *lastStr = [propertyName substringFromIndex:1];
    NSString *capStr = [NSString stringWithFormat:@"%@%@", firstStr, lastStr];
    
    //2.拼接上set关键字
    propertyName = [NSString stringWithFormat:@"set%@:", capStr];
    
    //3.返回set方法
    return NSSelectorFromString(propertyName);
}


-(void) assginToPropertyWithDictionary: (NSDictionary *) data{
    
    if (data == nil) {
        return;
    }
    ///1.获取字典的key
    NSArray *dicKey = [data allKeys];
    
    ///2.循环遍历字典key, 并且动态生成实体类的setter方法，把字典的Value通过setter方法
    ///赋值给实体类的属性
    for (int i = 0; i < dicKey.count; i ++) {
        
        // 通过getSetterSelWithAttibuteName 方法来获取实体类的set方法
        SEL setSel = [self creatSetterWithPropertyName:dicKey[i]];
        
        if ([self respondsToSelector:setSel]) {
            // 获取字典中key对应的value
            NSObject  *value =  data[dicKey[i]];
            
            // 把值通过setter方法赋值给实体类的属性
            [self performSelectorOnMainThread:setSel
                                   withObject:value
                                waitUntilDone:[NSThread isMainThread]];
        }
    }
}

///通过运行时获取当前对象的所有属性的名称，以数组的形式返回
- (NSArray *) allPropertyNames{
    ///存储所有的属性名称
    NSMutableArray *allNames = [[NSMutableArray alloc] init];
    
    ///存储属性的个数
    unsigned int propertyCount = 0;
    
    ///通过运行时获取当前类的属性
    objc_property_t *propertys = class_copyPropertyList([self class], &propertyCount);
    
    //把属性放到数组中
    for (int i = 0; i < propertyCount; i ++) {
        ///取出第一个属性
        objc_property_t property = propertys[i];
        
        const char * propertyName = property_getName(property);
        
        [allNames addObject:[NSString stringWithUTF8String:propertyName]];
    }
    ///释放
    free(propertys);
    
    return allNames;
}

#pragma 返回属性和字典key的映射关系
-(NSDictionary *) propertyMapDic{
    return nil;
}

@end
