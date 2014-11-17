//
//  ViewController.m
//  Time-Line
//
//  Created by connor on 14-4-2.
//  Copyright (c) 2014年 connor. All rights reserved.
//

#import "ViewController.h"
#import "CalendarDateUtil.h"
//#import "DailyCalendarTableViewController.h"
#import "UIViewController+MJPopupViewController.h"
#import "DayViewController.h"
#import "MAEvent.h"
#import "MJSecondDetailViewController.h"
#import "YQNavigationController.h"

#define LineGroundColor [UIColor colorWithRed:201.0f/255.0f green:201.0f/255.0f blue:201.0f/255.0f alpha:1.0f]
@interface ViewController ()<MJSecondPopupDelegate>{
    UILabel* titleLabel;
    NSMutableArray* houresArray;
    NSMutableArray* minArray;
    UILabel* startLabel;
    UILabel* endLabel;
    
    
    UILabel * startTimeLable;
    UILabel * endTimeLabel;
    UILabel * tStartLable;
    UILabel * tEndLable;
    UILabel *flagLab;
    
    UILabel * sameDayLable;
    UILabel * sameTimeLable;
    UILabel * allDayLable;
    
    BOOL isstate;
    NSString* startStr;
    NSString* endStr;
    AnyEvent * anyEventObj;
    
    BOOL isButtonOn;
}

@end

@implementation ViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    dateArr = [NSMutableArray array];
    houresArray=[[NSMutableArray alloc]initWithCapacity:0];
    minArray=[[NSMutableArray alloc]initWithCapacity:0];
    for (int i=0; i<24; i++) {
        [houresArray addObject:[NSString stringWithFormat:@"%d",i]];
    }
    for (int i=0; i<60; i++) {
        NSString* str=[NSString stringWithFormat:@"%d",i];
        if (i<10) {
            str=[NSString stringWithFormat:@"0%@",str];
        }
        [minArray addObject:str];
    }
    NSInteger cDay = calendarDateCount;
   // NSInteger cMonthCount = [CalendarDateUtil numberOfDaysInMonth:[CalendarDateUtil getCurrentMonth]];
    
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
    [calendarView goBackToday];

}



- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.startEventButton.backgroundColor=purple;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(fileStartDownload:) name:@"day" object:nil];
    UIButton *leftBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [leftBtn setBackgroundImage:[UIImage imageNamed:@"Icon_BackArrow.png"] forState:UIControlStateNormal];
   
    [leftBtn setFrame:CGRectMake(0, 2, 21, 25)];
    [leftBtn addTarget:self action:@selector(disviewcontroller) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]initWithCustomView:leftBtn];
   
    UIButton *rightBtn=[UIButton buttonWithType:UIButtonTypeCustom];
    [rightBtn setBackgroundImage:[UIImage imageNamed:@"free.png"] forState:UIControlStateNormal];
    [rightBtn setBackgroundImage:[UIImage imageNamed:@"occupied.png"] forState:UIControlStateHighlighted];
    [rightBtn setFrame:CGRectMake(CGRectGetWidth(leftBtn.frame)-CGRectGetWidth(leftBtn.bounds), CGRectGetMinY(leftBtn.frame), CGRectGetWidth(leftBtn.bounds), CGRectGetHeight(leftBtn.bounds))];
    [rightBtn addTarget:self action:@selector(chooseAllDay:) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.rightBarButtonItem=[[UIBarButtonItem alloc] initWithCustomView:rightBtn];
    
    
    /* 导航栏标题 */
    UIControl *titleView = [[UIControl alloc]initWithFrame:CGRectMake(0, 0, 260, 40)];
    
    
//    
//    titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 120, 40)];
//    titleLabel.textAlignment = NSTextAlignmentCenter;
//    titleLabel.font = [UIFont boldSystemFontOfSize:22];
//    titleLabel.textColor = [UIColor whiteColor];
//    [titleView addSubview:titleLabel];
    
    allDayLable = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 230, 40)];
    allDayLable.textAlignment = NSTextAlignmentCenter;
    allDayLable.font = [UIFont boldSystemFontOfSize:17];
    allDayLable.textColor = [UIColor whiteColor];
    [titleView addSubview:allDayLable];

    
    
    startTimeLable = [[UILabel alloc] initWithFrame:CGRectMake(5, 0, 110, 20)];
    startTimeLable.textAlignment = NSTextAlignmentCenter;
    startTimeLable.font = [UIFont boldSystemFontOfSize:17];
   // [startTimeLable setBackgroundColor:[UIColor redColor]];
    startTimeLable.textColor = [UIColor whiteColor];
    
    tStartLable = [[UILabel alloc] initWithFrame:CGRectMake(5, 20, 110, 20)];
    tStartLable.textAlignment = NSTextAlignmentCenter;
    tStartLable.font = [UIFont boldSystemFontOfSize:17];
   // [tStartLable setBackgroundColor:[UIColor redColor]];
    tStartLable.textColor = [UIColor whiteColor];
    [titleView addSubview:tStartLable];
    [titleView addSubview:startTimeLable];
    
    endTimeLabel = [[UILabel alloc] initWithFrame:CGRectMake(120, 0, 110, 20)];
    endTimeLabel.textAlignment = NSTextAlignmentCenter;
   // [startTimeLable setBackgroundColor:[UIColor greenColor]];
    endTimeLabel.font = [UIFont boldSystemFontOfSize:17];
    endTimeLabel.textColor = [UIColor whiteColor];
    
    tEndLable = [[UILabel alloc] initWithFrame:CGRectMake(120, 20, 110, 20)];
    tEndLable.textAlignment = NSTextAlignmentCenter;
    tEndLable.font = [UIFont boldSystemFontOfSize:17];
    tEndLable.textColor = [UIColor whiteColor];
   // [tEndLable setBackgroundColor:purple];

    flagLab=[[UILabel alloc] initWithFrame:CGRectMake(110, 20, 20, 20)];
    flagLab.textColor=[UIColor whiteColor];
    flagLab.text=@"→";
    
    [titleView addSubview:flagLab];
    [titleView addSubview:tEndLable];
    [titleView addSubview:endTimeLabel];
    
    sameDayLable=[[UILabel alloc] initWithFrame:CGRectMake(0, 0, 240, 20)];
    sameDayLable.textAlignment = NSTextAlignmentCenter;
    sameDayLable.font = [UIFont boldSystemFontOfSize:17];
    sameDayLable.textColor = [UIColor whiteColor];
    
    sameTimeLable=[[UILabel alloc] initWithFrame:CGRectMake(0, 20, 240, 20)];
    sameTimeLable.textAlignment = NSTextAlignmentCenter;
    sameTimeLable.font = [UIFont boldSystemFontOfSize:17];
    sameTimeLable.textColor = [UIColor whiteColor];
   
    
    [titleView addSubview:sameDayLable];
    [titleView addSubview:sameTimeLable];
    
    self.navigationItem.titleView = titleView;
    
    [self createTitleViewShowDataStartDate:anyEventObj.startDate endDate:anyEventObj.endDate];
    
    calendarView = [[CLCalendarView alloc] initWithFrame:CGRectMake(0, self.startEventButton.frame.origin.y+40, self.view.frame.size.width, 220)];
    calendarView.dataSuorce = self;
    calendarView.delegate = self;
    calendarView.backgroundColor=[UIColor whiteColor];
    for (NSObject* obj in [calendarView subviews]) {
        if ([obj isKindOfClass:[UITableView class]]) {
            UITableView* tableview=(UITableView*)obj;
            if (tableview.tag==1) {
                [tableview removeFromSuperview];
            }
        }
    }
    [self.view addSubview:calendarView];
    calendarView.displayMode = !calendarView.displayMode;
    
    
    UIView* dayview=[[UIView alloc]initWithFrame:CGRectMake(-1, calendarView.frame.origin.y+calendarView.frame.size.height, self.view.frame.size.width+1, 40)];
    dayview.backgroundColor=blueColor;
    dayview.layer.borderWidth =0.7;
    dayview.layer.borderColor = [[UIColor grayColor] CGColor];
    UILabel* daylabel=[[UILabel alloc]initWithFrame:CGRectMake(10, 0, 180, 40)];
    daylabel.backgroundColor=[UIColor clearColor];
    daylabel.font=[UIFont boldSystemFontOfSize:17.0f];
    daylabel.textColor=[UIColor whiteColor];
    daylabel.text=@"ALL DAY EVENT";
    UISwitch* switchButton=[[UISwitch alloc]initWithFrame:CGRectMake(260, 5, 60, 30)];
   
    [switchButton addTarget:self action:@selector(switchAction:) forControlEvents:UIControlEventValueChanged];
    [dayview addSubview:switchButton];
    [dayview addSubview:daylabel];
    [self.view addSubview:dayview];
    datePicker = [[JCDatePicker alloc] initWithFrame:CGRectMake(0, dayview.frame.origin.y+dayview.frame.size.height, self.view.frame.size.width, 120)];
    datePicker.delegate = self;
    datePicker.bgColor=[UIColor whiteColor];
    //    datePicker.pickerColor=BackGroundColor;
    datePicker.layer.borderWidth=1.0f;
    datePicker.layer.borderColor =[LineGroundColor CGColor];
    datePicker.font = [UIFont boldSystemFontOfSize:17.0f];
    datePicker.date =[[PublicMethodsViewController getPublicMethods] getcurrentTime:@"HH:mm"];
    datePicker.dateFormat = JCDateFormatClock;
    NSArray* array=[NSArray arrayWithObjects:@"AM", nil];
    datePicker.dayArray=array;
    
    [self.view addSubview:datePicker];
    startLabel=[[UILabel alloc]initWithFrame:CGRectMake(0, 0, 0, 0)];
    startLabel.text=anyEventObj.startDate;
    startStr=[[PublicMethodsViewController getPublicMethods] formaterStringfromDate:@"HH:mm" dateString: anyEventObj.startDate];
    
    endLabel=[[UILabel alloc]initWithFrame:CGRectMake(0, 0, 0, 0)];
    endLabel.text=anyEventObj.endDate;
    endStr=[[PublicMethodsViewController getPublicMethods] formaterStringfromDate:@"HH:mm" dateString: anyEventObj.endDate];
    isstate=YES;
    
    if ([anyEventObj.isAllDay boolValue]) {
        [switchButton setOn:YES];
        isButtonOn=YES;
        startStr=[[PublicMethodsViewController getPublicMethods] getcurrentTime:@"HH:mm"];
        
        NSDate *now = [NSDate new];
        NSDate *endDate= [now dateByAddingTimeInterval:60*60];
        NSString *endDateStr=[[PublicMethodsViewController getPublicMethods] stringformatWithDate:endDate];
        endStr=[[PublicMethodsViewController getPublicMethods] formaterStringfromDate:@"HH:mm" dateString: endDateStr];
        
        
     //   endStr=[[PublicMethodsViewController getPublicMethods] getcurrentTime:@"HH:mm"];
        [datePicker setHidden:YES];
        [self createAllDayEventDate:anyEventObj.startDate endDate:anyEventObj.endDate];
    }else{
        [switchButton setOn:NO];
        isButtonOn=NO;
        [datePicker setHidden:NO];
    }
}



