//
//  BaseMode.m
//  Time-Line
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

@end
