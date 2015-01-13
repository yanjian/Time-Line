//
//  AddEventViewController.m
//  Time-Line
//
//  Created by connor on 14-3-26.
//  Copyright (c) 2014年 connor. All rights reserved.
//

#import "AddEventViewController.h"
#import "ViewController.h"
#import "CLEvent.h"
#import "AlertViewController.h"
#import "AppDelegate.h"
#import "LocationViewController.h"
#import <CoreLocation/CLGeocoder.h>
#import <CoreLocation/CLPlacemark.h>
#import "GoogleMapViewController.h"
#import "AnyEvent.h"
#import "CalendarAccountViewController.h"
#import "CircleDrawView.h"
#import "CalendarDateUtil.h"
#import "RepeatViewController.h"
#import "IBActionSheet.h"
#import "RecurrenceModel.h"
#import "AnyEvent.h"

#define TITLE     @"eventTitle"
#define LOCATION  @"location"
#define STARTDATE  @"startDate"
#define ENDDATE    @"endDate"
#define NOTE       @"note"
#define CACCOUNT   @"calendarAccount"
#define ALERTS     @"alerts"
#define COORDINATE @"coordinate"
#define  REPEAT    @"repeat"

@interface AddEventViewController () <ASIHTTPRequestDelegate,CalendarAccountDelegate,IBActionSheetDelegate,UITableViewDataSource,UITableViewDelegate,RepeatViewControllerDelegate>
{
    UITableView *_tableView;
    UITextField* textfiled;
    UILabel *_textlable;
    
    NSMutableDictionary* eventDic;
    UILabel* startlabel;
    UILabel* endlabel;
    NSArray* alertarr;
    UIButton *intervalbtn;
    
    UITextField* localfiled;
    UILabel*_locallable;
    UIButton *_localtionBtn;//地图点击事件
    UIImageView *addressIcon;
    
    NSMutableArray *alertButtonArr;//存放alert按钮
    NSMutableArray *selectAlertArr;//存放用户选择的提醒时间
    NSMutableArray *selectRepeatArr;//现在的重复事件 如：每天，每周，等
    
    UIButton* addImage;
    NSString* imagename;
    UITextField* notefiled;
    UILabel* people;
    UILabel* calendar;
    NSString* startString;
    NSString* endString;
    NSMutableArray* alarmArray;
    UILabel* timealert;
    UILabel* peoplelabel;
    UILabel* calendarlabel;
    NSDictionary *coordinates;
    UILabel *_CAlable;
    BOOL isUse;
    BOOL isReadFlag;//编辑是取数据只执行一次！
    UILabel *_calendarLab;
    
    UIView *startView;
    UIView *endView;
    UILabel *directionLab;
    NSString *nowDay;//新增事件时，默认时间为当前时间
    BOOL isAllDay;//是不是全天事件
    UILabel *allDayStartLable;
    
    UILabel* repeatContent;
    UILabel* repeatLabel;
    AnyEvent *eventData;
    RecurrenceModel *recurObj;
    
    BOOL isClickEdit;
    
}
@property (nonatomic,assign) BOOL isShowMap;//地图是否显示
@property (nonatomic,assign) NSInteger alertCount;//设置的闹钟数
@property (nonatomic,strong) Calendar *calendarObj;

@end

@implementation AddEventViewController

@synthesize state,dateDic,dateArr,event;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
    }
    return self;
}




- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.navigationController.navigationBarHidden=NO;
   // self.navigationController.navigationBar.translucent=NO;
    self.navigationController.navigationBar.barTintColor =blueColor;
    _tableView=[[UITableView alloc] initWithFrame:CGRectMake(0, 64, kScreen_Width, kScreen_Height) style:UITableViewStylePlain];
    _tableView.delegate=self;
    _tableView.dataSource=self;
    self.view =_tableView ;
 
    
    UIButton *leftBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [leftBtn setBackgroundImage:[UIImage imageNamed:@"Icon_Cross"] forState:UIControlStateNormal];
    [leftBtn setFrame:CGRectMake(0, 2, 25, 25)];
    [leftBtn addTarget:self action:@selector(onClickCancel) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]initWithCustomView:leftBtn];
    
    
    UIButton*  rightBtn_arrow = [UIButton buttonWithType:UIButtonTypeCustom];
    [rightBtn_arrow setBackgroundImage:[UIImage imageNamed:@"Icon_Tick"] forState:UIControlStateNormal];
    [rightBtn_arrow setFrame:CGRectMake(0, 2, 30, 25)];
    [rightBtn_arrow addTarget:self action:@selector(onClickAdd) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithCustomView:rightBtn_arrow];
    
    
    UIView *rightView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 200, 40)];
    UILabel* titlelabel=[[UILabel alloc]initWithFrame:rightView.frame];
    titlelabel.textAlignment = NSTextAlignmentCenter;
    titlelabel.font =[UIFont fontWithName:@"Helvetica Neue" size:20.0];
    titlelabel.textColor = [UIColor whiteColor];
    [rightView addSubview:titlelabel];
    self.navigationItem.titleView =rightView;
    
    titlelabel.text = @"New Event";
    if ([state isEqualToString:@"edit"]) {
        titlelabel.text=@"Edit Event";
    }
    
    eventDic=[[NSMutableDictionary alloc]initWithCapacity:0];
    alertButtonArr=[[NSMutableArray alloc] initWithCapacity:0];//存放alert按钮的array
    selectAlertArr=[[NSMutableArray alloc] initWithCapacity:0];
    selectRepeatArr=[[NSMutableArray alloc] initWithCapacity:0];
    
    [self InitUI];
    
    if ([state isEqualToString:@"edit"]) {
        [intervalbtn setHidden:NO];
        UIView* headview=[[UIView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 60)];
        UIButton* button=[UIButton buttonWithType:UIButtonTypeCustom];
        button.backgroundColor=purple;
        button.frame=CGRectMake(20, 5, 280, 40);
        [button setTitle:@"Delete Event" forState:UIControlStateNormal];
        [button.layer setMasksToBounds:YES];
        [button.layer setCornerRadius:10.f];
        [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [button addTarget:self action:@selector(deleteEvent) forControlEvents:UIControlEventTouchUpInside];
        [headview addSubview:button];
        _tableView.tableFooterView=headview;
    }else{
        startlabel.text=@"Time";
        if(self.nowTimeDay){
            NSString *tmpNow=[[PublicMethodsViewController getPublicMethods] getcurrentTime:@"YYYY年 M月d日HH:mm"];
            NSString *selectDate=[self.nowTimeDay description];
            if ([tmpNow hasPrefix:selectDate]) {//选择的时间是跟当前时间一样
                nowDay=tmpNow;
            }else{
                  NSString *tmpTime=[[PublicMethodsViewController getPublicMethods] formaterStringfromDate:@"HH:mm" dateString: tmpNow];
                nowDay=[NSString stringWithFormat:@"%@%@",selectDate,tmpTime];
            }
        }else{
          nowDay=[[PublicMethodsViewController getPublicMethods] getcurrentTime:@"YYYY年 M月d日HH:mm"];
        }
    }

    if (event) {
        NSPredicate *pre=[NSPredicate predicateWithFormat:@"cid==%@",event.cId];
        NSArray * caArr= [Calendar MR_findAllWithPredicate:pre];
        self.calendarObj= [caArr lastObject];
    }else{
        //查询默认日历
        NSPredicate *pre=[NSPredicate predicateWithFormat:@"isDefault==1"];
        self.calendarObj=[[Calendar MR_findAllWithPredicate:pre] lastObject];
    }
    
}

