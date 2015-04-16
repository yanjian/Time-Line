//
//  PublicMethodsViewController.m
//  Time-Line
//
//  Created by zhoulei on 14-4-19.
//  Copyright (c) 2014年 connor. All rights reserved.
//
#include <math.h>
#import "PublicMethodsViewController.h"
#import "CalendarDateUtil.h"

@interface PublicMethodsViewController ()

@end

@implementation PublicMethodsViewController

static PublicMethodsViewController *PublicMethods = nil;
+ (PublicMethodsViewController *)getPublicMethods {
	if (PublicMethods == nil) {
		PublicMethods = [[PublicMethodsViewController alloc]init];
	}
	return PublicMethods;
}

- (id)init {
	if (self) {
	}
	return self;
}

#pragma -根据指定格式得到当前时间字符串
- (NSString *)getcurrentTime:(NSString *)format {
	NSDate *dates = [NSDate date];
	NSDateFormatter *formatter =  [[NSDateFormatter alloc] init];
	[formatter setDateFormat:format];
	NSTimeZone *timeZone = [NSTimeZone timeZoneWithName:SYS_DEFAULT_TIMEZONE];
	[formatter setTimeZone:timeZone];
	NSString *loctime = [formatter stringFromDate:dates];
	NSLog(@"%@", loctime);
	return loctime;
}

- (NSString *)getcurrentTime:(NSString *)format interval:(NSInteger)interval {
	NSDate *dates = [NSDate date];
	dates = [dates dateByAddingTimeInterval:interval * 5 * 60];
	NSDateFormatter *formatter =  [[NSDateFormatter alloc] init];
	[formatter setDateFormat:format];
	NSTimeZone *timeZone = [NSTimeZone timeZoneWithName:SYS_DEFAULT_TIMEZONE];
	[formatter setTimeZone:timeZone];
	NSString *loctime = [formatter stringFromDate:dates];
	NSLog(@"%@", loctime);
	return loctime;
}

#pragma -将时间yyyyy年m月d日 hh:mm:sss--->格式化为指定的格式
- (NSString *)formaterStringfromDate:(NSString *)format dateString:(NSString *)dateString {
	NSDateFormatter *formatter =  [[NSDateFormatter alloc] init];
	[formatter setDateFormat:format];
	NSTimeZone *timeZone = [NSTimeZone timeZoneWithName:SYS_DEFAULT_TIMEZONE];
	[formatter setTimeZone:timeZone];
	NSDate *dateTime = [self formatWithStringDate:dateString];
	return [formatter stringFromDate:dateTime];
}

