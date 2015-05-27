//
//  CLDay.h
//  Go2
//
//  Created by connor on 14-3-25.
//  Copyright (c) 2014年 connor. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CalendarDateUtil.h"

@interface CLDay : NSObject

@property (nonatomic, strong) NSMutableArray *events;

@property (nonatomic, readonly) BOOL isToday;
@property (nonatomic, assign)    BOOL isExistData;
@property (nonatomic, readonly) NSUInteger day;
@property (nonatomic, readonly) NSUInteger month;
@property (nonatomic, readonly) NSUInteger year;
@property (nonatomic, readonly) NSUInteger week;
@property (nonatomic, assign) BOOL isSelectDay;


- (id)initWithDate:(NSDate *)date;

- (void)addEvent:(id)event;

- (BOOL)removeEventByIndex:(int)index;

- (NSString *)weekDayMotch;
- (NSString *)monthFulfillEn;
- (NSString *)weekDayFulfillEn;
- (NSString *)abbreviationWeekDay;
- (NSString *)abbreviationWeekDayMotch;
@end
