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
@interface HomeViewController () {
    UILabel *titleLabel;
    BOOL ison;
    UIButton* rightBtn_arrow;
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
    [self getCalendarEvemt];
    dateArr = [NSMutableArray array];
    
    NSInteger cDay = [CalendarDateUtil getCurrentDay] + 6 *30;
    //    NSInteger cMonthCount = [CalendarDateUtil numberOfDaysInMonth:[CalendarDateUtil getCurrentMonth]];
    
    NSInteger weekDay = [CalendarDateUtil getWeekDayWithDate:[CalendarDateUtil dateSinceNowWithInterval:-(cDay - 1)]];
    
    NSInteger startIndex = -(cDay - 1  + weekDay - 1);
    
    for (int i = startIndex; i < startIndex + (7* 4 * 12); i+=7) {
        NSDate *temp = [CalendarDateUtil dateSinceNowWithInterval:i];
        
        NSArray *weekArr = [self switchWeekByDate:temp];
        for (int d = 0; d<7; d ++) {
            CLDay *day = [weekArr objectAtIndex:d];
            if (day.isToday) {
                [calendarView setToDayRow:(i-startIndex)/7 Index:d];
            }
        }
        [dateArr addObject:weekArr];
    }
    //刷新事件表
    for (NSObject* obj in [calendarView subviews]) {
        if ([obj isKindOfClass:[UITableView class]]) {
            UITableView* tableview=(UITableView*)obj;
            if (tableview.tag==1) {
                [tableview reloadData];
            }
        }
    }


//    [[NSNotificationCenter defaultCenter] postNotificationName:@"calander" object:nil];

}

