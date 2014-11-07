//
//  MJSecondDetailViewController.m
//  MJPopupViewControllerDemo
//
//  Created by Martin Juhasz on 24.06.12.
//  Copyright (c) 2012 martinjuhasz.de. All rights reserved.
//

#import "MJSecondDetailViewController.h"
#import "MAEvent.h"
#import "MAEventKitDataSource.h"

#define DATE_COMPONENTS (NSYearCalendarUnit| NSMonthCalendarUnit | NSDayCalendarUnit | NSWeekCalendarUnit |  NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit | NSWeekdayCalendarUnit | NSWeekdayOrdinalCalendarUnit)
#define CURRENT_CALENDAR [NSCalendar currentCalendar]

@interface MJSecondDetailViewController (PrivateMethods)
@property (readonly) MAEventKitDataSource *eventKitDataSource;
@end

@implementation MJSecondDetailViewController
@synthesize event=_event;
@synthesize delegate;


- (IBAction)closePopup:(id)sender
{
    if (self.mjdelegate && [self.mjdelegate respondsToSelector:@selector(cancelButtonClicked:)]) {
        [self.mjdelegate cancelButtonClicked:self];
    }
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	return YES;
}

- (void)viewDidLoad {
    MADayView *dayView = [[MADayView alloc] initWithFrame:CGRectMake(0, 0, 300, self.view.bounds.size.height-57)];
    dayView.delegate=self;
    dayView.dataSource=self;
	dayView.autoScrollToFirstEvent = YES;
    [self.view addSubview:dayView];
}

/* Implementation for the MADayViewDataSource protocol */

static NSDate *date = nil;

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


- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}


@end
