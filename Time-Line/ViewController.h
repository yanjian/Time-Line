//
//  ViewController.h
//  Time-Line
//
//  Created by connor on 14-4-2.
//  Copyright (c) 2014年 connor. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CLCalendarView.h"
#import "JCDatePicker.h"
#import "AnyEvent.h"
@protocol settimeDay <NSObject>
- (void)getstarttime:(NSString *)start getendtime:(NSString *)end isAllDay:(BOOL)isAll;
@end

@interface ViewController : UIViewController <CLCalendarDataSource, CLCalendarDelegate, JCDatePickerDelegate> {
	CLCalendarView *calendarView;
	NSMutableArray *dateArr;
	JCDatePicker *datePicker;
}
@property (nonatomic, weak) id <settimeDay> detelegate;

@property (weak, nonatomic) IBOutlet UIButton *startEventButton;
@property (weak, nonatomic) IBOutlet UIButton *endbutton;
- (IBAction)startevent:(id)sender;
- (IBAction)endEvent:(id)sender;
- (void)addEventViewControler:(UIViewController *)view anyEvent:(AnyEvent *)anyEvent;
@end
