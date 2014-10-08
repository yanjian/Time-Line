//
//  MAEventKitDataSource.h
//  Time-Line
//
//  Created by connor on 14-4-23.
//  Copyright (c) 2014年 connor. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "MADayView.h"
#import "MAWeekView.h"

@class EKEventStore;

@interface MAEventKitDataSource : NSObject<MADayViewDataSource,MAWeekViewDataSource> {
    EKEventStore *_eventStore;
}

@end