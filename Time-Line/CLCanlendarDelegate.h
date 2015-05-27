//
//  CLCanlendarDelegate.h
//  Go2
//
//  Created by connor on 14-3-26.
//  Copyright (c) 2014年 connor. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CLDay.h"

typedef NS_ENUM(NSInteger, EventType) {
    EventType_eventActive=1,
    EventType_eventSigple = 2
    
};

@class CLCalendarView;

@protocol CLCalendarDataSource <NSObject>

- (NSArray *)dateSourceWithCalendarView:(CLCalendarView *)calendarView;

@end

@protocol CLCalendarDelegate <NSObject>

@optional
- (void)calendarDidToMonth:(int)month year:(int)year CalendarView:(CLCalendarView *)calendarView;

- (void)calendarSelectEvent:(CLCalendarView *)calendarView eventType:(EventType)eventType day:(CLDay *)day event:(id)event AllEvent:(NSArray *)events;

- (void)calendartitle:(NSString *)title;

@end
