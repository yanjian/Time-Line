//
//  HomeViewController.m
//  Time-Line
//
//  Created by connor on 14-3-24.
//  Copyright (c) 2014年 connor. All rights reserved.
//

#import "HomeViewController.h"
#import "CalendarDateUtil.h"
#import "AddEventViewController.h"
#import "SHRootController.h"
#import "AddEventViewController.h"
#import "AnyEvent.h"
#import "AT_Event.h"
#import "RecurrenceModel.h"
#import "Calendar.h"
#import "SetingViewController.h"
#import "SetingsNavigationController.h"


@interface HomeViewController () <ASIHTTPRequestDelegate>{
    UILabel *titleLabel;
    BOOL ison;
    UIButton* rightBtn_arrow;
    BOOL isSuccess;
}
@end

@implementation HomeViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self initNavigationItem];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    self.navigationController.navigationBarHidden = YES;
    [self synchronizationDataWriteEventId];//同步数据写入离线事件的Eid
    if (self.isRefreshUIData) {
        dateArr = [NSMutableArray array];
        NSInteger cDay = calendarDateCount;
        //NSInteger cMonthCount = [CalendarDateUtil numberOfDaysInMonth:[CalendarDateUtil getCurrentMonth]];
        
        NSInteger weekDay = [CalendarDateUtil getWeekDayWithDate:[CalendarDateUtil dateSinceNowWithInterval:-(cDay - 1)]];
        NSInteger startIndex = -(cDay - 1  + weekDay - 1);
        for (int i = startIndex; i < startIndex + (7* 6 * 12); i+=7) {
            NSDate *temp = [CalendarDateUtil dateSinceNowWithInterval:i];//回到200天前
            NSArray *weekArr = [self switchWeekByDate:temp];
            for (int d = 0; d<7; d++) {
                CLDay *day = [weekArr objectAtIndex:d];
                if (day.isToday) {
                    [calendarView setToDayRow:(i-startIndex)/7 Index:d];
                }
            }
            [dateArr addObject:weekArr];
        }
        
        //默认不执行下面加载数据刷新ui的功能

        NSArray *calendararr=[Calendar MR_findAll];
        NSMutableArray *anyeventArr=[NSMutableArray arrayWithCapacity:0];
        for (Calendar *ca in calendararr) {
            if ([ca.isVisible intValue]==1) {
                NSPredicate *nspre=[NSPredicate predicateWithFormat:@"calendar==%@ and isDelete!=%i and recurringEventId==nil",ca,isDeleteData_YES];//不查询删除的数据
                NSArray *arr=[AnyEvent MR_findAllWithPredicate:nspre];
                for (AnyEvent *anyevent  in arr) {
                    [anyeventArr addObject:anyevent];
                }
            }
        }
        
        
        __block  NSUInteger intervalCount=0;
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            for (NSArray *weekArr in dateArr) {
                for (int d=0; d<7; d++) {
                    CLDay *day = [weekArr objectAtIndex:d];
                    for (AnyEvent *event in anyeventArr) {
                        NSLog(@"%@",event.recurrence);
                        
                        AT_Event *atEvent=[[AT_Event alloc] initWithAnyEvent:event];
                        
                        NSMutableArray *tmpEventArr=[NSMutableArray arrayWithCapacity:0];
                        NSPredicate *nspre=[NSPredicate predicateWithFormat:@"recurringEventId==%@",event.eId];
                        NSArray *arr=[AnyEvent MR_findAllWithPredicate:nspre];
                        for (AnyEvent *anyevent  in arr) {
                            [tmpEventArr addObject:anyevent];
                        }
                        
                        for (AnyEvent *tmpEvent in tmpEventArr) {
                            if ([tmpEvent.originalStartTime hasPrefix:[day description]]) {
                                if ([tmpEvent.status boolValue]) {//status的值为1表示在google或本地都删除了这条数据
                                    atEvent=nil;
                                }else{
                                    atEvent=[[AT_Event alloc] initWithAnyEvent:tmpEvent];
                                }
                            }
                        }

                        if (atEvent.recurrence){
                            
                            NSString *startStr = nil;
                            if (atEvent.startDate) {
                                NSRange rage = [atEvent.startDate rangeOfString:@"日"];
                                if (rage.location!=NSNotFound) {
                                    startStr = [atEvent.startDate substringToIndex:rage.location+1];
                                }
                            }
                            RecurrenceModel *rm = [[RecurrenceModel alloc] initRecrrenceModel:atEvent.recurrence];
                            
                            if(!rm.interval){
                                rm.interval=1;//默认为1
                            }
                            
                            NSDate *startDate = [[PublicMethodsViewController getPublicMethods] formatWithStringDate:startStr];
                            NSDate *dayDate = [[PublicMethodsViewController getPublicMethods] formatWithStringDate:[day description]];
                            if ([[rm.freq uppercaseString] isEqualToString:[@"daily" uppercaseString]]) {//重复提醒天
                                NSTimeInterval interval = [dayDate timeIntervalSinceDate:startDate];
                                if (interval>=0) {
                                    NSInteger tmpInte = interval/86400;//除以一天的时间秒
                                    
                                    if((tmpInte%rm.interval) == 0){
                                        if (!rm.count) {
                                            NSLog(@"%@",rm.until);
                                            [self untilDateWithEndEvent:rm.until clDay:day dayDate:dayDate atEvent:atEvent dayIndex:d weekArr:weekArr];
                                        }else{
                                            rm.count= rm.count-intervalCount;
                                            if (rm.count>0) {
                                                intervalCount++;
                                                AT_Event *atEvents= [atEvent mutableCopy];
                                                NSDate *date=[CalendarDateUtil dateWithTimeInterval:rm.interval  sinceDate:dayDate];
                                                atEvents.startDate=[[PublicMethodsViewController getPublicMethods] stringformatWithDate:date];
                                                
                                                [day addEvent:atEvents];
                                            }
                                        }
                                    }
                                }
                            }else if([[rm.freq uppercaseString] isEqualToString:[@"weekly" uppercaseString]]){
                                NSTimeInterval interval = [dayDate timeIntervalSinceDate:startDate];
                                if (interval>=0) {
                                    NSInteger tmpInte = interval/86400;//除以一天的时间秒
                                    NSInteger weekCount=tmpInte/7;
                                    if((weekCount%rm.interval) == 0){
                                        if (!rm.count) {
                                            NSInteger j= [CalendarDateUtil getWeekDayWithDate:dayDate]-1;
                                            NSArray *byDayArr= [[rm stringWithIntFromWeek] componentsSeparatedByString:@","];
                                            for (int i=0; i< byDayArr.count; i++) {
                                                NSInteger byDay= [byDayArr[i] integerValue];
                                                if (j==byDay) {
                                                    NSLog(@"%@",rm.until);
                                                    [self untilDateWithEndEvent:rm.until clDay:day dayDate:dayDate atEvent:atEvent dayIndex:d weekArr:weekArr];
                                                }
                                            }
                                        }else{
                                            rm.count= rm.count-intervalCount;
                                            
                                            NSInteger j= [CalendarDateUtil getWeekDayWithDate:dayDate]-1;
                                            NSArray *byDayArr= [[rm stringWithIntFromWeek] componentsSeparatedByString:@","];
                                            for (int i=0; i< byDayArr.count; i++) {
                                                NSInteger byDay= [byDayArr[i] integerValue];
                                                if (j==byDay) {
                                                    if (rm.count>0) {
                                                        intervalCount++;
                                                        AT_Event *atEvents= [atEvent mutableCopy];
                                                        // NSDate *date=[CalendarDateUtil dateWithTimeInterval:rm.interval  sinceDate:startDate];
                                                        // atEvents.startDate=[[PublicMethodsViewController getPublicMethods] stringformatWithDate:date];
                                                        [day addEvent:atEvents];
                                                    }
                                                }
                                            }
                                        }
                                    }
                                }
                            }else if([[rm.freq uppercaseString] isEqualToString:[@"monthly" uppercaseString]]){
                                NSCalendar* chineseClendar = [ [ NSCalendar alloc ] initWithCalendarIdentifier:NSGregorianCalendar ];
                                NSUInteger unitFlags = NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit | NSDayCalendarUnit | NSMonthCalendarUnit | NSYearCalendarUnit;
                                NSDateComponents *cps = [chineseClendar components:unitFlags fromDate:startDate  toDate:dayDate  options:0];
                                
                                NSInteger diffYear = [cps year];
                                NSInteger diffMon = [cps month];
                                NSInteger diffDay = [cps day];
                                if (diffYear>=0&&diffMon>=0&&diffDay==0) {
                                    NSInteger months= diffYear*12+diffMon;
                                    if (months%rm.interval==0) {
                                        if (!rm.count) {
                                            NSLog(@"%@",rm.until);
                                            [self untilDateWithEndEvent:rm.until clDay:day dayDate:dayDate atEvent:atEvent dayIndex:d weekArr:weekArr];
                                        }else{
                                            rm.count= rm.count-intervalCount;
                                            if (rm.count>0) {
                                                intervalCount++;
                                                AT_Event *atEvents= [atEvent mutableCopy];
                                                [day addEvent:atEvents];
                                            }
                                        }
                                    }
                                }
                                
                            }else if([[rm.freq uppercaseString] isEqualToString:[@"yearly" uppercaseString]]){
                                NSCalendar* chineseClendar = [ [ NSCalendar alloc ] initWithCalendarIdentifier:NSGregorianCalendar ];
                                NSUInteger unitFlags = NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit | NSDayCalendarUnit | NSMonthCalendarUnit | NSYearCalendarUnit;
                                NSDateComponents *cps = [chineseClendar components:unitFlags fromDate:startDate  toDate:dayDate  options:0];
                                
                                NSInteger diffYear = [cps year];
                                NSInteger diffMon = [cps month];
                                NSInteger diffDay = [cps day];
                                if (diffYear>=0&&diffMon==0&&diffDay==0) {
                                    NSInteger years= diffYear;
                                    if (years%rm.interval==0) {
                                        if (!rm.count) {
                                            NSLog(@"%@",rm.until);
                                            [self untilDateWithEndEvent:rm.until clDay:day dayDate:dayDate atEvent:atEvent dayIndex:d weekArr:weekArr];
                                        }else{
                                            rm.count= rm.count-intervalCount;
                                            if (rm.count>0) {
                                                intervalCount++;
                                                AT_Event *atEvents= [atEvent mutableCopy];
                                                [day addEvent:atEvents];
                                            }
                                        }
                                    }
                                }
                            }
                        }else{
                            if ([atEvent.startDate hasPrefix:[day description]]) {
                                [day addEvent:atEvent];
                            }
                        }
                    }
                    if (day.events.count>0) {//events集合数大于零表示有数据
                        day.isExistData=YES;
                    }
                    
                }
            }
            dispatch_async(dispatch_get_main_queue(), ^{
                [self refreshUI];
                
            });
        });
        [calendarView goBackToday];//回到今天
   }
   
}


