//
//  SimpleEventViewController.m
//  Go2
//
//  Created by IF on 15/4/30.
//  Copyright (c) 2015年 zhilifang. All rights reserved.
//

#import "SimpleEventViewController.h"
#import "LocationViewController.h"
#import "CalendarAccountViewController.h"
#import "RepeatViewController.h"
#import "CircleDrawView.h"
#import "ManageViewController.h"
#import "HomeViewController.h"

#import "RecurrenceModel.h"
#import "Calendar.h"
#import "AnyEvent.h"
#import "AT_Event.h"
#import "UIColor+HexString.h"

#define XSPACING 20
#define STARTENDSPACING 55
#define CELLOFLABLEH 44


typedef NS_ENUM(NSInteger, DateStartOrEndType) {
    DateStartOrEndType_start = 1,
    DateStartOrEndType_end = 2
};

@interface SimpleEventViewController ()<UITextViewDelegate,UITextFieldDelegate,RepeatViewControllerDelegate,CalendarAccountDelegate,getlocationDelegate,UITableViewDataSource,UITableViewDelegate>{
    UITextField  *  eventTitle ;
    UILabel      *  eventLocation ;
    UISwitch     *  eventAllDaySwitch ;
    UILabel      *  startTimeLable ;
    UILabel      *  endTimeLable ;
    UIView       *  pickView ;
    UIDatePicker *  datePickers ;
    UILabel      *  repeatsLab;
    UILabel      *  calendarLab ;
    UITextView   *  noteTextView ;
    UILabel      *  placeholderLab;
    
    NSMutableArray * dataArr;
    NSIndexPath    * lastPath;
    DateStartOrEndType dateStartOrEndType ;//表示选择的是开始时间还是结束时间
    NSDictionary *coordinates;
    
    //开始时间---结束时间
    NSDate * startDate ;
    NSDate * endDate ;
    //是否为全天
    BOOL isAllDay ;
    
    RecurrenceModel *recurObj;
    AnyEvent *eventData;
    
    NSIndexPath * clickIndexPath; //记住用户点击的行
}
@property (nonatomic,strong) Calendar *calendarObj;

@end

@implementation SimpleEventViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self colorWithNavigationBar];
    self.title = @"Event Details" ;
    
    UIButton *leftBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    
    [leftBtn setTag:1];
    if(self.isEdit){
        [leftBtn setFrame:CGRectMake(0, 0, 22, 14)];
        [leftBtn setBackgroundImage:[UIImage imageNamed:@"go2_arrow_left"] forState:UIControlStateNormal] ;
    }else{
        [leftBtn setFrame:CGRectMake(0, 0, 17 , 17)];
        [leftBtn setBackgroundImage:[UIImage imageNamed:@"go2_cross"] forState:UIControlStateNormal] ;
    }
    [leftBtn addTarget:self action:@selector(backToEventView:) forControlEvents:UIControlEventTouchUpInside] ;
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:leftBtn] ;
    
    UIButton *rightBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [rightBtn setFrame:CGRectMake(0, 0, 22, 14)];
    [rightBtn setTag:2];
    [rightBtn setBackgroundImage:[UIImage imageNamed:@"go2_tick"] forState:UIControlStateNormal] ;
    [rightBtn addTarget:self action:@selector(saveEventData:) forControlEvents:UIControlEventTouchUpInside] ;
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:rightBtn] ;
    
    self.navigationController.interactivePopGestureRecognizer.delegate =(id) self ;
    
    dataArr =  [[NSMutableArray alloc] initWithObjects:
               @[@{@"title":@"Title"},@{@"location":@"Location"}].mutableCopy,
               @[@{@"allDay":@"All-day"},@{@"starts":@"Starts"},@{@"ends":@"Ends"},@{@"repeats":@"Repeats"}].mutableCopy,
               @[@{@"calendar":@"Calendar"},@{@"note":@"Note"}].mutableCopy,nil];
    
    //查询默认日历
    NSPredicate *pre=[NSPredicate predicateWithFormat:@"isDefault==1"];
    self.calendarObj=[[Calendar MR_findAllWithPredicate:pre] lastObject];
    
    
    [self createSimpleEventTitle];
    [self createSimpleEventLocation];
    [self createSimpleEventAllDaySwitch];
    [self createSimpleEnvenStartAndEnd];
    [self createDatePicker];
    [self createSimpleEnvenRepeats];
    [self createSimpleEnvenCalendar];
    [self createSimpleEnvenNote];
}


