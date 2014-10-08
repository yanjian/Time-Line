//
//  CalendarListViewController.m
//  Time-Line
//
//  Created by IF on 14-9-29.
//  Copyright (c) 2014年 zhilifang. All rights reserved.
//

#import "CalendarListViewController.h"
#import "GoogleCalendarData.h"
#import "AppDelegate.h"
#import <QuartzCore/QuartzCore.h> 
#import "AnyEvent.h"
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
    self.navigationItem.title=@"Visible Calendars";
    
    
    self.view=calendarview;
    // Do any additional setup after loading the view.
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.googleCalendarDataArr.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *cellIdentifier=@"googleIdentifier";
    UITableViewCell *viewCell=[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (!viewCell) {
        viewCell=[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault  reuseIdentifier:cellIdentifier];
    }
    if (!self.isSelect) {
        viewCell.accessoryType=UITableViewCellAccessoryCheckmark;
        [self.selectIndexPathArr addObject:indexPath];
        if (indexPath.row==self.googleCalendarDataArr.count-1) {
            self.isSelect=YES;
        }
    }
    GoogleCalendarData *data=(GoogleCalendarData*)[self.googleCalendarDataArr objectAtIndex:indexPath.row];
    
    viewCell.textLabel.text=data.summary;
    
    return viewCell;
}


- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    GoogleCalendarData *data=(GoogleCalendarData*)[self.googleCalendarDataArr objectAtIndex:section];
    return data.Id;

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
    return 26;
}


//同步google事件数据
-(void)synchronizeGoogleData:(UIButton*) sender{
    for (NSIndexPath *indexPath in self.selectIndexPathArr) {
        GoogleCalendarData *googleData=[self.googleCalendarDataArr objectAtIndex:indexPath.row];
        NSLog(@"cid==========%@",googleData.Id);
        ASIHTTPRequest *request=[t_Network httpPostValue:@{@"cid":googleData.Id}.mutableCopy Url:Get_Google_GetCalendarEvent Delegate:self Tag:Get_Google_GetCalendarEvent_Tag];
        [request startSynchronous];
    }
    [[AppDelegate getAppDelegate] initMainView];
}


- (void)requestFinished:(ASIHTTPRequest *)request{
    NSString *reponseData=[request responseString];
    NSLog(@"event-data:%@",reponseData);
    
  //  NSString *plistPath=getSysDocumentsDir;
    
    
    NSDictionary *eventDic=[reponseData objectFromJSONString];
    NSString *status=[eventDic objectForKey:Google_Status];
    if ([@"1" isEqualToString:status]) {//状态成功
        id eventData=[eventDic objectForKey:google_Data];
        if ([eventData isKindOfClass:[NSDictionary class]]) {
            NSDictionary *eventDataDic=(NSDictionary *)eventData;
            NSArray *eventArr=[eventDataDic objectForKey:Google_Items];
            for (NSDictionary *event in eventArr) {
              //  NSMutableDictionary *data = [[NSMutableDictionary alloc] initWithContentsOfFile:plistPath];
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
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
