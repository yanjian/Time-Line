//
//  EventDetailsViewController.m
//  Go2
//
//  Created by IF on 15/5/7.
//  Copyright (c) 2015年 zhilifang. All rights reserved.
//

#import "EventDetailsViewController.h"
#import "CircleDrawView.h"
#import "AT_Event.h"
#import "SimpleEventViewController.h"
#import "IBActionSheet.h"
#import "HomeViewController.h"
#import "RecurrenceModel.h"
#import "UIColor+HexString.h"
#define XSPACING 20

static NSString * eventDetailsCellId = @"eventDetailsCellID" ;
@interface EventDetailsViewController ()<IBActionSheetDelegate,MKMapViewDelegate,UITableViewDataSource,UITableViewDelegate>
{
    UILabel   * titleLab ;
    UILabel   * startTimeLab ;
    UILabel   * endTimeLab ;
    UILabel   * noteLab ;
    UILabel   * locationLab ;
    MKMapView * vMap ;
    
    UILabel   * calendarLab;
    
    CGSize noteLabSize ;
    
    BOOL isRecurrence;

}
@property (nonatomic,strong) Calendar *calendarObj;

@end

@implementation EventDetailsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self colorWithNavigationBar];
    self.title = @"Event Details" ;
    
    UIButton *leftBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [leftBtn setFrame:CGRectMake(0, 0, 22, 14)];
    [leftBtn setTag:1];
    [leftBtn setBackgroundImage:[UIImage imageNamed:@"go2_arrow_left"] forState:UIControlStateNormal] ;
    [leftBtn addTarget:self action:@selector(backToEventView:) forControlEvents:UIControlEventTouchUpInside] ;
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:leftBtn] ;
    
    UIButton *rightBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [rightBtn setFrame:CGRectMake(0, 0, 20, 20)];
    [rightBtn setTag:2];
    [rightBtn setBackgroundImage:[UIImage imageNamed:@"Icon_Edit"] forState:UIControlStateNormal] ;
    [rightBtn addTarget:self action:@selector(editEventData:) forControlEvents:UIControlEventTouchUpInside] ;
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:rightBtn] ;
    
    self.navigationController.interactivePopGestureRecognizer.delegate =(id) self ;

    UIView * footerView =[[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreen_Width, 50)] ;
    UIButton * deleteBtn = [[UIButton alloc ] init];
   // [deleteBtn setBackgroundColor:[UIColor grayColor]];
    deleteBtn.frame = CGRectMake(0, 3, kScreen_Width, 44);
    
    [deleteBtn setTitle:@"Delete" forState:UIControlStateNormal];
    [deleteBtn setTitleColor:purple forState:UIControlStateNormal];
    [deleteBtn addTarget:self action:@selector(deleteSimpleEvent:) forControlEvents:UIControlEventTouchUpInside];
    [footerView addSubview:deleteBtn] ;
    self.eventDetailTableView.tableFooterView = footerView ;
    self.eventDetailTableView.separatorInset = UIEdgeInsetsMake(0, 20, 0, 20);
    
    [self createFirstCellViewContent];
    [self createSecondCellViewContent];
    [self createThirdCellViewContent];
    [self createFourthViewContent];
    
    if (self.event) {
        NSPredicate *pre=[NSPredicate predicateWithFormat:@"cid==%@",self.event.cId];
        NSArray * caArr= [Calendar MR_findAllWithPredicate:pre];
        self.calendarObj= [caArr lastObject];
    }else{
        //查询默认日历
        NSPredicate *pre=[NSPredicate predicateWithFormat:@"isDefault==1"];
        self.calendarObj=[[Calendar MR_findAllWithPredicate:pre] lastObject];
    }

}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self colorWithNavigationBar];
}

/**
 *配置NavigationBar的颜色，和字体的颜色
 */
-(void)colorWithNavigationBar{
    self.navigationController.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName:[UIColor whiteColor]};
    [self.navigationController.navigationBar setBarTintColor:[UIColor colorWithHexString:@"31aaeb"]];
}