-(void)createSimpleEventTitle{
    eventTitle = [[UITextField alloc] initWithFrame:CGRectMake(XSPACING, 0, kScreen_Width-XSPACING-5, CELLOFLABLEH)] ;
    eventTitle.placeholder = @"Title" ;
    eventTitle.adjustsFontSizeToFitWidth = YES ;
    eventTitle.clearButtonMode = UITextFieldViewModeWhileEditing;
    eventTitle.delegate = self ;
    eventTitle.returnKeyType = UIReturnKeyDone ;
   
    if (self.isEdit) {
        eventTitle.text = self.event.eventTitle ;
    }
}

-(void)createSimpleEventLocation{
    eventLocation = [[UILabel alloc] initWithFrame:CGRectMake(XSPACING, 0, kScreen_Width-XSPACING-5, CELLOFLABLEH)] ;
    eventLocation.attributedText = [[NSAttributedString alloc] initWithString:@"Location" attributes:@{NSForegroundColorAttributeName:[UIColor lightGrayColor]}];
    eventLocation.adjustsFontSizeToFitWidth = YES ;
    
    if (self.isEdit) {
        eventLocation.text = self.event.location ;
    }
    
}

-(void)createSimpleEventAllDaySwitch{
    eventAllDaySwitch = [[UISwitch alloc] init];
    [eventAllDaySwitch sizeToFit];
    [eventAllDaySwitch addTarget:self action:@selector(listeningValueChanged:) forControlEvents:UIControlEventValueChanged] ;
    eventAllDaySwitch.on = NO ;
    if (self.isEdit) {
        isAllDay = [self.event.isAllDay boolValue];
        if (isAllDay) {
            eventAllDaySwitch.on = YES ;
            
        }else{
             eventAllDaySwitch.on = NO ;
        }
    }
    
}

-(void)createSimpleEnvenStartAndEnd{
    startTimeLable=[[UILabel alloc] initWithFrame:CGRectMake(STARTENDSPACING, 0, kScreen_Width-(STARTENDSPACING+XSPACING+5), CELLOFLABLEH)] ;
    startTimeLable.textAlignment = NSTextAlignmentRight ;
    startTimeLable.adjustsFontSizeToFitWidth = YES ;
    
    endTimeLable = [[UILabel alloc] initWithFrame:CGRectMake(STARTENDSPACING, 0, kScreen_Width-(STARTENDSPACING+XSPACING+5), CELLOFLABLEH)] ;
    endTimeLable.textAlignment = NSTextAlignmentRight ;
    endTimeLable.adjustsFontSizeToFitWidth = YES ;
    
    
    NSDate *currDate = [NSDate date] ;
    startDate =  [currDate dateByAddingTimeInterval:5*60];
    endDate =  [startDate dateByAddingTimeInterval:60*60];
    
    if (self.isEdit) {
        startDate = [[PublicMethodsViewController getPublicMethods] formatWithStringDate:self.event.startDate];
        endDate   = [[PublicMethodsViewController getPublicMethods] formatWithStringDate:self.event.endDate];
    }
    
   
    if(!isAllDay){
         startTimeLable.text  = [self formaterDate:startDate formaterStyle:[self timeIs24HourFormat]?@"EEE, MMM d, yyyy  HH:mm":@"EEE, MMM d, yyyy  hh:mm"];
        if([self isSameWithstartDay:startDate endDate:endDate]){
            endTimeLable.text = [self formaterDate:endDate formaterStyle:[self timeIs24HourFormat]?@"HH:mm":@"hh:mm"];
        }else{
           endTimeLable.text  = [self formaterDate:endDate formaterStyle:[self timeIs24HourFormat]?@"EEE, MMM d, yyyy  HH:mm":@"EEE, MMM d, yyyy  hh:mm"];
        }
    }else{
         startTimeLable.text = [self formaterDate:startDate formaterStyle:@"EEE, MMM d, yyyy"];
         NSDate * tmpEndDate = [endDate dateByAddingTimeInterval:-1*24*60*60];
         endTimeLable.text   = [self formaterDate:tmpEndDate formaterStyle:@"EEE, MMM d, yyyy"];
    }
}

