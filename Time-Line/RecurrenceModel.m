//
//  RecurrenceModel.m
//  Go2
//
//  Created by IF on 14/11/14.
//  Copyright (c) 2014年 zhilifang. All rights reserved.
//

#import "RecurrenceModel.h"
#import "CalendarDateUtil.h"

@interface RecurrenceModel ()
{
	NSArray *weekArr;
	NSString *recStr;
}


@end

@implementation RecurrenceModel

- (instancetype)initRecrrenceModel:(NSString *)recString {
	self = [super init];
	if (self) {
		recStr = recString;
		self.interval = 1;//默认为1
		weekArr = [NSArray arrayWithObjects:@"SU", @"MO", @"TU", @"WE", @"TH", @"FR", @"SA", nil];
		if (recString) {
			NSRange tmpRange = [recString rangeOfString:@":"];
			if (tmpRange.location != NSNotFound) {
				NSString *str = [recString substringFromIndex:tmpRange.location + 1];
				NSArray *recurArr = [str componentsSeparatedByString:@";"];
				if (recurArr) {
					for (NSString *unObj in recurArr) {
						if ([unObj hasPrefix:@"FREQ"]) {
							NSArray *freqArr = [unObj componentsSeparatedByString:@"="];
							NSString *freqStr = freqArr[1];
							NSString *firstStr = [[freqStr substringToIndex:1] capitalizedString];
							NSString *lastStr = [[freqStr substringFromIndex:1] lowercaseString];
							NSString *capStr = [NSString stringWithFormat:@"%@%@", firstStr, lastStr];
							self.freq = capStr;
						}
						else if ([unObj hasPrefix:@"INTERVAL"]) {
							NSArray *intervalArr = [unObj componentsSeparatedByString:@"="];
							self.interval = [intervalArr[1] integerValue];
						}
						else if ([unObj hasPrefix:@"COUNT"]) {
							NSArray *countArr = [unObj componentsSeparatedByString:@"="];
							self.count = [countArr[1] integerValue];
						}
						else if ([unObj hasPrefix:@"UNTIL"]) {
							NSArray *untilArr = [unObj componentsSeparatedByString:@"="];
							self.until = untilArr[1];
						}
						else if ([unObj hasPrefix:@"BYDAY"]) {
							NSArray *byDayArr = [unObj componentsSeparatedByString:@"="];
							self.byDay = byDayArr[1];
						}
					}
				}
			}
		}
	}
	return self;
}

//该方法返回的是如：0,1,2,3类型的数据
- (NSString *)stringWithIntFromWeek {
	NSMutableArray *wArr = [NSMutableArray array];
	if (self.byDay) {
		NSArray *tmpArr = [self.byDay componentsSeparatedByString:@","];
		for (NSString *week in tmpArr) {
			NSUInteger uInt = [weekArr indexOfObject:week];
			[wArr addObject:@(uInt)];
		}
	}
	return [wArr componentsJoinedByString:@","];
}

- (NSString *)showIntervalWithRepat {
	NSString *inter = nil;

	if ([self.freq isEqualToString:@"Weekly"]) {
		if (self.interval > 1) {
			inter = [NSString stringWithFormat:@"%i weeks", self.interval];
		}
		else {
			inter = [NSString stringWithFormat:@"%i week", self.interval];
		}
	}
	else if ([self.freq isEqualToString:@"Daily"]) {
		if (self.interval > 1) {
			inter = [NSString stringWithFormat:@"%i days", self.interval];
		}
		else {
			inter = [NSString stringWithFormat:@"%i day", self.interval];
		}
	}
	else if ([self.freq isEqualToString:@"Monthly"]) {
		if (self.interval > 1) {
			inter = [NSString stringWithFormat:@"%i months", self.interval];
		}
		else {
			inter = [NSString stringWithFormat:@"%i month", self.interval];
		}
	}
	else if ([self.freq isEqualToString:@"Yearly"]) {
		if (self.interval > 1) {
			inter = [NSString stringWithFormat:@"%i years", self.interval];
		}
		else {
			inter = [NSString stringWithFormat:@"%i year", self.interval];
		}
	}
	else if ([self.freq isEqualToString:@"None"]) {
		inter = nil;
	}
	else {
		inter = @"error";
	}
	return inter;
}

