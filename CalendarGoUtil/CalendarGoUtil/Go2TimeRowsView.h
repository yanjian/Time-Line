//
//  Go2TimeRowsView.h
//  CalendarGoUtil
//
//  Created by IF on 15/7/10.
//  Copyright (c) 2015年 IF. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface Go2TimeRowsView : UIView

@property (nonatomic) NSCalendar *calendar;				// used to calculate current time
@property (nonatomic) CGFloat hourSlotHeight;			// height of a one-hour slot (default is 40)
@property (nonatomic) CGFloat insetsHeight;				// top and bottom margin height (default is 45)
@property (nonatomic) CGFloat timeColumnWidth;			// width of the time column on the left side (default is 40)
@property (nonatomic) NSTimeInterval timeMark;			// time from start of day for the mark that appears when an event is moved around - set to 0 to hide it
@property (nonatomic) BOOL showsCurrentTime;			// YES if shows red line for current time
@property (nonatomic, readonly) BOOL showsHalfHourLines; // returns YES if hourSlotHeight > 60

@property (nonatomic) UIFont *font;						// font used for time marks
@property (nonatomic) UIColor *timeColor;				// color used for time marks and lines
@property (nonatomic) UIColor *currentTimeColor;		// color used for current time mark and line

@end