-(void)createSimpleEnvenRepeats{
    repeatsLab = [[UILabel alloc] initWithFrame:CGRectMake(STARTENDSPACING, 0, kScreen_Width-(STARTENDSPACING+XSPACING+5), CELLOFLABLEH)] ;
    repeatsLab.textAlignment = NSTextAlignmentRight ;
    repeatsLab.adjustsFontSizeToFitWidth = YES ;
    if(self.isEdit){
        if (self.event.recurrence&&![self.event.recurrence isEqualToString:@""]) {
            recurObj=[[RecurrenceModel alloc] initRecrrenceModel:self.event.recurrence];
            repeatsLab.text=recurObj.freq;
        }else{
            repeatsLab.text=@"None";
        }
    }else{
        repeatsLab.text=@"None";
    }
}

-(void)createDatePicker{
    pickView  = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 216)];
    datePickers = [[UIDatePicker alloc] initWithFrame:CGRectMake(0, 0, 0, 0)];
    [datePickers setBackgroundColor:[UIColor whiteColor]];
    datePickers.datePickerMode = UIDatePickerModeDateAndTime;
    [datePickers setTimeZone:[NSTimeZone timeZoneWithName:SYS_DEFAULT_TIMEZONE]];
    [datePickers sizeToFit] ;
    [datePickers addTarget:self action:@selector(datePickerDateChanged:) forControlEvents:UIControlEventValueChanged];
    [pickView addSubview:datePickers];
}

-(void)createSimpleEnvenCalendar{
    calendarLab = [[UILabel alloc] initWithFrame:CGRectMake(STARTENDSPACING, 0, kScreen_Width-(STARTENDSPACING+XSPACING+5), CELLOFLABLEH)] ;
    calendarLab.textAlignment = NSTextAlignmentRight ;
    calendarLab.adjustsFontSizeToFitWidth = YES ;
    if (self.isEdit) {
        calendarLab.text = self.event.calendarAccount ;
    }
}

-(void)createSimpleEnvenNote{
    noteTextView = [[UITextView alloc] initWithFrame:CGRectMake(0, 0, kScreen_Width, 120)] ;
    noteTextView.font = [UIFont fontWithName:@"Arial" size:17.0];
    noteTextView.scrollEnabled = YES ;
    noteTextView.returnKeyType = UIReturnKeyDone ;
    noteTextView.delegate = self ;
    if (self.isEdit) {
        if (self.event.note) {
            noteTextView.text = self.event.note ;
            return ;
        }
    }
    placeholderLab = [[UILabel alloc] initWithFrame:CGRectMake(XSPACING, 10, kScreen_Width, 20)];
    placeholderLab.attributedText = [[NSAttributedString alloc] initWithString:@"Note" attributes:@{NSForegroundColorAttributeName:[UIColor lightGrayColor]}];
    [noteTextView addSubview:placeholderLab] ;
    
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



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}


-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return dataArr.count;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    NSMutableArray * tmpArr = (NSMutableArray *) dataArr[section];
    return tmpArr.count ;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
   
    NSMutableArray * tmpArr = (NSMutableArray *)  dataArr[indexPath.section] ;
    NSMutableDictionary * tmpDic = tmpArr[indexPath.row];
    
    if (indexPath.section == 1) {
        if ([tmpDic objectForKey:@"attachedCell"] && [[tmpDic objectForKey:@"attachedCell"] isEqualToString:@"AttachedCell"]) {
             return 216.f;
        }
    }else if (indexPath.section == 2){
        if ([[tmpDic objectForKey:@"note"] isEqualToString:@"Note"]) {
            return 120.f;
        }
    }
    return 44.f;
}


-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    NSString * simpleEventCellId = [NSString stringWithFormat:@"simpleEventCellId%i%i",indexPath.section,indexPath.row] ;
    UITableViewCell *