#pragma -该方法返回的是如：Sunday 或Sunday,Monday 或S,M,T类型的数据
- (NSString *)showWeekFromInt {
	NSString *onDaysValue = @"Default";
	NSArray *tmpArr = [[self stringWithIntFromWeek] componentsSeparatedByString:@","];
	if (tmpArr.count == 1) {
		NSInteger currWeekInt = [CalendarDateUtil getWeekDayWithDate:[NSDate new]] - 1;
		if (currWeekInt == [tmpArr[0] integerValue]) {
			onDaysValue = @"Default";
		}
		else {
			onDaysValue = [self repeatDateWithInteger:[tmpArr[0] integerValue]];
		}
	}
	else if (tmpArr.count == 2) {
		NSMutableArray *mutArr = [NSMutableArray array];
		for (int i = 0; i < tmpArr.count; i++) {
			[mutArr addObject:[self repeatDateWithInteger:[tmpArr[i] integerValue]]];
		}
		onDaysValue = [mutArr componentsJoinedByString:@","];
	}
	else {
		NSMutableArray *mutArr = [NSMutableArray array];
		for (int i = 0; i < tmpArr.count; i++) {
			[mutArr addObject:[self abbRepeatDateWithInteger:[tmpArr[i] integerValue]]];
		}
		onDaysValue = [mutArr componentsJoinedByString:@","];
	}
	return onDaysValue;
}

- (NSString *)showUtil {
	if (self.until) {
		NSDateFormatter *df = [[NSDateFormatter alloc] init];
		[df setDateFormat:@"yyyyMMdd"];
		NSDate *untilDate = [df dateFromString:self.until];
		CLDay *clDay = [[CLDay alloc] initWithDate:untilDate];
		return [clDay abbreviationWeekDayMotch];
	}
	return @"Forever";
}

- (CLDay *)showUtilClday {
	if (self.until) {
		NSDateFormatter *df = [[NSDateFormatter alloc] init];
		[df setDateFormat:@"yyyyMMdd"];
		NSDate *untilDate = [df dateFromString:self.until];
		CLDay *clDay = [[CLDay alloc] initWithDate:untilDate];
		return clDay;
	}
	return nil;
}

- (NSString *)description {
	NSMutableArray *tmpArr = [NSMutableArray array];
	if (self.freq) {
		[tmpArr addObject:[NSString stringWithFormat:@"RRULE:FREQ=%@", [self.freq uppercaseString]]];
	}
	if (self.interval) {
		[tmpArr addObject:[NSString stringWithFormat:@"INTERVAL=%i", self.interval]];
	}
	if (self.count) {
		[tmpArr addObject:[NSString stringWithFormat:@"COUNT=%i", self.count]];
	}
	if (self.byDay) {
		[tmpArr addObject:[NSString stringWithFormat:@"BYDAY=%@", [self.byDay uppercaseString]]];
	}
	if (self.until) {
		[tmpArr addObject:[NSString stringWithFormat:@"UNTIL=%@", self.until]];
	}
	return [tmpArr componentsJoinedByString:@";"];
}

- (NSString *)repeatDateWithInteger:(NSUInteger)dayCount {
	NSString *weakStr = @"";
	switch (dayCount) {
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

- (NSString *)abbRepeatDateWithInteger:(NSUInteger)dayCount {
	NSString *weakStr = @"";
	switch (dayCount) {
		case 0:
			weakStr = @"S";
			break;

		case 1:
			weakStr = @"M";
			break;

		case 2:
			weakStr = @"T";
			break;

		case 3:
			weakStr = @"W";
			break;

		case 4:
			weakStr = @"T";
			break;

		case 5:
			weakStr = @"F";
			break;

		case 6:
			weakStr = @"S";
			break;

		default:
			break;
	}
	return weakStr;
}

@end
