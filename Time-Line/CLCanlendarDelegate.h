//
//  CLCanlendarDelegate.h
//  Time-Line
//
//  Created by connor on 14-3-26.
//  Copyright (c) 2014年 connor. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CLDay.h"
#import "CLEvent.h"
#import "AnyEvent.h"

@class CLCalendarView;

@protocol CLCalendarDataSource <NSObject>

- (NSArray*)dateSourceWithCalendarView:(CLCalendarView *)calendarView;

@end

@protocol CLCalendarDelegate <NSObject>

- (void)calendarDidToMonth:(int)month year:(int)year CalendarView:(CLCalendarView *)calendarView;

- (void)calendarSelectEvent:(CLCalendarView *)calendarView day:(CLDay*)day event:(AnyEvent*)event AllEvent:(NSArray*)events;

-(void)calendartitle:(NSString*)title;

@end




