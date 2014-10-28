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

#define LineGroundColor [UIColor colorWithRed:201.0f/255.0f green:201.0f/255.0f blue:201.0f/255.0f alpha:1.0f]
@interface ViewController ()<MJSecondPopupDelegate>{
    UILabel* titleLabel;
    NSMutableArray* houresArray;
    NSMutableArray* minArray;
    UILabel* startLabel;
    UILabel* endLabel;
    BOOL isstate;
    NSString* startStr;
    NSString* endStr;
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
}



- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.startEventButton.backgroundColor=purple;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(fileStartDownload:) name:@"day" object:nil];
    UIButton *leftBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [leftBtn setBackgroundImage:[UIImage imageNamed:@"Icon_BackArrow.png"] forState:UIControlStateNormal];
   
    [leftBtn setFrame:CGRectMake(0, 2, 15, 20)];
    [leftBtn addTarget:self action:@selector(disviewcontroller) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]initWithCustomView:leftBtn];
   
    UIButton *rightBtn=[UIButton buttonWithType:UIButtonTypeCustom];
    [rightBtn setBackgroundImage:[UIImage imageNamed:@"free.png"] forState:UIControlStateNormal];
    [rightBtn setBackgroundImage:[UIImage imageNamed:@"occupied.png"] forState:UIControlStateHighlighted];
    [rightBtn setFrame:CGRectMake(CGRectGetWidth(leftBtn.frame)-CGRectGetWidth(leftBtn.bounds), CGRectGetMinY(leftBtn.frame), CGRectGetWidth(leftBtn.bounds), CGRectGetHeight(leftBtn.bounds))];
    [rightBtn addTarget:self action:@selector(chooseAllDay:) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.rightBarButtonItem=[[UIBarButtonItem alloc] initWithCustomView:rightBtn];
    
    
    /* 导航栏标题 */
    UIControl *titleView = [[UIControl alloc]initWithFrame:CGRectMake(0, 0, 140, 40)];
    
    
    
    titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 140, 40)];
    //titleLabel.backgroundColor = [UIColor redColor];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.font = [UIFont boldSystemFontOfSize:22];
    titleLabel.textColor = [UIColor whiteColor];
    titleLabel.text = @"January 2014";
    
    
    
    
    [titleView addSubview:titleLabel];
    
    self.navigationItem.titleView = titleView;
    
    calendarView = [[CLCalendarView alloc] initWithFrame:CGRectMake(0, 103, self.view.frame.size.width, 155)];
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
    [switchButton setOn:NO];
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
    NSArray* array=[NSArray arrayWithObjects:@"Am", nil];
    datePicker.dayArray=array;
    
    [self.view addSubview:datePicker];
    startLabel=[[UILabel alloc]initWithFrame:CGRectMake(0, 0, 0, 0)];
    startLabel.text=[[PublicMethodsViewController getPublicMethods] getcurrentTime:@"yyyy年 M月d日"];
    startStr=[[PublicMethodsViewController getPublicMethods] getcurrentTime:@"HH:mm"];
    endLabel=[[UILabel alloc]initWithFrame:CGRectMake(0, 0, 0, 0)];
    
    endStr=[[PublicMethodsViewController getPublicMethods] getonehourstime:@"HH:mm"];
    isstate=YES;
    NSDateFormatter *formatter =[[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"YYYY年 M月d日"];
    NSDate* date=[formatter dateFromString:startLabel.text];
    NSString* weakStr=[[PublicMethodsViewController getPublicMethods] getWeekdayFromDate:date];
    NSString* str=startLabel.text;
    str=[str stringByReplacingOccurrencesOfString:@"年 " withString:@"/"];
    str=[str stringByReplacingOccurrencesOfString:@"月" withString:@"/"];
    str=[str stringByReplacingOccurrencesOfString:@"日" withString:@"/"];
    NSArray* arrays=[str componentsSeparatedByString:@"/"];
    self.startlabelshow.text=[NSString stringWithFormat:@"%@ %@/%@",weakStr,[arrays objectAtIndex:2],[arrays objectAtIndex:1]];
    self.endlabelshow.text=[NSString stringWithFormat:@"%@ %@/%@",weakStr,[arrays objectAtIndex:2],[arrays objectAtIndex:1]];
    // Do any additional setup after loading the view from its nib.
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
    if (isstate) {
        endLabel.text=startLabel.text;
    }
    NSDateFormatter *df=[[NSDateFormatter alloc] init];
    [df setDateFormat:@"YYYY年 M月d日HH:ss"];
    NSDate *date1=[df dateFromString:[NSString stringWithFormat:@"%@%@",startLabel.text,startStr]];
    NSDate *date2=[df dateFromString:[NSString stringWithFormat:@"%@%@",endLabel.text,endStr]];
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
    startLabel.text=[NSString stringWithFormat:@"%@%@",startLabel.text,startStr];
    endLabel.text=[NSString stringWithFormat:@"%@%@",endLabel.text,endStr];
    NSLog(@"%@--------%@",endLabel.text,startLabel.text);
    
    NSLog(@"%@<><><><><>%@",startStr,endStr);
    NSLog(@"date1%@---qweqwe----date2%@",date1,date2);
    NSLog(@">>>>>>>>>%d",a);
    [self.detelegate getstarttime:startLabel.text getendtime:endLabel.text];
}