#pragma -格式化事件为string 将yyyy-MM-DD hh:mm---> yyyyy年m月d日 hh:mm
- (NSString *)stringFormaterDate:(NSString *)format dateString:(NSString *)dateString {
	NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
	[dateFormatter setLocale:[[NSLocale alloc]initWithLocaleIdentifier:@"en_US_POSIX"]];
	NSTimeZone *timeZone = [NSTimeZone timeZoneWithName:SYS_DEFAULT_TIMEZONE];
	[dateFormatter setTimeZone:timeZone];

	[dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:sss"];
	NSDate *dateTime = [NSDate new];
	[dateFormatter getObjectValue:&dateTime forString:dateString range:nil error:nil];
	[dateFormatter setDateFormat:format];
	return [dateFormatter stringFromDate:dateTime];
}

//时间格式化为rfc3339
- (NSString *)rfc3339DateFormatter:(NSDate *)date {
	NSDateFormatter *rfc3339DateFormatter = [[NSDateFormatter alloc] init];
	NSLocale *enUSPOSIXLocale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"];

	[rfc3339DateFormatter setLocale:enUSPOSIXLocale];
	[rfc3339DateFormatter setDateFormat:@"yyyy'-'MM'-'dd'T'HH':'mm':'ss.SSS'Z'"];
	NSTimeZone *timeZone = [NSTimeZone timeZoneWithName:SYS_DEFAULT_TIMEZONE];
	[rfc3339DateFormatter setTimeZone:timeZone];

	return [rfc3339DateFormatter stringFromDate:date];
}

- (NSString *)formatStringWithStringDate:(NSString *)dateString {
	NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
	[dateFormatter setLocale:[[NSLocale alloc]initWithLocaleIdentifier:@"en_US_POSIX"]];
	NSTimeZone *timeZone = [NSTimeZone timeZoneWithName:SYS_DEFAULT_TIMEZONE];
	[dateFormatter setTimeZone:timeZone];

	[dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ssZ"];
	NSDate *dateTime = nil;
	[dateFormatter getObjectValue:&dateTime forString:dateString range:nil error:nil];
	[dateFormatter setDateFormat:@"YYYY年 M月d日HH:mm"];
	return [dateFormatter stringFromDate:dateTime];
}

- (NSString *)rfc3339StringWithStringDate:(NSString *)dateString {
	NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
	[dateFormatter setLocale:[[NSLocale alloc]initWithLocaleIdentifier:@"en_US_POSIX"]];
	NSTimeZone *timeZone = [NSTimeZone timeZoneWithName:SYS_DEFAULT_TIMEZONE];
	[dateFormatter setTimeZone:timeZone];

	[dateFormatter setDateFormat:@"yyyyMMdd"];
	NSDate *dateTime = nil;
	[dateFormatter getObjectValue:&dateTime forString:dateString range:nil error:nil];
	[dateFormatter setDateFormat:@"YYYY年 M月d日"];
	return [dateFormatter stringFromDate:dateTime];
}

- (NSString *)dateWithStringDate:(NSString *)dateString {
	NSDate *dateTime = [self formatWithStringDate:dateString];
	NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
	[dateFormatter setLocale:[[NSLocale alloc]initWithLocaleIdentifier:@"en_US_POSIX"]];
	[dateFormatter setTimeZone:[NSTimeZone defaultTimeZone]];
	[dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ssZ"];
	return [dateFormatter stringFromDate:dateTime];
}

- (NSString *)getonehourstime:(NSString *)format {
	NSDateFormatter *formatter =  [[NSDateFormatter alloc] init];
	[formatter setDateFormat:format];
	NSTimeZone *timeZone = [NSTimeZone timeZoneWithName:SYS_DEFAULT_TIMEZONE];
	[formatter setTimeZone:timeZone];
	NSString *timeSp = [NSString stringWithFormat:@"%ld", (long)[[NSDate date] timeIntervalSince1970]];
	NSInteger timer = [timeSp integerValue];
	timer = timer + 60 * 60;
	NSDate *confromTimesp = [NSDate dateWithTimeIntervalSince1970:timer];
	NSString *confromTimespStr = [formatter stringFromDate:confromTimesp];
	return confromTimespStr;
}

- (NSDate *)formatWithStringDate:(NSString *)stringDate {
	NSRange range = [stringDate rangeOfString:@"日"];
	NSDateFormatter *tempFormatter = [[NSDateFormatter alloc]init];
	[tempFormatter setTimeZone:[NSTimeZone defaultTimeZone]];
	NSString *strs = [stringDate substringWithRange:NSMakeRange(range.location + 1, stringDate.length - range.location - 1)];
	if (strs.length <= 0) {
		[tempFormatter setDateFormat:@"YYYY年 M月d日"];
	}
	else {
		[tempFormatter setDateFormat:@"YYYY年 M月d日HH:mm"];
	}
	return [tempFormatter dateFromString:stringDate];
}

- (NSString *)stringformatWithDate:(NSDate *)date {
	NSDateFormatter *tempFormatter = [[NSDateFormatter alloc]init];
	[tempFormatter setTimeZone:[NSTimeZone defaultTimeZone]];
	[tempFormatter setDateFormat:@"YYYY年 M月d日HH:mm"];
	NSLog(@"%@", [tempFormatter stringFromDate:date]);
	return [tempFormatter stringFromDate:date];
}

- (NSString *)formatStringWithString:(NSString *)stringDate {
	NSRange range = [stringDate rangeOfString:@"日"];
	NSString *strs = [stringDate substringWithRange:NSMakeRange(range.location + 1, stringDate.length - range.location - 1)];
	NSString *dateStr = nil;
	if (strs.length > 0) {
		dateStr = [stringDate substringWithRange:NSMakeRange(0, range.location + 1)];
	}
	else {
		dateStr = stringDate;
	}
	return dateStr;
}

- (NSMutableArray *)intervalSinceNow:(NSString *)theDate getStrart:(NSString *)startdate {
	NSMutableArray *seledayArr = [[NSMutableArray alloc]initWithCapacity:0];
	NSDateFormatter *date = [[NSDateFormatter alloc] init];
	[date setTimeZone:[NSTimeZone defaultTimeZone]];
	[date setDateFormat:@"YYYY年 M月dd日"];
	NSDate *d = [date dateFromString:theDate];

	NSTimeInterval late = [d timeIntervalSince1970] * 1;


	NSDate *dat = [date dateFromString:startdate];
	NSTimeInterval now = [dat timeIntervalSince1970] * 1;
	NSString *timeString = @"";

	NSTimeInterval cha = late - now;

	if (cha / 3600 < 1) {
		timeString = [NSString stringWithFormat:@"%f", cha / 60];
		timeString = [timeString substringToIndex:timeString.length - 7];
		timeString = [NSString stringWithFormat:@"%@分钟", timeString];
	}
	if (cha / 3600 > 1 && cha / 86400 < 1) {
		timeString = [NSString stringWithFormat:@"%f", cha / 3600];
		timeString = [timeString substringToIndex:timeString.length - 7];
		timeString = [NSString stringWithFormat:@"%@小时", timeString];
	}
	if (cha / 86400 > 1) {
		timeString = [NSString stringWithFormat:@"%f", cha / 86400];
		timeString = [timeString substringToIndex:timeString.length - 7];
		timeString = [NSString stringWithFormat:@"%@天", timeString];
	}
	if (timeString.length <= 0) {
		timeString = @"1天";
	}
	else if ([[timeString substringFromIndex:timeString.length - 1] isEqualToString:@"钟"]) {
		timeString = @"0天";
	}
	if (timeString.length > 0 && [[timeString substringFromIndex:timeString.length - 1] isEqualToString:@"天"]) {
		NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
		[formatter setDateStyle:NSDateFormatterMediumStyle];
		[formatter setTimeStyle:NSDateFormatterShortStyle];
		[formatter setDateFormat:@"YYYY年 M月d日"];
		NSInteger dd = [[timeString substringToIndex:timeString.length - 1] integerValue];
		NSDate *date = [formatter dateFromString:startdate];
		NSInteger time = [[NSString stringWithFormat:@"%ld", (long)[date timeIntervalSince1970]] integerValue];
		for (int i = 0; i <= dd; i++) {
			NSInteger temtime = time + (24 * i * 60 * 60);
			NSDate *confromTimesp = [NSDate dateWithTimeIntervalSince1970:temtime];
			NSString *confromTimespStr = [formatter stringFromDate:confromTimesp];
			[seledayArr addObject:confromTimespStr];
		}
	}
	return seledayArr;
}

- (NSString *)intervalSinceNow:(NSString *)theDate {
	NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
	[formatter setDateStyle:NSDateFormatterMediumStyle];
	[formatter setTimeStyle:NSDateFormatterShortStyle];
	[formatter setDateFormat:@"YYYY-MM-dd HH:mm:ss"];// ----------设置你想要的格式,hh与HH的区别:分别表示12小时制,24小时制

	NSTimeZone *timeZone = [NSTimeZone defaultTimeZone];
	[formatter setTimeZone:timeZone];

	NSDate *datenow = [NSDate date];

	long dd = (long)[datenow timeIntervalSince1970] - [theDate longLongValue] / 1000;
	NSString *timeString = @"";
	if (dd / 3600 < 1) {
		timeString = [NSString stringWithFormat:@"%ld", dd / 60];
		timeString = [NSString stringWithFormat:@"%@分钟前", timeString];
	}
	if (dd / 3600 > 1 && dd / 86400 < 1) {
		timeString = [NSString stringWithFormat:@"%ld", dd / 3600];

		timeString = [NSString stringWithFormat:@"%@小时前", timeString];
	}
	if (dd / 86400 > 1) {
		timeString = [NSString stringWithFormat:@"%ld", dd / 86400];
		timeString = [NSString stringWithFormat:@"%@天前", timeString];
	}
	return timeString;
}

- (NSDate *)stringToDate:(NSString *)dateStr {
	NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
	[formatter setDateStyle:NSDateFormatterMediumStyle];
	[formatter setTimeStyle:NSDateFormatterShortStyle];
	[formatter setDateFormat:@"YYYY-MM-dd HH:mm:ss"];// ----------设置你想要的格式,hh与HH的区别:分别表示12小时制,24小时制

	NSTimeZone *timeZone = [NSTimeZone defaultTimeZone];
	[formatter setTimeZone:timeZone];
	return [formatter dateFromString:dateStr];
}

- (NSString *)shortTimeFromDate:(NSDate *)date {
	NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
	[formatter setTimeStyle:NSDateFormatterShortStyle];
	[formatter setDateFormat:@"HH:mm"];// ----------设置你想要的格式,hh与HH的区别:分别表示12小时制,24小时制

	NSTimeZone *timeZone = [NSTimeZone defaultTimeZone];
	[formatter setTimeZone:timeZone];
	return [formatter stringFromDate:date];
}

- (NSString *)timeDifference:(NSString *)theDate getStrart:(NSString *)startdate formmtterStyle:(NSString *)formartter {
	NSDateFormatter *date = [[NSDateFormatter alloc] init];
	[date setDateFormat:formartter];
	[date setTimeZone:[NSTimeZone defaultTimeZone]];
	NSDate *d = [date dateFromString:theDate];

	NSTimeInterval late = [d timeIntervalSince1970] * 1;


	NSDate *dat = [date dateFromString:startdate];
	NSTimeInterval now = [dat timeIntervalSince1970] * 1;
	NSString *timeString = @"";

	NSTimeInterval cha = late - now;

	NSNumberFormatter *nFormat = [[NSNumberFormatter alloc] init];
	[nFormat setNumberStyle:NSNumberFormatterDecimalStyle];
	[nFormat setMaximumFractionDigits:1];

	if (cha / 3600 < 1) {
		timeString = [nFormat stringFromNumber:@(cha / 60)];
		timeString = [NSString stringWithFormat:@"%@m", timeString];
	}
	if (cha / 3600 >= 1 && cha / 86400 < 1) {
		timeString = [nFormat stringFromNumber:@(cha / 3600)];
		timeString = [NSString stringWithFormat:@"%@h", timeString];
	}
	if (cha / 86400 >= 1) {
		timeString = [nFormat stringFromNumber:@(cha / 86400)];
		timeString = [NSString stringWithFormat:@"%@d", timeString];
	}
	return timeString;
}

//根据开始时间和结束时间得到多少天，小于1天返回 0
- (NSUInteger)timeIntegerDifference:(NSString *)theDate getStrart:(NSString *)startdate {
	NSDateFormatter *date = [[NSDateFormatter alloc] init];
	[date setDateFormat:@"YYYY年 M月dd日HH:mm"];
	[date setTimeZone:[NSTimeZone defaultTimeZone]];
	NSDate *d = [date dateFromString:theDate];

	NSTimeInterval late = [d timeIntervalSince1970] * 1;


	NSDate *dat = [date dateFromString:startdate];
	NSTimeInterval now = [dat timeIntervalSince1970] * 1;
	NSUInteger time = 0;
	NSTimeInterval cha = late - now;


//    if (cha/3600<1) {
//        time=cha/60;
//    }
//    if (cha/3600>=1&&cha/86400<1) {
//        time=cha/3600;
//    }
	if (cha / 86400 >= 1) {
		time = cha / 86400;
	}
	return time;
}

- (NSString *)getseconde:(NSString *)endstart {
	NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
	[dateFormatter setTimeZone:[NSTimeZone defaultTimeZone]];
	[dateFormatter setDateFormat:@"YYYY年 M月d日HH:mm"];
	NSDate *senddate = [NSDate date];
	//结束时间
	NSDate *endDate = [dateFormatter dateFromString:endstart];
	//当前时间
	NSDate *senderDate = [dateFormatter dateFromString:[dateFormatter stringFromDate:senddate]];
	//得到相差秒数
	NSTimeInterval time = [endDate timeIntervalSinceDate:senderDate];

	int minute = time / 60;
	NSString *dateContent = @"";
	if (minute < 60 && minute > 0) {
		dateContent = [[NSString alloc] initWithFormat:@"in %i min", minute];
	}
	else if (minute < 0 && minute > -60) {
		dateContent = [[NSString alloc] initWithFormat:@"out %i min", (int)fabs(minute)];
	}
	else {
		int hours = (int)time / 3600;
		if (hours < 0 && hours > -24) {
			dateContent = [[NSString alloc] initWithFormat:@"out %i hr", (int)fabs(hours)];
		}
		else if (hours >= 0) {
			dateContent = [[NSString alloc] initWithFormat:@"in %i hr", hours];
		}
	}
	NSLog(@"%f========%i", time, minute);
	return dateContent;
}

- (NSString *)getWeekdayFromDate:(NSDate *)date {
	NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
	NSDateComponents *components = [[NSDateComponents alloc] init];
	NSInteger unitFlags = NSYearCalendarUnit |
	    NSMonthCalendarUnit |
	    NSDayCalendarUnit |
	    NSWeekdayCalendarUnit |
	    NSHourCalendarUnit |
	    NSMinuteCalendarUnit |
	    NSSecondCalendarUnit;
	components = [calendar components:unitFlags fromDate:date];
	NSUInteger weekday = [components weekday];
	NSString *weakStr = @"";
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

- (void)setCorner:(UIView *)view radius:(float)cornerRadius borderWidth:(float)width {
	[view.layer setMasksToBounds:YES];
	[view.layer setCornerRadius:cornerRadius];
	[view.layer setBorderWidth:width];
	view.layer.borderColor = [[UIColor grayColor] CGColor];
}

- (UIImage *)imageWithImage:(UIImage *)image scaleToSize:(CGSize)newSize {
	if (NULL != UIGraphicsBeginImageContextWithOptions) {
		UIGraphicsBeginImageContextWithOptions(newSize, NO, 0.0);
	}
	else {
		UIGraphicsBeginImageContext(newSize);
	}
	[image drawInRect:CGRectMake(0, 0, newSize.width, newSize.height)];
	UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndPDFContext();

	return newImage;
}

- (UIImage *)imageFromImage:(UIImage *)image inRect:(CGRect)rect {
	CGImageRef sourceImageRef = [image CGImage];
	CGImageRef newImageRef = CGImageCreateWithImageInRect(sourceImageRef, rect);
	UIImage *newImage = [UIImage imageWithCGImage:newImageRef];
	return newImage;
}

- (void)viewDidLoad {
	[super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
	[super didReceiveMemoryWarning];
	// Dispose of any resources that can be recreated.
}

- (NSString *)datewithstringEnglist:(NSDate *)date {
	NSString *month = [self monthStringWithInteger:[CalendarDateUtil getMonthWithDate:date]];

	NSInteger day = [CalendarDateUtil getDayWithDate:date];
	NSString *week = [self weekStringWithInteger:[CalendarDateUtil getWeekDayWithDate:date]];
	//NSInteger year = [CalendarDateUtil getYearWithDate:date];

	return [NSString stringWithFormat:@"%@,%@ %d", week, month, day];
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

/*
   #pragma mark - Navigation

   // In a storyboard-based application, you will often want to do a little preparation before navigation
   - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
   {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
   }
 */

@end