-(void) untilDateWithEndEvent:(NSString *) until clDay:(CLDay *) day dayDate:(NSDate *)dayDate atEvent:(AT_Event *) atEvent dayIndex:(int) index weekArr:(NSArray *)weekArr{

    NSDate *sDate = [[PublicMethodsViewController getPublicMethods] formatWithStringDate:atEvent.startDate];
    NSDate *eDate = [[PublicMethodsViewController getPublicMethods] formatWithStringDate:atEvent.endDate];
    NSTimeInterval seInterval = [eDate timeIntervalSinceDate:sDate];//算出开始时间与结束时间的间距秒
    NSString *timeStr=nil;
    NSRange dR=[atEvent.startDate rangeOfString:@"日"];
    if (dR.location!=NSNotFound) {
        timeStr=[atEvent.startDate substringFromIndex:dR.location+1];
    }else{
        timeStr=@"00:00";
    }
    NSString *start=[NSString stringWithFormat:@"%@%@",[day description],timeStr];
    NSDate *newStartDate = [[PublicMethodsViewController getPublicMethods] formatWithStringDate:start];
    
    NSTimeInterval endInterval=[newStartDate timeIntervalSince1970]+seInterval;

    atEvent.startDate=[[PublicMethodsViewController getPublicMethods] stringformatWithDate:newStartDate];
    NSLog(@"%@",[NSDate dateWithTimeIntervalSince1970:endInterval]);
    atEvent.endDate=[[PublicMethodsViewController getPublicMethods] stringformatWithDate:[NSDate dateWithTimeIntervalSince1970:endInterval]];
    
    
    if (until) {//直到什么时间截止
        NSRange unT= [until rangeOfString:@"T"];//查看until中存在T没有
        if(unT.location!=NSNotFound){
            until=[until substringToIndex:unT.location+1];
        }

        NSString *untilStr= [[PublicMethodsViewController getPublicMethods] rfc3339StringWithStringDate:until];
        NSLog(@"%@",untilStr);
        NSDate *untilDate= [[PublicMethodsViewController getPublicMethods] formatWithStringDate:untilStr];//截止时间
        NSTimeInterval  timeIn = [untilDate timeIntervalSince1970];
        NSTimeInterval dayTimeIn = [dayDate timeIntervalSince1970];
        if (dayTimeIn<timeIn) {
           [day addEvent:atEvent];
        }
    }else{
         [day addEvent:atEvent];
     }
}

-(void)refreshUI{
    //刷新事件表
    for (NSObject* obj in [calendarView subviews]) {
        if ([obj isKindOfClass:[UITableView class]]) {
            UITableView* tableview=(UITableView*)obj;
            if (tableview.tag==1) {
                [tableview reloadData];
            }
        }
    }

}

