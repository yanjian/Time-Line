//
//  Go2DayPlannerViewController.m
//  Go2
//
//  Created by IF on 15/6/30.
//  Copyright (c) 2015年 zhilifang. All rights reserved.
//

#import "Go2DayPlannerViewController.h"
#import "MGCStandardEventView.h"
#import "NSCalendar+MGCAdditions.h"
#import "MGCDateRange.h"
#import "OSCache.h"


typedef enum {
    TimedEventType = 1,
    AllDayEventType = 2,
    AnyEventType = TimedEventType|AllDayEventType
} EventType;

static const NSUInteger cacheSize = 400;	// size of the cache (in days)
static NSString* const EventCellReuseIdentifier = @"EventCellReuseIdentifier";


@interface Go2DayPlannerViewController ()

@property (nonatomic) dispatch_queue_t bgQueue;			// dispatch queue for loading events
@property (nonatomic) NSMutableOrderedSet *daysToLoad;	// dates for months of which we want to load events
@property (nonatomic, readonly) NSCache *eventsCache;

@property (nonatomic) BOOL accessGranted;
@property (nonatomic) UIPopoverController *eventPopover;
@property (nonatomic) NSUInteger createdEventType;
@property (nonatomic, copy) NSDate *createdEventDate;

@end

@implementation Go2DayPlannerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadEvents) name:EKEventStoreChangedNotification object:nil];
    
    _eventsCache = [[OSCache alloc]init];
    _eventsCache.countLimit = cacheSize;
    
    _bgQueue = dispatch_queue_create("Go2DayPlannerEKViewController.bgQueue", NULL);

}


-(void)reloadEvents{
    [self.eventsCache removeAllObjects];
  //  [self fetchEventsInDateRange:self.dayPlannerView.visibleDays];
    [self.dayPlannerView reloadAllEvents];
}


#pragma mark - MGCDayPlannerViewDataSource

- (NSInteger)dayPlannerView:(MGCDayPlannerView *)view numberOfEventsOfType:(MGCEventType)type atDate:(NSDate *)date
{
    return 0;
}

- (MGCEventView*)dayPlannerView:(MGCDayPlannerView*)view viewForEventOfType:(MGCEventType)type atIndex:(NSUInteger)index date:(NSDate*)date
{
    NSLog(@"dayPlannerView:viewForEventOfType:atIndex:date: has to implemented in MGCDayPlannerViewController subclasses.");
    return nil;
}

- (MGCDateRange*)dayPlannerView:(MGCDayPlannerView*)view dateRangeForEventOfType:(MGCEventType)type atIndex:(NSUInteger)index date:(NSDate*)date
{
    NSLog(@"dayPlannerView:dateRangeForEventOfType:atIndex:date: has to implemented in MGCDayPlannerViewController subclasses.");
    return nil;
}

#pragma mark - MGCDayPlannerViewDelegate
- (void)dayPlannerView:(MGCDayPlannerView*)view didSelectEventOfType:(MGCEventType)type atIndex:(NSUInteger)index date:(NSDate*)date
{

}

- (void)dayPlannerView:(MGCDayPlannerView*)view willDisplayDate:(NSDate*)date
{
   
}

- (void)dayPlannerView:(MGCDayPlannerView*)view didEndDisplayingDate:(NSDate*)date
{
   
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    [self reloadEvents];
}


@end
