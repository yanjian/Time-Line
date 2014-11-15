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
  //  [self getCalendarEvemt];   //2014Year 9 -moth 18  屏蔽
    dateArr = [NSMutableArray array];

    NSInteger cDay = [CalendarDateUtil getCurrentDay] + 6 *30;
    //    NSInteger cMonthCount = [CalendarDateUtil numberOfDaysInMonth:[CalendarDateUtil getCurrentMonth]];
    
    NSInteger weekDay = [CalendarDateUtil getWeekDayWithDate:[CalendarDateUtil dateSinceNowWithInterval:-(cDay - 1)]];
    
    
    NSArray *calendararr=[Calendar MR_findAll];
    NSMutableArray *anyeventArr=[NSMutableArray arrayWithCapacity:0];
    for (Calendar *ca in calendararr) {
        if ([ca.isVisible intValue]==1) {
            NSPredicate *nspre=[NSPredicate predicateWithFormat:@"calendar==%@",ca];
            NSArray *arr=[AnyEvent MR_findAllWithPredicate:nspre];
            if (arr) {
                [anyeventArr addObject:arr];
            }
        }
    }
    
    NSInteger startIndex = -(cDay - 1  + weekDay - 1);
    
    for (int i = startIndex; i < startIndex + (7* 4 * 12); i+=7) {
        NSDate *temp = [CalendarDateUtil dateSinceNowWithInterval:i];//回到200天前
        NSArray *weekArr = [self switchWeekByDate:temp];
        for (int d = 0; d<7; d ++) {
            CLDay *day = [weekArr objectAtIndex:d];
            if (day.isToday) {
                [calendarView setToDayRow:(i-startIndex)/7 Index:d];
            }
            for (int j=0; j<anyeventArr.count; j++) {
                for (AnyEvent *event in anyeventArr[j]) {
                    if ([event.startDate hasPrefix:[day description] ]) {
                        day.isExistData=YES;
                    }
                }
            }
         }
        [dateArr addObject:weekArr];
    }
   [self refreshUI];
   [calendarView goBackToday];//回到今天