-(void)fileStartDownload:(id)sender
{
    NSNotification *tmp = (NSNotification *)sender;
    
    if (isstate) {
        startLabel.text=[NSString stringWithFormat:@"%@",[tmp object]];
        self.startlabelshow.text=startLabel.text;
        self.endlabelshow.text=startLabel.text;
        NSDateFormatter *formatter =[[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"YYYY年 M月dd日"];
        NSDate* date=[formatter dateFromString:startLabel.text];
        NSString* weakStr=[[PublicMethodsViewController getPublicMethods] getWeekdayFromDate:date];
        NSString* str=startLabel.text;
        str=[str stringByReplacingOccurrencesOfString:@"年 " withString:@"/"];
        str=[str stringByReplacingOccurrencesOfString:@"月" withString:@"/"];
        str=[str stringByReplacingOccurrencesOfString:@"日" withString:@"/"];
        NSArray* array=[str componentsSeparatedByString:@"/"];
        self.startlabelshow.text=[NSString stringWithFormat:@"%@ %@/%@",weakStr,[array objectAtIndex:2],[array objectAtIndex:1]];
        self.endlabelshow.text=[NSString stringWithFormat:@"%@ %@/%@",weakStr,[array objectAtIndex:2],[array objectAtIndex:1]];
    }else{
        endLabel.text=[NSString stringWithFormat:@"%@",[tmp object]];
        NSDateFormatter *formatter =[[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"YYYY年 M月dd日"];
        NSDate* date=[formatter dateFromString:endLabel.text];
        NSString* weakStr=[[PublicMethodsViewController getPublicMethods] getWeekdayFromDate:date];
        NSString* str=endLabel.text;
        str=[str stringByReplacingOccurrencesOfString:@"年 " withString:@"/"];
        str=[str stringByReplacingOccurrencesOfString:@"月" withString:@"/"];
        str=[str stringByReplacingOccurrencesOfString:@"日" withString:@"/"];
        NSArray* array=[str componentsSeparatedByString:@"/"];
        self.endlabelshow.text=[NSString stringWithFormat:@"%@ %@/%@",weakStr,[array objectAtIndex:2],[array objectAtIndex:1]];
    }
    
}


- (void)datePicker:(JCDatePicker *)datePicker dateDidChange:(NSString *)date
{
    if (isstate) {
        startStr=date;
    }else{
        endStr=date;
    }
}



-(void)chooseAllDay:(UIButton *) sender
{
//    DayViewController *dailyCalController = [[DayViewController alloc] init];
//    [self.navigationController pushViewController:dailyCalController animated:YES];
    MJSecondDetailViewController *secondDetailViewController = [[MJSecondDetailViewController alloc] initWithNibName:@"MJSecondDetailViewController" bundle:nil];
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

    secondDetailViewController.mjdelegate = self;
    [self presentPopupViewController:secondDetailViewController animationType:MJPopupViewAnimationFade];
}


-(void)switchAction:(id)sender
{
    UISwitch *switchButton = (UISwitch*)sender;
    BOOL isButtonOn = [switchButton isOn];
    if (isButtonOn) {
        startStr=@"";
        endStr=@"";
        datePicker.hidden=YES;
    }else {
        datePicker.hidden=NO;
        
    }
}
-(void)calendartitle:(NSString *)title{
    
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [calendarView goBackToday];
}

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
            title = @"Jan.";
            break;
        case 2:
            title = @"Feb.";
            break;
        case 3:
            title = @"Mar.";
            break;
        case 4:
            title = @"Apr.";
            break;
        case 5:
            title = @"May";
            break;
        case 6:
            title = @"Jun.";
            break;
        case 7:
            title = @"Jul.";
            break;
        case 8:
            title = @"Aug.";
            break;
        case 9:
            title = @"Sept.";
            break;
        case 10:
            title = @"Oct.";
            break;
        case 11:
            title = @"Nov.";
            break;
        case 12:
            title = @"Dec.";
            break;
            
        default:
            break;
    }
    titleLabel.text = [title stringByAppendingFormat:@" %i", year];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)startevent:(id)sender {
    isstate=YES;
    datePicker.date=[[PublicMethodsViewController getPublicMethods] getcurrentTime:@"HH:mm"];
    self.startEventButton.backgroundColor=purple;
    self.endbutton.backgroundColor=grayjcDatePicker;
    
}

- (IBAction)endEvent:(id)sender {
    datePicker.date=[[PublicMethodsViewController getPublicMethods] getonehourstime:@"HH:mm"];
    isstate=NO;
    endLabel.text=startLabel.text;
    self.endbutton.backgroundColor=purple;
    self.startEventButton.backgroundColor=grayjcDatePicker;
    
}
@end
