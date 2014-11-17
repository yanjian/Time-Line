//
//  RepeatUntilViewController.m
//  Time-Line
//
//  Created by IF on 14/11/12.
//  Copyright (c) 2014年 zhilifang. All rights reserved.
//

#import "RepeatUntilViewController.h"
#import "CLCalendarView.h"
@interface RepeatUntilViewController ()<CLCalendarDataSource,CLCalendarDelegate,UITableViewDataSource,UITableViewDelegate>{
     CLCalendarView *calendarView;
     NSMutableArray *dateArr;
}
@property (nonatomic,strong) UITableView *tableView;
@end

@implementation RepeatUntilViewController

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
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(chickSelectStartDate:) name:@"day" object:nil];

    
    calendarView = [[CLCalendarView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 220)];
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
    calendarView.displayMode = !calendarView.displayMode;
    
    
    dateArr = [NSMutableArray array];
    NSInteger cDay = calendarDateCount;
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
    
    UIView *titleView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 200, 40)];
    UILabel* titlelabel=[[UILabel alloc]initWithFrame:titleView.frame];
    titlelabel.textAlignment = NSTextAlignmentCenter;
    titlelabel.font =[UIFont fontWithName:@"Helvetica Neue" size:20.0];
    titlelabel.textColor = [UIColor whiteColor];
    [titleView addSubview:titlelabel];
    self.navigationItem.titleView =titleView;
    titlelabel.text = @"Repeat";
    
    UIButton *leftBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [leftBtn setBackgroundImage:[UIImage imageNamed:@"Icon_BackArrow.png"] forState:UIControlStateNormal];
    
    [leftBtn setFrame:CGRectMake(0, 2, 21, 25)];
    [leftBtn addTarget:self action:@selector(disviewcontroller) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]initWithCustomView:leftBtn];
    
    self.tableView=[[UITableView alloc] initWithFrame:CGRectMake(0, 0, kScreen_Width, kScreen_Height-naviHigth) style:UITableViewStyleGrouped];
    self.tableView.delegate=self;
    self.tableView.dataSource=self;
    self.tableView.scrollEnabled = NO;//禁止滚动
    [self.view addSubview:self.tableView];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
  //  [calendarView goBackToday];
}


-(void)chickSelectStartDate:(NSNotification *) notification{
    CLDay *selectDate=[notification object];
    NSLog(@"==========>>>> %@", [selectDate abbreviationWeekDayMotch]);
    [self.delegate selectedDidDate:selectDate];
    [self disviewcontroller];
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section==0) {
        return 240.f;
    }
    return 44.f;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    if(section==0){
        return 0.1f;
    }
    return 30.f;
 
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static  NSString *cellID=@"repeatUntilID";
    UITableViewCell *repeartCell=[tableView dequeueReusableCellWithIdentifier:cellID];
    if (!repeartCell) {
        repeartCell=[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID];
    }
    if (indexPath.section==0) {
        [repeartCell.contentView addSubview:calendarView];
    }else if (indexPath.section==1){
        repeartCell.textLabel.textAlignment=NSTextAlignmentCenter;
        repeartCell.textLabel.text=@"Repeat Forever";
    }
    return repeartCell;
}


-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.section==1) {
        [self.delegate selectedDidDate:nil];
        [self disviewcontroller];
    }
}



- (NSArray*)dateSourceWithCalendarView:(CLCalendarView *)calendarView{
    return dateArr;
}

- (void)calendarDidToMonth:(int)month year:(int)year CalendarView:(CLCalendarView *)calendarView{

}

- (void)calendarSelectEvent:(CLCalendarView *)calendarView day:(CLDay*)day event:(AnyEvent*)event AllEvent:(NSArray*)events{

}

-(void)calendartitle:(NSString*)title{

}



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
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


-(void)disviewcontroller{
    [self.navigationController popViewControllerAnimated:YES];
}


@end
