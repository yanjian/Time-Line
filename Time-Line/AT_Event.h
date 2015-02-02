//
//  AT_Event.h
//  Time-Line
//
//  Created by IF on 14/11/15.
//  Copyright (c) 2014年 zhilifang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AnyEvent.h"
#import "Calendar.h"
@interface AT_Event : NSObject <NSCopying, NSMutableCopying>

@property (nonatomic, retain) NSString *alerts;
@property (nonatomic, retain) NSString *calendarAccount;
@property (nonatomic, retain) NSString *coordinate;
@property (nonatomic, retain) NSString *endDate; //事件结束时间
@property (nonatomic, retain) NSString *eventTitle;
@property (nonatomic, retain) NSString *location;
@property (nonatomic, retain) NSString *note;
@property (nonatomic, retain) NSString *repeat;
@property (nonatomic, retain) NSString *startDate; //事件开始执行事件
@property (nonatomic, retain) NSNumber *isSync; //表示是否同步到google等服务器
@property (nonatomic, retain) NSString *eId; //事件id（google等）
@property (nonatomic, retain) NSString *created; //创建时间
@property (nonatomic, retain) NSString *updated; //更新时间
@property (nonatomic, retain) NSString *orgDisplayName; //组织者的日历的名字
@property (nonatomic, retain) NSString *creatorDisplayName; //创建者的日历的名字
@property (nonatomic, retain) NSString *creator; //创建者
@property (nonatomic, retain) NSString *organizer; //组织者
@property (nonatomic, retain) NSNumber *sequence;
@property (nonatomic, retain) NSString *status;
@property (nonatomic, retain) NSNumber *isAllDay; //是否是全天事件
@property (nonatomic, retain) NSString *recurrence;
@property (nonatomic, retain) NSNumber *isDelete;
@property (nonatomic, retain) NSString *originalStartTime;

@property (nonatomic, retain) NSString *backgroundColor; //日历的背景色
@property (nonatomic, retain) NSString *cId; //日历的id
@property (nonatomic, retain) NSString *recurringEventId;
- (instancetype)initWithAnyEvent:(AnyEvent *)anyEvent;

@end
