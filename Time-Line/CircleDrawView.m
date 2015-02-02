//
//  CircleDrawView.m
//  Time-Line
//
//  Created by IF on 14/10/28.
//  Copyright (c) 2014年 zhilifang. All rights reserved.
//
#define PI 3.14159265358979323846
#import "CircleDrawView.h"
#import "UIColor+HexString.h"

@implementation CircleDrawView

- (id)initWithFrame:(CGRect)frame {
	self = [super initWithFrame:frame];
	if (self) {
		[self setBackgroundColor:[UIColor clearColor]];
	}
	return self;
}

// 覆盖drawRect方法，你可以在此自定义绘画和动画
- (void)drawRect:(CGRect)rect {
	//An opaque type that represents a Quartz 2D drawing environment.
	//一个不透明类型的Quartz 2D绘画环境,相当于一个画布,你可以在上面任意绘画
	CGContextRef context = UIGraphicsGetCurrentContext();
	if (!self.hexString) {
		self.hexString = @"#000000";
	}
	if (!self.cirSize) {
		self.cirSize = 10;
	}
	CGContextSetFillColor(context, CGColorGetComponents([[UIColor colorWithHexString:self.hexString] CGColor]));
	//填充圆，无边框
	CGContextFillEllipseInRect(context, CGRectMake(self.frame.size.width / 2, self.frame.size.height / 2 - 5, self.cirSize, self.cirSize));
}

@end
