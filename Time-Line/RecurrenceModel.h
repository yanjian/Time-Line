//
//  RecurrenceModel.h
//  Time-Line
//
//  Created by IF on 14/11/14.
//  Copyright (c) 2014年 zhilifang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CLDay.h"
@interface RecurrenceModel : NSObject
@property (nonatomic, copy) NSString *freq;
@property (nonatomic, assign) NSInteger interval;
@property (nonatomic, copy) NSString *until;
@property (nonatomic, assign) NSInteger count;
@property (nonatomic, copy) NSString *byDay;




- (instancetype)initRecrrenceModel:(NSString *)recString;
- (NSString *)stringWithIntFromWeek;
- (NSString *)showWeekFromInt;
- (NSString *)showIntervalWithRepat;
- (NSString *)showUtil;
- (CLDay *)showUtilClday;
@end