-(void)InitUI{
    _textlable = [[UILabel alloc] initWithFrame:CGRectMake(0, 5, self.view.frame.size.width, 20)];
    textfiled=[[UITextField alloc]initWithFrame:CGRectMake(0, 20, self.view.frame.size.width, 64)];
    textfiled.delegate = self;
    textfiled.tag = 3;
    textfiled.font=[UIFont boldSystemFontOfSize:15.0f];
    textfiled.textAlignment=NSTextAlignmentCenter;
    [textfiled setBorderStyle:UITextBorderStyleNone];
    
    _locallable = [[UILabel alloc] initWithFrame:CGRectMake(0, 5, self.view.frame.size.width, 20)];
    localfiled=[[UITextField alloc]initWithFrame:CGRectMake(0, 20, self.view.frame.size.width, 64)];
    localfiled.textAlignment=NSTextAlignmentCenter;
    localfiled.font=[UIFont boldSystemFontOfSize:15.0f];
    localfiled.enabled=NO;
    localfiled.tag=1;
    localfiled.delegate=self;
    
    _localtionBtn=[UIButton buttonWithType:UIButtonTypeCustom];
    _localtionBtn.frame=CGRectMake(5, 0, self.view.frame.size.width-10, 164);
    _localtionBtn.showsTouchWhenHighlighted=NO;
    _localtionBtn.backgroundColor=[UIColor clearColor];
    [_localtionBtn addTarget:self action:@selector(openMapDetails:) forControlEvents:UIControlEventTouchUpInside];
    
    addressIcon=[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"adress_Icon"]];

    startlabel=[[UILabel alloc]initWithFrame:CGRectMake(90, 22, self.view.frame.size.width-150, 25)];
    startlabel.textAlignment=NSTextAlignmentCenter;
    startlabel.font=[UIFont boldSystemFontOfSize:15.0f];
    
    //alert按钮初始化
    NSArray *arr = [[NSArray alloc] initWithObjects:@"1d",@"0.5h",@"5m",@"2d",@"1h",@"10m",@"7d",@"2h",@"15m", nil];
    for (NSUInteger i=0; i<arr.count; i++) {
        UIButton *btn = [[UIButton alloc] init];
        btn.tag = i+10;
        CGRect frame;
        frame.size.width = 40;//设置按钮坐标及大小
        frame.size.height = 40;
        frame.origin.x = (i%3)*(65+35)+45;
        frame.origin.y = floor(i/3)*(30+20)+70;
        [btn setFrame:frame];
        [btn setTitle:[arr objectAtIndex:i] forState:UIControlStateNormal];
        [btn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
         btn.titleLabel.font=[UIFont systemFontOfSize:17.f];
        [btn addTarget:self action:@selector(btnPressed:) forControlEvents:UIControlEventTouchUpInside];
        [alertButtonArr addObject:btn];
    }
    
    _CAlable = [[UILabel alloc] initWithFrame:CGRectMake(0, 5, self.view.frame.size.width, 20)];
   
    _calendarLab = [[UILabel alloc] initWithFrame:CGRectMake(0, 22, self.view.frame.size.width, 62)];
    _calendarLab.textAlignment=NSTextAlignmentCenter;
    _calendarLab.font=[UIFont boldSystemFontOfSize:15.0f];
    _calendarLab.textColor=[UIColor blackColor];

    
    
    notefiled=[[UITextField alloc]initWithFrame:CGRectMake(0,20,self.view.frame.size.width, 64)];
    notefiled.tag=2;
    notefiled.delegate=self;
    notefiled.textAlignment=NSTextAlignmentCenter;
    notefiled.font=[UIFont boldSystemFontOfSize:15.0f];
    notefiled.textColor=[UIColor blackColor];

    peoplelabel=[[UILabel alloc]initWithFrame:CGRectMake(0, 5, self.view.frame.size.width, 20)];
    peoplelabel.backgroundColor=[UIColor clearColor];
    peoplelabel.textAlignment=NSTextAlignmentCenter;
    peoplelabel.font=[UIFont boldSystemFontOfSize:15.0f];
    peoplelabel.text=@"0 Alerts";
    calendarlabel=[[UILabel alloc]initWithFrame:CGRectMake(0, 5, self.view.frame.size.width, 20)];
    
    endlabel=[[UILabel alloc]initWithFrame:CGRectMake(90, 44, self.view.frame.size.width-150, 25)];
    endlabel.textAlignment=NSTextAlignmentCenter;
    endlabel.font=[UIFont boldSystemFontOfSize:15.0f];
    
    
    intervalbtn=[UIButton buttonWithType:UIButtonTypeCustom];
    intervalbtn.frame=CGRectMake(50, 26, 40, 40);
    [intervalbtn setBackgroundImage:[UIImage imageNamed:@"Event_time_red"] forState:UIControlStateNormal];
    intervalbtn.titleLabel.font=[UIFont systemFontOfSize:12.f];
    [intervalbtn setHidden:YES];//设置为隐藏
    
    //事件时间设置（不是同一天）开始事件
    startView=[[UIView alloc] initWithFrame:CGRectMake(60, 0, kScreen_Width/2-50, 84)];
    UILabel *startLab=[[UILabel alloc] initWithFrame:CGRectMake(0, 10, startView.frame.size.width, 25)];
    startLab.tag=1;
    startLab.textAlignment=NSTextAlignmentCenter;
    startLab.font=[UIFont boldSystemFontOfSize:15.0f];
    UILabel *starttimeLab=[[UILabel alloc] initWithFrame:CGRectMake(0, 35, startView.frame.size.width, 25)];
    starttimeLab.tag=2;
    starttimeLab.textAlignment=NSTextAlignmentCenter;
    starttimeLab.font=[UIFont boldSystemFontOfSize:15.0f];

    
    [startView addSubview:startLab];
    [startView addSubview:starttimeLab];
    //结束时间日期显示地方
    endView=[[UIView alloc] initWithFrame:CGRectMake(kScreen_Width/2+20, 0, kScreen_Width/2-50, 84)];
    UILabel *endLab=[[UILabel alloc] initWithFrame:CGRectMake(0, 10, endView.frame.size.width, 25)];
    endLab.tag=1;
    endLab.lineBreakMode=NSLineBreakByWordWrapping;
    endLab.textAlignment=NSTextAlignmentCenter;
    endLab.font=[UIFont boldSystemFontOfSize:15.0f];
    UILabel *endtimeLab=[[UILabel alloc] initWithFrame:CGRectMake(0, 35, endView.frame.size.width, 25)];
    endtimeLab.tag=2;
    endtimeLab.textAlignment=NSTextAlignmentCenter;
    endtimeLab.font=[UIFont boldSystemFontOfSize:15.0f];
    
    [endView addSubview:endLab];
    [endView addSubview:endtimeLab];
    directionLab=[[UILabel alloc] initWithFrame:CGRectMake(168, 26, 20, 25)];
    directionLab.text=@"→";
    [directionLab setHidden:YES];
    addImage.titleLabel.textColor=[UIColor whiteColor];
    addImage.titleLabel.textAlignment=NSTextAlignmentCenter;
    addImage.titleLabel.font=[UIFont boldSystemFontOfSize:17.0f];
    [addImage addTarget:self action:@selector(handleSingleTapFrom) forControlEvents:UIControlEventTouchUpInside];
    
    allDayStartLable=[[UILabel alloc] initWithFrame:CGRectMake(80, 27, kScreen_Width-90, 40)];
    allDayStartLable.textAlignment=NSTextAlignmentCenter;
    allDayStartLable.font=[UIFont boldSystemFontOfSize:15.0f];
    
    //repeat 重复提醒
    repeatLabel=[[UILabel alloc]initWithFrame:CGRectMake(30,0,60, 44)];
    repeatLabel.tag=200;
    repeatLabel.textAlignment=NSTextAlignmentLeft;
    repeatLabel.font=[UIFont boldSystemFontOfSize:15.0f];
    repeatLabel.textColor=[UIColor blackColor];
    repeatLabel.text=@"Repeat";
    repeatContent=[[UILabel alloc]initWithFrame:CGRectMake(repeatLabel.frame.origin.x+repeatLabel.frame.size.width,0,200, 44)];
    repeatContent.textAlignment=NSTextAlignmentRight;
    repeatContent.font=[UIFont boldSystemFontOfSize:15.0f];
    repeatContent.textColor=[UIColor blackColor];
    repeatContent.text=@"None";
     self.isOpen = NO;
     self.isShowMap=NO;
}





