//
//  CalendarListViewController.h
//  Time-Line
//
//  Created by IF on 14-9-29.
//  Copyright (c) 2014年 zhilifang. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CalendarListViewController : UIViewController
@property (nonatomic,strong) NSArray *googleCalendarDataArr;//存放GoogleCalendarData对象
@property (nonatomic,strong) NSArray *calendarAccountArr;
@end