//读取日历事件并写入到本地 --- 每次进入Home界面都会执行（---该方法没有使用----2014 Year 9 moth 屏蔽）
- (void)getCalendarEvemt {
    NSMutableDictionary* eventDic=[[NSMutableDictionary alloc]initWithCapacity:0];
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *plistPath = [documentsDirectory stringByAppendingPathComponent:@"addtime.plist"];
    NSLog(@"%@",plistPath);
    EKEventStore* store=[[EKEventStore alloc]init];
    // 获取适当的日期（Get the appropriate calendar），获取第一次用这个应用创建的事件
    NSCalendar *calendar = [NSCalendar currentCalendar];
    
    // 创建起始日期组件（Create the start date components）
    NSDateComponents *oneDayAgoComponents = [[NSDateComponents alloc] init];
    oneDayAgoComponents.day = -1;
    NSDate *oneDayAgo = [calendar dateByAddingComponents:oneDayAgoComponents
                                                  toDate:[NSDate date]
                                                 options:0];
    
    // 创建结束日期组件（Create the end date components）从事件里第一次事件开始后一年
    NSDateComponents *oneYearFromNowComponents = [[NSDateComponents alloc] init];
    oneYearFromNowComponents.year = 1;
    NSDate *oneYearFromNow = [calendar dateByAddingComponents:oneYearFromNowComponents
                                                       toDate:[NSDate date]
                                                      options:0];
    // 用事件库的实例方法创建谓词 (Create the predicate from the event store's instance method)
    NSPredicate *predicate = [store predicateForEventsWithStartDate:oneDayAgo
                                                            endDate:oneYearFromNow
                                                          calendars:nil];
    // 获取所有匹配该谓词的事件(Fetch all events that match the predicate)
    NSMutableArray *eventArray = [NSMutableArray arrayWithArray:[store eventsMatchingPredicate:predicate]];
    
    //把事件写到本地addtime.plist文件内
    for (EKEvent* event in eventArray){
        NSDateFormatter *tempFormatter = [[NSDateFormatter alloc]init];
        [tempFormatter setDateFormat:@"YYYY年 M月d日"];
        NSString* sateStr=[tempFormatter stringFromDate:event.startDate];
        NSString* endstr=[tempFormatter stringFromDate:event.endDate];
        NSMutableArray* arraytem=[[PublicMethodsViewController getPublicMethods] intervalSinceNow:endstr getStrart:sateStr];
        for (NSString* day in arraytem) {
            NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
            NSString *documentsDirectory = [paths objectAtIndex:0];
            NSString *plistPath = [documentsDirectory stringByAppendingPathComponent:@"addtime.plist"];
            NSMutableDictionary *data = [[NSMutableDictionary alloc] initWithContentsOfFile:plistPath];
            if ([data count]>0) {
                eventDic=data;
            }
            NSMutableArray* array=[[NSMutableArray alloc]initWithCapacity:0];
            NSMutableDictionary* dictem=[[NSMutableDictionary alloc]initWithCapacity:0];
            NSDateFormatter *tempFormatters = [[NSDateFormatter alloc]init];
            [tempFormatters setDateFormat:@"YYYY年 M月d日HH:mm"];
            [dictem setObject:event.title forKey:@"title"];
            [dictem setObject:[tempFormatters stringFromDate:event.startDate] forKey:@"start"];
            [dictem setObject:[tempFormatters stringFromDate:event.endDate] forKey:@"end"];
            [dictem setObject:event.eventIdentifier forKey:@"timeid"];
            if (event.location) {
                [dictem setObject:event.location forKey:@"loc"];
            }
            if (event.notes) {
                [dictem setObject:event.notes forKey:@"note"];
            }
           // [dictem setObject:[event.URL absoluteString] forKey:@"url"];
            NSLog(@"%@",[event.URL absoluteString]);
            
            for (NSString* str in [data allKeys]) {
                if ([str isEqualToString:day]) {
                    for (NSDictionary* temdic in [data objectForKey:str]) {
                        [array addObject:temdic];
                    }
                }
            }
            [array addObject:dictem];
            [eventDic setObject:array forKey:day];
            [eventDic writeToFile:plistPath atomically:YES];
            
        }
    }
}


- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}
//将anyEvent 转换为json
-(NSString *)assemblyStringWithGoogleAnyEvent:(AnyEvent *)anyEvent{
    NSDictionary *anyEventDic=[NSMutableDictionary dictionaryWithCapacity:0];
    [anyEventDic setValue:@"calendar#event" forKey:@"kind"];
    
    [anyEventDic setValue:anyEvent.created forKey:@"created"];
    [anyEventDic setValue:anyEvent.updated forKey:@"updated"];
    [anyEventDic setValue:anyEvent.eventTitle forKey:@"summary"];
    if (anyEvent.recurrence&&![@"" isEqualToString:anyEvent.recurrence]) {
        NSArray *tmpArr=[NSArray arrayWithObjects:anyEvent.recurrence, nil];
        [anyEventDic setValue:tmpArr forKey:@"recurrence"];

    }
    
    if(anyEvent.note){
      [anyEventDic setValue:anyEvent.note forKey:@"description"];
    }
   
    if (anyEvent.location) {
         [anyEventDic setValue:anyEvent.location forKey:@"location"];
    }
    if (anyEvent.sequence) {
        [anyEventDic setValue:anyEvent.sequence forKey:@"sequence"];
    }
    [anyEventDic setValue:@{@"email": anyEvent.creator==nil?@"":anyEvent.creator,@"displayName":anyEvent.creatorDisplayName==nil?@"":anyEvent.creatorDisplayName} forKey:@"creator"];
    [anyEventDic setValue:@{@"email": anyEvent.organizer==nil?@"":anyEvent.organizer,@"displayName":anyEvent.orgDisplayName==nil?@"":anyEvent.orgDisplayName} forKey:@"organizer"];
    if(![anyEvent.isAllDay boolValue]){//非全天事件
        
      NSString *startEventDate=  [[PublicMethodsViewController getPublicMethods] dateWithStringDate:anyEvent.startDate];//开始事件的时间
      NSString *endEventDate=  [[PublicMethodsViewController getPublicMethods] dateWithStringDate:anyEvent.endDate];//开始事件的时间

      [anyEventDic setValue:@{@"dateTime":startEventDate,@"timeZone":anyEvent.calendar.timeZone} forKey:@"start"];
      [anyEventDic setValue:@{@"dateTime":endEventDate,@"timeZone":anyEvent.calendar.timeZone} forKey:@"end"];
    }else{
       
        NSString *startDate=[self newSubStrWithDateStr:anyEvent.startDate];
        NSString *endDate=[self newSubStrWithDateStr:anyEvent.endDate];
        
        [anyEventDic setValue:@{@"date":startDate} forKey:@"start"];
        [anyEventDic setValue:@{@"date":endDate} forKey:@"end"];
    }
    return [anyEventDic JSONString];
}

-(NSString *) newSubStrWithDateStr:(NSString *) dateStr{
    NSString *tmpdate=nil;
    NSRange range=[dateStr rangeOfString:@"日"];
    if (range.location!=NSNotFound) {
        tmpdate= [dateStr substringToIndex:range.location+1];
    }else{
        tmpdate=dateStr;
    }
    if (tmpdate) {
         tmpdate=[tmpdate stringByReplacingOccurrencesOfString:@"年 " withString:@"-"];
         tmpdate=[tmpdate stringByReplacingOccurrencesOfString:@"月" withString:@"-"];
         tmpdate=[tmpdate stringByReplacingOccurrencesOfString:@"日" withString:@""];
    }
    
    return tmpdate;
}

//
-(NSString *)assemblyStringWithLocalAnyEvent:(AnyEvent *)anyEvent{

    NSString *startEventDate=  [[PublicMethodsViewController getPublicMethods] formaterStringfromDate:@"yyyy-MM-dd HH:mm:ss" dateString:anyEvent.startDate];//开始事件的时间
    NSString *endEventDate=  [[PublicMethodsViewController getPublicMethods] formaterStringfromDate:@"yyyy-MM-dd HH:mm:ss" dateString:anyEvent.endDate];//开始事件的时间
    NSDictionary *anyEventDic=[NSMutableDictionary dictionaryWithCapacity:0];
    // {"title":"标题","location":"地点","coordinates":"坐标","startTime":"开始时间","endTime":"结束时间","timeZone":"时区","note":"备注说明","allDay":"","recurrence":"","recurringEventId":"","status":"","originalStartTime":""}
    
    
   // [anyEventDic setValue:anyEvent.calendar.cid forKey:@"calendarId"];
    //{"calendarId":"日历id","title":"标题","location":"地点","coordinates":"坐标","startTime":"开始时间","endTime":"结束时间","timeZone":"时区","note":"备注说明","allDay":"",   "recurrence":"","recurringEventId":"","status":"", "originalStartTime":""}
    [anyEventDic setValue:anyEvent.eventTitle forKey:@"title"];
    [anyEventDic setValue:anyEvent.location forKey:@"location"];
    [anyEventDic setValue:anyEvent.coordinate forKey:@"coordinates"];
    [anyEventDic setValue:startEventDate forKey:@"startTime"];
    [anyEventDic setValue:endEventDate forKey:@"endTime"];
    Calendar *ca=anyEvent.calendar;
    if (ca.cid) {
        [anyEventDic setValue:ca.cid forKey:@"cid"];
    }
    if (anyEvent.eId) {
        [anyEventDic setValue:anyEvent.eId forKey:@"id"];
    }
    [anyEventDic setValue:anyEvent.recurrence==nil?@"":anyEvent.recurrence forKey:@"recurrence"];
    [anyEventDic setValue:anyEvent.status forKey:@"status"];
    [anyEventDic setValue:anyEvent.recurringEventId==nil?@"":anyEvent.recurringEventId forKey:@"recurringEventId"];
    [anyEventDic setValue:anyEvent.originalStartTime==nil?@"":anyEvent.originalStartTime forKey:@"originalStartTime"];
    [anyEventDic setValue:anyEvent.calendar.timeZone forKey:@"timeZone"];
    [anyEventDic setValue:anyEvent.note==nil?@"":anyEvent.note forKey:@"note"];
    [anyEventDic setValue:anyEvent.isAllDay forKey:@"allDay"];
    [anyEventDic setValue:anyEvent.sequence forKey:@"sequence"];
    return [anyEventDic JSONString];
}