-(void)createAllDayEventDate:(NSString *) startDatStr endDate:(NSString *) enddateStr{
    [flagLab setHidden:YES];
    [sameTimeLable setHidden:YES];
    [sameDayLable setHidden:YES];
    
    [startTimeLable setHidden:YES];
    [tStartLable setHidden:YES];
    [endTimeLabel setHidden:YES];
    [tEndLable setHidden:YES];

    CLDay *startday=[[CLDay alloc] initWithDate:[[PublicMethodsViewController getPublicMethods] formatWithStringDate:startDatStr]];
    CLDay *endday=[[CLDay alloc] initWithDate:[[PublicMethodsViewController getPublicMethods] formatWithStringDate:enddateStr]];
     NSString *instr=[[PublicMethodsViewController getPublicMethods] timeDifference:enddateStr getStrart:startDatStr ];
    if ([[startday description] isEqualToString:[endday description]]||[instr isEqualToString:@"1d"]) {//同一天或为1d都是一天
        allDayLable.text=[[startday abbreviationWeekDayMotch] stringByAppendingString:@" (ALL DAY)"];
    }else{
        allDayLable.text=[NSString stringWithFormat:@"%@ → %@",[startday abbreviationWeekDayMotch],[endday abbreviationWeekDayMotch]];
    }
}


