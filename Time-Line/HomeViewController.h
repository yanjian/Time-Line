//
//  HomeViewController.h
//  Time-Line
//
//  Created by connor on 14-3-24.
//  Copyright (c) 2014年 connor. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/CoreAnimation.h>
#import "CLCalendarView.h"
#import "DateDetailsViewController.h"
@interface HomeViewController : UIViewController <CLCalendarDataSource, CLCalendarDelegate>
{
	CLCalendarView *calendarView;
	NSMutableArray *dateArr;
	UIScrollView *_scrollview;
}
- (void)fetchDataResult:(void (^)(UIBackgroundFetchResult result))completionHandler;

@property (nonatomic, assign) BOOL isRefreshUIData;//是否刷新ui数据
@end
