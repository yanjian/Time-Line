
#import "CalendarDateUtil.h"

@implementation CalendarDateUtil

+ (BOOL)isLeapYear:(NSInteger)year
{
    NSAssert(!(year < 1), @"invalid year number");
    BOOL leap = FALSE;
    if ((0 == (year % 400))) {
        leap = TRUE;
    }
    else if((0 == (year%4)) && (0 != (year % 100))) {
        leap = TRUE;
    }
    return leap;
}

#pragma mark -

+ (NSInteger)numberOfDaysInMonth:(NSInteger)month
{
    return [CalendarDateUtil numberOfDaysInMonth:month year:[CalendarDateUtil getCurrentYear]];
}

+ (NSInteger)numberOfDaysInMonth:(NSInteger)month year:(NSInteger) year
{
    NSAssert(!(month < 1||month > 12), @"invalid month number");
    NSAssert(!(year < 1), @"invalid year number");
    month = month - 1;
    static int daysOfMonth[12] = {31, 29, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31};
    NSInteger days = daysOfMonth[month];
    /*
     * feb
     */
    if (month == 1) {
        if ([CalendarDateUtil isLeapYear:year]) {
            days = 29;
        }
        else
        {
            days = 28;
        }
    }
    return days;
}

#pragma mark -

+ (NSInteger)getCurrentYear
{
    time_t ct = time(NULL);
	struct tm *dt = localtime(&ct);
	int year = dt->tm_year + 1900;
    return year;
}

+ (NSInteger)getCurrentMonth
{
    time_t ct = time(NULL);
	struct tm *dt = localtime(&ct);
	int month = dt->tm_mon + 1;
    return month;
}

+ (NSInteger)getCurrentDay
{
    time_t ct = time(NULL);
	struct tm *dt = localtime(&ct);
	int day = dt->tm_mday;
    return day;
}


#pragma mark -

+ (NSInteger)getMonthWithDate:(NSDate*)date
{
    return [self getDateComponents:date].month;
}

+ (NSInteger)getWeekDayWithDate:(NSDate*)date
{
    return [self getDateComponents:date].weekday;
}

+ (NSInteger)getDayWithDate:(NSDate*)date
{
    return [self getDateComponents:date].day;
}

+ (NSInteger)getYearWithDate:(NSDate*)date
{
    return [self getDateComponents:date].year;
}

+ (NSDateComponents*)getDateComponents:(NSDate*)date
{
    unsigned unitFlags = NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit|NSWeekdayCalendarUnit;
    NSCalendar *gregorian = [NSCalendar currentCalendar];
    return [gregorian components:unitFlags fromDate:date];
}

#pragma mark -

+ (NSDate*)dateSinceNowWithInterval:(NSInteger)dayInterval
{
    return [NSDate dateWithTimeIntervalSinceNow:dayInterval*24*60*60];
}

+ (NSDate*)dateWithTimeInterval:(NSInteger)dayInterval sinceDate:(NSDate*)date
{
    return [NSDate dateWithTimeInterval:dayInterval*24*60*60 sinceDate:date];
}


#pragma mark - 

    static CalendarDateUtil *_singletion;

+ (CalendarDateUtil*)shareInstance {
    
    if (!_singletion) {
        _singletion = [[self alloc] init];
    }

    return _singletion;
}
//
//+ (id)alloc
//{
//    
//   return [super allocWithZone:NULL];
//}

@end