//    = [tableView dequeueReusableCellWithIdentifier:simpleEventCellId]; //不重用
//    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:simpleEventCellId];
//    }
    NSMutableArray * tmpArr = (NSMutableArray *)  dataArr[indexPath.section] ;
    NSMutableDictionary * tmpDic = tmpArr[indexPath.row];
    
    for (UIView *subView in cell.contentView.subviews) {
        [subView removeFromSuperview];
    }
    
    if ([[tmpDic objectForKey:@"title"] isEqualToString:@"Title"]) {
        [cell.contentView addSubview:eventTitle];
    }else if ([[tmpDic objectForKey:@"location"] isEqualToString:@"Location"]){
        cell.accessoryType =  UITableViewCellAccessoryDisclosureIndicator ;
        [cell.contentView addSubview:eventLocation];
    }else if ([[tmpDic objectForKey:@"allDay"] isEqualToString:@"All-day"]){
        cell.textLabel.text = @"All-day" ;
        cell.accessoryView = eventAllDaySwitch ;
    }else if ([[tmpDic objectForKey:@"starts"] isEqualToString:@"Starts"]){
        cell.textLabel.text = @"Starts" ;
        [cell.contentView addSubview:startTimeLable];
    }else if ([[tmpDic objectForKey:@"ends"] isEqualToString:@"Ends"]){
        cell.textLabel.text = @"Ends" ;
        [cell.contentView addSubview:endTimeLable];
    }else if ([[tmpDic objectForKey:@"repeats"] isEqualToString:@"Repeats"]){
        cell.accessoryType =  UITableViewCellAccessoryDisclosureIndicator ;
        cell.textLabel.text = @"Repeats" ;
        [cell.contentView addSubview:repeatsLab];
    }else if ([[tmpDic objectForKey:@"calendar"] isEqualToString:@"Calendar"]){
        cell.accessoryType =  UITableViewCellAccessoryDisclosureIndicator ;
        cell.textLabel.text = @"Calendar" ;
        [cell.contentView addSubview:calendarLab];
        
        NSDictionary *attribute = @{NSFontAttributeName: [UIFont systemFontOfSize:17]};
        CGSize size = [self.calendarObj.summary boundingRectWithSize:CGSizeMake(320, 0) options: NSStringDrawingTruncatesLastVisibleLine | NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading attributes:attribute context:nil].size;
        CircleDrawView *cd =[[CircleDrawView alloc] initWithFrame:CGRectMake((kScreen_Width-XSPACING-size.width-30), 12, 20, 20)];
        if (self.isEdit) {
            cd.hexString = self.event.backgroundColor;
            calendarLab.text = self.event.calendarAccount;
        }else{
            cd.hexString = self.calendarObj.backgroundColor;
            calendarLab.text = self.calendarObj.summary;
        }
        [cell.contentView addSubview:cd];
        
    }else if ([[tmpDic objectForKey:@"note"] isEqualToString:@"Note"]){
        [cell.contentView addSubview:noteTextView];
    }else if([[tmpDic objectForKey:@"attachedCell"] isEqualToString:@"AttachedCell"]){
        [cell.contentView addSubview:pickView];
    }
    return cell ;
}


-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    clickIndexPath = indexPath ;
    
    
    NSMutableArray * tmpArr = (NSMutableArray *)  dataArr[indexPath.section] ;
    NSMutableDictionary * tmpDic = tmpArr[indexPath.row];
    if ([[tmpDic objectForKey:@"location"] isEqualToString:@"Location"]){
        LocationViewController * locationVC = [[LocationViewController alloc] init] ;
        locationVC.detelegate = self ;
        if (eventLocation.text) {
            locationVC.locationFiled.text = eventLocation.text ;
        }
        [self.navigationController pushViewController:locationVC animated:YES];
    }else if ([[tmpDic objectForKey:@"starts"] isEqualToString:@"Starts"]){
         dateStartOrEndType = DateStartOrEndType_start ;
        [datePickers setDate:startDate animated:YES] ;
        
        NSMutableDictionary * tmpDataDic = tmpArr[indexPath.row+2];
        if ([tmpDataDic objectForKey:@"attachedCell"] && [[tmpDataDic objectForKey:@"attachedCell"] isEqualToString:@"AttachedCell"]) {
            lastPath = [NSIndexPath indexPathForItem:indexPath.row+2 inSection:indexPath.section] ;
            [tmpArr removeObjectAtIndex:lastPath.row];
            [self.simpleEventTableView beginUpdates];
            [self.simpleEventTableView deleteRowsAtIndexPaths:@[lastPath]  withRowAnimation:UITableViewRowAnimationMiddle];
            [self.simpleEventTableView endUpdates];
        }else{
            lastPath = indexPath ;
        }
        [self showOrHidePickDate:indexPath dataArr:tmpArr] ;
    }else if ([[tmpDic objectForKey:@"ends"] isEqualToString:@"Ends"]){
        dateStartOrEndType = DateStartOrEndType_end ;
        [datePickers setDate:endDate animated:YES] ;
        
        NSMutableDictionary * tmpDataDic = tmpArr[indexPath.row-1];
        if ([tmpDataDic objectForKey:@"attachedCell"] && [[tmpDataDic objectForKey:@"attachedCell"] isEqualToString:@"AttachedCell"]) {
            lastPath = [NSIndexPath indexPathForItem:indexPath.row-1 inSection:indexPath.section] ;
            [tmpArr removeObjectAtIndex:lastPath.row];
            [self.simpleEventTableView beginUpdates];
            [self.simpleEventTableView deleteRowsAtIndexPaths:@[lastPath]  withRowAnimation:UITableViewRowAnimationMiddle];
            [self.simpleEventTableView endUpdates];
        }else{
            lastPath = indexPath ;
        }
         [self showOrHidePickDate:lastPath dataArr:tmpArr] ;
    }else if ([[tmpDic objectForKey:@"calendar"] isEqualToString:@"Calendar"]){
        
        CalendarAccountViewController *caVC=[[CalendarAccountViewController alloc] init];
        caVC.delegate=self;
        [self.navigationController pushViewController:caVC animated:YES];
    }else if ([[tmpDic objectForKey:@"repeats"] isEqualToString:@"Repeats"]){
        RepeatViewController *repeatVc = [[RepeatViewController alloc] init];
        repeatVc.recurrObj = recurObj;
        repeatVc.delegate=self;
        repeatVc.repeatParam = repeatsLab.text ;
        [self.navigationController pushViewController:repeatVc animated:YES];
    }
    
}

