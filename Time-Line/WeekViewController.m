//
//  WeekViewExampleController.m
//  Time-Line
//
//  Created by connor on 14-4-9.
//  Copyright (c) 2014年 connor. All rights reserved.
//

#import "WeekViewController.h"
#import "MAWeekView.h"
#import "MAEvent.h"
#import "MAEventKitDataSource.h"

// Uncomment the following line to use the built in calendar as a source for events:
//#define USE_EVENTKIT_DATA_SOURCE 1

#define DATE_COMPONENTS (NSYearCalendarUnit| NSMonthCalendarUnit | NSDayCalendarUnit | NSWeekCalendarUnit |  NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit | NSWeekdayCalendarUnit | NSWeekdayOrdinalCalendarUnit)
#define CURRENT_CALENDAR [NSCalendar currentCalendar]

@interface WeekViewController(PrivateMethods)
@property (readonly) MAEvent *event;
@property (readonly) MAEventKitDataSource *eventKitDataSource;
@end

@implementation WeekViewController

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	return YES;
}

/* Implementation for the MAWeekViewDataSource protocol */

#ifdef USE_EVENTKIT_DATA_SOURCE

- (NSArray *)weekView:(MAWeekView *)weekView eventsForDate:(NSDate *)startDate {
    return [self.eventKitDataSource weekView:weekView eventsForDate:startDate];
}

#else

static int counter = 7 * 5;

- (NSArray *)weekView:(MAWeekView *)weekView eventsForDate:(NSDate *)startDate {
	counter--;
	
	unsigned int r = arc4random() % 24;
	unsigned int r2 = arc4random() % 10;
	
	NSArray *arr;
	
	if (counter < 0) {
		arr = [NSArray arrayWithObjects: self.event, nil];
	} else {
		arr = (r <= 5 ? [NSArray arrayWithObjects: self.event, self.event, nil] : [NSArray arrayWithObjects: self.event, self.event, self.event, nil]);
		
		((MAEvent *) [arr objectAtIndex:1]).title = @"All-day events test";
		((MAEvent *) [arr objectAtIndex:1]).allDay = YES;
		
		if (r > 5) {
			((MAEvent *) [arr objectAtIndex:2]).title = @"Foo!";
			((MAEvent *) [arr objectAtIndex:2]).backgroundColor = [UIColor brownColor];
			((MAEvent *) [arr objectAtIndex:2]).allDay = YES;
		}
	}
	
	((MAEvent *) [arr objectAtIndex:0]).title = @"Event lorem ipsum es dolor test";
	
	NSDateComponents *components = [CURRENT_CALENDAR components:DATE_COMPONENTS fromDate:startDate];
	[components setHour:r];
	[components setMinute:0];
	[components setSecond:0];
	
	((MAEvent *) [arr objectAtIndex:0]).start = [CURRENT_CALENDAR dateFromComponents:components];
	
	[components setHour:r+1];
	[components setMinute:0];
	
	((MAEvent *) [arr objectAtIndex:0]).end = [CURRENT_CALENDAR dateFromComponents:components];
	
	if (r2 > 5) {
		((MAEvent *) [arr objectAtIndex:0]).backgroundColor = [UIColor brownColor];
	}
	
	return arr;
}

#endif

- (MAEvent *)event {
	static int counter;
	
	NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
	
	[dict setObject:[NSString stringWithFormat:@"number %i", counter++] forKey:@"test"];
	
	MAEvent *event = [[MAEvent alloc] init];
	event.backgroundColor = [UIColor purpleColor];
	event.textColor = [UIColor whiteColor];
	event.allDay = NO;
	event.userInfo = dict;
	return event;
}

- (MAEventKitDataSource *)eventKitDataSource {
    if (!_eventKitDataSource) {
        _eventKitDataSource = [[MAEventKitDataSource alloc] init];
    }
    return _eventKitDataSource;
}

/* Implementation for the MAWeekViewDelegate protocol */

- (void)weekView:(MAWeekView *)weekView eventTapped:(MAEvent *)event {
	NSDateComponents *components = [CURRENT_CALENDAR components:DATE_COMPONENTS fromDate:event.start];
	NSString *eventInfo = [NSString stringWithFormat:@"Event tapped: %02i:%02i. Userinfo: %@", [components hour], [components minute], [event.userInfo objectForKey:@"test"]];
	
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:event.title
													 message:eventInfo delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
	[alert show];
}

- (void)weekView:(MAWeekView *)weekView eventDragged:(MAEvent *)event {
	NSDateComponents *components = [CURRENT_CALENDAR components:DATE_COMPONENTS fromDate:event.start];
	NSString *eventInfo = [NSString stringWithFormat:@"Event dragged to %02i:%02i. Userinfo: %@", [components hour], [components minute], [event.userInfo objectForKey:@"test"]];
	
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
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
}


@end
