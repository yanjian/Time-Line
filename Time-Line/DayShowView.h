//
//  DayShowView.h
//  Time-Line
//
//  Created by IF on 14/11/5.
//  Copyright (c) 2014年 zhilifang. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DayShowView : UIView {
	UILabel *calStartLable;
	UILabel *calEndLable;
	UILabel *timeStartLable;
	UILabel *timeEndLable;
	UILabel *flagLable;
}

@property (nonatomic, assign) BOOL isAllDay;
@property (nonatomic, copy) NSString *startDay;
@property (nonatomic, copy) NSString *endDay;

@end