-(void)createFirstCellViewContent{
    titleLab = [[UILabel alloc] initWithFrame:CGRectMake(XSPACING, 20, kScreen_Width-2*XSPACING, 30)];
    titleLab.font = [UIFont systemFontOfSize:25];
    titleLab.text = self.event.eventTitle ;
    startTimeLab = [[UILabel alloc] initWithFrame:CGRectMake(XSPACING, CGRectGetMaxY(titleLab.frame)+20, kScreen_Width-2*XSPACING, 30)];
    endTimeLab = [[UILabel alloc] initWithFrame:CGRectMake(XSPACING, CGRectGetMaxY(startTimeLab.frame), kScreen_Width-2*XSPACING, 30)];
    
    NSDate * startTime = [[PublicMethodsViewController getPublicMethods] formatWithStringDate:self.event.startDate];
    NSDate * endTime   = [[PublicMethodsViewController getPublicMethods] formatWithStringDate:self.event.endDate];

    
    if ([self.event.isAllDay boolValue]) {
        startTimeLab.text   = [self formaterDate:startTime formaterStyle:@"EEEE, d  MMMM"];
        NSDate * tmpEndDate = [endTime dateByAddingTimeInterval:-1*24*60*60];
        
        endTimeLab.text     = [self formaterDate:tmpEndDate formaterStyle:@"EEEE, d  MMMM"];
    }else{
        if ([self isSameWithstartDay:startTime endDate:endTime]) {
            startTimeLab.text = [self formaterDate:startTime formaterStyle:@"EEEE, d  MMMM"];
            endTimeLab.text = [NSString stringWithFormat:@"%@ - %@",[self formaterDate:startTime formaterStyle:[self timeIs24HourFormat]?@"HH:mm":@"hh:mm"],[self formaterDate:endTime formaterStyle:[self timeIs24HourFormat]?@"HH:mm":@"hh:mm"]];
        }else{
            startTimeLab.text = [self formaterDate:startTime formaterStyle:@"EEEE, d  MMMM HH:ss"];
            endTimeLab.text   = [self formaterDate:endTime formaterStyle:@"EEEE, d  MMMM HH:ss"];
        }
    }
}

-(void)createSecondCellViewContent {
    if (self.event.note) {
        NSDictionary *attribute = @{NSFontAttributeName: [UIFont systemFontOfSize:17]};
        noteLabSize = [self.event.note boundingRectWithSize:CGSizeMake(320, 0) options: NSStringDrawingTruncatesLastVisibleLine | NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading attributes:attribute context:nil].size;
        noteLab = [[UILabel alloc] initWithFrame:CGRectMake(XSPACING, 20, kScreen_Width-2*XSPACING, noteLabSize.height)];
        noteLab.numberOfLines = 0 ;
        noteLab.text = self.event.note ;
    }else{
        noteLab = [[UILabel alloc] initWithFrame:CGRectMake(XSPACING, 20, kScreen_Width-2*XSPACING, 44)];
        noteLab.textAlignment = NSTextAlignmentCenter ;
        noteLab.text = @"No note" ;
    }
   
}


-(void)createThirdCellViewContent {
    if (self.event.location) {
        locationLab = [[UILabel alloc] initWithFrame:CGRectMake(XSPACING, 0, kScreen_Width-2*XSPACING, 30)];
        locationLab.font = [UIFont systemFontOfSize:17];
        locationLab.text = self.event.location ;
    }else{
        locationLab = [[UILabel alloc] initWithFrame:CGRectMake(XSPACING, 0, kScreen_Width-2*XSPACING, 44)];
        locationLab.font = [UIFont systemFontOfSize:17];
        locationLab.text = @"No location" ;
    }
    
    if (self.event.coordinate) {
        NSArray *coorArr = [self.event.coordinate componentsSeparatedByString:@";"];
        
        vMap = [[MKMapView alloc] initWithFrame:CGRectMake(XSPACING, CGRectGetMaxY(locationLab.frame)+5, kScreen_Width-2*XSPACING, 110)];
        vMap.delegate = self;
        vMap.centerCoordinate = CLLocationCoordinate2DMake([coorArr[0] doubleValue], [coorArr[1]  doubleValue]);
        vMap.camera.altitude = 150;
        vMap.showsBuildings = YES;
        vMap.zoomEnabled = NO ;
        vMap.scrollEnabled = NO ;
        MKPointAnnotation *annotation = [[MKPointAnnotation alloc] init];
        annotation.coordinate = vMap.centerCoordinate;
        annotation.title = self.event.location;
        [vMap addAnnotation:annotation];
    }
    
}