//读取日历事件并写入到本地 --- 每次进入Home界面都会执行
- (void)getCalendarEvemt {
    NSMutableDictionary* eventDic=[[NSMutableDictionary alloc]initWithCapacity:0];
    NSArray *path = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectorys = [path objectAtIndex:0];
    NSString *plistPaths = [documentsDirectorys stringByAppendingPathComponent:@"addtime.plist"];
    NSFileManager *defaultManager;
    defaultManager = [NSFileManager defaultManager];
    [defaultManager removeItemAtPath:plistPaths error:nil];
    
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
    
    [calendarView goBackToday];
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
    _scrollview .contentSize = CGSizeMake(3*_scrollview.frame.size.width, 0);
    //_scrollview.contentSize = CGSizeMake(3*kScreen_Width, 0);
    _scrollview.contentOffset = CGPointMake(kScreen_Width, 0);
    _scrollview.backgroundColor = [UIColor whiteColor];
    _scrollview.pagingEnabled = YES;
    _scrollview.bounces = NO;//最后一页滑不动
    [self.view addSubview:_scrollview];
    calendarView = [[CLCalendarView alloc] init];
    calendarView.frame = CGRectMake (kScreen_Width, 40, kScreen_Width, kScreen_Height);
    calendarView.dataSuorce = self;
    calendarView.delegate = self;
    calendarView.time=@"time";
    [_scrollview addSubview:calendarView];
    ison=YES;
    titleLabel.text=[NSString stringWithFormat:@"Today %@",[[PublicMethodsViewController getPublicMethods] getcurrentTime:@"dd/M"]];

    
    
//    中间view
    UIView *rview = [[UIView alloc] initWithFrame:CGRectMake(kScreen_Width, -20, kScreen_Width, 66)];
    rview.backgroundColor = [UIColor colorWithRed:0.0f/255.0f green:93.0f/255.0f blue:123.0f/255.0f alpha:1];
//    左边的按钮
    _ZVbutton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    _ZVbutton.frame = CGRectMake(20, 30, 21, 25);
//    _ZVbutton.backgroundColor = [UIColor redColor];
    [_ZVbutton setBackgroundImage:[UIImage imageNamed:@"Icon_BackArrow"] forState:UIControlStateNormal];
    [_ZVbutton addTarget:self action:@selector(setZVbutton) forControlEvents:UIControlEventTouchUpInside];
    [rview addSubview:_ZVbutton];
    

//    右边的按钮
    _YVbutton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    _YVbutton.frame = CGRectMake(280, 30, 21, 25);
    //_YVbutton.backgroundColor = [UIColor redColor];
    [_YVbutton setBackgroundImage:[UIImage imageNamed:@"Icon_BackArrow1"] forState:UIControlStateNormal];
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
    UIControl *titleView = [[UIControl alloc]initWithFrame:CGRectMake(100, 20, 110, 30)];
    [titleView addTarget:self action:@selector(oClickArrow) forControlEvents:UIControlEventTouchUpInside];
    [rview addSubview:titleView];
    
    titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 110, 30)];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    //    titleLabel.font = [UIFont fontWithName:@"Helvetica Neue" size:20.0];
    titleLabel.font=[UIFont boldSystemFontOfSize:20.0f];
    titleLabel.textColor = [UIColor whiteColor];
    //titleLabel.backgroundColor = [UIColor yellowColor];
    [titleView addSubview:titleLabel];
    [_scrollview addSubview:rview];
    
    
    
    //    右边view
    UIView *xview = [[UIView alloc] initWithFrame:CGRectMake(640, -20, kScreen_Width, kScreen_Height)];
    xview.backgroundColor = [UIColor orangeColor];
    
    float topHeight = (200.0f/480.0f)*kScreen_Height;
    //    上
    UIButton *Sbutton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [Sbutton setTitle:@"Porsonal Event" forState:UIControlStateNormal];
    [Sbutton addTarget:self action:@selector(oClickAdd) forControlEvents:UIControlEventTouchUpInside];
    Sbutton.frame = CGRectMake(0, 0, kScreen_Width, topHeight);
    Sbutton.backgroundColor = [UIColor colorWithRed:0.0f/255.0f green:93.0f/255.0f blue:123.0f/255.0f alpha:1];
    [xview addSubview:Sbutton];
    //    中
    UIButton *Zbutton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [Zbutton setTitle:@"Concel" forState:UIControlStateNormal];
    [Zbutton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    Zbutton.frame = CGRectMake(0, topHeight, kScreen_Width, kScreen_Height - 2*topHeight);
    Zbutton.backgroundColor = [UIColor whiteColor];
    [xview addSubview:Zbutton];
    //    下
    UIButton *Xbutton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [Xbutton setTitle:@"Social Event" forState:UIControlStateNormal];
    Xbutton.frame = CGRectMake(0, kScreen_Height - topHeight, kScreen_Width, topHeight);
    Xbutton.backgroundColor = [UIColor colorWithRed:244.0f/255.0f green:10.0f/255.0f blue:115.0f/255.0f alpha:1];
    [xview addSubview:Xbutton];
    [_scrollview addSubview:xview];

    //    左间view
    UIView *zview = [[UIView alloc] initWithFrame:CGRectMake(0, -20, kScreen_Width, 66)];
    zview.backgroundColor = [UIColor colorWithRed:0.0f/255.0f green:93.0f/255.0f blue:123.0f/255.0f alpha:1];
    
    //   右边xiew上返回button
    _rbutton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    _rbutton.frame = CGRectMake(280, 30, 21, 25);
    //_rbutton.backgroundColor = [UIColor redColor];
    [_rbutton setBackgroundImage:[UIImage imageNamed:@"Icon_BackArrow1"] forState:UIControlStateNormal];
    [_rbutton addTarget:self action:@selector(setrbutton) forControlEvents:UIControlEventTouchUpInside];
    [zview addSubview:_rbutton];
    [_scrollview addSubview:zview];
    

    
//    self.navigationController.navigationBar.barTintColor = blueColor;
//    
//    /* 导航栏左 */
//    UIButton *leftBtn = [UIButton buttonWithType:UIButtonTypeCustom];
//    [leftBtn setImage:[UIImage imageNamed:@"Icon_Menu"] forState:UIControlStateNormal];
//    [leftBtn setFrame:CGRectMake(0, 2, 20, 18)];
//    [leftBtn addTarget:self action:@selector(oClickMenu) forControlEvents:UIControlEventTouchUpInside];
//    
//    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]initWithCustomView:leftBtn];
//    
//    /* 导航栏右 */
//    
//    
//     rightBtn_arrow = [UIButton buttonWithType:UIButtonTypeCustom];
//    [rightBtn_arrow setImage:[UIImage imageNamed:@"arrow_icon"] forState:UIControlStateNormal];
//    [rightBtn_arrow setFrame:CGRectMake(0, 2, 30, 40)];
//    [rightBtn_arrow addTarget:self action:@selector(oClickArrow) forControlEvents:UIControlEventTouchUpInside];
//    
//    UIButton *rightBtn_add = [UIButton buttonWithType:UIButtonTypeCustom];
//    [rightBtn_add setBackgroundImage:[UIImage imageNamed:@"Icon_Add"] forState:UIControlStateNormal];
//    [rightBtn_add setFrame:CGRectMake(40, 10, 20, 20)];
//    [rightBtn_add addTarget:self action:@selector(oClickAdd) forControlEvents:UIControlEventTouchUpInside];
//    
//    UIView *rightView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 60, 40)];
//    [rightView addSubview:rightBtn_arrow];
//    [rightView addSubview:rightBtn_add];
//    
//    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithCustomView:rightView];
    
    /* 导航栏标题 */
//    UIControl *titleView = [[UIControl alloc]initWithFrame:CGRectMake(0, 0, 140, 40)];
//    [titleView addTarget:self action:@selector(oClickArrow) forControlEvents:UIControlEventTouchUpInside];
//    
//    titleView.backgroundColor = [UIColor redColor];
//    
//    
//    titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 140, 40)];
//    titleLabel.textAlignment = NSTextAlignmentCenter;
////    titleLabel.font = [UIFont fontWithName:@"Helvetica Neue" size:20.0];
//    titleLabel.font=[UIFont boldSystemFontOfSize:20.0f];
//    titleLabel.textColor = [UIColor whiteColor];
//    
//    titleLabel.backgroundColor = [UIColor yellowColor];
//    
//    
//    [titleView addSubview:titleLabel];
//    
//    self.navigationItem.titleView = titleView;
    
    
  
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
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:.2];
    [UIView setAnimationCurve:UIViewAnimationCurveLinear];
    _scrollview.contentOffset = CGPointMake(0, 0);
    [UIView commitAnimations];
}
-(void)setYVbutton
{
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:.2];
    [UIView setAnimationCurve:UIViewAnimationCurveLinear];
    _scrollview.contentOffset = CGPointMake(640, 0);
    [UIView commitAnimations];
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
    }
    else{
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
        AddEventViewController *addVC = [[AddEventViewController alloc] initWithNibName:@"AddEventViewController" bundle:nil];
        UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:addVC];
        [self presentViewController:nav animated:YES completion:nil];
    
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
- (void)calendarSelectEvent:(CLCalendarView *)calendarView day:(CLDay*)day event:(NSDictionary*)event AllEvent:(NSArray *)events {
    if ([event count] == 0) {  //没有事件添加
        AddEventViewController* add=[[AddEventViewController alloc]initWithNibName:@"AddEventViewController" bundle:nil];
        UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:add];
        [self presentViewController:nav animated:YES completion:nil];
    }
    else {  //有事件查看详细
        DateDetailsViewController* dateDetails=[[DateDetailsViewController alloc]initWithNibName:@"DateDetailsViewController" bundle:nil];
        dateDetails.datedic=event;
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
    titleLabel.text = title;
}




@end