//    [[NSNotificationCenter defaultCenter] postNotificationName:@"calander" object:nil];

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
    //同步事件数据
    if (g_NetStatus!=NotReachable) {
        NSPredicate *pre=[NSPredicate predicateWithFormat:@"isSync==%d",isSyncData_NO];//这里只查询没有同步的数据同步
        NSArray *anyEventArr=[AnyEvent MR_findAllWithPredicate:pre];
        for (AnyEvent *anyEvent in anyEventArr) {
            Calendar *ca= anyEvent.calendar;
            if (ca) {
                if ([ca.type intValue]==AccountTypeGoogle) {//是google日历就同步到google上
                    NSString *jsonEvent= [self assemblyStringWithGoogleAnyEvent:anyEvent];
                    NSLog(@"%@",jsonEvent);
                    NSMutableDictionary *paramDic;
                    if (anyEvent.eId&&![anyEvent.eId isEqualToString:@""]) {//更新
                          paramDic=@{@"cid":anyEvent.calendar.cid,@"eid":anyEvent.eId,@"type":@2,@"text":jsonEvent}.mutableCopy;
                    }else{//新增
                          paramDic=@{@"cid":anyEvent.calendar.cid,@"type":@1,@"text":jsonEvent}.mutableCopy;
                    }
                    ASIHTTPRequest *googleRequest= [t_Network httpPostValue:paramDic  Url:Google_CalendarEventOperation Delegate:self Tag:Google_CalendarEventOperation_tag userInfo:@{@"anyEvent":anyEvent}];
                    [googleRequest startAsynchronous];
                }else if([ca.type intValue]==AccountTypeLocal) {//是local日历同步到本地服务器上
                    NSString *jsonEvent= [self assemblyStringWithLocalAnyEvent:anyEvent];
                    NSLog(@"%@",jsonEvent);
                    NSMutableDictionary *paramDic;
                    if (anyEvent.eId) {//更新
                        paramDic=@{@"cid":anyEvent.calendar.cid,@"id":anyEvent.eId,@"type":@2,@"text":jsonEvent}.mutableCopy;
                    }else{//新增
                        paramDic=@{@"cid":anyEvent.calendar.cid,@"type":@1,@"text":jsonEvent}.mutableCopy;
                    }
                    ASIHTTPRequest *localRequest= [t_Network httpPostValue:paramDic  Url:Local_SingleEventOperation Delegate:self Tag:Local_SingleEventOperation_Tag userInfo:@{@"anyEvent":anyEvent}];
                    [localRequest startAsynchronous];
                }
            }
        }
        [g_ASIQuent go];
    }else{
        NSLog(@"《《《《《《《《网络异常：没有网络》》》》》》》");
    }
}
//将anyEvent 转换为json
-(NSString *)assemblyStringWithGoogleAnyEvent:(AnyEvent *)anyEvent{
    NSDictionary *anyEventDic=[NSMutableDictionary dictionaryWithCapacity:0];
    [anyEventDic setValue:@"calendar#event" forKey:@"kind"];
    
//    if (anyEvent.eId) {
//        [anyEventDic setValue:anyEvent.eId forKey:@"id"];
//    }
    
    [anyEventDic setValue:anyEvent.created forKey:@"created"];
    [anyEventDic setValue:anyEvent.updated forKey:@"updated"];
    [anyEventDic setValue:anyEvent.eventTitle forKey:@"summary"];
//    if (anyEvent.eId) {
//        [anyEventDic setValue:anyEvent.eId forKey:@"id"];
//    }
    if (anyEvent.recurrence) {
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
    [anyEventDic setValue:anyEvent.recurrence forKey:@"recurrence"];
    [anyEventDic setValue:@(0) forKey:@"status"];
    [anyEventDic setValue:@"" forKey:@"recurringEventId"];
    [anyEventDic setValue:@"" forKey:@"originalStartTime"];
    [anyEventDic setValue:anyEvent.calendar.timeZone forKey:@"timeZone"];
    [anyEventDic setValue:anyEvent.note forKey:@"note"];
    [anyEventDic setValue:anyEvent.isAllDay forKey:@"allDay"];
    [anyEventDic setValue:@(0) forKey:@"sequence"];
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
                    anyEvent.isSync=@(isSyncData_YES);
                    if ([dataDic objectForKey:@"location"]) {
                        anyEvent.location= [dataDic objectForKey:@"location"];
                    }
                    
                    anyEvent.eId=[dataDic objectForKey:@"id"];
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
                    NSDictionary *dataDic= [responseDic objectForKey:@"data"];
                    
                    AnyEvent *anyEvent=[request.userInfo objectForKey:@"anyEvent"];
                    anyEvent.isSync=@(isSyncData_YES);
                    if ([dataDic objectForKey:@"location"]) {
                        anyEvent.location= [dataDic objectForKey:@"location"];
                    }
                    anyEvent.eId=[dataDic objectForKey:@"id"];
                    
                    NSString *statrstring=[[PublicMethodsViewController getPublicMethods] stringFormaterDate:@"YYYY年 M月d日HH:mm" dateString:[dataDic objectForKey:@"startTime"]];
                    anyEvent.sequence=[dataDic objectForKey:@"sequence"];
                    anyEvent.recurrence=[dataDic objectForKey:@"recurrence"];
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
    rightBtn_arrow = [UIButton buttonWithType:UIButtonTypeCustom];
    [rightBtn_arrow setImage:[UIImage imageNamed:@"arrow_icon"] forState:UIControlStateNormal];
    [rightBtn_arrow setFrame:CGRectMake(240, 20, 30, 30)];
    //rightBtn_arrow.backgroundColor = [UIColor greenColor];
    [rightBtn_arrow addTarget:self action:@selector(oClickArrow) forControlEvents:UIControlEventTouchUpInside];
    [rview addSubview:rightBtn_arrow];
//  中间的标题
    UIControl *titleView = [[UIControl alloc]initWithFrame:CGRectMake(80, 30, 180, 30)];
    [titleView addTarget:self action:@selector(oClickArrow) forControlEvents:UIControlEventTouchUpInside];
    [rview addSubview:titleView];
    
    titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 150, 30)];
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


#pragma mark - Action
/**
 * 点击导航箭头按钮
 */
- (void)oClickArrow {
    if (ison) {
        ison=NO;
        [UIView beginAnimations:@"clockwiseAnimation" context:NULL];
        [UIView setAnimationDuration:1.0f];
        [UIView setAnimationDelegate:self];
        rightBtn_arrow.transform = CGAffineTransformMakeRotation((180.0f * M_PI) / 90.0f);
        [UIView commitAnimations];
    }else{
        ison=YES;
        [UIView beginAnimations:@"clockwiseAnimation" context:NULL];
        [UIView setAnimationDuration:1.0f];
        [UIView setAnimationDelegate:self];
        rightBtn_arrow.transform = CGAffineTransformMakeRotation((180.0f * M_PI) / 180.0f);
        [UIView commitAnimations];
        
    }
    calendarView.displayMode = !calendarView.displayMode;
}

/**
 * 点击导航添加按钮
 */
- (void)oClickAdd
{
    AddEventViewController *addVC = [[AddEventViewController alloc] init];
    [self.navigationController pushViewController:addVC animated:YES];
    
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
- (void)calendarSelectEvent:(CLCalendarView *)calendarView day:(CLDay*)day event:(AnyEvent*)event AllEvent:(NSArray *)events {
    if (!event) {  //没有事件添加
        AddEventViewController* add=[[AddEventViewController alloc] init];
        add.nowTimeDay=day;
        [self.navigationController pushViewController:add animated:YES];
    }else {  //有事件查看详细
        DateDetailsViewController* dateDetails=[[DateDetailsViewController alloc] init];
        dateDetails.event=event;
        dateDetails.dateArr=events;
        [self.navigationController pushViewController:dateDetails animated:YES];
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