-(void)createFourthViewContent{
    calendarLab = [[UILabel alloc] initWithFrame:CGRectMake(100, 0, kScreen_Width-100-XSPACING, 44)];
    calendarLab.font = [UIFont systemFontOfSize:17];
    calendarLab.textAlignment = NSTextAlignmentRight ;
    calendarLab.text = self.event.calendarAccount ;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 4 ;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.row == 0) {
        return 150.f;
    }else if (indexPath.row == 1){
        if (self.event.note) {
            if (noteLabSize.height<150) {
                noteLab.frame = CGRectMake(XSPACING, 0, kScreen_Width-2*XSPACING,noteLabSize.height<44?44:noteLabSize.height);
                return noteLabSize.height<44?44:noteLabSize.height ;
            }else{
                return 150.f;
            }
        }
    }else if (indexPath.row == 2){
        if (self.event.coordinate) {
            return 150.f;
        }
    }
    return 44.f;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:eventDetailsCellId];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:eventDetailsCellId];
    }
    for (UIView * subView in cell.contentView.subviews) {
        [subView removeFromSuperview];
    }
    if (indexPath.row == 0) {
        [cell.contentView addSubview:titleLab];
        [cell.contentView addSubview:startTimeLab];
        [cell.contentView addSubview:endTimeLab];
    }else if(indexPath.row == 1){
        [cell.contentView addSubview:noteLab];
    }else if (indexPath.row == 2){
        [cell.contentView addSubview:locationLab];
        [cell.contentView addSubview:vMap];
    }else if(indexPath.row == 3){
        cell.textLabel.text = @"Calendar" ;
        [cell.contentView addSubview:calendarLab];
        
        NSDictionary *attribute = @{NSFontAttributeName: [UIFont systemFontOfSize:17]};
        CGSize size = [calendarLab.text boundingRectWithSize:CGSizeMake(320, 0) options: NSStringDrawingTruncatesLastVisibleLine | NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading attributes:attribute context:nil].size;
        CircleDrawView *cd =[[CircleDrawView alloc] initWithFrame:CGRectMake((kScreen_Width-XSPACING-size.width-30), 12, 20, 20)];
        cd.hexString = self.event.backgroundColor;
        [cell.contentView addSubview:cd];
    }
    return cell;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}


-(void)backToEventView:(UIButton *) sender{
    [self.navigationController popViewControllerAnimated:YES] ;
}


-(void)editEventData:(UIButton *) sender{
    SimpleEventViewController *simpleEventVC = [[SimpleEventViewController alloc] init] ;
    simpleEventVC.isEdit = YES ;
    simpleEventVC.event = self.event ;
    [self.navigationController pushViewController:simpleEventVC animated:YES];
}

-(NSString *)formaterDate:(NSDate *) selectDate formaterStyle:(NSString *) formater{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:formater];
    [dateFormatter setTimeZone:[NSTimeZone timeZoneWithName:SYS_DEFAULT_TIMEZONE]];
    return  [dateFormatter stringFromDate:selectDate];
}

#pragma mark - 比较两个日期是否是同一天
- (BOOL)isSameWithstartDay:(NSDate *)start endDate:(NSDate *) end{
    if (start==nil || end == nil) return NO;
    NSCalendar *cal = [NSCalendar currentCalendar];
    NSDateComponents *components = [cal components:(NSEraCalendarUnit|NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit) fromDate:start];
    NSDate *startTime = [cal dateFromComponents:components];
    components = [cal components:(NSEraCalendarUnit|NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit) fromDate:end];
    NSDate *endTime = [cal dateFromComponents:components];
    if([startTime isEqualToDate:endTime]){
        return YES;
    }
    return NO;
}

//判断是否是24小时制还是12小时制
- (BOOL)timeIs24HourFormat {
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateStyle:NSDateFormatterNoStyle];
    [formatter setTimeStyle:NSDateFormatterShortStyle];
    NSString *dateString = [formatter stringFromDate:[NSDate date]];
    NSRange amRange = [dateString rangeOfString:[formatter AMSymbol]];
    NSRange pmRange = [dateString rangeOfString:[formatter PMSymbol]];
    BOOL is24Hour = amRange.location == NSNotFound && pmRange.location == NSNotFound;
    return is24Hour;
}


