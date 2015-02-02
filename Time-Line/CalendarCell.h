//
//  CalendarCell.h
//  Time-Line
//
//  Created by zhoulei on 14-5-3.
//  Copyright (c) 2014年 connor. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CLDay.h"
@class CalendarCell;
@protocol CalendarCellDelegate <NSObject>

- (void)selectDates:(CalendarCell *)cell weekDay:(NSInteger)index;

- (int)getShowMonths;

- (int)getShowSelectDays:(CalendarCell *)cell;
@end

@interface CalendarCell : UITableViewCell {
	NSMutableArray *_btnArray;
	NSMutableArray *_bgArray;
	NSMutableArray *_pointArray;
}


@property (nonatomic, weak) id <CalendarCellDelegate> detelegate;
@property (nonatomic, strong) NSArray *weekArr;
@property (nonatomic, copy) NSString *time;
@property (nonatomic, strong) UIImageView *pointImage;
@property (nonatomic, retain) UIImageView *imageview;
@property (nonatomic, strong) NSArray *AllWeekArr;

@end
