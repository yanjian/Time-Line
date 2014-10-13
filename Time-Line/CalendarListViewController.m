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
#define Google_Status @"statusCode"
#define google_Data   @"data"
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
@property(assign,nonatomic) BOOL isSelect;

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
        returnStr=[NSString stringWithFormat:@"GOOGLE(%@)",data.Id];
    }else if([tmpObj isKindOfClass:[LocalCalendarData class]]){
        NSUserDefaults *userInfo=[NSUserDefaults standardUserDefaults];
        NSString *email=[userInfo valueForKey:@"email"];
        returnStr=email;
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
    [NSManagedObject cleanTable:NSStringFromClass([AnyEvent class])];//用户每次同步都清空数据库中的数据
    for (NSIndexPath *indexPath in self.selectIndexPathArr) {
        id dataObj=[[self.googleCalendarDataArr objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
        
        if ([dataObj isKindOfClass:[GoogleCalendarData class]]) {
            GoogleCalendarData *googleData=(GoogleCalendarData *)dataObj;
            ASIHTTPRequest *request=[t_Network httpPostValue:@{@"cid":googleData.Id}.mutableCopy Url:Get_Google_GetCalendarEvent Delegate:self Tag:Get_Google_GetCalendarEvent_Tag];
             [request startSynchronous];
            
        }else if ([dataObj isKindOfClass:[LocalCalendarData class]]){
          LocalCalendarData *localData=(LocalCalendarData *)dataObj;
          ASIHTTPRequest *request=[t_Network httpGet:@{@"cid":localData.Id}.mutableCopy Url:Local_SingleEventOperation Delegate:self Tag:Local_SingleEventOperation_Tag];
            [request startSynchronous];
        }
    }
    NSMutableArray *tmpArr=[g_AppDelegate loadDataFromFile:calendarList];
    if (tmpArr&&tmpArr.count>0) {
        for (id calendar in self.googleCalendarDataArr) {
            [tmpArr addObject:calendar];
        }
        [g_AppDelegate saveFileWithArray:tmpArr fileName:calendarList];
    }else{
        [g_AppDelegate saveFileWithArray:[self.googleCalendarDataArr mutableCopy] fileName:calendarList];
    }
    
    [[AppDelegate getAppDelegate] initMainView];
}


- (void)requestFinished:(ASIHTTPRequest *)request{
    NSString *reponseData=[request responseString];
    NSLog(@"event-data:%@",reponseData);
    NSDictionary *eventDic=[reponseData objectFromJSONString];
    NSString *status=[eventDic objectForKey:Google_Status];
    if ([@"1" isEqualToString:status]) {//状态成功
        id eventData=[eventDic objectForKey:google_Data];
        if ([eventData isKindOfClass:[NSDictionary class]]) {
            NSDictionary *eventDataDic=(NSDictionary *)eventData;
            NSArray *eventArr=[eventDataDic objectForKey:Google_Items];
            for (NSDictionary *event in eventArr) {
                [self saveGoogleEventData:event];
            }
        }
    }
}


-(void)saveGoogleEventData:(NSDictionary *) dataDic
{
    NSLog(@"%@",dataDic);
    //事件存储库
    
    NSString *startTime= [[dataDic objectForKey:@"start"] objectForKey:@"dateTime"];
    NSString *statrstring=[self formatWithStringDate: startTime];
    NSMutableDictionary *googleDataDic=[[NSMutableDictionary alloc] initWithCapacity:0];
    [googleDataDic setObject:[dataDic objectForKey:@"summary"] forKey:TITLE];
    if ([dataDic objectForKey:@"location"]) {
        [googleDataDic setObject:[dataDic objectForKey:@"location"] forKey:LOCATION];
    }
    
    [googleDataDic setObject:statrstring forKey:STARTDATE];
    [googleDataDic setObject:[self formatWithStringDate:[[dataDic objectForKey:@"end"] objectForKey:@"dateTime"]] forKey:ENDDATE];
    
    if ([dataDic objectForKey:@"description"]) {
        [googleDataDic setObject:[dataDic objectForKey:@"description"] forKey:NOTE];
    }
    
  
//    NSString *coor=@"";
//    if (coordinates) {
//        coor=[NSString stringWithFormat:@"%@,%@",[coordinates objectForKey:LATITUDE],[coordinates objectForKey:LONGITUDE]];
//    }
//    [googleDataDic setObject:coor forKey:COORDINATE];
//    
//    NSString * alertStr=@"";
//    if( selectAlertArr) {
//        alertStr=[selectAlertArr componentsJoinedByString:@","];
//    }
//    [googleDataDic setObject:alertStr forKey:ALERTS];
//    [googleDataDic setObject:localfiled.text forKey:CACCOUNT];
//    
//    
//    NSString * repeatStr=@"";
//    if(selectRepeatArr) {
//        repeatStr=[selectRepeatArr componentsJoinedByString:@","];
//    }
//    [googleDataDic setObject:repeatStr forKey:REPEAT];
    
    [NSManagedObject addObject_sync:googleDataDic toTable:NSStringFromClass([AnyEvent class])];
    
    
    
    
    
//    NSString *startTime= [[dataDic objectForKey:@"start"] objectForKey:@"dateTime"];
//    NSString *statrstring=[self formatWithStringDate: startTime];
//    
//    NSRange strRange=  [statrstring rangeOfString:@"日"];
//    NSString *startDate=[statrstring substringWithRange:NSMakeRange(0, strRange.location+1)];
//    if (!data) {
//        data=[NSMutableDictionary dictionaryWithCapacity:0];
//        NSMutableArray *calendarDataArr=[NSMutableArray arrayWithCapacity:0];
//        NSMutableDictionary *dic=[[NSMutableDictionary alloc] initWithCapacity:0];
//        [dic setObject:[dataDic objectForKey:@"id"] forKey:@"eventID"];
//        
//        [dic setObject:[dataDic objectForKey:@"summary"] forKey:TITLE];
//        
//        [dic setObject:[dataDic objectForKey:@"location"] forKey:LOCATION];
//        
//        [dic setObject:statrstring forKey:STARTDATE];
//        
//        [dic setObject: [self formatWithStringDate:[[dataDic objectForKey:@"end"] objectForKey:@"dateTime"]]
//                    forKey:ENDDATE];
//        
//        if ([dataDic objectForKey:@"description"]) {
//            [dic setObject:[dataDic objectForKey:@"description"] forKey:NOTE];
//        }
//        
////        if (coordinates) {
////            [dataDic setObject:[dataDic objectForKey:@"id"] forKey:COORDINATE];
////        }
//        //[dataDic setObject:[dataDic objectForKey:@"id"] forKey:ALERTS];
//        //[dataDic setObject:localfiled.text forKey:CACCOUNT];
//        //[dataDic setObject:[dataDic objectForKey:@"id"] forKey:REPEAT];
//        [calendarDataArr addObject:dic];
//        [data setObject:calendarDataArr forKey:startDate];
//        
//    }else{
//        NSMutableArray *calendarDataArr=[data valueForKey:startDate];
//        if (!calendarDataArr) {
//            calendarDataArr=[[NSMutableArray alloc] initWithCapacity:0];
//            [data setObject:calendarDataArr forKey:startDate];
//        }
//        //用于存放要保存的数据
//        NSMutableDictionary *arrdic=[[NSMutableDictionary alloc] initWithCapacity:0];
//        [arrdic setObject:[dataDic objectForKey:@"id"] forKey:@"eventID"];
//        
//        [arrdic setObject:[dataDic objectForKey:@"summary"] forKey:TITLE];
//        
//        if ([dataDic objectForKey:@"location"]) {
//            [arrdic setObject:[dataDic objectForKey:@"location"] forKey:LOCATION];
//        }
//
//        [arrdic setObject:statrstring forKey:STARTDATE];
//        
//        [arrdic setObject: [self formatWithStringDate:[[dataDic objectForKey:@"end"] objectForKey:@"dateTime"]]
//                    forKey:ENDDATE];
//        
//        if ([dataDic objectForKey:@"description"]) {
//            [arrdic setObject:[dataDic objectForKey:@"description"] forKey:NOTE];
//        }
//        
//        [calendarDataArr addObject:arrdic];
//    }
//    [data writeToFile:getSysDocumentsDir atomically:NO];


}


-(NSString *) formatWithStringDate:(NSString *) dateString
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setLocale:[[NSLocale alloc]initWithLocaleIdentifier:@"en_US_POSIX"]];
    [dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ssZ"];
    NSDate *dateTime = nil;
    [dateFormatter getObjectValue:&dateTime forString:dateString range:nil error:nil];
    [dateFormatter setDateFormat:@"YYYY年 M月d日HH:mm"];
    return [dateFormatter stringFromDate:dateTime];
}
@end
