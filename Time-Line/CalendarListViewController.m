//
//  CalendarListViewController.m
//  Time-Line
//
//  Created by IF on 14-9-29.
//  Copyright (c) 2014年 zhilifang. All rights reserved.
//

#import "CalendarListViewController.h"
#import "GoogleCalendarData.h"
#import <QuartzCore/QuartzCore.h> 
#import "AnyEvent.h"
#import "LocalCalendarData.h"
#import "Calendar.h"
#import "AT_Account.h"

#define Status @"statusCode"
#define Data   @"data"
#define Google_Items  @"items"
#define PI 3.14159265358979323846 

#define TITLE     @"eventTitle"
#define LOCATION  @"location"
#define STARTDATE  @"startDate"
#define ENDDATE    @"endDate"
#define NOTE       @"note"
#define CACCOUNT   @"calendarAccount"
#define ALERTS     @"alerts"
#define COORDINATE @"coordinate"
#define  REPEAT    @"repeat"

@interface CalendarListViewController ()<UITableViewDataSource,UITableViewDelegate,ASIHTTPRequestDelegate>
@property(strong,nonatomic) UITableView *tableView;
@property(strong,nonatomic) NSMutableArray *selectIndexPathArr;
@property(strong,nonatomic) NSMutableArray *allArr;
@property(assign,nonatomic) BOOL isSelect;
@property(nonatomic,strong) NSMutableArray *requestQueue;

@end

@implementation CalendarListViewController

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
    
    NSLog(@"日历列表：%@",self.googleCalendarDataArr);
    
    self.selectIndexPathArr=[[NSMutableArray alloc] initWithCapacity:0];
    self.allArr=[[NSMutableArray alloc] initWithCapacity:0];
    _requestQueue = @[].mutableCopy;
    
    UIView *calendarview=[[UIView alloc] initWithFrame:[[UIScreen mainScreen] applicationFrame]];
    calendarview.backgroundColor=[UIColor grayColor];
    self.tableView=[[UITableView alloc] initWithFrame:CGRectMake(0, 0, kScreen_Width, kScreen_Height)
 style:UITableViewStyleGrouped];
    self.tableView.delegate=self;
    self.tableView.dataSource=self;
    [calendarview addSubview:self.tableView];
    UIButton *rightBtn=[UIButton buttonWithType:UIButtonTypeCustom];
    rightBtn.frame=CGRectMake(280, 20, 30, 20);
    [rightBtn setBackgroundImage:[UIImage imageNamed:@"Icon_Tick"] forState:UIControlStateNormal];
    [rightBtn addTarget:self action:@selector(synchronizeGoogleData:) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.rightBarButtonItem=[[UIBarButtonItem alloc] initWithCustomView:rightBtn];
    [self.navigationItem setHidesBackButton:YES animated:YES];
    
    UIView *titleView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 200, 40)];
    UILabel* titlelabel=[[UILabel alloc]initWithFrame:titleView.frame];
    titlelabel.textAlignment = NSTextAlignmentCenter;
    titlelabel.font =[UIFont fontWithName:@"Helvetica Neue" size:20.0];
    titlelabel.text = @"Visible Calendars";
    titlelabel.textColor = [UIColor whiteColor];
    [titleView addSubview:titlelabel];
    self.navigationItem.titleView =titleView;
    self.view=calendarview;
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
}


-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    
    for (NSIndexPath *indexPath in self.allArr) {
        id dataObj=[[self.googleCalendarDataArr objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
        
        if ([dataObj isKindOfClass:[GoogleCalendarData class]]) {
            GoogleCalendarData *googleData=(GoogleCalendarData *)dataObj;
            NSDictionary *googleDic=@{@"cid": googleData.Id,@"account":googleData.account,@"summary":googleData.summary,@"timeZone":googleData.timeZone,@"backgroundColor":googleData.backgroundColor,@"type":@(AccountTypeGoogle),@"isVisible":@(0),@"isDefault":@(0),@"isNotification":@(0)};
            
            ASIHTTPRequest *googleRequest=[t_Network httpPostValue:@{@"cid":googleData.Id}.mutableCopy Url:Get_Google_GetCalendarEvent Delegate:self Tag:Get_Google_GetCalendarEvent_Tag userInfo:@{@"googleData":googleDic}];
            [g_ASIQuent addOperation:googleRequest];
            [self addRequestTAG:Get_Google_GetCalendarEvent_Tag];
            
        }else if ([dataObj isKindOfClass:[LocalCalendarData class]]){
            LocalCalendarData *localData=(LocalCalendarData *)dataObj;
            NSDictionary *localDic=@{@"cid": localData.Id,@"account":localData.emailAccount,@"summary":localData.calendarName,@"timeZone":[[NSTimeZone defaultTimeZone] name],@"backgroundColor":localData.color,@"type":@(AccountTypeLocal),@"isVisible":@(0),@"isDefault":@(0),@"isNotification":@(0)};
            
            ASIHTTPRequest *localRequest=[t_Network httpGet:@{@"cid":localData.Id}.mutableCopy Url:Local_SingleEventOperation Delegate:self Tag:Local_SingleEventOperation_Tag userInfo:@{@"localData":localDic}];
            [g_ASIQuent addOperation:localRequest];
            [self addRequestTAG:Local_SingleEventOperation_Tag];
        }
    }
    
    [g_ASIQuent go];
    

}

//取消网络请求队列
-(void)cancelNetWorkrequestQueue{
    for (ASIHTTPRequest *request in g_ASIQuent.operations) {
        if (request) {
            [_requestQueue enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                int requestTag = [obj intValue];
                if (request.tag == requestTag) {
                    NSLog(@"取消网络请求队列.......%d",requestTag);
                    [request clearDelegatesAndCancel];
                }
            }];
        }
    }
}