-(void)createTitleViewShowDataStartDate:(NSString *) startDateStr endDate:(NSString *) endDateStr{
    CLDay *startday;
    CLDay *endday;
    NSString *startTime;
    NSString *endTime;
    
    if (isstate) {
        startday=[[CLDay alloc] initWithDate:[[PublicMethodsViewController getPublicMethods] formatWithStringDate:startDateStr]];
        endday=startday;
        
        startTime=[[PublicMethodsViewController getPublicMethods] formaterStringfromDate:@"HH:mm" dateString: startDateStr];
        endTime=[[PublicMethodsViewController getPublicMethods] formaterStringfromDate:@"HH:mm" dateString: endDateStr];
        startLabel.text=startDateStr;
        endLabel.text=[NSString stringWithFormat:@"%@%@",[endday description],endTime];
    }else{
    
        startday=[[CLDay alloc] initWithDate:[[PublicMethodsViewController getPublicMethods] formatWithStringDate:startDateStr]];
        endday=[[CLDay alloc] initWithDate:[[PublicMethodsViewController getPublicMethods] formatWithStringDate:endDateStr]];
    
        startTime=[[PublicMethodsViewController getPublicMethods] formaterStringfromDate:@"HH:mm" dateString: startDateStr];
        endTime=[[PublicMethodsViewController getPublicMethods] formaterStringfromDate:@"HH:mm" dateString: endDateStr];
    }
    
    if ([[startday description] isEqualToString:[endday description]]) {
        [flagLab setHidden:YES];
        [sameTimeLable setHidden:NO];
        [sameDayLable setHidden:NO];
        
        [startTimeLable setHidden:YES];
        [tStartLable setHidden:YES];
        [endTimeLabel setHidden:YES];
        [tEndLable setHidden:YES];
        
        //设置数据
        sameDayLable.text=[startday abbreviationWeekDayMotch];
        sameTimeLable.text=[NSString stringWithFormat:@"%@ → %@",startTime,endTime];
    }else{
        [flagLab setHidden:NO];
        [startTimeLable setHidden:NO];
        [tStartLable setHidden:NO];
        [endTimeLabel setHidden:NO];
        [tEndLable setHidden:NO];
        [sameTimeLable setHidden:YES];
        [sameDayLable setHidden:YES];
        
        //设置数据
        startTimeLable.text=[startday abbreviationWeekDayMotch];
        tStartLable.text=startTime;
        endTimeLabel.text=[endday abbreviationWeekDayMotch];
        tEndLable.text=endTime;
        
    }

}

//弹出视图的代理方法
- (void)leveyPopListView:(UIView *)popListView didSelectedIndex:(NSInteger)anIndex{


}
- (void)leveyPopListViewDidCancel{

}

-(void)disviewcontroller{
    [self sureEvent];
    [self.navigationController popViewControllerAnimated:YES];
}