-(void)scrollViewDidScroll:(UIScrollView *)scrollView{
    if (scrollView == self.simpleEventTableView){
        if (eventTitle.isFirstResponder){
            [eventTitle resignFirstResponder];
        }
        if (noteTextView.isFirstResponder) {
            [noteTextView resignFirstResponder];
            [UIView animateWithDuration:0.5f animations:^{
               self.simpleEventTableView.frame = CGRectMake(0, 0, self.simpleEventTableView.bounds.size.width, self.simpleEventTableView.bounds.size.height);
            }];
        }
     }
}

-(void)showOrHidePickDate:(NSIndexPath *) indexPath dataArr:(NSMutableArray * ) tmpArr{
    lastPath = [NSIndexPath indexPathForItem:(indexPath.row+1) inSection:indexPath.section];
    NSMutableDictionary * tmpPathDic = tmpArr[lastPath.row];
    
    if ([[tmpPathDic objectForKey:@"isAttached"] boolValue]){
        [tmpArr removeObjectAtIndex:lastPath.row];
        [self.simpleEventTableView beginUpdates];
        [self.simpleEventTableView deleteRowsAtIndexPaths:@[lastPath]  withRowAnimation:UITableViewRowAnimationMiddle];
        [self.simpleEventTableView endUpdates];
    }else{
        NSDictionary * addDic = @{@"attachedCell": @"AttachedCell",@"isAttached":@(YES)};
        [tmpArr insertObject:addDic atIndex:lastPath.row];
        [self.simpleEventTableView beginUpdates];
        [self.simpleEventTableView insertRowsAtIndexPaths:@[lastPath] withRowAnimation:UITableViewRowAnimationMiddle];
        [self.simpleEventTableView endUpdates];
    }
}

-(void)listeningValueChanged:(UISwitch *) sender {
    if (sender.on) {
        isAllDay = YES ;
        [datePickers setDatePickerMode:UIDatePickerModeDate] ;
        startTimeLable.text = [self formaterDate:startDate formaterStyle:@"EEE, MMM d, yyyy"];
        endTimeLable.text = [self formaterDate:endDate formaterStyle:@"EEE, MMM d, yyyy"];

    }else{
        isAllDay = NO ;
        [datePickers setDatePickerMode:UIDatePickerModeDateAndTime] ;
        
        startTimeLable.text = [self formaterDate:startDate formaterStyle:[self timeIs24HourFormat]?@"EEE, MMM d, yyyy  HH:mm":@"EEE, MMM d, yyyy  hh:mm"];
        if([self isSameWithstartDay:startDate endDate:endDate]){
            endTimeLable.text = [self formaterDate:endDate formaterStyle:[self timeIs24HourFormat]?@"HH:mm":@"hh:mm"];
        }else{
            endTimeLable.text = [self formaterDate:endDate formaterStyle:[self timeIs24HourFormat]?@"EEE, MMM d, yyyy  HH:mm":@"EEE, MMM d, yyyy  hh:mm"];
        }
    }
}

