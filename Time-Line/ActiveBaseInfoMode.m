//
//  ActiveBaseInfoMode.m
//  Go2
//
//  Created by IF on 15/1/22.
//  Copyright (c) 2015年 zhilifang. All rights reserved.
//

#import "ActiveBaseInfoMode.h"

@implementation ActiveBaseInfoMode


- (void)setImgUrl:(NSString *)imgUrl {
	if (imgUrl) {
		_imgUrl = [imgUrl stringByReplacingOccurrencesOfString:@"\\" withString:@"/"];
	}
}

@end
