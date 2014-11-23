//
//  AT_Event.m
//  Time-Line
//
//  Created by IF on 14/11/15.
//  Copyright (c) 2014年 zhilifang. All rights reserved.
//

#import "AT_Event.h"

@implementation AT_Event

@synthesize alerts;
@synthesize calendarAccount;
@synthesize coordinate;
@synthesize endDate;
@synthesize eventTitle;
@synthesize location;
@synthesize note;
@synthesize repeat;
@synthesize startDate;
@synthesize isSync;
@synthesize eId;
@synthesize updated;
@synthesize created;
@synthesize orgDisplayName;
@synthesize creatorDisplayName;
@synthesize creator;
@synthesize organizer;
@synthesize sequence;
@synthesize status;
@synthesize isAllDay;
@synthesize recurrence;
@synthesize recurringEventId;
@synthesize isDelete;

@synthesize backgroundColor;
@synthesize cId;
-(instancetype)initWithAnyEvent:(AnyEvent *) anyEvent{
    self=[super init];
    if (self) {
        alerts=anyEvent.alerts;
        calendarAccount=anyEvent.calendarAccount;
        coordinate=anyEvent.coordinate;
        endDate=anyEvent.endDate ;
        eventTitle=anyEvent.eventTitle;
        location=anyEvent.location;
        note=anyEvent.note;
        repeat=anyEvent.repeat ;
        startDate=anyEvent.startDate;
        isSync=anyEvent.isSync ;
        eId=anyEvent.eId ;
        updated=anyEvent.updated;
        created=anyEvent.created;
        orgDisplayName=anyEvent.orgDisplayName;
        creatorDisplayName=anyEvent.creatorDisplayName;
        creator=anyEvent.creator ;
        organizer=anyEvent.organizer ;
        sequence=anyEvent.sequence;
        status=anyEvent.status;
        isAllDay=anyEvent.isAllDay ;
        recurrence=anyEvent.recurrence;
        backgroundColor=anyEvent.calendar.backgroundColor;
        cId=anyEvent.calendar.cid;
        recurringEventId=anyEvent.recurringEventId;
        isDelete =anyEvent.isDelete;
    }
    return self;
}


-(id)copyWithZone:(NSZone *)zone{
    AT_Event *atEvent=[[[self class] allocWithZone:zone] init];
    atEvent->alerts=self.alerts;
    atEvent->calendarAccount=self.calendarAccount;
    atEvent->coordinate=self.coordinate;
    atEvent->endDate=self.endDate ;
    atEvent->eventTitle=self.eventTitle;
    atEvent->location=self.location;
    atEvent->note=self.note;
    atEvent->repeat=self.repeat ;
    atEvent->startDate=self.startDate;
    atEvent->isSync=self.isSync ;
    atEvent->eId=self.eId ;
    atEvent->updated=self.updated;
    atEvent->created=self.created;
    atEvent->orgDisplayName=self.orgDisplayName;
    atEvent->creatorDisplayName=self.creatorDisplayName;
    atEvent->creator=self.creator ;
    atEvent->organizer=self.organizer ;
    atEvent->sequence=self.sequence;
    atEvent->status=self.status;
    atEvent->isAllDay=self.isAllDay ;
    atEvent->recurrence=self.recurrence;
    atEvent->backgroundColor=self.backgroundColor;
    atEvent->cId=self.cId;
    atEvent->recurringEventId=self.recurringEventId;
    atEvent->isDelete=self.isDelete;
    return atEvent;
}

-(id)mutableCopyWithZone:(NSZone *)zone{
    AT_Event *atEvent=[[[self class] allocWithZone:zone] init];
    atEvent->alerts=[alerts copy];
    atEvent->calendarAccount=[calendarAccount copy];
    atEvent->coordinate=[coordinate copy];
    atEvent->endDate=[endDate copy];
    atEvent->eventTitle=[eventTitle copy];
    atEvent->location=[location copy];
    atEvent->note=[note copy];
    atEvent->repeat=[repeat copy];
    atEvent->startDate=[startDate copy];
    atEvent->isSync=[isSync copy];
    atEvent->eId=[eId copy];
    atEvent->updated=[updated copy];
    atEvent->created=[created copy];
    atEvent->orgDisplayName=[orgDisplayName copy];
    atEvent->creatorDisplayName=[creatorDisplayName copy];
    atEvent->creator=[creator copy];
    atEvent->organizer=[organizer copy];
    atEvent->sequence=[sequence copy];
    atEvent->status=[status copy];
    atEvent->isAllDay=[isAllDay copy];
    atEvent->recurrence=[recurrence copy];
    atEvent->backgroundColor=[backgroundColor copy];
    atEvent->cId=[cId copy];
    atEvent->recurringEventId=[recurringEventId copy];
        atEvent->isDelete=[self.isDelete copy];
    return atEvent;
}

@end