-(void)datePickerDateChanged:(UIDatePicker *) datePicker {
    NSDate *selectDate = [datePicker date];
    switch (dateStartOrEndType) {
        case DateStartOrEndType_start:{
            startDate =  selectDate ;
            if(!isAllDay){//不是全天
               startTimeLable.text = [self formaterDate:startDate formaterStyle:[self timeIs24HourFormat]?@"EEE, MMM d, yyyy  HH:mm":@"EEE, MMM d, yyyy  hh:mm"];
                
                if([self isSameWithstartDay:startDate endDate:endDate]){
                    endTimeLable.text = [self formaterDate:endDate formaterStyle:[self timeIs24HourFormat]?@"HH:mm":@"hh:mm"];
                }else{
                    endTimeLable.text = [self formaterDate:endDate formaterStyle:[self timeIs24HourFormat]?@"EEE, MMM d, yyyy  HH:mm":@"EEE, MMM d, yyyy  hh:mm"];
                }

            }else{
                startTimeLable.text = [self formaterDate:startDate formaterStyle:@"EEE, MMM d, yyyy"];
            }
        }
        break;
        case DateStartOrEndType_end:{
            endDate = selectDate ;
            if(!isAllDay){//不是全天
                if([self isSameWithstartDay:startDate endDate:endDate]){
                    endTimeLable.text = [self formaterDate:endDate formaterStyle:[self timeIs24HourFormat]?@"HH:mm":@"hh:mm"];
                }else{
                    endTimeLable.text = [self formaterDate:endDate formaterStyle:[self timeIs24HourFormat]?@"EEE, MMM d, yyyy  HH:mm":@"EEE, MMM d, yyyy  hh:mm"];
                }
            }else{
                endTimeLable.text = [self formaterDate:endDate formaterStyle:@"EEE, MMM d, yyyy"];
            }
        }
        break ;
        default:
            break;
    }
}

-(void)backToEventView:(UIButton *) sender {
    [self.navigationController popViewControllerAnimated: YES] ;
}


-(NSString *)formaterDate:(NSDate *) selectDate formaterStyle:(NSString *) formater{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:formater];
    [dateFormatter setTimeZone:[NSTimeZone timeZoneWithName:SYS_DEFAULT_TIMEZONE]];
    return  [dateFormatter stringFromDate:selectDate];
}

#pragma mark - locationDelegate控制器 的代理
-(void)getlocation:(NSString*) name coordinate:(NSDictionary *) coordinatesDic{
    if (!name) {
        eventLocation.text = @"";
    }else{
        eventLocation.text = name ;
    }
    coordinates =  coordinatesDic;
}
#pragma mark - calendarAccount控制器 的代理。。。
- (void)calendarAccountWithAccont:(Calendar *)ca{
    NSLog(@"%@",ca);
    self.calendarObj=ca;
    calendarLab.text = ca.summary ;
    [self.simpleEventTableView reloadRowsAtIndexPaths:@[clickIndexPath] withRowAnimation:UITableViewRowAnimationNone];
}

#pragma mark -RepeatViewControllerDelegate的代理。。。。
- (void)selectValueWithDateString:(NSString *)dateString repeatRecurrence:(RecurrenceModel *)recurrence{
    repeatsLab.text = dateString;
    recurObj = recurrence;
    
    [self.simpleEventTableView reloadRowsAtIndexPaths:@[clickIndexPath] withRowAnimation:UITableViewRowAnimationNone];
}

#pragma mark - 保存事件
-(void)saveEventData:(UIButton *) sender {
    if (!eventTitle.text || [@"" isEqualToString:eventTitle.text]) {
        if (eventTitle.text.length<=0) {
            [eventTitle becomeFirstResponder];
        }
        return ;
    }
    if (self.isEdit) {
        [self editEvent];
    }else{
        [self saveEnvent];
    }
}