//删除事件
-(void)deleteEvent{
    isClickEdit=NO;
    IBActionSheet *ibActionSheet=nil;
    if (event.recurrence) {
        ibActionSheet=[[IBActionSheet alloc] initWithTitle:@"Delete" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"This event only",@"This and future events",@"All events in series", nil];
    }else{
        ibActionSheet=[[IBActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:@"Delete Event" otherButtonTitles:nil, nil];
    }
    [ibActionSheet showInView:self.navigationController.view];
    
}


#pragma -ibactionsheet的代理
-(void)actionSheet:(IBActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (buttonIndex==0) {
        if (isClickEdit) {
                AnyEvent *anyEvent= [AnyEvent MR_createEntity];
              //-----------start---------下面值是关键
                anyEvent.eId=[self generateUniqueEventID];

                anyEvent.recurringEventId=event.eId;
                anyEvent.originalStartTime=startString;
                anyEvent.isSync=@(isSyncData_NO);
               if ([self.calendarObj.type intValue]==AccountTypeLocal) {
                   anyEvent.isDelete=@(isDeleteData_NO);
               }else{
                   anyEvent.isDelete=@(isDeleteData_mode);
               }
                anyEvent.status=[NSString stringWithFormat:@"%i",eventStatus_confirmed];//为0表示确认如果有originalStartTime表示是修改的数据
                anyEvent.calendar=self.calendarObj;
             //------------end-----------
                anyEvent.eventTitle=textfiled.text;
                anyEvent.location= localfiled.text;
                anyEvent.startDate= startString;
                anyEvent.endDate= endString;
                anyEvent.note= notefiled.text;
                anyEvent.calendarAccount=_calendarLab.text;
                anyEvent.isAllDay=@(isAllDay);//全天事件 标记
                NSString *coor=nil;
                if (coordinates) {
                    coor=[NSString stringWithFormat:@"%@,%@",[coordinates objectForKey:LATITUDE],[coordinates objectForKey:LONGITUDE]];
                }
                anyEvent.coordinate= coor;
                NSString * alertStr=nil;
                if( selectAlertArr) {
                    alertStr=[selectAlertArr componentsJoinedByString:@","];
                }
                anyEvent.alerts= alertStr;
                
                NSString * repeatStr=nil;
                if(selectRepeatArr) {
                    repeatStr=[selectRepeatArr componentsJoinedByString:@","];
                }
                anyEvent.repeat= repeatStr;
                NSString * nowDate=[[PublicMethodsViewController getPublicMethods] rfc3339DateFormatter:[NSDate new]];
                anyEvent.updated=nowDate;
                anyEvent.created=nowDate;
                anyEvent.creator=event.creator;
                anyEvent.organizer=event.organizer;
                anyEvent.sequence=event.sequence;
                [[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreAndWait];
                for (UIViewController* obj in [self.navigationController viewControllers]) {
                    if ([obj isKindOfClass:[HomeViewController class]]) {
                        HomeViewController *homeVc= (HomeViewController *)obj;
                        homeVc.isRefreshUIData=YES;
                        [self.navigationController popToViewController:homeVc animated:YES];
                    }
                }
//            }else{
//                ASIHTTPRequest *request =  [t_Network httpGet:@{@"cid":event.cId,@"eid":event.eId}.mutableCopy Url:Google_CalendarEventRepeat Delegate:self Tag:Google_CalendarEventRepeat_tag];
//                [request startAsynchronous];
//            }
        }else{
            //在没有网络的情况下先记录删除的事件
            if (event.recurrence&&![@"" isEqualToString:event.recurrence ]) {
                NSLog(@"-------------->>><<<<<>>>>> %@",event.startDate);
                
                AnyEvent *anyEvent= [AnyEvent MR_createEntity];
                
                NSPredicate *pre=[NSPredicate predicateWithFormat:@"cid==%@",event.cId];
                NSArray * caArr= [Calendar MR_findAllWithPredicate:pre];
                Calendar *ca=[caArr lastObject];
                anyEvent.calendar=ca;
                if ([ca.type intValue]==AccountTypeLocal) {//如果是本地日历
                     anyEvent.isDelete=@(isDeleteData_NO);
                     anyEvent.eId=[self generateUniqueEventID];
                }else{
                    anyEvent.isDelete=@(isDeleteData_mode);//记录重复数据中删除的事件
                    NSString *tmpStr=[[PublicMethodsViewController getPublicMethods] getcurrentTime:@"yyyyMMddHHmmsss"];
                    anyEvent.eId=[NSString stringWithFormat:@"%@_%@",event.eId,tmpStr];
                }
                
                anyEvent.isSync=@(isSyncData_NO);//没有同步
                anyEvent.isAllDay=event.isAllDay;//全天事件 标记
                anyEvent.recurringEventId=event.eId;
                anyEvent.status=[NSString stringWithFormat:@"%i",eventStatus_cancelled];
                anyEvent.originalStartTime=event.startDate;
            
                anyEvent.startDate= event.startDate;
                anyEvent.endDate= event.endDate;
                anyEvent.eventTitle=event.eventTitle;
                anyEvent.calendarAccount=event.calendarAccount;
                
                //后面的数据可以不要
                anyEvent.location= event.location;
                anyEvent.note= event.note;
                anyEvent.coordinate= event.coordinate;
                anyEvent.alerts= event.alerts;
                anyEvent.repeat= event.repeat;
                anyEvent.updated=event.updated;
                anyEvent.created=event.created;
                anyEvent.orgDisplayName=event.orgDisplayName;
                anyEvent.creatorDisplayName=event.creatorDisplayName;
                anyEvent.creator=event.creator ;
                anyEvent.organizer=event.organizer ;
            }else{
                NSPredicate *pre=[NSPredicate predicateWithFormat:@"eId==%@ ",event.eId];
                AnyEvent *anyEvent=[[AnyEvent MR_findAllWithPredicate:pre] lastObject];
                Calendar *ca=anyEvent.calendar;
                if (ca) {
                    if ([ca.type intValue]==AccountTypeGoogle) {
                        anyEvent.isSync=@(isSyncData_NO);
                        anyEvent.isDelete=@(isDeleteData_record);
                    }else if([ca.type intValue]==AccountTypeLocal){
                        anyEvent.isDelete=@(isDeleteData_record);
                        anyEvent.status=[NSString stringWithFormat:@"%i",eventStatus_cancelled];
                    }
                    NSString * uniqueFlagNot=[[anyEvent.objectID URIRepresentation] absoluteString];
                    NSLog(@"删除通知的唯一标记：%@",uniqueFlagNot);
                    [self removeLocationNoticeWithName:uniqueFlagNot];
                }
            
            }
            [[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreAndWait];
            for (UIViewController* obj in [self.navigationController viewControllers]) {
                if ([obj isKindOfClass:[HomeViewController class]]) {
                    HomeViewController *homeVc= (HomeViewController *)obj;
                    homeVc.isRefreshUIData=YES;
                    [self.navigationController popToViewController:homeVc animated:YES];
                }
            }

        }
    }else if (buttonIndex==1){
        if(event.recurrence){
            RecurrenceModel *recuMode=[[RecurrenceModel alloc] initRecrrenceModel:event.recurrence];
            NSLog(@"%@",startString) ;
            
            NSPredicate *pre=[NSPredicate predicateWithFormat:@"eId==%@",event.eId];
            NSArray * currEvents= [AnyEvent MR_findAllWithPredicate:pre];
            AnyEvent * currEvent=[currEvents lastObject];
            NSDate *startD= [[PublicMethodsViewController getPublicMethods] formatWithStringDate: startString];
            
            NSDateFormatter *tempFormatter = [[NSDateFormatter alloc]init];
            [tempFormatter setTimeZone:[NSTimeZone defaultTimeZone]];
            [tempFormatter setDateFormat:@"YYYYMMdd"];
            
            recuMode.until=[tempFormatter stringFromDate:startD];
            currEvent.recurrence=[recuMode description];
            currEvent.isSync=@(isSyncData_NO);
            
            if (isClickEdit) {
                //原来的数据重复提醒时间要修改   event
                //新增一条数据
                [self postEvent];
                NSLog(@"%@", [recuMode description]);
            }
            [[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreAndWait];
            for (UIViewController* obj in [self.navigationController viewControllers]) {
                if ([obj isKindOfClass:[HomeViewController class]]) {
                    HomeViewController *homeVc= (HomeViewController *)obj;
                    homeVc.isRefreshUIData=YES;
                    [self.navigationController popToViewController:homeVc animated:YES];
                }
            }
        }
    }else if(buttonIndex==2){
        if (isClickEdit) {
            //修改所有事件数据时用户已经修改过的备份数据  删除
            NSPredicate *pre=[NSPredicate predicateWithFormat:@"recurringEventId==%@",event.eId];
            NSArray *eventArr= [AnyEvent MR_findAllWithPredicate:pre];
            for (AnyEvent *eventTmp in eventArr) {
                if([eventTmp.status intValue]==eventStatus_confirmed){
                     eventTmp.isSync=@(isSyncData_YES);
                    [eventTmp MR_deleteEntity];
                }
            }
            [self editEvent];
        }else{
            [self deleteAllEventsInData];
        }
        [[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreAndWait];
        for (UIViewController* obj in [self.navigationController viewControllers]) {
            if ([obj isKindOfClass:[HomeViewController class]]) {
                HomeViewController *homeVc= (HomeViewController *)obj;
                homeVc.isRefreshUIData=YES;
                [self.navigationController popToViewController:homeVc animated:YES];
            }
        }

    }
}

-(void)deleteAllEventsInData{
    NSPredicate *pre=[NSPredicate predicateWithFormat:@"eId==%@",event.eId];
    AnyEvent *anyEvent=[[AnyEvent MR_findAllWithPredicate:pre] lastObject];
    if ([anyEvent.calendar.type intValue]==AccountTypeLocal) {//本地账号
        anyEvent.isDelete=@(isDeleteData_YES);//数据删除
        anyEvent.isSync=@(isSyncData_NO);//数据没有同步
        NSPredicate *pre=[NSPredicate predicateWithFormat:@"recurringEventId==%@",anyEvent.eId];
        NSArray *childEventArr=[AnyEvent MR_findAllWithPredicate:pre];
        for (AnyEvent *tmpEvent in childEventArr) {
            tmpEvent.isDelete=@(isDeleteData_YES);//数据删除
            tmpEvent.isSync=@(isSyncData_NO);//数据没有同步
        }
    }else{
        anyEvent.isDelete=@(isDeleteData_YES);//数据删除
        anyEvent.isSync=@(isSyncData_NO);//数据没有同步
    }
    NSString * uniqueFlagNot=[[anyEvent.objectID URIRepresentation] absoluteString];
    NSLog(@"删除通知的唯一标记：%@",uniqueFlagNot);
    [self removeLocationNoticeWithName:uniqueFlagNot];//删除通知
}


-(void)viewWillAppear:(BOOL)animated{
    
    alarmArray=[[NSMutableArray alloc]initWithCapacity:0];
    if ([[NSUserDefaults standardUserDefaults] objectForKey:@"alert"]) {
        alarmArray=[[NSUserDefaults standardUserDefaults] objectForKey:@"alert"];
    }
    [_tableView reloadData];

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//取消返回
- (void)onClickCancel
{
    if ([state isEqualToString:@"edit"]) {
        [self.navigationController popViewControllerAnimated:YES];
        return;
    }
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(void)dissViewcontroller{
    //if ([state isEqualToString:@"edit"]) {
        [self.navigationController popViewControllerAnimated:YES];
   // }else{
    //   [self dismissViewControllerAnimated:YES completion:nil];
   // }
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    [textfiled resignFirstResponder];
    [localfiled resignFirstResponder];
    [notefiled resignFirstResponder];
    return YES;
}

-(int)getRandomNumber:(int)from to:(int)to

{

  return (int)(from + (arc4random()%(to -from + 1)));
    
}

#pragma mark - tableview

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 7;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (self.isOpen) {
        if (self.selectIndex.section == section) {
             return 3;
        }
    }
    if (self.isShowMap) {
        if (2==section) {//当是location时为两行
            return 2;
        }
    }
    
    return 1;
}



-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
   if (indexPath.section==4) {
        if (indexPath.row==0) {
            return 200;
        }
    }
    if (self.isShowMap) {
        if (indexPath.section==2) {
            if (indexPath.row==1) {
                return 164;
            }
        }
    }if(indexPath.section==6){
        if (indexPath.row==0) {
           return  44.f;
        }
    }
    return 84;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
        static NSString* cellId=@"addIdentifier";
        UITableViewCell *cell1 = [tableView dequeueReusableCellWithIdentifier:cellId];
        if (cell1 == nil) {
            cell1 = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellId];
        }
        //取消选中行的样式
        cell1.selectionStyle=UITableViewCellSelectionStyleNone;
        //清除contentView中的所有视图
        NSArray *subviews = [[NSArray alloc]initWithArray:cell1.contentView.subviews];
        for (UIView *subview in subviews) {
            [subview removeFromSuperview];
        }
        if (indexPath.section==0) {
            if (indexPath.row==0) {
                [cell1.contentView addSubview:_textlable];
                [cell1.contentView addSubview:textfiled];
                if (![state isEqualToString:@"edit"]) {
                    [textfiled becomeFirstResponder];
                }
            }
        }
        if (indexPath.section==1) {//time 时间显示区
            if (indexPath.row==0) {
                if ([state isEqualToString:@"edit"]) {//事件不为空就是编辑
                    NSString *tmpstartTime;
                    NSString *tmpendTime;
                    if (startString) {
                        tmpstartTime=startString;
                    }else{
                        tmpstartTime=event.startDate;
                    }
                    if (endString) {
                        tmpendTime=endString;
                    }else{
                        tmpendTime=event.endDate;
                    }
                    
                    CLDay *startday=[[CLDay alloc] initWithDate:[[PublicMethodsViewController getPublicMethods] formatWithStringDate:tmpstartTime]];
                    CLDay *endday=[[CLDay alloc] initWithDate:[[PublicMethodsViewController getPublicMethods] formatWithStringDate:tmpendTime]];
                    
                    NSString *startTime=[[PublicMethodsViewController getPublicMethods] formaterStringfromDate:@"HH:mm" dateString: tmpstartTime];
                    NSString *endTime=[[PublicMethodsViewController getPublicMethods] formaterStringfromDate:@"HH:mm" dateString: tmpendTime];
                     NSString *instr=[[PublicMethodsViewController getPublicMethods] timeDifference:tmpendTime getStrart:tmpstartTime ];
                    
                    if ([event.isAllDay boolValue]) {
                        [allDayStartLable setHidden:NO];
                        [startlabel setHidden:YES];
                        [endlabel setHidden:YES];
                        [directionLab setHidden:YES];
                        if (![[startday description] isEqualToString:[endday description]]&&![@"1d" isEqualToString:instr]) {
                            allDayStartLable.text=[NSString stringWithFormat:@"%@ → %@",[startday abbreviationWeekDayMotch],[endday abbreviationWeekDayMotch]];
                        }else{
                            allDayStartLable.text=[NSString stringWithFormat:@"%@ (ALL DAY)",[startday abbreviationWeekDayMotch]];
                        }
                    }else{
                        [allDayStartLable setHidden:YES];
                        if (![[startday description] isEqualToString:[endday description]]) {//开始时间和结束时间不相同 的从新布局
                            for (UILabel *lab in startView.subviews) {
                                if (lab.tag==1) {
                                    lab.lineBreakMode = NSLineBreakByWordWrapping;
                                    lab.text=[startday abbreviationWeekDayMotch];
                                }else if (lab.tag==2){
                                    lab.text=startTime;
                                }                        }
                            for (UILabel *lab in endView.subviews) {
                                if (lab.tag==1) {
                                    lab.lineBreakMode = NSLineBreakByWordWrapping;
                                    lab.text=[endday abbreviationWeekDayMotch];
                                }else if (lab.tag==2){
                                    lab.text=endTime;
                                }
                            }
                   
                            intervalbtn.frame=CGRectMake(35, 18, 40, 40);;
                            [startlabel setHidden:YES];
                            [endlabel setHidden:YES];
                            [directionLab setHidden:NO];
                        }else{
                            startlabel.text=[startday weekDayMotch];
                            endlabel.text=[NSString stringWithFormat:@"%@ → %@",startTime,endTime]  ;
                        }
                     }
                     [intervalbtn setTitle:instr forState:UIControlStateNormal];
                }
                
                if (nowDay) {
                        NSDate *nowDate= [[PublicMethodsViewController getPublicMethods] formatWithStringDate:nowDay];
                        CLDay *now=[[CLDay alloc] initWithDate:nowDate];
                        NSDate *futureDate=[nowDate dateByAddingTimeInterval:60*60];
                        NSString *future=[[PublicMethodsViewController getPublicMethods] stringformatWithDate:futureDate];
                      
                        startString=nowDay;//事件开始时间
                        endString=future;//事件结束时间
                       
                        NSString *startTime=[[PublicMethodsViewController getPublicMethods] formaterStringfromDate:@"HH:mm" dateString: nowDay];
                        NSString *endTime=[[PublicMethodsViewController getPublicMethods] formaterStringfromDate:@"HH:mm" dateString: future];
                        
                         NSString *instr=[[PublicMethodsViewController getPublicMethods] timeDifference:future getStrart:nowDay ];
                        
                        [intervalbtn setTitle:instr forState:UIControlStateNormal];
                        startlabel.text=[now weekDayMotch];
                        endlabel.text=[NSString stringWithFormat:@"%@ → %@",startTime,endTime]  ;
                        [intervalbtn setHidden:NO];
                }
                [cell1.contentView addSubview:directionLab];
                [cell1.contentView addSubview:startView];
                [cell1.contentView addSubview:endView];
                [cell1.contentView addSubview:intervalbtn];
                [cell1.contentView addSubview:startlabel];
                [cell1.contentView addSubview:endlabel];
                [cell1.contentView addSubview:allDayStartLable];
            }
        }
        if (indexPath.section==2){//地图，地址显示区
            if (indexPath.row==0) {
                [cell1.contentView addSubview:_locallable];
                [cell1.contentView addSubview:localfiled];
                if(localfiled.text.length >0){//地图文本不为空
                    NSString *str = localfiled.text;
                    //计算文本的宽度
                    NSDictionary *attribute = @{NSFontAttributeName: [UIFont systemFontOfSize:15]};
                    CGSize size = [str boundingRectWithSize:CGSizeMake(320, 0) options: NSStringDrawingTruncatesLastVisibleLine | NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading attributes:attribute context:nil].size;
                    addressIcon.frame=CGRectMake( (self.view.bounds.size.width/2-size.width/2)-17,25, 10, 15);
                    [localfiled addSubview:addressIcon ];
                }
            }else if (indexPath.row==1){
                [cell1.contentView addSubview:_localtionBtn];
            }
        }
        if (indexPath.section==3){
            if (indexPath.row==0) {
                [cell1.contentView addSubview:_CAlable];
                
                NSDictionary *attribute = @{NSFontAttributeName: [UIFont systemFontOfSize:15]};
                CGSize size = [self.calendarObj.summary boundingRectWithSize:CGSizeMake(320, 0) options: NSStringDrawingTruncatesLastVisibleLine | NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading attributes:attribute context:nil].size;
                CircleDrawView *cd =[[CircleDrawView alloc] initWithFrame:CGRectMake((self.view.bounds.size.width/2-size.width/2)-27, 43, 20, 20)];
                cd.hexString=self.calendarObj.backgroundColor;
                _calendarLab.text=self.calendarObj.summary;
                [cell1.contentView addSubview:cd];
                [cell1.contentView addSubview:_calendarLab];
                [cell1 viewWithTag:0];
            }
        }
        if (indexPath.section==4) {//alerts 提醒
            if (indexPath.row==0) {
                NSArray *array = [[NSArray alloc] initWithObjects:@"Alert_Day.png",@"Alert_Hour.png",@"Alert_Minute.png", nil];
                for (NSUInteger i=0; i<3; i++)
                {
                    UIImageView*imageview = [[UIImageView alloc] init];
                    imageview.frame = CGRectMake(50+(i*100), 30, 30, 30);
                    imageview.image = [UIImage imageNamed:[array objectAtIndex:i]];
                    [cell1.contentView addSubview:imageview];
                }
                for (UIButton *eachBtn in alertButtonArr) {
                    [cell1.contentView addSubview:eachBtn];
                }
                [cell1.contentView addSubview:peoplelabel];
            }
        }
        if (indexPath.section==5) {
            if (indexPath.row==0) {
                [cell1.contentView addSubview:notefiled];
                [cell1.contentView addSubview:calendarlabel];
            }
        }
        if (indexPath.section==6)//重复提醒事件
        {
            if (indexPath.row==0)
            {
                
                [cell1.contentView addSubview:repeatContent];
                [cell1.contentView addSubview:repeatLabel];
            }
        }
            localfiled.placeholder=@"LOCATION";
            _locallable.text = @"                          Location";
            notefiled.placeholder=@"Note";
            calendarlabel.text=@"                              Note";
        
            _CAlable.text = @"                    Calendar Account";

            textfiled.placeholder = @"EVENT TITLE";
            _textlable.text = @"                         Event Title";
        
            if ([state isEqualToString:@"edit"]) {
                if (!isReadFlag) {
                    startString=event.startDate;
                    endString=event.endDate;
                    startlabel.text=[startString substringFromIndex:5];
                    endlabel.text=[endString substringFromIndex:5];
                    notefiled.text=event.note;
                    textfiled.text =event.eventTitle;
                    localfiled.text=event.location;
                    
                    //读取alerts数据
                    NSArray *alertItemArr=nil;
                    if (![event.alerts isEqualToString:@""]) {
                        alertItemArr=[event.alerts componentsSeparatedByString:@","];
                    }
                    self.alertCount=alertItemArr.count;
                    peoplelabel.text=[NSString stringWithFormat:@"%ld Alerts",(long)self.alertCount];
                    for (NSString *alertStr in alertItemArr) {
                        for (UIButton *eachBtn in alertButtonArr) {
                            if ([alertStr isEqualToString:[eachBtn currentTitle]]) {
                               // [eachBtn setBackgroundImage:[UIImage imageNamed:@"Event_time_red"] forState:UIControlStateNormal];
                                [eachBtn setTitleColor:purple forState:UIControlStateNormal];
                                eachBtn.titleLabel.font=[UIFont systemFontOfSize:20.f];
                                [eachBtn setBackgroundColor:[UIColor clearColor]];
                                [selectAlertArr addObject:[eachBtn currentTitle]];
                                [eachBtn setSelected:YES];
                            }
                        }
                        
                    }
                    
                    //读取repeat数据
                    NSArray *repeatItemArr=nil;
                    if (![event.repeat isEqualToString:@""]&&event.repeat) {
                        repeatItemArr=[event.repeat componentsSeparatedByString:@","];
                    }
                    if (event.recurrence&&![event.recurrence isEqualToString:@""]) {
                        recurObj=[[RecurrenceModel alloc] initRecrrenceModel:event.recurrence];
                        repeatContent.text=recurObj.freq;
                    }else{
                        repeatContent.text=@"None";
                    }

                    NSArray *coorArr=nil;
                    if (![event.coordinate isEqualToString:@""]&&event.coordinate) {
                        NSLog(@"%@",event.coordinate);
                        coorArr= [event.coordinate componentsSeparatedByString:@","];
                    }
                    if ([coorArr count]>0) {
                        [self getlocation:event.location coordinate:@{LATITUDE: [coorArr objectAtIndex:0],LONGITUDE:[coorArr objectAtIndex:1]}];
                    }else{
                        [self getlocation:event.location coordinate: nil];
                    }
                    isReadFlag=YES;//默认只取一次值
              }
          }
         return cell1;
}



-(void)openMapDetails:(UIButton *) button
{
    GoogleMapViewController *googleMapCon=[[GoogleMapViewController alloc] init];
    if ([googleMapCon respondsToSelector:@selector(setCoordinateDictionary:)]) {
        [googleMapCon setCoordinateDictionary:coordinates];
    }
    [self.navigationController pushViewController:googleMapCon animated:YES];
    NSLog(@"点击咯地图");
}



-(void)btnPressed:(UIButton *)btn
{
  
    [self publicAlertSeting:btn];
     NSLog(@"按钮tag： %ld",(long)btn.tag);
    for (UIButton *eachBtn in alertButtonArr) {
        if(eachBtn.isSelected){
            NSLog(@"%@",eachBtn.currentTitle);
        }
    }
    
}


-(void)publicAlertSeting:(UIButton *) btn
{
   
    if(!btn.selected) {
        [btn setTitleColor:purple forState:UIControlStateNormal];
        btn.titleLabel.font=[UIFont systemFontOfSize:20.f];
       // [btn setBackgroundImage:[UIImage imageNamed:@"Event_time_red"] forState:UIControlStateNormal];
        [btn setBackgroundColor:[UIColor clearColor]];
        [selectAlertArr addObject:[btn currentTitle]];
        self.alertCount++;
        [btn setSelected:YES];
    }else{
        [btn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        //[btn setBackgroundImage:nil forState:UIControlStateNormal];
        [btn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        btn.titleLabel.font=[UIFont systemFontOfSize:17.f];
        [selectAlertArr removeObject:[btn currentTitle]];
        self.alertCount--;
        [btn setSelected:NO];
    }
    peoplelabel.text=[NSString stringWithFormat:@"%ld Alerts",(long)self.alertCount];
}



-(void)scrollViewDidScroll:(UIScrollView *)scrollView{
    [textfiled resignFirstResponder];
    [localfiled resignFirstResponder];
    [notefiled resignFirstResponder];
    _tableView.frame=CGRectMake(0, 64, _tableView.frame.size.width, _tableView.frame.size.height);
    
    
}

#pragma mark - Table view delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
   if (indexPath.section==1) {
        ViewController* controler=[[ViewController alloc]initWithNibName:@"ViewController" bundle:nil];
        eventData=[AnyEvent MR_createEntity];
        if (event) {
            if (startString) {
                eventData.startDate=startString;
                startString=nil;
            }else{
                eventData.startDate=event.startDate;
            }
            if (endString) {
                eventData.endDate=endString;
                endString=nil;
            }else{
                eventData.endDate=event.endDate;
            }
            [controler addEventViewControler:self anyEvent:eventData];
        }else{
            
            eventData=[AnyEvent MR_createEntity];
            eventData.eventTitle=textfiled.text;
            eventData.location= localfiled.text;
            eventData.startDate= startString;
            eventData.endDate= endString;
            eventData.calendarAccount=_calendarLab.text;
            eventData.isAllDay=@(isAllDay);//全天事件 标记
            [controler addEventViewControler:self anyEvent:eventData];
        }
        controler.detelegate=self;
        [self.navigationController pushViewController:controler animated:YES];
    }else if(indexPath.section==3){
        CalendarAccountViewController *caVC=[[CalendarAccountViewController alloc] init];
        caVC.delegate=self;
        [self.navigationController pushViewController:caVC animated:YES];
    
    }else if(indexPath.section==2){
        LocationViewController *locationView=[[LocationViewController alloc] initWithNibName:@"LocationViewController" bundle:nil];
        locationView.detelegate=self;
        [self.navigationController pushViewController:locationView animated:YES];
    }else if(indexPath.section==6){
        RepeatViewController *repeatVc = [[RepeatViewController alloc] init];
        repeatVc.recurrObj = recurObj;
        repeatVc.delegate=self;
        repeatVc.repeatParam=repeatContent.text;
        [self.navigationController pushViewController:repeatVc animated:YES];
    }
    
}


-(void)selectValueWithDateString:(NSString *) dateString repeatRecurrence:(RecurrenceModel *)recurrence{
    repeatContent.text=dateString;
    recurObj=recurrence;
}
# pragma - calendar account view 的代理 取得选择的日历列表
-(void)calendarAccountWithAccont:(Calendar *)ca{
    NSLog(@"%@",ca);
    self.calendarObj=ca;
    _calendarLab.text=ca.summary;
}




//没有使用到
- (void)didSelectCellRowFirstDo:(BOOL)firstDoInsert nextDo:(BOOL)nextDoInsert
{
    self.isOpen = firstDoInsert;
//    UITableViewCell *cell2 = (UITableViewCell *)[self.tableView cellForRowAtIndexPath:self.selectIndex];
//    [cell2 changeArrowWithUp:firstDoInsert];
    [_tableView beginUpdates];
    int section = self.selectIndex.section;
    int contentCount = 2;
	NSMutableArray* rowToInsert = [[NSMutableArray alloc] init];
	for (NSUInteger i = 1; i < contentCount + 1; i++) {
		NSIndexPath* indexPathToInsert = [NSIndexPath indexPathForRow:i inSection:section];
		[rowToInsert addObject:indexPathToInsert];
	}
	if (firstDoInsert)
    {
        [_tableView insertRowsAtIndexPaths:rowToInsert withRowAnimation:UITableViewRowAnimationTop];
    }
	else
    {
        [_tableView deleteRowsAtIndexPaths:rowToInsert withRowAnimation:UITableViewRowAnimationTop];
    }
	[_tableView endUpdates];
    if (nextDoInsert) {
        self.isOpen = YES;
        self.selectIndex = [_tableView indexPathForSelectedRow];
        [self didSelectCellRowFirstDo:YES nextDo:NO];
    }
    if (self.isOpen)
        [_tableView scrollToNearestSelectedRowAtScrollPosition:UITableViewScrollPositionTop animated:YES];
}



#pragma mark - 时间选择viewController的代理方法 settimedelegate
-(void)getstarttime:(NSString *)start getendtime:(NSString *)end isAllDay:(BOOL)isAll{
    
    nowDay=nil;//清空新增时的默认时间数据
    
    startString=start;
    endString=end;
    
    CLDay *startday=[[CLDay alloc] initWithDate:[[PublicMethodsViewController getPublicMethods] formatWithStringDate:start]];
    CLDay *endday=[[CLDay alloc] initWithDate:[[PublicMethodsViewController getPublicMethods] formatWithStringDate:end]];
    
    NSString *startTime=[[PublicMethodsViewController getPublicMethods] formaterStringfromDate:@"HH:mm" dateString: start];
    NSString *endTime=[[PublicMethodsViewController getPublicMethods] formaterStringfromDate:@"HH:mm" dateString: end];
    
    NSString *instr=[[PublicMethodsViewController getPublicMethods] timeDifference:end getStrart:start ];
    [intervalbtn setTitle:instr forState:UIControlStateNormal];
    [intervalbtn setHidden:NO];
    
    isAllDay=isAll;
    eventData.isAllDay=@(isAllDay);
    if (isAll) {
        [allDayStartLable setHidden:NO];
        [startlabel setHidden:YES];
        [endlabel setHidden:YES];
        [directionLab setHidden:YES];
        [startView setHidden:YES];
        [endView setHidden:YES];
        intervalbtn.frame=CGRectMake(50, 26, 40, 40);
        if (![@"1d" isEqualToString:instr]) {
            allDayStartLable.text=[NSString stringWithFormat:@"%@ → %@",[startday abbreviationWeekDayMotch],[endday abbreviationWeekDayMotch]];
        }else{
            allDayStartLable.text=[NSString stringWithFormat:@"%@ (ALL DAY)",[startday abbreviationWeekDayMotch]];
        }
    }else{
            [allDayStartLable setHidden:YES];
           if (![[startday description] isEqualToString:[endday description]]) {//开始时间和结束时间不相同的 从新布局
                for (UILabel *lab in startView.subviews) {
                    if (lab.tag==1) {
                        lab.lineBreakMode = NSLineBreakByWordWrapping;
                        lab.text=[startday abbreviationWeekDayMotch];
                    }else if (lab.tag==2){
                        lab.text=startTime;
                    }
                }
                for (UILabel *lab in endView.subviews) {
                    if (lab.tag==1) {
                        lab.lineBreakMode = NSLineBreakByWordWrapping;
                        lab.text=[endday abbreviationWeekDayMotch];
                    }else if (lab.tag==2){
                        lab.text=endTime;
                    }
                }
                intervalbtn.frame=CGRectMake(35, 18, 40, 40);
                [startlabel setHidden:YES];
                [endlabel setHidden:YES];
                [directionLab setHidden:NO];
                [startView setHidden:NO];
                [endView setHidden:NO];
        }else{
                intervalbtn.frame=CGRectMake(50, 26, 40, 40);
                startlabel.text=[startday weekDayMotch];
                endlabel.text=[NSString stringWithFormat:@"%@ → %@",startTime,endTime];
                
                [startlabel setHidden:NO];
                [endlabel setHidden:NO];
                
                [directionLab setHidden:YES];
                [startView setHidden:YES];
                [endView setHidden:YES];
        }
    }
}

#pragma mark -代理方法 -- getlocation:coordinate:
-(void)getlocation:(NSString*) name coordinate:(NSDictionary *) coordinatesDic{
    coordinates =  coordinatesDic;
    if (name.length>0) {
        localfiled.text=name;
        if (coordinatesDic) {
            NSString *coordStr= [NSString stringWithFormat:@"%@,%@",[coordinatesDic objectForKey:LATITUDE],[coordinatesDic objectForKey:LONGITUDE] ];
            NSMutableDictionary *paramDic=@{@"center":coordStr,
                                            @"zoom":@"9",
                                            @"size":@"320x164",
                                            @"sensor":@"false",
                                            @"format":@"PNG",
                                            @"markers":coordStr,
                                            @"language":CurrentLanguage,
                                            @"key":GOOGLE_API_KEY }.mutableCopy;
            ASIHTTPRequest *request=[t_Network httpGet:paramDic Url:GOOGLE_ADDRESS_PIC Delegate:self Tag:GOOGLE_ADDRESS_PIC_TAG];
            [request startAsynchronous];
            self.isShowMap=YES;
        }else{
            self.isShowMap=NO;
        }
        [_tableView reloadData];
    }
}

- (void)requestFinished:(ASIHTTPRequest *)request
{
    NSLog(@"%@", [request responseString]);
    switch (request.tag) {
        case GOOGLE_ADDRESS_PIC_TAG:{
            NSError * error=[request error];
            if (error) {
                NSLog(@"请求数据出错：%@",error.debugDescription);
                return;
            }
            if (request.responseString||![@"" isEqualToString:request.responseString]) {
                [_localtionBtn setBackgroundImage:[UIImage imageWithData:[request responseData]] forState:UIControlStateNormal];
            }else{
                NSLog(@"图片空。。。。。！");
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
                        [eventDics setObject:_calendarObj forKey:@"calendar"];
                        [tmpArr addObject:[self paseGoogleEventData:eventDics]];
                    }
                    
                    for (AT_Event *anEvent in tmpArr) {
                        if([anEvent.startDate isEqualToString:event.startDate]){
                            NSLog(@"-------------->>><<<<<>>>>> %@",anEvent.startDate);
                            AnyEvent *anyEvent= [AnyEvent MR_createEntity];
                            anyEvent.eventTitle=textfiled.text;
                            anyEvent.location= localfiled.text;
                            anyEvent.startDate= startString;
                            anyEvent.endDate= endString;
                            anyEvent.note= notefiled.text;
                            anyEvent.calendarAccount=_calendarLab.text;
                            
                            NSString *coor=nil;
                            if (coordinates) {
                                coor=[NSString stringWithFormat:@"%@,%@",[coordinates objectForKey:LATITUDE],[coordinates objectForKey:LONGITUDE]];
                            }
                            anyEvent.coordinate= coor;
                            NSString * alertStr=nil;
                            if( selectAlertArr) {
                                alertStr=[selectAlertArr componentsJoinedByString:@","];
                            }
                            anyEvent.alerts= alertStr;
                            NSString * repeatStr=nil;
                            if(selectRepeatArr) {
                                repeatStr=[selectRepeatArr componentsJoinedByString:@","];
                            }
                          //  anyEvent.recurrence=[recurObj description];修改这一天不用重复
                            anyEvent.repeat= repeatStr;
                            anyEvent.isSync=@(isSyncData_NO);
                            anyEvent.isAllDay=@(isAllDay);//全天事件 标记
                            anyEvent.eId=anEvent.eId ;
                            anyEvent.updated=anEvent.updated;
                            anyEvent.created=anEvent.created;
                            anyEvent.orgDisplayName=anEvent.orgDisplayName;
                            anyEvent.creatorDisplayName=anEvent.creatorDisplayName;
                            anyEvent.creator=anEvent.creator ;
                            anyEvent.organizer=anEvent.organizer ;
                            anyEvent.sequence=anEvent.sequence;
                            anyEvent.status=anEvent.status;
                            anyEvent.calendar=self.calendarObj;
                            anyEvent.recurringEventId=anEvent.recurringEventId;
                            anyEvent.originalStartTime=anEvent.originalStartTime;
                            
                            [[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreAndWait];
                            for (UIViewController* obj in [self.navigationController viewControllers]) {
                                if ([obj isKindOfClass:[HomeViewController class]]) {
                                    HomeViewController *homeVc= (HomeViewController *)obj;
                                    homeVc.isRefreshUIData=YES;
                                    [self.navigationController popToViewController:homeVc animated:YES];
                                }
                            }
                            

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


#pragma mark getnotesdelegate
-(void)getnotes:(NSString *)notestr{
    NSLog(@"%@",notestr);
    if (notestr.length>0) {
        notefiled.text=notestr;
    }
}


-(void)textFieldDidBeginEditing:(UITextField *)textField{
    if (!(3==textField.tag)) {
        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationDuration:0.3];
        _tableView.frame=CGRectMake(0, -180, _tableView.frame.size.width, _tableView.frame.size.height);
        [UIView commitAnimations];
    }
    NSLog(@"%ld",textField.tag);
    
}





//创建通知
-(void)createLocationNotification:(AnyEvent *) anyEvent
{
    UILocalNotification *notification = [[UILocalNotification alloc] init];
    if (notification!=nil) {
        NSString *startStr=anyEvent.startDate;//事件开始时间
        NSMutableArray *timeSecArr=nil;
        if (anyEvent.alerts&&![anyEvent.alerts isEqualToString:@""]) {
          NSArray *alertsArr=[anyEvent.alerts componentsSeparatedByString:@","];
          timeSecArr=[NSMutableArray arrayWithCapacity:0];
            NSLog(@"%f",[self timeDifference:startStr]);
          for (NSString *alStr in alertsArr) {
                if ([@"1d" isEqualToString:alStr]) {
                    if ([self timeDifference:startStr]>24*60*60) {
                        [timeSecArr addObject:@(24*60*60)] ;
                    }
                }else if ([@"2d" isEqualToString:alStr]) {
                    if ([self timeDifference:startStr]>2*24*60*60) {
                         [timeSecArr addObject:@(2*24*60*60)];
                    }
                }else if ([@"7d" isEqualToString:alStr]) {
                    if ([self timeDifference:startStr]>7*24*60*60) {
                        [timeSecArr addObject:@(7*24*60*60)];
                    }
                }else if ([@"0.5h" isEqualToString:alStr]) {
                    if ([self timeDifference:startStr]>60*60/2) {
                         [timeSecArr addObject:@(60*60/2)];
                    }
                }else if ([@"1h" isEqualToString:alStr]) {
                    if ([self timeDifference:startStr]>60*60) {
                        [timeSecArr addObject:@(60*60)];
                    }
                }else if ([@"2h" isEqualToString:alStr]) {
                    if ([self timeDifference:startStr]>2*60*60) {
                        [timeSecArr addObject:@(2*60*60)];
                    }
                }else if ([@"5m" isEqualToString:alStr]) {
                    if ([self timeDifference:startStr]>5*60) {
                        [timeSecArr addObject:@(5*60)];
                    }
                }else if ([@"10m" isEqualToString:alStr]) {
                    if ([self timeDifference:startStr]>10*60) {
                        [timeSecArr addObject:@(10*60)];
                    }
                }else if ([@"15m" isEqualToString:alStr]) {
                    if ([self timeDifference:startStr]>15*60) {
                         [timeSecArr addObject:@(15*60)];
                    }
                }
            }
        }
        if (timeSecArr&&timeSecArr.count>0) {
            [timeSecArr addObject:@(0)];//表示当前事件的开始时间
            for (NSUInteger i=0; i<timeSecArr.count; i++) {
                NSTimeInterval t=[[timeSecArr objectAtIndex:i] doubleValue];
                NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
                [formatter setDateFormat:@"YYYY年 M月d日HH:mm"];
                //触发通知的时间
                
                //时区
                notification.timeZone = [NSTimeZone defaultTimeZone];
                NSDate *now = [formatter dateFromString:startStr];
                notification.fireDate = [now dateByAddingTimeInterval:-t];

                if (anyEvent.repeat&&![@"" isEqualToString:anyEvent.repeat]) {
                    //通知重复提示的单位，可以是天、周、月
                    NSArray *repeatArr=[anyEvent.repeat componentsSeparatedByString:@","];
                    for (NSString *repeatStr in repeatArr) {
                        if ([@"Daily" isEqualToString:repeatStr]) {
                            notification.repeatInterval = NSDayCalendarUnit;
                        }else if ([@"Weekly" isEqualToString:repeatStr]) {
                            notification.repeatInterval = NSWeekdayCalendarUnit;
                        }else if ([@"Monthly" isEqualToString:repeatStr]) {
                            notification.repeatInterval = NSMonthCalendarUnit;
                        }
                    }
                }
                //通知内容
                NSString *title=anyEvent.eventTitle;
                if (title) {
                    notification.alertBody = title;
                }
                //通知被触发时播放的声音
                notification.soundName = UILocalNotificationDefaultSoundName;
                notification.applicationIconBadgeNumber=[[[UIApplication sharedApplication] scheduledLocalNotifications] count]+1;
                NSString *uniqueFlag=[[anyEvent.objectID URIRepresentation] absoluteString];
                
                NSLog(@"通知唯一标记：%@",uniqueFlag);
                
                NSDictionary *dict =[NSDictionary dictionaryWithObjectsAndKeys:uniqueFlag,anyEventLocalNot_Flag,nil];
                [notification setUserInfo:dict];
                //执行通知注册
                [[UIApplication sharedApplication] scheduleLocalNotification:notification];
            }
        }else{
            NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
            [formatter setDateFormat:@"YYYY年 M月d日HH:mm"];
            //触发通知的时间
            
            //时区
            notification.timeZone = [NSTimeZone defaultTimeZone];
            NSDate *now = [formatter dateFromString:startStr];
            notification.fireDate = now;
        
            if (anyEvent.repeat&&![@"" isEqualToString:anyEvent.repeat]) {
                 //通知重复提示的单位，可以是天、周、月
                NSArray *repeatArr=[anyEvent.repeat componentsSeparatedByString:@","];
                for (NSString *repeatStr in repeatArr) {
                    if ([@"Daily" isEqualToString:repeatStr]) {
                        notification.repeatInterval = NSDayCalendarUnit;
                    }else if ([@"Weekly" isEqualToString:repeatStr]) {
                        notification.repeatInterval = NSWeekdayCalendarUnit;
                    }else if ([@"Monthly" isEqualToString:repeatStr]) {
                        notification.repeatInterval = NSMonthCalendarUnit;
                    }
                }
            }
            //通知内容
            NSString *title=anyEvent.eventTitle;
            if (title) {
                 notification.alertBody = title;
            }
            //通知被触发时播放的声音
            notification.soundName = UILocalNotificationDefaultSoundName;
            notification.applicationIconBadgeNumber=[[[UIApplication sharedApplication] scheduledLocalNotifications] count]+1;
            NSString *uniqueFlag=[[anyEvent.objectID URIRepresentation] absoluteString];
            
            NSLog(@"通知唯一标记：%@",uniqueFlag);
            
            NSDictionary *dict =[NSDictionary dictionaryWithObjectsAndKeys:uniqueFlag,anyEventLocalNot_Flag,nil];
            [notification setUserInfo:dict];
            //执行通知注册
            [[UIApplication sharedApplication] scheduleLocalNotification:notification];
        }
    }
}


/**
 *取消一個通知
 *name 通知的唯一标记名
 *
 */
- (void)removeLocationNoticeWithName:(NSString*)name{
    NSArray *narry=[[UIApplication sharedApplication] scheduledLocalNotifications];
    NSUInteger acount=[narry count];
    if (acount>0)
    {
        for (NSUInteger i=0; i<acount; i++)
        {
            UILocalNotification *myUILocalNotification = [narry objectAtIndex:i];
            NSDictionary *userInfo = myUILocalNotification.userInfo;
            NSString *obj = [userInfo objectForKey:anyEventLocalNot_Flag];
            if ([obj isEqualToString:name])
            {
                // 删除通知
                [[UIApplication sharedApplication] cancelLocalNotification:myUILocalNotification];
                break;
            }
        }
    }
}

-(NSInteger)gettimemonth:(NSArray*)arr{
    //得到当前日期
    //得到当前日期
    CFAbsoluteTime currTime=CFAbsoluteTimeGetCurrent();
    CFGregorianDate currenttDate=CFAbsoluteTimeGetGregorianDate(currTime,CFTimeZoneCopyDefault());
    //得到要提醒的日期
    CFGregorianDate clockDate=CFAbsoluteTimeGetGregorianDate(currTime, CFTimeZoneCopyDefault());
    clockDate.hour=[[arr objectAtIndex:3] integerValue];
    clockDate.minute=[[arr objectAtIndex:4] integerValue];
    clockDate.second=1;
    clockDate.month=[[arr objectAtIndex:1] integerValue];
    clockDate.day=[[arr objectAtIndex:2]integerValue];
    NSLog(@"currdata,year=%ld",currenttDate.year);
    //把两个日期存放到tm类型的变量中
    struct tm t0,t1;
    t0.tm_year=currenttDate.year - 1900;
    t0.tm_mon=currenttDate.month;
    t0.tm_mday=currenttDate.day;
    t0.tm_hour=currenttDate.hour;
    t0.tm_min=currenttDate.minute;
    t0.tm_sec=currenttDate.second;
    
    t1.tm_year=clockDate.year - 1900;
    t1.tm_mon=clockDate.month;
    t1.tm_mday=clockDate.day;
    t1.tm_hour=clockDate.hour;
    t1.tm_min=clockDate.minute;
    t1.tm_sec=clockDate.second;
    
    NSLog(@"%d",t1.tm_yday);
    NSLog(@"time1=%ld ,time2=%ld",mktime(&t1),mktime(&t0));
    NSTimeInterval time=mktime(&t1)-mktime(&t0);
    if (time<0) {
        t1.tm_wday++;
        time=mktime(&t1)-mktime(&t0);
    }
    NSLog(@"相差%f秒",time);
    return time;
}

//当前时间与设置的时间之间的差
- (NSTimeInterval )timeDifference: (NSString*)startdate
{
    NSDate *nowDate=[NSDate new];
    NSTimeInterval now=[nowDate timeIntervalSince1970]*1;
    
    NSDateFormatter *date=[[NSDateFormatter alloc] init];
    [date setDateFormat:@"YYYY年 M月dd日HH:mm"];
    [date setTimeZone: [NSTimeZone defaultTimeZone]];
    NSDate* latedate = [date dateFromString:startdate];
    
    NSTimeInterval late=[latedate timeIntervalSince1970]*1;
    return late-now;
}



//#pragma mark getimagename
//-(void)handleSingleTapFrom{
//    BackGroundViewController* background=[[BackGroundViewController alloc]initWithNibName:@"BackGroundViewController" bundle:nil];
//    background.detelegate=self;
//    [self.navigationController pushViewController:background animated:YES];
//}
//
//-(void)getimage:(NSString *)image{
//    NSLog(@"%@",[image substringToIndex:6]);
//    if ([[image substringToIndex:6] isEqualToString:@"/Users"]) {
//        UIImage* images=[UIImage imageWithContentsOfFile:image];
//        imagename=@"photo.png";
//        [addImage setBackgroundImage:images forState:UIControlStateNormal];
//    }else{
//    imagename=image;
//    [addImage setBackgroundImage:[UIImage imageNamed:image] forState:UIControlStateNormal];
//    }
//    [addImage setTitle:@"CHANGE A PICTURE" forState:UIControlStateNormal];
//}


//添加事件或保存修改
- (void)onClickAdd
{
    
    NSLog(@"点击保存数据");
    if (textfiled.text.length<=0) {
        [textfiled becomeFirstResponder];
        return;
    }
    if ([startlabel.text isEqualToString:@"CHOOSE"])
    {
        UIAlertView* alert=[[UIAlertView alloc]initWithTitle:@"提示:" message:@"请选择时间" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alert show];
        return;
    }
  
    [textfiled resignFirstResponder];
    if ([state isEqualToString:@"edit"]) {
        isClickEdit=YES;
        if (event.recurrence) {
            IBActionSheet *ibActionSheet=[[IBActionSheet alloc] initWithTitle:@"Save for" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"This event only",@"This and future events",@"All events in series", nil];
            [ibActionSheet showInView:self.navigationController.view];
        }else{
            [self editEvent];
        }
    }else {
         [self postEvent];
        
       //  [self dissViewcontroller];
       // [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(dissViewcontroller) userInfo:nil repeats:YES];
       //    [self dismissViewControllerAnimated:YES completion:nil];
    }
}


#pragma -新增事件
- (void)postEvent
{
    if (!eventData) {
        eventData=[AnyEvent MR_createEntity];
    }
    eventData.eId=[self generateUniqueEventID];
    eventData.eventTitle=textfiled.text;
    eventData.location= localfiled.text;
    eventData.startDate= startString;
    eventData.endDate= endString;
    eventData.note= notefiled.text;
    eventData.calendarAccount=_calendarLab.text;
    NSString *coor=nil;
    if (coordinates) {
        coor=[NSString stringWithFormat:@"%@,%@",[coordinates objectForKey:LATITUDE],[coordinates objectForKey:LONGITUDE]];
    }
    eventData.coordinate= coor;

    NSString * alertStr=nil;
    if( selectAlertArr) {
        alertStr=[selectAlertArr componentsJoinedByString:@","];
    }
    eventData.alerts= alertStr;
    NSString * repeatStr=nil;
    if(selectRepeatArr) {
        repeatStr=[selectRepeatArr componentsJoinedByString:@","];
    }
    eventData.repeat= repeatStr;
    eventData.recurrence=[recurObj description];
    eventData.isSync=@(isSyncData_NO);
    eventData.isDelete=@(isDeleteData_NO);//数据非删除
    NSString * nowDate=[[PublicMethodsViewController getPublicMethods] rfc3339DateFormatter:[NSDate new]];
    eventData.updated=nowDate;
    eventData.created=nowDate;
    eventData.creator= [USER_DEFAULT objectForKey:@"email"];
    eventData.organizer= [USER_DEFAULT objectForKey:@"email"];
    eventData.isAllDay=@(isAllDay);//全天事件 标记
    eventData.status=[NSString stringWithFormat:@"%i",eventStatus_confirmed];//新添加的数据为确定状态
    [self.calendarObj addAnyEventObject:eventData];
    
    [[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreWithCompletion:^(BOOL contextDidSave, NSError *error) {
        if (error) {
            NSLog(@"%@",error);
            NSString *idStr=[[[eventData objectID] URIRepresentation] absoluteString];
            [self removeLocationNoticeWithName:idStr];
            return;
        }
        if (contextDidSave) {
            //为事件添加通知
            [self createLocationNotification:eventData];
        }
        
        for (UIViewController* obj in [self.navigationController viewControllers]) {
            if ([obj isKindOfClass:[HomeViewController class]]) {
                HomeViewController *homeVc= (HomeViewController *)obj;
                homeVc.isRefreshUIData=YES;
                [self.navigationController popToViewController:homeVc animated:YES];
            }
        }

    }];
    
//2014年9月18号屏蔽--------------start-----------yj
//    EKEventStore *eventStore = [[EKEventStore alloc] init];
//    if ([eventStore respondsToSelector:@selector(requestAccessToEntityType:completion:)])
//    {
//        [eventStore requestAccessToEntityType:EKEntityTypeEvent completion:^(BOOL granted, NSError *error) {
//            dispatch_async(dispatch_get_main_queue(), ^{
//                if (error)
//                {
//                    NSLog(@"error:%@",error);
//                    //错误细心
//                    // display error message here
//                }
//                else if (!granted)
//                {
//                    //被用户拒绝，不允许访问日历
//                    // display access denied error message here
//                }
//                else
//                {
//                    // access granted
//                    // ***** do the important stuff here *****
//                    
//                    //事件保存到日历
//                    
//                    
//                    //创建事件
//                    EKEvent *event  = [EKEvent eventWithEventStore:eventStore];
//                    event.title =textfiled.text;
//                    event.location =localfiled.text;
//                    event.URL=[NSURL URLWithString:imagename];
//                    NSLog(@"%@-------%@",imagename,event.URL);
//                    NSDate *startDate= [self formatWithStringDate:startString];
//                    event.startDate =startDate;
//                    NSLog(@"%@---------%@",startDate,event.eventIdentifier);
//                    NSDate *endDate=[self formatWithStringDate:endString];
//                    event.endDate= endDate;
//                    event.location = localfiled.text;
//                    event.notes=notefiled.text;
////                  event.allDay = YES;
//                    //添加提醒
//
//                    NSLog(@"%@",seledayArr);
//                    [event addAlarm:[EKAlarm alarmWithRelativeOffset:60.0f]];
//                    [event addAlarm:[EKAlarm alarmWithAbsoluteDate:startDate]];
//                    NSDateFormatter *tempFormatter = [[NSDateFormatter alloc]init];
//                    [seledayArr removeObjectAtIndex:0];
//                    for (NSString* str in seledayArr) {
//                        [event addAlarm:[EKAlarm alarmWithRelativeOffset:60.0f]];
//                        [event addAlarm:[EKAlarm alarmWithAbsoluteDate:[tempFormatter dateFromString:[NSString stringWithFormat:@"%@08:00",str]]]];
//                    }
//                    
//                    [event setCalendar:[eventStore defaultCalendarForNewEvents]];
//                    NSError *err;
//                    BOOL bSave = [eventStore saveEvent:event span:EKSpanThisEvent error:&err];
//                    NSLog(@"保存成功---%d",bSave);
//
//                    
//                    UIAlertView *alert = [[UIAlertView alloc]
//                                          initWithTitle:@"Event Created"
//                                          message:@"Yay!?"
//                                          delegate:nil
//                                          cancelButtonTitle:@"Okay"
//                                          otherButtonTitles:nil];
//                    [alert show];
//                }
//            });
//        }];
//    }
  
// ----------------------end------------------------
}

//修改事件数据
-(void)editEvent
{
    NSPredicate * pre=[NSPredicate predicateWithFormat:@"eId==%@ ",event.eId];
    AnyEvent *anyEvent= [[AnyEvent MR_findAllWithPredicate:pre ] lastObject];
    anyEvent.eventTitle= textfiled.text;
    anyEvent.location= localfiled.text ;
    
    anyEvent.startDate= startString ;
    anyEvent.endDate= endString ;
    anyEvent.note= notefiled.text;
    anyEvent.calendarAccount=_calendarLab.text;
    NSString *coor=nil;
    if (coordinates) {
        coor=[NSString stringWithFormat:@"%@,%@",[coordinates objectForKey:LATITUDE],[coordinates objectForKey:LONGITUDE]];
    }
    anyEvent.coordinate= coor;
    
    NSString * alertStr=nil;
    if( selectAlertArr) {
        alertStr=[selectAlertArr componentsJoinedByString:@","];
    }
    anyEvent.alerts= alertStr;
    
    anyEvent.calendarAccount= localfiled.text;
    if ([recurObj description]) {
        anyEvent.recurrence=[recurObj description];
    }
    NSString * repeatStr=nil;
    if(selectRepeatArr) {
        repeatStr=[selectRepeatArr componentsJoinedByString:@","];
    }
    anyEvent.repeat= repeatStr;
    anyEvent.isSync=@(isSyncData_NO);//数据没有同步
    anyEvent.isDelete=@(isDeleteData_NO);//数据非删除
    
    NSLog(@"[anyEvent.calendar.type ===%d",[anyEvent.calendar.type intValue]);
    NSLog(@"self.calendarObj.type  ===%d",[self.calendarObj.type intValue]);
    if ([anyEvent.calendar.type intValue]!=[self.calendarObj.type intValue]) {//如歌
        anyEvent.eId=nil;
    }
    anyEvent.calendar=self.calendarObj;
    
    anyEvent.isAllDay=@(isAllDay);
    
    NSString * nowDate=[[PublicMethodsViewController getPublicMethods] rfc3339DateFormatter:[NSDate new]];
    anyEvent.updated=nowDate;
    
    [self.calendarObj addAnyEventObject:anyEvent];
    
    [[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreWithCompletion:^(BOOL contextDidSave, NSError *error) {
        NSString *idStr=[[[anyEvent objectID] URIRepresentation] absoluteString];
        if (error) {
            NSLog(@"%@",error);
            return;
        }
        [self removeLocationNoticeWithName:idStr];
        if (contextDidSave) {
            //为事件添加通知
            [self createLocationNotification:anyEvent];
        }
        
        for (UIViewController* obj in [self.navigationController viewControllers]) {
            if ([obj isKindOfClass:[HomeViewController class]]) {
                HomeViewController *homeVc= (HomeViewController *)obj;
                homeVc.isRefreshUIData=YES;
                [self.navigationController popToViewController:homeVc animated:YES];
            }
        }
        
    }];
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
    
    
    NSString *originalStartTimeStr;
    id originalStartTimeObj=[dataDic objectForKey:@"originalStartTime"];
    if ([originalStartTimeObj isKindOfClass:[NSDictionary class]]){//全天事件的键值---date
        NSString * originalStartTimeAll=[originalStartTimeObj objectForKey:@"date"];
        if (originalStartTimeAll) {
            NSDateFormatter *df=[[NSDateFormatter alloc] init];
            [df setDateFormat:@"yyyy-M-d"];
            [df setTimeZone:[NSTimeZone defaultTimeZone]];
            NSDate *sdate=[df dateFromString:originalStartTimeAll];
            [df setDateFormat:@"YYYY年 M月d日HH:mm"];
            originalStartTimeStr=[df stringFromDate:sdate];
        }else{
            NSString *statrstring=[originalStartTimeObj objectForKey:@"dateTime"];
            originalStartTimeStr=[[PublicMethodsViewController getPublicMethods] formatStringWithStringDate:statrstring];
        }
    }
    anyEvent.originalStartTime=originalStartTimeStr;
    
    anyEvent.recurringEventId=[dataDic objectForKey:@"recurringEventId"];
    
    
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


//生成唯一个eventId
-(NSString *) generateUniqueEventID
{
    NSString *prefix=@"event";
    NSDate *newDate=[NSDate date];
    NSDateFormatter *df=[[NSDateFormatter alloc] init];
    [df setDateFormat:@"YYYYMdHHmmss"];
    NSString *dateStr=[df stringFromDate:newDate];
    NSInteger random= arc4random()%10000+1;
    return [NSString stringWithFormat:@"%@%@%d",prefix,dateStr,random];
}

@end
