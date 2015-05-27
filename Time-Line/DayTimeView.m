//
//  DayTimeView.m
//  Go2
//
//  Created by IF on 15/4/24.
//  Copyright (c) 2015年 zhilifang. All rights reserved.
//

#import "DayTimeView.h"
#import "CLCalendarView.h"
#import "MAEvent.h"
#import "MAEventKitDataSource.h"

#define DATE_COMPONENTS (NSYearCalendarUnit| NSMonthCalendarUnit | NSDayCalendarUnit | NSWeekCalendarUnit |  NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit | NSWeekdayCalendarUnit | NSWeekdayOrdinalCalendarUnit)
#define CURRENT_CALENDAR [NSCalendar currentCalendar]
static NSDate *date = nil;


@interface DayTimeView ()<CLCalendarDataSource, CLCalendarDelegate>{
    UINavigationItem * dayTimeBarItem ;
    UINavigationBar * dayTimeBar;
    UIToolbar * dayTimeToolbar ;
     CLCalendarView *calendarView;
    UIView * calendarShowView;
    BOOL isCalendarShow ;
}
@property (readonly) MAEventKitDataSource *eventKitDataSource;
@end

@implementation DayTimeView
@synthesize event=_event;

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return YES;
}

-(id)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
        self.layer.masksToBounds = YES ;
        self.layer.cornerRadius = 5 ;
       
        [self createMADayView];
        [self createCLCalendarView];
        [self createNavigationBar];
        [self createToolBars];
    }
    return self;
}


-(void)createNavigationBar{
    dayTimeBar = [[UINavigationBar alloc] initWithFrame:CGRectMake(0, 0, self.bounds.size.width, 44)];
    dayTimeBar.barTintColor = [UIColor whiteColor] ;
    dayTimeBarItem = [[UINavigationItem alloc] initWithTitle:self.title];
    dayTimeBarItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"Invitations_Filled"]
                                                                        style:UIBarButtonItemStyleBordered
                                                                       target:self
                                                                       action:@selector(clickDayTimeLeftButton:)];
    
    //创建一个右边按钮
    dayTimeBarItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"Invitations_Filled"]
                                                                         style:UIBarButtonItemStyleDone
                                                                        target:self
                                                                        action:@selector(clickDayTimeRightButton:)];
    [dayTimeBar pushNavigationItem:dayTimeBarItem animated:NO];
    [self addSubview:dayTimeBar];
}


-(void)createToolBars{
    dayTimeToolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, self.bounds.size.height-44, self.bounds.size.width, 44)];
    
    UIBarButtonItem * leftToolbarItem = [[UIBarButtonItem alloc] initWithTitle:@"   Option   "
                                                                         style:UIBarButtonItemStyleBordered
                                                                        target:self
                                                                        action:@selector(clickDayTimeToolLeftButton:)];
    UIBarButtonItem * rightToolbarItem = [[UIBarButtonItem alloc] initWithTitle:@"  Add More  "
                                                                          style:UIBarButtonItemStyleBordered
                                                                         target:self
                                                                         action:@selector(clickDayTimeToolRightButton:)];
    
    UIBarButtonItem *flexible = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:self action:nil] ;
    [dayTimeToolbar setItems:@[leftToolbarItem,flexible,rightToolbarItem] animated:YES] ;
    [self addSubview:dayTimeToolbar];
}


-(void)createCLCalendarView{
    calendarShowView = [[UIView alloc] initWithFrame:CGRectMake(0, 44, self.bounds.size.width, 240)];
    calendarShowView.backgroundColor = [UIColor whiteColor];
    //日历的创建
    calendarView = [[CLCalendarView alloc] initWithFrame:CGRectMake(-10, 0, self.bounds.size.width, 220)];
    //CGRectMake(-10, 44, self.bounds.size.width, 220)
    calendarView.dataSuorce = self;
    calendarView.delegate = self;
    calendarView.displayMode = CLCalendarViewModeMonth;
    calendarView.time=@"time";
    calendarView.backgroundColor = [UIColor whiteColor];
    for (NSObject *obj in[calendarView subviews]) {
        if ([obj isKindOfClass:[UITableView class]]) {
            UITableView *tableview = (UITableView *)obj;
            if (tableview.tag == 1) {
                [tableview removeFromSuperview];
            }
        }
    }
    [calendarShowView addSubview:calendarView];
    [calendarView goBackToday];
    [self addSubview:calendarShowView];
    if (!isCalendarShow) {
        calendarShowView.hidden = YES ;
        isCalendarShow = YES ;
    }
}





-(void)createMADayView{
    MADayView *dayView = [[MADayView alloc] initWithFrame:CGRectMake(0, 44, CGRectGetWidth(self.bounds), self.bounds.size.height-44*2)];
    dayView.delegate=self;
    dayView.dataSource=self;
    dayView.autoScrollToFirstEvent = YES;
    [self addSubview:dayView];
}