-(void)saveEnvent{
    if (!eventData) {
        eventData=[AnyEvent MR_createEntity];
    }
    eventData.eId            = [self generateUniqueEventID];
    eventData.eventTitle     = eventTitle.text;
    eventData.location       = eventLocation.text;
    NSLog(@"%@",[[PublicMethodsViewController getPublicMethods] stringformatWithDate:startDate]);
    
    if(isAllDay){
        NSString * startTime =  [NSString stringWithFormat:@"%@%@",[self formaterDate:startDate formaterStyle:@"YYYY年 M月d日"],@"00:00"];
        eventData.startDate  = startTime ;
        
        NSDate * tmpNewDate  = [endDate dateByAddingTimeInterval:1*60*60*24];
        NSString * endTime =  [NSString stringWithFormat:@"%@%@",[self formaterDate:tmpNewDate formaterStyle:@"YYYY年 M月d日"],@"00:00"];

        eventData.endDate    = endTime ;
    
    }else{
        eventData.startDate       = [[PublicMethodsViewController getPublicMethods] stringformatWithDate:startDate];
        eventData.endDate         = [[PublicMethodsViewController getPublicMethods] stringformatWithDate:endDate] ;
    }
    eventData.note            = noteTextView.text;
    eventData.calendarAccount = calendarLab.text;
    NSString *coor=nil;
    if (coordinates) {
        coor=[NSString stringWithFormat:@"%@;%@",[coordinates objectForKey:LATITUDE],[coordinates objectForKey:LONGITUDE]];
    }
    
    eventData.coordinate = coor;
    
    //    NSString * alertStr=nil;
    //    if( selectAlertArr) {
    //        alertStr=[selectAlertArr componentsJoinedByString:@","];
    //    }
    //    eventData.a4lerts= alertStr;
    
    //    NSString * repeatStr=nil;
    //    if(selectRepeatArr) {
    //        repeatStr=[selectRepeatArr componentsJoinedByString:@","];
    //    }
    //  eventData.repeat     = repeatStr;
    eventData.recurrence = [recurObj description];
    eventData.isSync     = @(isSyncData_NO);
    eventData.isDelete   = @(isDeleteData_NO);//数据非删除
    NSString * nowDate   = [[PublicMethodsViewController getPublicMethods] rfc3339DateFormatter:[NSDate new]];
    eventData.updated    =  nowDate;
    eventData.created    =  nowDate;
    eventData.creator    = [USER_DEFAULT objectForKey:@"email"];
    eventData.organizer  = [USER_DEFAULT objectForKey:@"email"];
    eventData.isAllDay   = @(isAllDay);//全天事件 标记
    eventData.status     = [NSString stringWithFormat:@"%li",(long)eventStatus_confirmed];//新添加的数据为确定状态
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
            [self createLocationNotice:eventData];
        }

        for (UIViewController* obj in [self.navigationController viewControllers]) {
            if ([obj isKindOfClass:[ManageViewController class]]) {
                ManageViewController *mVc= (ManageViewController *)obj;
                [self.navigationController popToViewController:mVc animated:YES];
                break ;
            }
        }
    }];
}

