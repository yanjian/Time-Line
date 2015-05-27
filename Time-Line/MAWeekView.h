//
//  MAWeekView.h
//  Go2
//
//  Created by connor on 14-4-9.
//  Copyright (c) 2014年 connor. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MAGridView;
@class MAHourView;
@class MAWeekdayBarView;
@class MAAllDayEventView;
@class MAEvent;

@protocol MAWeekViewDataSource, MAWeekViewDelegate;

@interface MAWeekView : UIView {
	UIImageView *_topBackground;
	UIButton *_leftArrow, *_rightArrow;
	UILabel *_dateLabel;
	
	MAAllDayEventView *_allDayEventView;
	UIScrollView *_scrollView;
	MAGridView *_gridView;
	MAHourView *_hourView;
	MAWeekdayBarView *_weekdayBarView;
	
	unsigned int _labelFontSize;
	UIFont *_regularFont;
	UIFont *_boldFont;
	
	NSDate *_week;
	
	UISwipeGestureRecognizer *_swipeLeftRecognizer, *_swipeRightRecognizer;
	
	id<MAWeekViewDataSource> _dataSource;
	id<MAWeekViewDelegate> __unsafe_unretained _delegate;
}

@property (readwrite,assign) BOOL eventDraggingEnabled;
@property (readwrite,assign) unsigned int labelFontSize;
@property (nonatomic,copy) NSDate *week;
@property (nonatomic,unsafe_unretained) IBOutlet id<MAWeekViewDataSource> dataSource;
@property (nonatomic,unsafe_unretained) IBOutlet id<MAWeekViewDelegate> delegate;

- (void)reloadData;

@end

@protocol MAWeekViewDataSource <NSObject>

- (NSArray *)weekView:(MAWeekView *)weekView eventsForDate:(NSDate *)date;

@end

@protocol MAWeekViewDelegate <NSObject>

@optional
- (void)weekView:(MAWeekView *)weekView eventTapped:(MAEvent *)event;
- (void)weekView:(MAWeekView *)weekView weekDidChange:(NSDate *)week;
- (void)weekView:(MAWeekView *)weekView eventDragged:(MAEvent *)event;
- (BOOL)weekView:(MAWeekView *)weekView eventDraggingEnabled:(MAEvent *)event;

@end