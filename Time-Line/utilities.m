//
//  utilities.m
//  Time-Line
//
//  Created by IF on 14/12/3.
//  Copyright (c) 2014年 zhilifang. All rights reserved.
//
#import "utilities.h"
UIImage* ResizeImage(UIImage *image, CGFloat width, CGFloat height)

{
	CGSize size = CGSizeMake(width, height);
	UIGraphicsBeginImageContextWithOptions(size, NO, 0);
	[image drawInRect:CGRectMake(0, 0, size.width, size.height)];
	image = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();
	return image;
}

void PostNotification(NSString *notification)
{
	[[NSNotificationCenter defaultCenter] postNotificationName:notification object:nil];
}