-(void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
    [self cancelNetWorkrequestQueue];
}

-(void)addRequestTAG:(int) TAG
{
    [_requestQueue addObject:[[NSNumber numberWithInt:TAG] stringValue]];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return self.googleCalendarDataArr.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSArray *dataArr=[self.googleCalendarDataArr objectAtIndex:section];
    return dataArr.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *cellIdentifier=@"googleIdentifier";
    UITableViewCell *viewCell=[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (!viewCell) {
        viewCell=[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault  reuseIdentifier:cellIdentifier];
    }
    NSArray *calendarListArr=[self.googleCalendarDataArr objectAtIndex:indexPath.section];
    if (!self.isSelect) {
        viewCell.accessoryType=UITableViewCellAccessoryCheckmark;
      
        [self.selectIndexPathArr addObject:indexPath];
        [self.allArr addObject:indexPath];
        if (indexPath.section==self.googleCalendarDataArr.count-1) {
            if(indexPath.row==calendarListArr.count-1){
                  self.isSelect=YES;
            }
        }
    }
    id tmpObj=[calendarListArr objectAtIndex:indexPath.row];
    if ([tmpObj isKindOfClass:[GoogleCalendarData class]]) {
        GoogleCalendarData *data=(GoogleCalendarData*)tmpObj;
        viewCell.textLabel.text=data.summary;
    }else if([tmpObj isKindOfClass:[LocalCalendarData class]]){
        LocalCalendarData *data=(LocalCalendarData*)tmpObj;
        viewCell.textLabel.text=data.calendarName;
    }
    return viewCell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell * cell=(UITableViewCell*)[tableView cellForRowAtIndexPath:indexPath];
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (cell.accessoryType==UITableViewCellAccessoryCheckmark) {
        cell.accessoryType=UITableViewCellAccessoryNone;
        [self.selectIndexPathArr removeObject:indexPath];
    }else{
        cell.accessoryType=UITableViewCellAccessoryCheckmark;
        [self.selectIndexPathArr addObject:indexPath];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 20.f;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    NSArray *calendarListArr=[self.googleCalendarDataArr objectAtIndex:section];
    id tmpObj=[calendarListArr objectAtIndex:0];
    NSString *returnStr=@"";
    if ([tmpObj isKindOfClass:[GoogleCalendarData class]]) {
        GoogleCalendarData *data=(GoogleCalendarData*)tmpObj;
        returnStr=[NSString stringWithFormat:@"GOOGLE(%@)",data.account];
    }else if([tmpObj isKindOfClass:[LocalCalendarData class]]){
        LocalCalendarData *data=(LocalCalendarData*)tmpObj;
        returnStr=[NSString stringWithFormat:@"LOCAL(%@)",data.emailAccount];
    }
    
    UILabel *label=[[UILabel alloc] init] ;
    label.frame=CGRectMake(12, 0, 300, 22);
    label.backgroundColor=[UIColor clearColor];
    label.textColor=[UIColor grayColor];
    label.text=returnStr;
    
    UIView *sectionView=[[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.bounds.size.width, 22)];
    [sectionView setBackgroundColor:[UIColor clearColor]];
    [sectionView addSubview:label];
    return sectionView;
}

//同步google事件数据
-(void)synchronizeGoogleData:(UIButton*) sender{
    
    [[AppDelegate getAppDelegate] initMainView];
}


- (void)requestFinished:(ASIHTTPRequest *)request{
    NSString *responseStr=[request responseString];
    NSLog(@"%@",responseStr);
    switch (request.tag) {
        case Get_Google_GetCalendarEvent_Tag:{
            NSDictionary *eventDic=[responseStr objectFromJSONString];
            NSString *status=[eventDic objectForKey:Status];
            if ([@"1" isEqualToString:status]) {//状态成功
                NSMutableDictionary *userinfo= [[request.userInfo objectForKey:@"googleData"] mutableCopy];
                id eventData=[eventDic objectForKey:Data];
                NSMutableSet *googleSet=[NSMutableSet setWithCapacity:0];
                Calendar *calendar=[Calendar MR_createEntity];
                if (userinfo) {
                    for (NSIndexPath *indexPath in self.selectIndexPathArr) {
                        id dataObj=[[self.googleCalendarDataArr objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
                        if ([dataObj isKindOfClass:[GoogleCalendarData class]]) {
                            GoogleCalendarData *gcd=(GoogleCalendarData *)dataObj;
                            if ([[userinfo objectForKey:@"cid"] isEqualToString:gcd.Id]) {
                                [userinfo setObject:@(1) forKey:@"isVisible"];
                            }
                        }
                    }
                }
                
                if ([eventData isKindOfClass:[NSDictionary class]]) {
                    NSDictionary *eventDataDic=(NSDictionary *)eventData;
                    NSArray *eventArr=[eventDataDic objectForKey:Google_Items];
                    for (NSDictionary *event in eventArr) {
                        NSMutableDictionary *eventDic=[event mutableCopy];
                        [eventDic setObject:calendar forKey:@"calendar"];
                        [googleSet addObject:[self paseEventData:eventDic] ];
                    }
                }
                [self paseUserInfo:userinfo calendarData:calendar];
                [calendar addAnyEvent:googleSet];
                
                for (AT_Account *at in self.calendarAccountArr) {
                    if (at.accountType==[NSNumber numberWithInt:AccountTypeGoogle]) {
                        [at addCaObject:calendar];
                    }
                }

                [[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreAndWait];
            }
            break;
         }
        case Local_SingleEventOperation_Tag:{
            NSDictionary *eventDic=[responseStr objectFromJSONString];
            NSString *status=[eventDic objectForKey:Status];
            if ([@"1" isEqualToString:status]) {//状态成功
                NSMutableDictionary *userinfo= [[request.userInfo objectForKey:@"localData"] mutableCopy];
                id eventData=[eventDic objectForKey:Data];
                NSMutableSet *localSet=[NSMutableSet setWithCapacity:0];
                Calendar *calendar=[Calendar MR_createEntity];
                
               if (userinfo) {
                 for (NSIndexPath *indexPath in self.selectIndexPathArr) {
                    id dataObj=[[self.googleCalendarDataArr objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
                    if ([dataObj isKindOfClass:[LocalCalendarData class]]) {
                        LocalCalendarData *lcd=(LocalCalendarData *)dataObj;
                        if ([[userinfo objectForKey:@"cid"] isEqualToString:lcd.Id]) {
                            [userinfo setObject:@(1) forKey:@"isVisible"];
                        }
                    }
                 }
                
                 if ([eventData isKindOfClass:[NSDictionary class]]) {
                    NSDictionary *eventDataDic=(NSDictionary *)eventData;
                    NSArray *eventArr=[eventDataDic objectForKey:Google_Items];
                    for (NSMutableDictionary *event in eventArr) {
                        [event setObject:calendar forKey:@"calendar"];
                       // [localSet addObject:[self paseEventData:event] ];
                    }
                 }
                [self paseUserInfo:userinfo calendarData:calendar];
                [calendar addAnyEvent:localSet];
                for (AT_Account *at in self.calendarAccountArr) {
                       if (at.accountType== [NSNumber numberWithInt:AccountTypeLocal] ) {
                           [at addCaObject:calendar];
                       }
                }
                [[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreAndWait];
             }
            }
            break;
        }
        default:
            break;
    }
}


-(void)paseUserInfo:(NSDictionary *) userInfo  calendarData:(Calendar *) calendar{
    
    calendar.account =[userInfo objectForKey:@"account"];
    calendar.backgroundColor =[userInfo objectForKey:@"backgroundColor"];
    calendar.cid =[userInfo objectForKey:@"cid"];
    calendar.isDefault =[userInfo objectForKey:@"isDefault"];
    calendar.isNotification= [userInfo objectForKey:@"isNotification"];
    calendar.isVisible =[userInfo objectForKey:@"isVisible"];
    calendar.summary= [userInfo objectForKey:@"summary"];
    calendar.timeZone =[userInfo objectForKey:@"timeZone"];
    calendar.type =[userInfo objectForKey:@"type"];
    
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
    
    anyEvent.created=[dataDic objectForKey:@"created"];
    anyEvent.updated=[dataDic objectForKey:@"updated"];
    
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


@end
