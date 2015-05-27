//
//  MADayView.h
//  Go2
//
//  Created by connor on 14-4-9.
//  Copyright (c) 2014年 connor. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MA_AllDayGridView;
@class MADayHourView;
@class MADayGridView;
@class MAEvent;
@class TimeMoveView;
@class DayTimeScrollView ;
@protocol MADayViewDataSource, MADayViewDelegate;

@interface MADayView : UIView {
	UIImageView *_topBackground;
	UIButton *_leftArrow, *_rightArrow;
	UILabel *_dateLabel;
	
    TimeMoveView * _moveToView; //已经添加
    
	DayTimeScrollView *_scrollView;
	MA_AllDayGridView *_allDayGridView;
	MADayHourView *_hourView;
	MADayGridView *_gridView;	
	
	BOOL _autoScrollToFirstEvent;
	unsigned int _labelFontSize;
	UIFont *_regularFont;
	UIFont *_boldFont;
	
	NSDate *_day;
	
	UISwipeGestureRecognizer *_swipeLeftRecognizer, *_swipeRightRecognizer;
	
	id<MADayViewDataSource> __unsafe_unretained _dataSource;
	id<MADayViewDelegate> __unsafe_unretained _delegate;
}

@property (nonatomic,assign) BOOL autoScrollToFirstEvent;
@property (readwrite,assign) unsigned int labelFontSize;
@property (nonatomic,copy) NSDate *day;
@property (nonatomic,unsafe_unretained) IBOutlet id<MADayViewDataSource> dataSource;
@property (nonatomic,unsafe_unretained) IBOutlet id<MADayViewDelegate> delegate;

- (void)reloadData;
- (void)limitDaysToFirstDate:(NSDate *)firstDate lastDate:(NSDate*)lastDate;

@end

@protocol MADayViewDataSource <NSObject>

- (NSArray *)dayView:(MADayView *)dayView eventsForDate:(NSDate *)date;

@end

@protocol MADayViewDelegate <NSObject>

@optional
- (void)dayView:(MADayView *)dayView eventTapped:(MAEvent *)event;

@end