-(void)deleteSimpleEvent:(UIButton *) sender {
    IBActionSheet *ibActionSheet=nil;
    if (self.event.recurrence) {
        isRecurrence = YES ;
        ibActionSheet=[[IBActionSheet alloc] initWithTitle:@"Delete" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"This event only",@"This and future events",@"All events in series", nil];
    }else{
        isRecurrence = NO ;
        ibActionSheet=[[IBActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:@"Delete Event" otherButtonTitles:nil, nil];
    }
    [ibActionSheet showInView:self.navigationController.view];

}



#pragma -ibactionsheet的代理
-(void)actionSheet:(IBActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (buttonIndex==0) {
        //在没有网络的情况下先记录删除的事件
        if (self.event.recurrence&&![@"" isEqualToString:self.event.recurrence ]) {
            NSLog(@"-------------->>><<<<<>>>>> %@",self.event.startDate);
            
            AnyEvent *anyEvent = [AnyEvent MR_createEntity];
            
            NSPredicate *pre = [NSPredicate predicateWithFormat:@"cid==%@",self.event.cId];
            NSArray * caArr  = [Calendar MR_findAllWithPredicate:pre];
            Calendar *ca     = [caArr lastObject];
            anyEvent.calendar = ca;
            if ([ca.type intValue] == AccountTypeLocal) {//如果是本地日历
                anyEvent.isDelete = @(isDeleteData_NO);
                anyEvent.eId      = [self generateUniqueEventID];
            }else{
                anyEvent.isDelete  =  @(isDeleteData_mode);//记录重复数据中删除的事件
                NSString *tmpStr   =[[PublicMethodsViewController getPublicMethods] getcurrentTime:@"yyyyMMddHHmmsss"];
                anyEvent.eId  =   [NSString stringWithFormat:@"%@_%@",self.event.eId,tmpStr];
            }
            
            anyEvent.isSync             = @(isSyncData_NO);//没有同步
            anyEvent.isAllDay           = self.event.isAllDay;//全天事件 标记
            anyEvent.recurringEventId   = self.event.eId;
            anyEvent.status             = [NSString stringWithFormat:@"%i",eventStatus_cancelled];
            anyEvent.originalStartTime  = self.event.startDate;
            
            anyEvent.startDate         = self.event.startDate;
            anyEvent.endDate           = self.event.endDate;
            anyEvent.eventTitle        = self.event.eventTitle;
            anyEvent.calendarAccount   = self.event.calendarAccount;
            
            //后面的数据可以不要
            anyEvent.location          = self.event.location;
            anyEvent.note              = self.event.note;
            anyEvent.coordinate        = self.event.coordinate;
            anyEvent.alerts            = self.event.alerts;
            anyEvent.repeat            = self.event.repeat;
            anyEvent.updated           = self.event.updated;
            anyEvent.created           = self.event.created;
            anyEvent.orgDisplayName    = self.event.orgDisplayName;
            anyEvent.creatorDisplayName = self.event.creatorDisplayName;
            anyEvent.creator            = self.event.creator ;
            anyEvent.organizer          = self.event.organizer ;
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
    }else if (buttonIndex==1){
        if(self.event.recurrence){
            RecurrenceModel *recuMode = [[RecurrenceModel alloc] initRecrrenceModel:self.event.recurrence];
            
            NSPredicate * pre    = [NSPredicate predicateWithFormat:@"eId==%@",self.event.eId];
            NSArray * currEvents = [AnyEvent MR_findAllWithPredicate:pre];
            AnyEvent * currEvent = [currEvents lastObject];
            NSDate   *  startD   = [[PublicMethodsViewController getPublicMethods] formatWithStringDate: self.event.startDate];
            
            NSDateFormatter *tempFormatter = [[NSDateFormatter alloc]init];
            [tempFormatter setTimeZone:[NSTimeZone defaultTimeZone]];
            [tempFormatter setDateFormat:@"YYYYMMdd"];
            
            recuMode.until       = [tempFormatter stringFromDate:startD];
            currEvent.recurrence = [recuMode description];
            currEvent.isSync     = @(isSyncData_NO);
            
            [[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreAndWait];
            for (UIViewController* obj in [self.navigationController viewControllers]) {
                if ([obj isKindOfClass:[HomeViewController class]]) {
                    HomeViewController *homeVc = (HomeViewController *)obj;
                    homeVc.isRefreshUIData = YES;
                    [self.navigationController popToViewController:homeVc animated:YES];
                }
            }
        }
    }else if(buttonIndex==2){
        [self deleteAllEventsInData];
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
    NSPredicate * pre  = [NSPredicate predicateWithFormat:@"eId==%@",self.event.eId];
    AnyEvent *anyEvent = [[AnyEvent MR_findAllWithPredicate:pre] lastObject];
    if ([anyEvent.calendar.type intValue] == AccountTypeLocal) {//本地账号
        anyEvent.isDelete = @(isDeleteData_YES);//数据删除
        anyEvent.isSync   = @(isSyncData_NO);//数据没有同步
        NSPredicate *pre  = [NSPredicate predicateWithFormat:@"recurringEventId==%@",anyEvent.eId];
        NSArray *childEventArr = [AnyEvent MR_findAllWithPredicate:pre];
        for (AnyEvent *tmpEvent in childEventArr) {
            tmpEvent.isDelete = @(isDeleteData_YES);//数据删除
            tmpEvent.isSync   = @(isSyncData_NO);//数据没有同步
        }
    }else{
        anyEvent.isDelete = @(isDeleteData_YES);//数据删除
        anyEvent.isSync   = @(isSyncData_NO);//数据没有同步
    }
    NSString * uniqueFlagNot = [[anyEvent.objectID URIRepresentation] absoluteString];
    NSLog(@"删除通知的唯一标记：%@",uniqueFlagNot);
    [self removeLocationNoticeWithName:uniqueFlagNot];//删除通知
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

/**
 *取消一個通知
 *name 通知的唯一标记名
 *
 */
- (void)removeLocationNoticeWithName:(NSString*) name {
    NSArray * narry = [[UIApplication sharedApplication] scheduledLocalNotifications];
    NSUInteger acount = [narry count];
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

@end