-(void)editEvent{
    
    NSPredicate * pre   = [NSPredicate predicateWithFormat:@"eId==%@ ",self.event.eId];
    AnyEvent * anyEvent = [[AnyEvent MR_findAllWithPredicate:pre ] lastObject];
    anyEvent.eventTitle = eventTitle.text;
    anyEvent.location   = eventLocation.text ;
    
    
    if(isAllDay){
        NSString * startTime =  [NSString stringWithFormat:@"%@%@",[self formaterDate:startDate formaterStyle:@"YYYY年 M月d日"],@"00:00"];
        eventData.startDate  = startTime ;
        
        NSDate * tmpNewDate  = [endDate dateByAddingTimeInterval:1*60*60*24];
        NSString * endTime =  [NSString stringWithFormat:@"%@%@",[self formaterDate:tmpNewDate formaterStyle:@"YYYY年 M月d日"],@"00:00"];
        
        eventData.endDate    = endTime ;
        
    }else{
        eventData.startDate       = [[PublicMethodsViewController getPublicMethods] stringformatWithDate:startDate];
        eventData.endDate         = [[PublicMethodsViewController getPublicMethods] stringformatWithDate:endDate] ;
    }
    
    anyEvent.note       = noteTextView.text;
    anyEvent.calendarAccount= calendarLab.text;
    NSString *coor      = nil;
    if (coordinates) {
        coor = [NSString stringWithFormat:@"%@;%@",[coordinates objectForKey:LATITUDE],[coordinates objectForKey:LONGITUDE]];
    }else{
        coor = self.event.coordinate ;
    }
    anyEvent.coordinate = coor;
    
//    NSString * alertStr=nil;
//    if( selectAlertArr) {
//        alertStr=[selectAlertArr componentsJoinedByString:@","];
//    }
//    anyEvent.alerts= alertStr;
    
    anyEvent.calendarAccount= calendarLab.text;
    if ([recurObj description]) {
        anyEvent.recurrence=[recurObj description];
    }
//    NSString * repeatStr=nil;
//    if(selectRepeatArr) {
//        repeatStr=[selectRepeatArr componentsJoinedByString:@","];
//    }
//    anyEvent.repeat = repeatStr;
    anyEvent.isSync   = @(isSyncData_NO);//数据没有同步
    anyEvent.isDelete = @(isDeleteData_NO);//数据非删除
    
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
            [self createLocationNotice:anyEvent];
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

#pragma mark -uitextview 的代理。。。
- (void)textViewDidChange:(UITextView *)textView{
    if (placeholderLab) {
         [placeholderLab removeFromSuperview] ;
    }
}

- (BOOL)textViewShouldBeginEditing:(UITextView *)textView{
    [UIView animateWithDuration:0.5f animations:^{
        self.simpleEventTableView.frame = CGRectMake(0, -200, self.simpleEventTableView.bounds.size.width, self.simpleEventTableView.bounds.size.height);
    }];
    return YES;
}

#pragma mark - textField的代理
-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    if (textField.isFirstResponder) {
        [textField resignFirstResponder];
    }
    return YES ;
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

//生成唯一个eventId
-(NSString *) generateUniqueEventID
{
    NSString *prefix=@"event";
    NSDate *newDate=[NSDate date];
    NSDateFormatter *df=[[NSDateFormatter alloc] init];
    [df setDateFormat:@"YYYYMdHHmmss"];
    NSString *dateStr=[df stringFromDate:newDate];
    NSInteger random= arc4random()%10000+1;
    return [NSString stringWithFormat:@"%@%@%ld",prefix,dateStr,(long)random];
}



-(void)createLocationNotice:(AnyEvent *) anyEvent{
    NSDateFormatter *dateFormatter=[[NSDateFormatter alloc] init];
    [dateFormatter setTimeZone: [NSTimeZone timeZoneWithName:SYS_DEFAULT_TIMEZONE]];
    [dateFormatter setDateFormat:@"YYYY年 M月d日HH:mm"];
    NSDate * notificationDate = nil ;
    if (isAllDay) {
        NSRange range = [anyEvent.startDate rangeOfString:@"日"];
        NSString * startStrs = [anyEvent.startDate substringWithRange:NSMakeRange(0,range.location + 1)];
        
        NSInteger  allDayInt =  [[USER_DEFAULT objectForKey:@"allDay"] integerValue];
        
        if (EventsAllDayAlert_Never == allDayInt) {
            return;
        }else if ( EventsAllDayAlert_5Hour  ==  allDayInt ){
           startStrs = [NSString stringWithFormat:@"%@%@",startStrs,@"05:00"];
        }else if ( EventsAllDayAlert_7Hour  ==  allDayInt ){
           startStrs = [NSString stringWithFormat:@"%@%@",startStrs,@"07:00"];
        }else if ( EventsAllDayAlert_8Hour  ==  allDayInt ){
           startStrs = [NSString stringWithFormat:@"%@%@",startStrs,@"08:00"];
        }else if ( EventsAllDayAlert_9Hour  ==  allDayInt ){
           startStrs = [NSString stringWithFormat:@"%@%@",startStrs,@"09:00"];
        }else if ( EventsAllDayAlert_10Hour ==  allDayInt ){
           startStrs = [NSString stringWithFormat:@"%@%@",startStrs,@"10:00"];
        }
        notificationDate = [dateFormatter dateFromString:startStrs];
    }else{
        NSInteger  eventTimeAlert = [[USER_DEFAULT objectForKey:@"eventTime"] integerValue] ;
        NSDate * tmpDate = [dateFormatter dateFromString:anyEvent.startDate] ;
        
        if (EventsAlertTime_Never == eventTimeAlert) {
            return;
        }else if (EventsAlertTime_AtTimeEvent == eventTimeAlert){
            notificationDate = tmpDate ;
        }else if (EventsAlertTime_5MinBefore  == eventTimeAlert){
            notificationDate = [tmpDate dateByAddingTimeInterval:-5*60];
        }else if (EventsAlertTime_15MinBefore == eventTimeAlert){
            notificationDate = [tmpDate dateByAddingTimeInterval:-15*60];
        }else if (EventsAlertTime_30MinBefore == eventTimeAlert){
            notificationDate = [tmpDate dateByAddingTimeInterval:-30*60];
        }else if (EventsAlertTime_1HourBefore == eventTimeAlert){
            notificationDate = [tmpDate dateByAddingTimeInterval:-1*60*60];
        }else if (EventsAlertTime_2HourBefore == eventTimeAlert){
            notificationDate = [tmpDate dateByAddingTimeInterval:-2*60*60];
        }
    }
    
    UILocalNotification * notification = [[UILocalNotification alloc] init];
    //时区
    notification.timeZone = [NSTimeZone defaultTimeZone];
    
    notification.fireDate = notificationDate;
    
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

/**
 *取消一個通知
 *name 通知的唯一标记名
 */
- (void)removeLocationNoticeWithName:(NSString*) name {
    NSArray *narry=[[UIApplication sharedApplication] scheduledLocalNotifications];
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