//--------------------------------------------------------------

#ifdef USE_EVENTKIT_DATA_SOURCE

- (NSArray *)dayView:(MADayView *)dayView eventsForDate:(NSDate *)startDate {
    return [self.eventKitDataSource dayView:dayView eventsForDate:startDate];
}

#else
- (NSArray *)dayView:(MADayView *)dayView eventsForDate:(NSDate *)startDate {
    NSArray *arr = [NSArray arrayWithObjects: self.event, nil];
    return arr;
}
#endif



- (MAEventKitDataSource *)eventKitDataSource {
    if (!_eventKitDataSource) {
        _eventKitDataSource = [[MAEventKitDataSource alloc] init];
    }
    return _eventKitDataSource;
}



/* Implementation for the MADayViewDelegate protocol */

- (void)dayView:(MADayView *)dayView eventTapped:(MAEvent *)event {
    NSDateComponents *components = [CURRENT_CALENDAR components:DATE_COMPONENTS fromDate:event.start];
    NSString *eventInfo = [NSString stringWithFormat:@"Hour %i. Userinfo: %@", [components hour], [event.userInfo objectForKey:@"test"]];
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:event.title
                                                    message:eventInfo delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [alert show];
}

//--------------start ------------
#pragma  mark -DayTimeDelegete的代理
-(void)clickDayTimeLeftButton:(UIBarButtonItem *) barButtonItem{
    if (!isCalendarShow) {
        [UIView animateWithDuration:0.5f animations:^{
           calendarShowView.frame = CGRectMake(0, -284, self.bounds.size.width, 240);
            
        } completion:^(BOOL finished) {
            calendarShowView.hidden = YES ;
            isCalendarShow = YES ;
        }];
    } else {
        [UIView animateWithDuration:0.5f animations:^{
            calendarShowView.frame = CGRectMake(0,  44, self.bounds.size.width, 240);
        } completion:^(BOOL finished) {
            calendarShowView.hidden = NO ;
            isCalendarShow = NO ;
        }];
    }
}

-(void)clickDayTimeRightButton:(UIBarButtonItem *) barButtonItem {
    
}

-(void)clickDayTimeToolLeftButton:(UIBarButtonItem *) barButtonItem{
    if (self.delegate && [self.delegate respondsToSelector:@selector(clickDayTimeToolLeftButton:)]) {
        [self.delegate clickDayTimeToolLeftButton:barButtonItem] ;
    }
    
}


-(void)clickDayTimeToolRightButton:(UIBarButtonItem *) barButtonItem{
    
}

//--------------end------------


#pragma mark - CLCalendarDataSource
- (NSArray *)dateSourceWithCalendarView:(CLCalendarView *)calendarView {
    NSMutableArray * dateArr = @[].mutableCopy ;
    NSInteger cDay = calendarDateCount;
    // NSInteger cMonthCount = [CalendarDateUtil numberOfDaysInMonth:[CalendarDateUtil getCurrentMonth]];
    NSLog(@"%@", [CalendarDateUtil dateSinceNowWithInterval:-(cDay - 1)]);
    NSInteger weekDay = [CalendarDateUtil getWeekDayWithDate:[CalendarDateUtil dateSinceNowWithInterval:-(cDay - 1)]];
    
    NSInteger startIndex = -(cDay - 1  + weekDay - 1);
    
    for (int i = startIndex; i < startIndex + (7 * 5 * 12); i += 7) {
        NSDate *temp = [CalendarDateUtil dateSinceNowWithInterval:i];
        NSArray *weekArr = [self switchWeekByDate:temp];
        for (int d = 0; d < 7; d++) {
            CLDay *day = [weekArr objectAtIndex:d];
            if (day.isToday) {
                [calendarView setToDayRow:(i - startIndex) / 7 Index:d];
            }
        }
        [dateArr addObject:weekArr];
    }
    return dateArr ;
}


- (NSMutableArray *)switchWeekByDate:(NSDate *)date;
{
    NSMutableArray *array = [[NSMutableArray alloc] init];
    int head = [CalendarDateUtil getWeekDayWithDate:date] - 1;
    for (int i = 0; i < 7; i++) {
        NSDate *temp = [CalendarDateUtil dateWithTimeInterval:i - head sinceDate:date];
        CLDay *day = [[CLDay alloc] initWithDate:temp];
        [array addObject:day];
    }
    
    return array;
}
#pragma mark - CLCalendar Delegate
- (void)calendarDidToMonth:(int)month year:(int)year CalendarView:(CLCalendarView *)calendarView {
    NSString *title = @"";
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
    if ([CalendarDateUtil getCurrentYear] == year) {
        dayTimeBarItem.title = title;
    }
    else {
        dayTimeBarItem.title = [title stringByAppendingFormat:@" %i", year];
    }
}
- (void)calendartitle:(NSString *)title {
}

@end

