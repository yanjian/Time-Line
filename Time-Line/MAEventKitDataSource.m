//
//  MAEventKitDataSource.m
//  Go2
//
//  Created by connor on 14-4-23.
//  Copyright (c) 2014年 connor. All rights reserved.
//

#import "MAEventKitDataSource.h"

#import "MAEvent.h"
#import <EventKit/EventKit.h>

#define CURRENT_CALENDAR [NSCalendar currentCalendar]

@interface MAEventKitDataSource(PrivateMethods)

- (NSDate *)nextDayForDate:(NSDate *)date;
- (NSArray *)eventKitEventsForDate:(NSDate *)date;
- (NSArray *)eventKitEventsToMAEvents:(NSArray *)eventKitEvents;

@property (readonly) EKEventStore *eventStore;

@end

@implementation MAEventKitDataSource

/*
 * =======================================
 * MADayViewDataSource
 * =======================================
 */

- (NSArray *)dayView:(MADayView *)dayView eventsForDate:(NSDate *)date
{
    return [self eventKitEventsToMAEvents:[self eventKitEventsForDate:date]];
}

/*
 * =======================================
 * MAWeekViewDataSource
 * =======================================
 */

- (NSArray *)weekView:(MAWeekView *)weekView eventsForDate:(NSDate *)date
{
    return [self eventKitEventsToMAEvents:[self eventKitEventsForDate:date]];
}

/*
 * =======================================
 * Properties
 * =======================================
 */

- (EKEventStore *)eventStore
{
    if (!_eventStore) {
        _eventStore = [[EKEventStore alloc] init];
    }
    return _eventStore;
}

/*
 * =======================================
 * Private
 * =======================================
 */

- (NSDate *)nextDayForDate:(NSDate *)date
{
    NSDateComponents *components = [[NSDateComponents alloc] init];
    [components setDay:1];
    
    return [CURRENT_CALENDAR dateByAddingComponents:components toDate:date options:0];
}

- (NSArray *)eventKitEventsForDate:(NSDate *)startDate
{
    NSPredicate *predicate = [self.eventStore predicateForEventsWithStartDate:startDate
                                                                      endDate:[self nextDayForDate:startDate]
                                                                    calendars:nil];
    
    NSArray *events = [self.eventStore eventsMatchingPredicate:predicate];
    return events;
}

- (NSArray *)eventKitEventsToMAEvents:(NSArray *)eventKitEvents
{
    NSMutableArray *events = [[NSMutableArray alloc] init];
    for (EKEvent *event in eventKitEvents) {
        MAEvent *maEvent = [[MAEvent alloc] init];
        maEvent.title  = event.title;
        maEvent.start  = event.startDate;
        maEvent.end    = event.endDate;
        maEvent.allDay = event.allDay;
        
        maEvent.backgroundColor = [UIColor colorWithCGColor:event.calendar.CGColor];
        maEvent.textColor       = [UIColor whiteColor];
        
        [events addObject:maEvent];
    }
    return events;
}

@end