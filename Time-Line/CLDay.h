//
//  CLDay.h
//  Time-Line
//
//  Created by connor on 14-3-25.
//  Copyright (c) 2014年 connor. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CLEvent.h"
#import "CalendarDateUtil.h"

@interface CLDay : NSObject

@property (nonatomic, strong) NSMutableArray *events;

@property (nonatomic, readonly) BOOL isToday;

@property (nonatomic, readonly) NSUInteger day;
@property (nonatomic, readonly) NSUInteger month;
@property (nonatomic, readonly) NSUInteger year;

- (id)initWithDate:(NSDate*)date;

- (BOOL)addEvent:(CLEvent*)event;

- (BOOL)removeEventByIndex:(int)index;

@end
