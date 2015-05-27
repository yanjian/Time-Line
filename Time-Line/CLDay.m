//
//  CLDay.m
//  Go2
//
//  Created by connor on 14-3-25.
//  Copyright (c) 2014年 connor. All rights reserved.
//

#import "CLDay.h"


@implementation CLDay

- (id)init {
	return [self initWithDate:[NSDate date]];
}

- (id)initWithDate:(NSDate *)date {
	self = [super init];
	if (self) {
		self.events = [[NSMutableArray alloc] init];
		_day = [CalendarDateUtil getDayWithDate:date];
		_month = [CalendarDateUtil getMonthWithDate:date];
		_year = [CalendarDateUtil getYearWithDate:date];
		_week = [CalendarDateUtil getWeekDayWithDate:date];
		if (_year == [CalendarDateUtil getCurrentYear] && _day == [CalendarDateUtil getCurrentDay] && _month == [CalendarDateUtil getCurrentMonth]) {
			_isToday = YES;
		}
	}
	return self;
}

- (void)addEvent:(id)event {
	if (event) {
		[self.events addObject:event];
	}
}

- (BOOL)removeEventByIndex:(int)index {
	return NO;
}

//日周月全写
- (NSString *)weekDayMotch {
	return [NSString stringWithFormat:@"%@, %lu %@", [self weekStringWithInteger:_week], (unsigned long)_day, [self monthStringWithInteger:_month]];
}

- (NSString *)description {
	return [NSString stringWithFormat:@"%i年 %i月%i日", _year, _month, _day];
}

- (NSString *)abbreviationWeekDayMotch {
	return [NSString stringWithFormat:@"%@, %@ %lu", [self abbreviationWeekStringWithInteger:_week], [self abbreviationMonthStringWithInteger:_month], (unsigned long)_day];
}

//英文形式的星期几全写
- (NSString *)weekDayFulfillEn {
	return [self weekStringWithInteger:_week];
}

//英文形式的月
- (NSString *)monthFulfillEn {
	return [self monthStringWithInteger:_month];
}

//简写周几
- (NSString *)abbreviationWeekDay {
	return [self abbreviationWeekStringWithInteger:_week];
}

- (NSString *)weekStringWithInteger:(NSUInteger)weekday {
	NSString *weakStr;
	switch (weekday - 1) {
		case 0:
			weakStr = @"Sunday";
			break;

		case 1:
			weakStr = @"Monday";
			break;

		case 2:
			weakStr = @"Tuesday";
			break;

		case 3:
			weakStr = @"Wednesday";
			break;

		case 4:
			weakStr = @"Thursday";
			break;

		case 5:
			weakStr = @"Friday";
			break;

		case 6:
			weakStr = @"Saturday";
			break;

		default:
			break;
	}
	return weakStr;
}

- (NSString *)abbreviationWeekStringWithInteger:(NSUInteger)weekday {
	NSString *weakStr;
	switch (weekday - 1) {
		case 0:
			weakStr = @"Sun";
			break;

		case 1:
			weakStr = @"Mon";
			break;

		case 2:
			weakStr = @"Tue";
			break;

		case 3:
			weakStr = @"Wed";
			break;

		case 4:
			weakStr = @"Thu";
			break;

		case 5:
			weakStr = @"Fri";
			break;

		case 6:
			weakStr = @"Sat";
			break;

		default:
			break;
	}
	return weakStr;
}

- (NSString *)abbreviationMonthStringWithInteger:(NSUInteger)month {
	NSString *title;
	switch (month) {
		case 1:
			title = @"Jan";
			break;

		case 2:
			title = @"Feb";
			break;

		case 3:
			title = @"Mar";
			break;

		case 4:
			title = @"Apr";
			break;

		case 5:
			title = @"May";
			break;

		case 6:
			title = @"Jun";
			break;

		case 7:
			title = @"Jul";
			break;

		case 8:
			title = @"Aug";
			break;

		case 9:
			title = @"Sep";
			break;

		case 10:
			title = @"Oct";
			break;

		case 11:
			title = @"Nov";
			break;

		case 12:
			title = @"Dec";
			break;

		default:
			break;
	}
	return title;
}

- (NSString *)monthStringWithInteger:(NSUInteger)month {
	NSString *title;
	switch (month) {
		case 1:
			title = @"January";
			break;

		case 2:
			title = @"February";
			break;

		case 3:
			title = @"March";
			break;

		case 4:
			title = @"April";
			break;

		case 5:
			title = @"May";
			break;

		case 6:
			title = @"June";
			break;

		case 7:
			title = @"July";
			break;

		case 8:
			title = @"August";
			break;

		case 9:
			title = @"September";
			break;

		case 10:
			title = @"October";
			break;

		case 11:
			title = @"November";
			break;

		case 12:
			title = @"December";
			break;

		default:
			break;
	}
	return title;
}

@end
