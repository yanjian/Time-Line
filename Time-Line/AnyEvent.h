//
//  AnyEvent.h
//  Time-Line
//  事件列表
//  Created by IF on 14/10/21.
//  Copyright (c) 2014年 zhilifang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
//数据是否同步
typedef NS_ENUM (NSInteger, isSyncData) {
	isSyncData_NO = 0,//没有
	isSyncData_YES = 1
};

typedef NS_ENUM (NSInteger, isDeleteData) {
	isDeleteData_NO = 0,//不需要删除的数据
	isDeleteData_YES = 1,//要删除的数据
	isDeleteData_mode = 2,//表示重复数据中有数据删除但还没有达到远程的id
	isDeleteData_record = 3//表示这条记录不需要删除
};


@class Calendar;

@interface AnyEvent : NSManagedObject

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
@property (nonatomic, retain) Calendar *calendar;
@property (nonatomic, retain) NSString *recurrence;
@property (nonatomic, retain) NSString *recurringEventId;
@property (nonatomic, retain) NSNumber *isDelete;
@property (nonatomic, retain) NSString *originalStartTime;
@end
