//
//  CLCalendarView.h
//  Time-Line
//
//  Created by connor on 14-3-25.
//  Copyright (c) 2014年 connor. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CLCanlendarDelegate.h"
#import "CLCalendarCell.h"
#import "CLEvent.h"
#import "CalendarCell.h"
typedef enum {
    CLCalendarViewModeMonth = 0,
    CLCalendarViewModeWeek = 1,
} CLCalendarDisplayMode;


@interface CLCalendarView : UIView <UITableViewDataSource, UITableViewDelegate, CLCalendarCellDelegate,CalendarCellDelegate>

@property (nonatomic, assign) CLCalendarDisplayMode displayMode;

@property (nonatomic, assign) id<CLCalendarDelegate> delegate;

@property (nonatomic, assign)  id<CLCalendarDataSource> dataSuorce;

@property (retain,nonatomic) NSString* time;
- (id)initByMode:(CLCalendarDisplayMode)mode;

- (void)setToDayRow:(int)row Index:(int)index;

- (void)goBackToday;



@end





