//
//  WeekViewExampleController.h
//  Time-Line
//
//  Created by connor on 14-4-9.
//  Copyright (c) 2014年 connor. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MAWeekView.h" // MAWeekViewDataSource,MAWeekViewDelegate

@class MAEventKitDataSource;

@interface WeekViewController : UIViewController<MAWeekViewDataSource,MAWeekViewDelegate> {
    MAEventKitDataSource *_eventKitDataSource;
}

@end