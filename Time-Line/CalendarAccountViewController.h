//
//  CalendarAccountViewController.h
//  Time-Line
//
//  Created by IF on 14/10/23.
//  Copyright (c) 2014年 zhilifang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AT_Account.h"
#import "Calendar.h"

@protocol CalendarAccountDelegate;

@interface CalendarAccountViewController : UIViewController

@property (nonatomic,assign) id<CalendarAccountDelegate> delegate;

@end

@protocol CalendarAccountDelegate <NSObject>

@optional
-(void)calendarAccountWithAccont:(Calendar *)ca;

@end