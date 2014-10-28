//
//  HomeViewController.h
//  Time-Line
//
//  Created by connor on 14-3-24.
//  Copyright (c) 2014年 connor. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CLCalendarView.h"
#import "DateDetailsViewController.h"
@interface HomeViewController : UIViewController <CLCalendarDataSource, CLCalendarDelegate>
{
       CLCalendarView *calendarView;
        NSMutableArray     *dateArr;
    UIScrollView *_scrollview;
    UIButton *_rbutton;//滑动试图左边view上的右边按钮
    UIButton *_ZVbutton;//滑动试图左边view上的左边按钮
    UIButton *_YVbutton;//滑动试图左边view上的右边按钮
}
-(void)fetchDataResult:(void (^)(UIBackgroundFetchResult result))completionHandler;
@end