-(void)sureEvent{
   
    NSString *startDateStr;
    NSString *endDateStr;
    if (isButtonOn) {//是全天事件
        CLDay * startday=[[CLDay alloc] initWithDate:[[PublicMethodsViewController getPublicMethods] formatWithStringDate:startLabel.text]];
        CLDay * endday=[[CLDay alloc] initWithDate:[[PublicMethodsViewController getPublicMethods] formatWithStringDate:endLabel.text]];
        if ([[startday description] isEqualToString:[endday description]]) {
            NSDateFormatter *df=[[NSDateFormatter alloc] init];
            [df setDateFormat:@"YYYY年 M月d日HH:ss"];
            NSDate *startDate=[df dateFromString:startLabel.text];
            NSDate *endDate=[CalendarDateUtil dateWithTimeInterval:1 sinceDate:startDate];
            
            CLDay * startday_t=[[CLDay alloc] initWithDate:startDate];
            CLDay * endday_t=[[CLDay alloc] initWithDate:endDate];
            startDateStr=[NSString stringWithFormat:@"%@%@",[startday_t description],@"00:00" ];
            endDateStr=[NSString stringWithFormat:@"%@%@",[endday_t description],@"00:00" ];
        }else{
            startDateStr=[NSString stringWithFormat:@"%@%@",[startday description],@"00:00" ];
            endDateStr=[NSString stringWithFormat:@"%@%@",[endday description],@"00:00" ];
        }
    }else{
        startDateStr=startLabel.text;
        endDateStr=endLabel.text;
    }

    NSDateFormatter *df=[[NSDateFormatter alloc] init];
    [df setDateFormat:@"YYYY年 M月d日HH:ss"];
    NSDate *date1=[df dateFromString:startDateStr];
    NSDate *date2=[df dateFromString:endDateStr];
    int a = [date1 timeIntervalSinceDate:date2];
    
    switch ([date1 compare:date2]) {
        case NSOrderedSame:
            NSLog(@"相等");
            break;
        case NSOrderedAscending:
            break;
        case NSOrderedDescending:
        {
           UIAlertView* alert=[[UIAlertView alloc]initWithTitle:@"提示" message:@"结束时间必须大于开始时间" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
            [alert show];
            return;
        }
            break;
        default:{
            UIAlertView* alert=[[UIAlertView alloc]initWithTitle:@"提示" message:@"非法时间" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
            [alert show];
            return;
            
        }
            break;
    }
    NSLog(@"%@--------%@",endLabel.text,startLabel.text);
    
    NSLog(@"%@<><><><><>%@",startStr,endStr);
    NSLog(@"date1%@---qweqwe----date2%@",date1,date2);
    NSLog(@">>>>>>>>>%d",a);
    [self.detelegate getstarttime:startDateStr getendtime:endDateStr isAllDay:isButtonOn];
}

-(void)fileStartDownload:(id)sender
{
    NSNotification *tmp = (NSNotification *)sender;
    NSString *timeStr=[NSString stringWithFormat:@"%@",[tmp object]];

    if (isstate) {
        NSString *tmpStart=[NSString stringWithFormat:@"%@%@",timeStr,startStr];
        NSString *tmpEnd=@"";
        if (!endLabel.text||[@"" isEqualToString:endLabel.text]){
            tmpEnd=[NSString stringWithFormat:@"%@%@",timeStr,endStr];
        }else{
            tmpEnd=endLabel.text;
        }
        startLabel.text=tmpStart;//yyyy年M月d日 HH:mm
        endLabel.text=tmpEnd;
        if (isButtonOn) {//开全天事件
            NSString *start=[NSString stringWithFormat:@"%@%@",timeStr,@"00:00"];
            startLabel.text=start;
            endLabel.text=[NSString stringWithFormat:@"%@%@",timeStr,@"23:59"];
            CLDay * startday=[[CLDay alloc] initWithDate:[[PublicMethodsViewController getPublicMethods] formatWithStringDate:tmpStart]];
            allDayLable.text=[NSString stringWithFormat:@"%@ (ALL DAY)",[startday abbreviationWeekDayMotch]];
        }else{
            [self createTitleViewShowDataStartDate:tmpStart endDate:tmpEnd];
        }
      
    }else{
        NSString *tmpEnd=[NSString stringWithFormat:@"%@%@",timeStr,endStr];
        NSString *tmpStart=startLabel.text;
        endLabel.text=tmpEnd;
        if (!isButtonOn) {
            [self createTitleViewShowDataStartDate:tmpStart endDate:tmpEnd];
        }else{
            CLDay * startday=[[CLDay alloc] initWithDate:[[PublicMethodsViewController getPublicMethods] formatWithStringDate:tmpStart]];
            CLDay * endday=[[CLDay alloc] initWithDate:[[PublicMethodsViewController getPublicMethods] formatWithStringDate:tmpEnd]];
            if ([[startday description] isEqualToString:[endday description]]) {
                 allDayLable.text=[[startday abbreviationWeekDayMotch] stringByAppendingString:@" (ALL DAY)"];
            }else{
             allDayLable.text=[NSString stringWithFormat:@"%@ → %@",[startday abbreviationWeekDayMotch],[endday abbreviationWeekDayMotch]];
            }
        }
    }
    
}


-(void)addEventViewControler:(UITableViewController *)view anyEvent:(AnyEvent *)anyEvent{
    
    anyEventObj=anyEvent;
    NSLog(@"%@",anyEvent.startDate);

}

- (void)datePicker:(JCDatePicker *)datePicker dateDidChange:(NSString *)date
{
    
    CLDay *startday=[[CLDay alloc] initWithDate:[[PublicMethodsViewController getPublicMethods] formatWithStringDate:startLabel.text]];
    CLDay *endday=[[CLDay alloc] initWithDate:[[PublicMethodsViewController getPublicMethods] formatWithStringDate:endLabel.text]];
    if (isstate) {
        startStr=date;
        NSString *endTime=[[PublicMethodsViewController getPublicMethods] formaterStringfromDate:@"HH:mm" dateString: endLabel.text];

        if ([[startday description] isEqualToString:[endday description]]) {
              sameTimeLable.text=[NSString stringWithFormat:@"%@ → %@",startStr,endTime];
              startLabel.text=[NSString stringWithFormat:@"%@%@",[startday description],date];
              endLabel.text=[NSString stringWithFormat:@"%@%@",[startday description],endTime];
        }else{
             tStartLable.text=date;
             startLabel.text=[NSString stringWithFormat:@"%@%@",[startday description],date];
             endLabel.text=[NSString stringWithFormat:@"%@%@",[endday description],endTime];
        }
    }else{
        endStr=date;
         NSString *startTime=[[PublicMethodsViewController getPublicMethods] formaterStringfromDate:@"HH:mm" dateString: startLabel.text];
        if ([[startday description] isEqualToString:[endday description]]) {
            sameTimeLable.text=[NSString stringWithFormat:@"%@ → %@",startTime,endStr];
            
            startLabel.text=[NSString stringWithFormat:@"%@%@",[startday description],startTime];
            endLabel.text=[NSString stringWithFormat:@"%@%@",[startday description],date];
        }else{
            tEndLable.text=date;
            
            startLabel.text=[NSString stringWithFormat:@"%@%@",[startday description],startTime];
            endLabel.text=[NSString stringWithFormat:@"%@%@",[endday description],date];
        }
        // endLabel.text=[NSString stringWithFormat:@"%@%@",[endday description],date];
    }
}



-(void)chooseAllDay:(UIButton *) sender
{
    MJSecondDetailViewController *secondDetailViewController = [[MJSecondDetailViewController alloc] init];
    if (isstate) {
        endLabel.text=startLabel.text;
    }
    NSDateFormatter *df=[[NSDateFormatter alloc] init];
    [df setDateFormat:@"YYYY年 M月d日HH:ss"];
    NSDate *date1=[df dateFromString:[NSString stringWithFormat:@"%@%@",startLabel.text,startStr]];
    NSDate *date2=[df dateFromString:[NSString stringWithFormat:@"%@%@",endLabel.text,endStr]];
    
    MAEvent *event=[[MAEvent alloc] init];
    event.start=date1;
    event.end=date2;
    event.title=@"nihao";
    event.displayDate=date1;
    secondDetailViewController.event=event;
    NSLog(@"%@",@"========>>>>>>转的事件");
    
    // secondDetailViewController.mjdelegate = self;
    
    
    YQNavigationController *nav = [[YQNavigationController alloc] initWithSize:CGSizeMake(300, 400) rootViewController:secondDetailViewController];
    nav.touchSpaceHide = YES;
    nav.panPopView = YES;
    
    [nav show:YES animated:YES];
}


-(void)switchAction:(id)sender
{
    UISwitch *switchButton = (UISwitch*)sender;
    isButtonOn = [switchButton isOn];
    if (isButtonOn) {
        datePicker.hidden=YES;

        [allDayLable setHidden:NO];
        [flagLab setHidden:YES];
        [startTimeLable setHidden:YES];
        [tStartLable setHidden:YES];
        [endTimeLabel setHidden:YES];
        [tEndLable setHidden:YES];
        [sameTimeLable setHidden:YES];
        [sameDayLable setHidden:YES];
        
        CLDay *startday=[[CLDay alloc] initWithDate:[[PublicMethodsViewController getPublicMethods] formatWithStringDate:startLabel.text]];
        CLDay *endday=[[CLDay alloc] initWithDate:[[PublicMethodsViewController getPublicMethods] formatWithStringDate:endLabel.text]];
         if ([[startday description] isEqualToString:[endday description]]) {
             allDayLable.text=[[startday abbreviationWeekDayMotch] stringByAppendingString:@" (ALL DAY)"];
         }else{
              allDayLable.text=[NSString stringWithFormat:@"%@ → %@",[startday abbreviationWeekDayMotch],[endday abbreviationWeekDayMotch]];
         }
        
    }else {
        [allDayLable setHidden:YES];
        datePicker.hidden=NO;
        
        CLDay *startday=[[CLDay alloc] initWithDate:[[PublicMethodsViewController getPublicMethods] formatWithStringDate:startLabel.text]];
        CLDay *endday=[[CLDay alloc] initWithDate:[[PublicMethodsViewController getPublicMethods] formatWithStringDate:endLabel.text]];
        
        if ([[startday description] isEqualToString:[endday description]]) {
            [flagLab setHidden:YES];
            [sameTimeLable setHidden:NO];
            [sameDayLable setHidden:NO];
            
            [startTimeLable setHidden:YES];
            [tStartLable setHidden:YES];
            [endTimeLabel setHidden:YES];
            [tEndLable setHidden:YES];
            NSString *startD=[NSString stringWithFormat:@"%@%@",[startday description],startStr] ;
            NSString *endD=[NSString stringWithFormat:@"%@%@",[endday description],endStr] ;
            [self createTitleViewShowDataStartDate:startD endDate:endD];
        }else{
            NSString *startD=[NSString stringWithFormat:@"%@%@",[startday description],startStr] ;
             NSString *endD=[NSString stringWithFormat:@"%@%@",[endday description],endStr] ;
            [self createTitleViewShowDataStartDate:startD endDate:endD];
        }

    }
}
-(void)calendartitle:(NSString *)title{
    
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

#pragma mark - Method

- (NSMutableArray*)switchWeekByDate:(NSDate*)date;
{
    NSMutableArray* array = [[NSMutableArray alloc] init];
    
    int head = [CalendarDateUtil getWeekDayWithDate:date] - 1;
    
    NSUInteger *time=[[PublicMethodsViewController getPublicMethods] timeIntegerDifference:anyEventObj.endDate getStrart:anyEventObj.startDate];
    

    
    for (int i = 0 ; i < 7; i++) {
        NSDate *temp = [CalendarDateUtil dateWithTimeInterval:i - head sinceDate:date];
        CLDay *day = [[CLDay alloc] initWithDate:temp];
//        for (int t=0; t<=time; t++) {
//            NSDate *startDate=[[PublicMethodsViewController getPublicMethods] formatWithStringDate:anyEventObj.startDate];
//            CLDay *inDate=[[CLDay alloc] initWithDate:[CalendarDateUtil dateWithTimeInterval:t sinceDate:startDate]];
//            
//            if ([[inDate description] isEqualToString:[day description]]) {
//                day.isSelectDay=YES;
//            }else{
//                day.isSelectDay=NO;
//            }
//        }
        [array addObject:day];
    }
    
    return array;
}

#pragma mark - CLCalendarDataSource

- (NSArray*)dateSourceWithCalendarView:(CLCalendarView *)calendarView
{
    return [NSArray arrayWithArray:dateArr];
}

-(void)calendarSelectEvent:(CLCalendarView *)calendarView day:(CLDay *)day event:(AnyEvent *)event AllEvent:(NSArray *)events{
}


#pragma mark - CLCalendar Delegate

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
       titleLabel.text = [title stringByAppendingFormat:@" %i", year];
    }
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)startevent:(id)sender {
    isstate=YES;
    datePicker.date=startStr;
    NSLog(@"%@",startStr);
   
    self.startEventButton.backgroundColor=purple;
    self.endbutton.backgroundColor=grayjcDatePicker;
    
}

- (IBAction)endEvent:(id)sender {
      isstate=NO;
    datePicker.date=endStr;
    NSLog(@"%@",endStr);
    
  
   // endLabel.text=startLabel.text;
    self.endbutton.backgroundColor=purple;
    self.startEventButton.backgroundColor=grayjcDatePicker;
    
}
@end