- (void)requestFinished:(ASIHTTPRequest *)request{
    NSString *responseStr=[request responseString];
    NSLog(@"json ==== %@",responseStr);
    switch (request.tag) {
        case Google_CalendarEventOperation_tag:{
            id responseObj=[responseStr objectFromJSONString];
            if ([responseObj isKindOfClass:[NSDictionary class]]) {
                NSDictionary *responseDic=(NSDictionary *)responseObj;
                NSString *statusCode=[responseDic objectForKey:@"statusCode"];
                if ([statusCode isEqualToString:@"-3"]||[statusCode isEqualToString:@"-2"]||[statusCode isEqualToString:@"-1"]) {
                    NSLog(@"message ======== %@",[responseDic objectForKey:@"message"]);
                    return;
                }
                if ([statusCode isEqualToString:@"0"]) {
                    NSLog(@"message ======== 失败");
                    return;
                }
                if ([statusCode isEqualToString:@"1"]) {
                    NSDictionary *dataDic= [responseDic objectForKey:@"data"];
                    
                    AnyEvent *anyEvent=[request.userInfo objectForKey:@"anyEvent"];
                    anyEvent.isSync=@(isSyncData_YES);//表示已经同步
                    if ([dataDic objectForKey:@"location"]) {
                        anyEvent.location= [dataDic objectForKey:@"location"];
                    }
                    anyEvent.created=[dataDic objectForKey:@"created"];
                    anyEvent.status=[[dataDic objectForKey:@"status"] isEqualToString:cancelled]?[NSString stringWithFormat:@"%i",eventStatus_cancelled] :[NSString stringWithFormat:@"%i",eventStatus_confirmed];
                    
                    //检查用户在没有网络情况下是否有删除数据
                    NSPredicate *pre=[NSPredicate predicateWithFormat:@"recurringEventId==%@", anyEvent.eId];
                    NSArray *eventArr= [AnyEvent MR_findAllWithPredicate:pre];
                    for (AnyEvent *event in eventArr) {//如果有修改则把删除的事件的recurringEventId改为主事件的eid
                        event.recurringEventId=[dataDic objectForKey:@"id"];
                    }
                    anyEvent.eId=[dataDic objectForKey:@"id"];//把本地的event....改为google上的事件id
                    anyEvent.updated=[dataDic objectForKey:@"updated"];
                    anyEvent.sequence=[dataDic objectForKey:@"sequence"];
                    id recurrence= [dataDic objectForKey:@"recurrence"];
                    if (recurrence) {
                        if ([recurrence isKindOfClass:[NSArray class]]) {
                            NSArray *recArr=(NSArray *)recurrence;
                            for (NSString *str in recArr) {
                                if ([str hasPrefix:@"RRULE"]) {
                                    anyEvent.recurrence=str;
                                    break;
                                }
                            }
                        }
                    }
                    NSDictionary *creatordic=[dataDic objectForKey:@"creator"];//创建者
                    if (creatordic) {
                        anyEvent.creator=[creatordic objectForKey:@"email"];
                        anyEvent.creatorDisplayName=[creatordic objectForKey:@"displayName"];
                    }
                    NSDictionary *orgdic=[dataDic objectForKey:@"organizer"];//组织者
                    if (orgdic) {
                        anyEvent.organizer =[orgdic objectForKey:@"email"];
                        anyEvent.orgDisplayName=[orgdic objectForKey:@"displayName"];
                    }
                    [[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreAndWait];
                }
            }
            break;
        }
        case Local_SingleEventOperation_Tag:{
            id responseObj=[responseStr objectFromJSONString];
            if ([responseObj isKindOfClass:[NSDictionary class]]) {
                NSDictionary *responseDic=(NSDictionary *)responseObj;
                NSString *statusCode=[responseDic objectForKey:@"statusCode"];
                if ([statusCode isEqualToString:@"1"]) {
                    
                    AnyEvent *anyEvent=[request.userInfo objectForKey:@"anyEvent"];
                    
                    if ([anyEvent.isDelete intValue]==isDeleteData_YES) {//本地如果为1 表示这条数据是要删除的
                        [anyEvent MR_deleteEntity];
                        [[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreAndWait];
                    }
                    if ([anyEvent.isDelete intValue]==isDeleteData_record) {
                        NSPredicate *pre=[NSPredicate predicateWithFormat:@"eId==%@",anyEvent.eId];
                        AnyEvent *event= [[AnyEvent MR_findAllWithPredicate:pre] lastObject];
                        event.isSync=@(isSyncData_YES);
                        event.status= [NSString stringWithFormat:@"%i",eventStatus_cancelled];
                        [[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreAndWait];
                    }
                    NSDictionary *dataDic= [responseDic objectForKey:@"data"];
                    if(dataDic){
                            anyEvent.isSync=@(isSyncData_YES);
                           
                            NSString *location=[dataDic objectForKey:@"location"];
                            if (![location isEqualToString:@""]&&location) {
                                 anyEvent.location= [dataDic objectForKey:@"location"];
                            }
                            anyEvent.eId=[dataDic objectForKey:@"id"];
                            NSString *repeat=[dataDic objectForKey:@"repeat"];
                            if (![@"" isEqualToString:repeat]) {
                                anyEvent.repeat=repeat;

                            }
                            
                            NSString *originalStartTime= [dataDic objectForKey:@"originalStartTime"] ;
                            if (![originalStartTime isEqualToString:@""]&&originalStartTime) {
                                 anyEvent.originalStartTime=originalStartTime;
                            }
                            
                            NSString *recurringEventId=[dataDic objectForKey:@"recurringEventId"];
                            if (![@"" isEqualToString:recurringEventId]&&recurringEventId) {
                                anyEvent.recurringEventId=recurringEventId;
                            }
                            
                            NSString *statrstring=[[PublicMethodsViewController getPublicMethods] stringFormaterDate:@"YYYY年 M月d日HH:mm" dateString:[dataDic objectForKey:@"startTime"]];
                            anyEvent.sequence=[dataDic objectForKey:@"sequence"];
                            
                            NSString *recurrence= [dataDic objectForKey:@"recurrence"];
                            if (![@"" isEqualToString:recurrence]&&recurrence) {
                                 anyEvent.recurrence=[dataDic objectForKey:@"recurrence"];
                            }
                            anyEvent.created=[[PublicMethodsViewController getPublicMethods] rfc3339DateFormatter:[NSDate new]];
                            anyEvent.updated=[[PublicMethodsViewController getPublicMethods] rfc3339DateFormatter:[NSDate new]];
                            anyEvent.status=[dataDic objectForKey:@"status"];
                            anyEvent.startDate= statrstring;
                            anyEvent.endDate= [[PublicMethodsViewController getPublicMethods] stringFormaterDate:@"YYYY年 M月d日HH:mm" dateString:[dataDic objectForKey:@"endTime"]];
                            if ([dataDic objectForKey:@"calendar"]) {
                                Calendar *ca=[dataDic objectForKey:@"calendar"];
                                anyEvent.calendar=ca;
                                anyEvent.creator=ca.account;
                                anyEvent.creatorDisplayName=ca.summary;
                                anyEvent.organizer =ca.account;
                                anyEvent.orgDisplayName=ca.summary;
                            }
                        [[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreAndWait];
                     }
                }else{
                    NSLog(@"message ======== %@",[responseDic objectForKey:@"message"]);
                }
            }
            break;
        }
        case Get_Google_GetCalendarEvent_Tag:{
             NSDictionary *eventDic=[responseStr objectFromJSONString];
            
            NSString *status=[eventDic objectForKey:@"statusCode"];
            if ([@"1" isEqualToString:status]) {//状态成功
                
                 id eventData=[eventDic objectForKey:@"data"];
                 if ([eventData isKindOfClass:[NSDictionary class]]) {
                     NSMutableSet *googleSet=[NSMutableSet setWithCapacity:0];
                     NSDictionary *eventDataDic=(NSDictionary *)eventData;
                     NSArray *eventArr=[eventDataDic objectForKey:@"items"];
                     Calendar *calendar=[request.userInfo objectForKey:@"calendar"];
                     for (NSDictionary *event in eventArr) {
                         NSMutableDictionary *eventDic=[event mutableCopy];
                         [eventDic setObject:calendar forKey:@"calendar"];
                         [googleSet addObject:[self paseEventData:eventDic] ];
                     }
                     [calendar addAnyEvent:googleSet];
                 }
            }
            break;
        }
        case Local_SingleEventOperation_fetch_Tag:{
            
            break;
        }
        case Google_DeleteCalendarEvent_tag:{
           id requestDic= [responseStr objectFromJSONString];
            if ([requestDic isKindOfClass:[NSDictionary class]]) {
                NSDictionary *tmpDic=(NSDictionary *)requestDic;
                NSString *statusCode= [tmpDic objectForKey:@"statusCode"];
                if ([statusCode isEqualToString:@"1"]) {
                    AnyEvent *anyEvent=[request.userInfo objectForKey:@"anyEvent"];
                   
                    if ([anyEvent.isDelete intValue]==isDeleteData_record) {
                        NSPredicate *pre=[NSPredicate predicateWithFormat:@"eId==%@",anyEvent.eId];
                        AnyEvent *event= [[AnyEvent MR_findAllWithPredicate:pre] lastObject];
                        event.isSync=@(isSyncData_YES);
                        event.status= [NSString stringWithFormat:@"%i",eventStatus_cancelled];
                    }else{
                        NSPredicate *pre=[NSPredicate predicateWithFormat:@"eId like %@",[NSString stringWithFormat:@"%@*",anyEvent.eId]];
                        NSArray *eventArr= [AnyEvent MR_findAllWithPredicate:pre];
                        for (AnyEvent *event in eventArr) {
                            event.isSync=@(isSyncData_YES);
                            [event MR_deleteEntity];
                        }
                    }
                    [[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreAndWait];
                }
            }
            break;
        }
        case Google_CalendarEventRepeat_tag:{
            id tmpObj= [request.responseString objectFromJSONString];
            if ([tmpObj isKindOfClass:[NSDictionary class]]) {
                NSDictionary *dic= (NSDictionary *) tmpObj;
                NSString *statusCode = [dic objectForKey:@"statusCode"];
                if ([@"1" isEqualToString:statusCode]) {
                    NSDictionary *eventDataDic= [[dic objectForKey:@"data"] objectForKey:@"data"];
                    
                    NSArray *eventArr=[eventDataDic objectForKey:@"items"];
                    NSMutableArray *tmpArr=[NSMutableArray arrayWithCapacity:0];
                    for (NSDictionary *eventObj in eventArr) {
                        NSMutableDictionary *eventDics=[eventObj mutableCopy];
                        [tmpArr addObject:[self paseGoogleEventData:eventDics]];
                    }
                    AnyEvent *event=(AnyEvent *)[request.userInfo objectForKey:@"anyEvent"];
                    for (AT_Event *anEvent in tmpArr) {
                        if([anEvent.startDate isEqualToString:event.startDate]){
                            NSLog(@"-------------->>><<<<<>>>>> %@",anEvent.startDate);
                            NSPredicate *pre=[NSPredicate predicateWithFormat:@"eId==%@",event.eId];
                            AnyEvent *tmpEvent= [[AnyEvent MR_findAllWithPredicate:pre] lastObject];
                            tmpEvent.eId=anEvent.eId;
                            tmpEvent.created=anEvent.created;
                            if([event.status intValue]==eventStatus_confirmed){//表示只是修改事件不删除修改保存的记录
                                tmpEvent.isDelete=@(isDeleteData_NO);
                            }else{
                                tmpEvent.isDelete=@(isDeleteData_record);
                            }
                            
                            [[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreAndWait];
                            break;
                        }
                    }
                }
            }
            break;
        }
        default:
            break;
    }

}


-(void)fetchDataResult:(void (^)(UIBackgroundFetchResult result))completionHandler{
    NSArray * calendarArr=[Calendar MR_findAll];
    for (Calendar *calendar in calendarArr) {
        if ([calendar.type intValue]==AccountTypeGoogle) {
            ASIHTTPRequest *googleRequest=[t_Network httpPostValue:@{@"cid":calendar.cid}.mutableCopy Url:Get_Google_GetCalendarEvent Delegate:self Tag:Get_Google_GetCalendarEvent_Tag userInfo:@{@"calendar":calendar}];
            [googleRequest startSynchronous];
            [[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreWithCompletion:^(BOOL contextDidSave, NSError *error) {
                if (error) {
                    completionHandler(UIBackgroundFetchResultFailed);
                }
                if(contextDidSave){
                    completionHandler(UIBackgroundFetchResultNewData);
                }else{
                    completionHandler(UIBackgroundFetchResultNoData);
                }
                
            }];
        }else if([calendar.type intValue]==AccountTypeLocal){
            ASIHTTPRequest *localRequest=[t_Network httpGet:@{@"cid":calendar.cid}.mutableCopy Url:Local_SingleEventOperation Delegate:self Tag:Local_SingleEventOperation_fetch_Tag userInfo:@{@"calendar":calendar}];
            [localRequest startSynchronous];
            [self successFetchDataResult:completionHandler];
            [[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreWithCompletion:^(BOOL contextDidSave, NSError *error) {
                if (error) {
                    completionHandler(UIBackgroundFetchResultFailed);
                }
                if(contextDidSave){
                    completionHandler(UIBackgroundFetchResultNewData);
                }else{
                    completionHandler(UIBackgroundFetchResultNoData);
                }
                
            }];
        }
    }
     [self refreshUI];
}


-(void)successFetchDataResult:(void (^)(UIBackgroundFetchResult result))completionHandler{


}


- (void)requestFailed:(ASIHTTPRequest *)request{

    switch (request.tag) {
        case Get_Google_GetCalendarEvent_Tag:{
            
            break;
        }
        case Local_SingleEventOperation_fetch_Tag:{
            
            break;
        }
        default:
            break;
    }
}


//google
-(AnyEvent *)paseEventData:(NSDictionary *) dataDic
{
    NSLog(@"%@",dataDic);
    //事件存储库
    
    AnyEvent *anyEvent=[AnyEvent MR_createEntity];
    
    NSString *startTime= [[dataDic objectForKey:@"start"] objectForKey:@"dateTime"];
    NSString *statrstring=[[PublicMethodsViewController getPublicMethods] formatStringWithStringDate:startTime];
    
    anyEvent.eventTitle=[dataDic objectForKey:@"summary"];
    
    if ([dataDic objectForKey:@"location"]) {
        anyEvent.location= [dataDic objectForKey:@"location"];
    }
    
    anyEvent.eId=[dataDic objectForKey:@"id"];
    anyEvent.sequence=[dataDic objectForKey:@"sequence"];
    
    anyEvent.created=[dataDic objectForKey:@"created"];
    anyEvent.updated=[dataDic objectForKey:@"updated"];
    anyEvent.recurrence=[dataDic objectForKey:@"recurrence"];
    
    anyEvent.startDate= statrstring;
    anyEvent.endDate= [[PublicMethodsViewController getPublicMethods] formatStringWithStringDate:[[dataDic objectForKey:@"end"] objectForKey:@"dateTime"]];
    
    if ([dataDic objectForKey:@"description"]) {
        anyEvent.note= [dataDic objectForKey:@"description"];
    }
    if ([dataDic objectForKey:@"calendar"]) {
        anyEvent.calendar=[dataDic objectForKey:@"calendar"];
    }
    
    NSDictionary *creatordic=[dataDic objectForKey:@"creator"];//创建者
    if (creatordic) {
        anyEvent.creator=[creatordic objectForKey:@"email"];
        anyEvent.creatorDisplayName=[creatordic objectForKey:@"displayName"];
    }
    NSDictionary *orgdic=[dataDic objectForKey:@"organizer"];//组织者
    if (orgdic) {
        anyEvent.organizer =[orgdic objectForKey:@"email"];
        anyEvent.orgDisplayName=[orgdic objectForKey:@"displayName"];
    }
    anyEvent.isSync=@(isSyncData_YES);//表示已经是同步的数据
    return anyEvent;
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/**
 * 初始化导航栏内容
 */
- (void)initNavigationItem
{
    _scrollview = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, kScreen_Width, kScreen_Height)];
    //_scrollview .contentSize = CGSizeMake(3*_scrollview.frame.size.width, 0);
    
  //  _scrollview.contentOffset = CGPointMake(kScreen_Width, 0);
    _scrollview.backgroundColor = [UIColor whiteColor];
    _scrollview.pagingEnabled = YES;
    _scrollview.bounces = NO;//最后一页滑不动
    [self.view addSubview:_scrollview];
    calendarView = [[CLCalendarView alloc] init];
    //calendarView.frame = CGRectMake (kScreen_Width, 40, kScreen_Width, kScreen_Height);
    calendarView.frame = CGRectMake (0, 40, kScreen_Width, kScreen_Height);
    calendarView.dataSuorce = self;
    calendarView.delegate = self;
    calendarView.time=@"time";
    [_scrollview addSubview:calendarView];
    ison=YES;
    titleLabel.text=[NSString stringWithFormat:@"Today %@",[[PublicMethodsViewController getPublicMethods] getcurrentTime:@"dd/M"]];

    
    
//    中间view
 //   UIView *rview = [[UIView alloc] initWithFrame:CGRectMake(kScreen_Width, -20, kScreen_Width, 66)];
    UIView *rview = [[UIView alloc] initWithFrame:CGRectMake(0, -20, kScreen_Width, 66)];
    rview.backgroundColor = [UIColor colorWithRed:0.0f/255.0f green:93.0f/255.0f blue:123.0f/255.0f alpha:1];
//    左边的按钮
    _ZVbutton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    _ZVbutton.frame = CGRectMake(10, 32, 27, 25);
    [_ZVbutton setBackgroundImage:[UIImage imageNamed:@"Icon_Menu"] forState:UIControlStateNormal];
    [_ZVbutton addTarget:self action:@selector(setZVbutton) forControlEvents:UIControlEventTouchUpInside];
    [rview addSubview:_ZVbutton];
    

//   导航： 右边的按钮
    _YVbutton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    _YVbutton.frame = CGRectMake(280, 32, 27, 25);
    [_YVbutton setBackgroundImage:[UIImage imageNamed:@"add_action"] forState:UIControlStateNormal];
    [_YVbutton addTarget:self action:@selector(setYVbutton) forControlEvents:UIControlEventTouchUpInside];
    [rview addSubview:_YVbutton];
    
//  箭头图标
//    rightBtn_arrow = [UIButton buttonWithType:UIButtonTypeCustom];
//    [rightBtn_arrow setImage:[UIImage imageNamed:@"arrow_icon"] forState:UIControlStateNormal];
//    [rightBtn_arrow setFrame:CGRectMake(240, 20, 30, 30)];
//    //rightBtn_arrow.backgroundColor = [UIColor greenColor];
//    [rightBtn_arrow addTarget:self action:@selector(oClickArrow) forControlEvents:UIControlEventTouchUpInside];
//    [rview addSubview:rightBtn_arrow];
//  中间的标题
    UIControl *titleView = [[UIControl alloc]initWithFrame:CGRectMake(80, 30, 180, 30)];
    [titleView addTarget:self action:@selector(oClickArrow) forControlEvents:UIControlEventTouchUpInside];
    [rview addSubview:titleView];
    
    titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 170, 30)];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    //    titleLabel.font = [UIFont fontWithName:@"Helvetica Neue" size:20.0];
    titleLabel.font=[UIFont boldSystemFontOfSize:20.0f];
    titleLabel.textColor = [UIColor whiteColor];
    //titleLabel.backgroundColor = [UIColor yellowColor];
    [titleView addSubview:titleLabel];
    [_scrollview addSubview:rview];
    
    
    
//    //    右边view
//    UIView *xview = [[UIView alloc] initWithFrame:CGRectMake(640, -20, kScreen_Width, kScreen_Height)];
//    xview.backgroundColor = [UIColor orangeColor];
//    
//    float topHeight = (200.0f/480.0f)*kScreen_Height;
//    //    上
//    UIButton *Sbutton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
//    [Sbutton setTitle:@"Porsonal Event" forState:UIControlStateNormal];
//    [Sbutton addTarget:self action:@selector(oClickAdd) forControlEvents:UIControlEventTouchUpInside];
//    Sbutton.frame = CGRectMake(0, 0, kScreen_Width, topHeight);
//    Sbutton.backgroundColor = [UIColor colorWithRed:0.0f/255.0f green:93.0f/255.0f blue:123.0f/255.0f alpha:1];
//    [xview addSubview:Sbutton];
//    //    中
//    UIButton *Zbutton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
//    [Zbutton setTitle:@"Concel" forState:UIControlStateNormal];
//    [Zbutton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
//    Zbutton.frame = CGRectMake(0, topHeight, kScreen_Width, kScreen_Height - 2*topHeight);
//    Zbutton.backgroundColor = [UIColor whiteColor];
//    [xview addSubview:Zbutton];
//    //    下
//    UIButton *Xbutton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
//    [Xbutton setTitle:@"Social Event" forState:UIControlStateNormal];
//    Xbutton.frame = CGRectMake(0, kScreen_Height - topHeight, kScreen_Width, topHeight);
//    Xbutton.backgroundColor = [UIColor colorWithRed:244.0f/255.0f green:10.0f/255.0f blue:115.0f/255.0f alpha:1];
//    [xview addSubview:Xbutton];
//    [_scrollview addSubview:xview];
//
//    //    左间view
//    UIView *zview = [[UIView alloc] initWithFrame:CGRectMake(0, -20, kScreen_Width, 66)];
//    zview.backgroundColor = [UIColor colorWithRed:0.0f/255.0f green:93.0f/255.0f blue:123.0f/255.0f alpha:1];
//    
//    //   右边xiew上返回button
//    _rbutton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
//    _rbutton.frame = CGRectMake(280, 30, 21, 25);
//    //_rbutton.backgroundColor = [UIColor redColor];
//    [_rbutton setBackgroundImage:[UIImage imageNamed:@"Icon_BackArrow1"] forState:UIControlStateNormal];
//    [_rbutton addTarget:self action:@selector(setrbutton) forControlEvents:UIControlEventTouchUpInside];
//    [zview addSubview:_rbutton];
//    [_scrollview addSubview:zview];
}
#pragma mark -－－ 所有点击事件
- (void)setrbutton
{
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:.2];
    [UIView setAnimationCurve:UIViewAnimationCurveLinear];
    _scrollview.contentOffset = CGPointMake(kScreen_Width, 0);
    [UIView commitAnimations];
    
}
-(void)setZVbutton
{
//    [UIView beginAnimations:nil context:nil];
//    [UIView setAnimationDuration:.2];
//    [UIView setAnimationCurve:UIViewAnimationCurveLinear];
//    _scrollview.contentOffset = CGPointMake(0, 0);
//    [UIView commitAnimations];
    SetingViewController *setVC=[[SetingViewController alloc] init];
    SetingsNavigationController *nc=[[SetingsNavigationController alloc] initWithRootViewController:setVC];
    nc.navigationBar.translucent=NO;
    nc.navigationBar.barTintColor=blueColor;
    [self presentViewController:nc animated:YES completion:nil];
    self.isRefreshUIData=NO;
}
-(void)setYVbutton
{
//    [UIView beginAnimations:nil context:nil];
//    [UIView setAnimationDuration:.2];
//    [UIView setAnimationCurve:UIViewAnimationCurveLinear];
//    _scrollview.contentOffset = CGPointMake(640, 0);
//    [UIView commitAnimations];
    
    [self oClickAdd];
    
}

-(AT_Event *)paseGoogleEventData:(NSDictionary *) dataDic
{
    NSLog(@"%@",dataDic);
    //事件存储库
    
    AT_Event *anyEvent=[[AT_Event alloc] init];
    
    
    
    NSString *startTime=nil;
    id startObj=[dataDic objectForKey:@"start"];
    if ([startObj isKindOfClass:[NSDictionary class]]){//全天事件的键值---date
        NSString * start=[[dataDic objectForKey:@"start"] objectForKey:@"date"];
        if (start) {
            NSDateFormatter *df=[[NSDateFormatter alloc] init];
            [df setDateFormat:@"yyyy-M-d"];
            [df setTimeZone:[NSTimeZone defaultTimeZone]];
            NSDate *sdate=[df dateFromString:start];
            [df setDateFormat:@"YYYY年 M月d日HH:mm"];
            startTime=[df stringFromDate:sdate];
            anyEvent.isAllDay=@(1);//全天事件
        }else{
            NSString *statrstring=[[dataDic objectForKey:@"start"] objectForKey:@"dateTime"];
            startTime=[[PublicMethodsViewController getPublicMethods] formatStringWithStringDate:statrstring];
        }
    }
    
    NSString *endTime=nil;
    id endOjd=[dataDic objectForKey:@"end"];
    if ([endOjd isKindOfClass:[NSDictionary class]]){//全天事件的键值---date
        NSString * end=[[dataDic objectForKey:@"end"] objectForKey:@"date"];
        if (end) {
            NSDateFormatter *df=[[NSDateFormatter alloc] init];
            [df setDateFormat:@"yyyy-M-d"];
            [df setTimeZone:[NSTimeZone defaultTimeZone]];
            NSDate *edate=[df dateFromString:end];
            [df setDateFormat:@"YYYY年 M月d日HH:mm"];
            endTime=[df stringFromDate:edate];
        }else{
            NSString * endString=[[dataDic objectForKey:@"end"] objectForKey:@"dateTime"];
            endTime=[[PublicMethodsViewController getPublicMethods] formatStringWithStringDate:endString];
        }
    }
    
    
    anyEvent.eventTitle=[dataDic objectForKey:@"summary"];
    
    if ([dataDic objectForKey:@"location"]) {
        anyEvent.location= [dataDic objectForKey:@"location"];
    }
    
    anyEvent.eId=[dataDic objectForKey:@"id"];
    anyEvent.sequence=[dataDic objectForKey:@"sequence"];
    
    anyEvent.created=[dataDic objectForKey:@"created"];
    anyEvent.updated=[dataDic objectForKey:@"updated"];
    anyEvent.status=[[dataDic objectForKey:@"status"] isEqualToString:cancelled]?[NSString stringWithFormat:@"%i",eventStatus_cancelled] :[NSString stringWithFormat:@"%i",eventStatus_confirmed];

    id recurrence=[dataDic objectForKey:@"recurrence"];
    if (recurrence) {
        if ([recurrence isKindOfClass:[NSArray class]]) {
            NSArray *recArr=(NSArray *)recurrence;
            for (NSString *str in recArr) {
                if ([str hasPrefix:@"RRULE"]) {
                    anyEvent.recurrence=str;
                    break;
                }
            }
        }
    }
    
    anyEvent.startDate= startTime;
    anyEvent.endDate= endTime;
    anyEvent.recurringEventId=[dataDic objectForKey:@"recurringEventId"];
    if ([dataDic objectForKey:@"description"]) {
        anyEvent.note= [dataDic objectForKey:@"description"];
    }
    
    NSDictionary *creatordic=[dataDic objectForKey:@"creator"];//创建者
    if (creatordic) {
        anyEvent.creator=[creatordic objectForKey:@"email"];
        anyEvent.creatorDisplayName=[creatordic objectForKey:@"displayName"];
    }
    NSDictionary *orgdic=[dataDic objectForKey:@"organizer"];//组织者
    if (orgdic) {
        anyEvent.organizer =[orgdic objectForKey:@"email"];
        anyEvent.orgDisplayName=[orgdic objectForKey:@"displayName"];
    }
    anyEvent.isSync=@(isSyncData_NO);//表示已经是非同步的数据
    return anyEvent;
    
}


#pragma mark - Action
/**
 * 点击titleView 导航箭头按钮
 */
- (void)oClickArrow {
//    if (ison) {
//        ison=NO;
//        [UIView beginAnimations:@"clockwiseAnimation" context:NULL];
//        [UIView setAnimationDuration:1.0f];
//        [UIView setAnimationDelegate:self];
//       // rightBtn_arrow.transform = CGAffineTransformMakeRotation((180.0f * M_PI) / 90.0f);
//        [UIView commitAnimations];
//    }else{
//        ison=YES;
//        [UIView beginAnimations:@"clockwiseAnimation" context:NULL];
//        [UIView setAnimationDuration:1.0f];
//        [UIView setAnimationDelegate:self];
//      //  rightBtn_arrow.transform = CGAffineTransformMakeRotation((180.0f * M_PI) / 180.0f);
//        [UIView commitAnimations];
//        
//    }
    calendarView.displayMode = !calendarView.displayMode;
}

/**
 * 点击导航添加按钮
 */
- (void)oClickAdd
{
    AddEventViewController *addVC = [[AddEventViewController alloc] init];
    [self.navigationController pushViewController:addVC animated:YES];
    self.isRefreshUIData=NO;
    
}

///**
// * 点击导航菜单按钮
// */
//- (void)oClickMenu
//{
//    SHRootController* sh=[[SHRootController alloc]init];
//    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:sh];
//    [self presentViewController:nav animated:YES completion:nil];
////    sh.view.backgroundColor = [UIColor blackColor];
////    sh.view.alpha=0.8;
////    UIViewController*  rootViewr=[UIApplication sharedApplication].keyWindow.rootViewController;
////    rootViewr.modalPresentationStyle = UIModalPresentationCurrentContext;
////    [rootViewr presentViewController:sh animated:YES completion:nil];
//
//}


#pragma mark - Method

- (NSMutableArray*)switchWeekByDate:(NSDate*)date;
{
    NSMutableArray* array = [[NSMutableArray alloc] init];
    int head = [CalendarDateUtil getWeekDayWithDate:date] - 1;
    for (int i = 0 ; i < 7; i++) {
        NSDate *temp = [CalendarDateUtil dateWithTimeInterval:i - head sinceDate:date];
        CLDay *day = [[CLDay alloc] initWithDate:temp];
        [array addObject:day];
    }
    
    return array;
}

#pragma mark - CLCalendarDataSource
//日历数组传给CLCalendarView
- (NSArray*)dateSourceWithCalendarView:(CLCalendarView *)calendarView
{
    return [NSArray arrayWithArray:dateArr];
}


#pragma mark - CLCalendar Delegate
//点击事件tableview，添加或查询事件详细
- (void)calendarSelectEvent:(CLCalendarView *)calendarView day:(CLDay*)day event:(AT_Event*)event AllEvent:(NSArray *)events {
    if (!event) {  //没有事件添加
        AddEventViewController* add=[[AddEventViewController alloc] init];
        add.nowTimeDay=day;
        [self.navigationController pushViewController:add animated:YES];
        self.isRefreshUIData=NO;
    }else {  //有事件查看详细
        DateDetailsViewController* dateDetails=[[DateDetailsViewController alloc] init];
        dateDetails.event=event;
        dateDetails.dateArr=events;
        [self.navigationController pushViewController:dateDetails animated:YES];
        self.isRefreshUIData=NO;
    }
}


-(void)synchronizationDataWriteEventId{
    //同步事件数据
    if (g_NetStatus!=NotReachable) {
        NSPredicate *pre=[NSPredicate predicateWithFormat:@"isSync==%d",isSyncData_NO];//这里只查询没有同步的数据同步
        NSArray *anyEventArr=[AnyEvent MR_findAllWithPredicate:pre];
        for (AnyEvent *anyEvent in anyEventArr) {
            Calendar *ca= anyEvent.calendar;
            if (ca) {
                if ([ca.type intValue]==AccountTypeGoogle) {//是google日历就同步到google上
                    if([anyEvent.isDelete intValue]==isDeleteData_NO){//不是删除数据
                        NSString *jsonEvent= [self assemblyStringWithGoogleAnyEvent:anyEvent];
                        NSLog(@"%@",jsonEvent);
                        NSMutableDictionary *paramDic;
                        if ([anyEvent.eId hasPrefix:@"event"]) {//有event前缀的表示是本地生成的一个Eid //新增
                            paramDic=@{@"cid":anyEvent.calendar.cid,@"type":@1,@"text":jsonEvent}.mutableCopy;
                        }else{//表示修改
                            paramDic=@{@"cid":anyEvent.calendar.cid,@"eid":anyEvent.eId,@"type":@2,@"text":jsonEvent}.mutableCopy;
                        }
                        ASIHTTPRequest *googleRequest= [t_Network httpPostValue:paramDic  Url:Google_CalendarEventOperation Delegate:self Tag:Google_CalendarEventOperation_tag userInfo:@{@"anyEvent":anyEvent}];
                        [googleRequest startSynchronous];
                    }else{
                        if ([anyEvent.isDelete intValue]==isDeleteData_YES||[anyEvent.isDelete intValue]==isDeleteData_record) {
                            if (anyEvent.eId) {
                                ASIHTTPRequest *deleteGoogleRequest= [t_Network httpPostValue:@{@"cid":ca.cid,@"eid":anyEvent.eId}.mutableCopy Url:Google_DeleteCalendarEvent Delegate:self Tag:Google_DeleteCalendarEvent_tag userInfo:@{@"anyEvent": anyEvent}];
                                [deleteGoogleRequest startSynchronous];
                            }
                           
                        }else{
                            NSLog(@"%@=====%@",ca.cid,anyEvent.eId);
                            ASIHTTPRequest *request =  [t_Network httpGet:@{@"cid":ca.cid,@"eid":anyEvent.recurringEventId}.mutableCopy Url:Google_CalendarEventRepeat Delegate:self Tag:Google_CalendarEventRepeat_tag userInfo:@{@"anyEvent":anyEvent}];
                            [request startSynchronous];
                        }
                    }
                }else if([ca.type intValue]==AccountTypeLocal) {//是local日历同步到本地服务器上
                    if([anyEvent.isDelete intValue]==isDeleteData_NO){//不是删除数据
                        NSString *jsonEvent= [self assemblyStringWithLocalAnyEvent:anyEvent];
                        NSLog(@"%@",jsonEvent);
                        NSMutableDictionary *paramDic;
                        if ([anyEvent.eId hasPrefix:@"event"]) {//新增
                            paramDic=@{@"cid":anyEvent.calendar.cid,@"type":@1,@"text":jsonEvent}.mutableCopy;
                        }else{//更新
                            paramDic=@{@"cid":anyEvent.calendar.cid,@"id":anyEvent.eId,@"type":@2,@"text":jsonEvent}.mutableCopy;
                        }
                        ASIHTTPRequest *localRequest= [t_Network httpPostValue:paramDic  Url:Local_SingleEventOperation Delegate:self Tag:Local_SingleEventOperation_Tag userInfo:@{@"anyEvent":anyEvent}];
                        [localRequest startSynchronous];
                    }else{
                        if ([anyEvent.isDelete intValue]==isDeleteData_YES||[anyEvent.isDelete intValue]==isDeleteData_record) {
                            if (anyEvent.eId) {
                                ASIHTTPRequest *deleteLocalRequest= [t_Network httpPostValue:@{@"id":anyEvent.eId,@"type":@(3)}.mutableCopy Url:Local_SingleEventOperation Delegate:self Tag:Local_SingleEventOperation_Tag userInfo:@{@"anyEvent": anyEvent}];
                                [deleteLocalRequest startSynchronous];
                            }
                        }else if([anyEvent.isDelete intValue]==isDeleteData_mode){
                            anyEvent.isDelete=@(isDeleteData_NO);
                            anyEvent.isSync=@(isSyncData_NO);
                            [[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreAndWait];
                        }
                    }
                }
            }
        }
        [g_ASIQuent go];
    }else{
        NSLog(@"《《《《《《《《网络异常：没有网络》》》》》》》");
    }


}



-(void)calendartitle:(NSString *)title{
     titleLabel.text = title;
}

- (void)calendarDidToMonth:(int)month year:(int)year CalendarView:(CLCalendarView *)calendarView
{

    NSString *title = @"";
    switch (month) {
        case 1:
            title = @"January";
            break;
        case 2:
            title = @"February";
            break;
        case 3:
            title = @"March";
            break;
        case 4:
            title = @"April";
            break;
        case 5:
            title = @"May";
            break;
        case 6:
            title = @"June";
            break;
        case 7:
            title = @"July";
            break;
        case 8:
            title = @"August";
            break;
        case 9:
            title = @"September";
            break;
        case 10:
            title = @"October";
            break;
        case 11:
            title = @"November";
            break;
        case 12:
            title = @"December";
            break;
            
        default:
            break;
    }
    if ([CalendarDateUtil getCurrentYear]==year) {
        titleLabel.text = title;
    }else{
        titleLabel.text=[[NSString alloc] initWithFormat:@"%@ %d",title,year];
    }
    
}




@end
