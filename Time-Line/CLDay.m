//
//  CLDay.m
//  Time-Line
//
//  Created by connor on 14-3-25.
//  Copyright (c) 2014年 connor. All rights reserved.
//

#import "CLDay.h"

@implementation CLDay

- (id)init
{
   return [self initWithDate:[NSDate date]];
}

- (id)initWithDate:(NSDate*)date
{
    self = [super init];
    if (self) {
        _day = [CalendarDateUtil getDayWithDate:date];
        _month = [CalendarDateUtil getMonthWithDate:date];
        _year = [CalendarDateUtil getYearWithDate:date];
        
        if (_year == [CalendarDateUtil getCurrentYear] && _day == [CalendarDateUtil getCurrentDay] && _month == [CalendarDateUtil getCurrentMonth]) {
            _isToday = YES;
        }
        
    }
    return self;
}

- (BOOL)addEvent:(CLEvent*)event
{
    return NO;
}

- (BOOL)removeEventByIndex:(int)index
{
    return NO;
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"%i年 %i月%i日", _year, _month, _day];
}

@end
