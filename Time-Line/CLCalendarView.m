//
//  CLCalendarView.m
//  Time-Line
//
//  Created by Charlie Liao on 14-3-25.
//  Copyright (c) 2014年 connor. All rights reserved.
//

#import "CLCalendarView.h"
#import "EventCell.h"
#import "AppDelegate.h"
#import "AnyEvent.h"
#import "Calendar.h"
#import "CircleDrawView.h"
#define calendar_Table_Month_H  132   //只显示一周此处改为44
#define calendar_Table_Week_H   90   //110

//表行的高度 139.0f
#define rowHeight 55

//表头高度
#define headHeight 20

#define calendar_Table_Month_F CGRectMake(0, 20, self.bounds.size.width, calendar_Table_Month_H)
#define calendar_Table_Week_F  CGRectMake(0, 20, self.bounds.size.width, calendar_Table_Week_H)

#define event_Table_Month_F CGRectMake(0, 20+calendar_Table_Month_H, self.bounds.size.width, self.bounds.size.height - calendar_Table_Month_H-20 )

#define event_Table_Week_F CGRectMake(0, calendar_Table_Week_H-headHeight, self.bounds.size.width, self.bounds.size.height - calendar_Table_Week_H+headHeight )

#define cellID @"CLCalendarCell"
#define eventCellID @"eventCell"



@interface CLCalendarView () {
    UITableView *event_tableView;
    UITableView *calendar_tableView;
    UIButton *goBackbtn;
    
    NSArray     *dateArr;
    int          showMonth;
    
    int          selectDate[2];
    int          toDayDate[2];
    
    BOOL         needReload;
    UILabel* month;
    BOOL isshow;
    NSArray *eventArr;
}

@end

@implementation CLCalendarView
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
     return [self initByMode:CLCalendarViewModeWeek];
}

- (id)init
{
    self = [super initWithFrame:CGRectMake(0, 64, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height-64)];
    return [self initByMode:CLCalendarViewModeWeek];
}
//calendartimeline
- (id)initByMode:(CLCalendarDisplayMode)mode
{
    if (self) {
        self.backgroundColor = [UIColor whiteColor];//原为黑色
        
        
        [self loadLable];
        [self loadCalendar];
        [self loadEventTable];
        [self loadTodayBtn];
        self.displayMode = mode;
    }
    return self;
}

//顶部的星期label
- (void)loadLable {
    NSLog(@"%@",_time);
    
    NSArray *array = [NSArray arrayWithObjects:@"Sun", @"Mon", @"Tue", @"Wed", @"Thi", @"Fri", @"Sat", nil];
    
    for (int i = 0; i < 7; i++) {
        UILabel *lab = [[UILabel alloc] initWithFrame:CGRectMake(kScreen_Width/7*i, 5, kScreen_Width/6, 15)]; // x,y,w,h
        lab.font = [UIFont systemFontOfSize:13]; // label size = 13
        lab.textColor = [UIColor whiteColor];
        lab.backgroundColor = [UIColor clearColor]; // 透明
        if (_time.length<=0) {
           lab.textColor=[UIColor blackColor];
//            星期背景色
           lab.backgroundColor=[UIColor whiteColor];
        }

        lab.text = [array objectAtIndex:i];
        lab.textAlignment = NSTextAlignmentCenter; // 直线居中
        //暂时屏蔽 多余
//        UIView *lineview=[[UIView alloc]initWithFrame:CGRectMake(0, 237, self.frame.size.width, 1)];
//        lineview.backgroundColor=[UIColor whiteColor];
//        [self addSubview:lineview];
        [self addSubview:lab];
    }
}

//日历表
- (void)loadCalendar {
    if (!calendar_tableView) {
        calendar_tableView = [[UITableView alloc] initWithFrame: self.displayMode ? calendar_Table_Week_F : calendar_Table_Month_F];
        calendar_tableView.delegate = self;
        calendar_tableView.dataSource = self;
        calendar_tableView.tag = 0;
        calendar_tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        calendar_tableView.backgroundColor= [UIColor clearColor];
        calendar_tableView.showsHorizontalScrollIndicator = NO;
        calendar_tableView.showsVerticalScrollIndicator = NO;
        [self addSubview:calendar_tableView];
        selectDate[0] = -1;
        
        month=[[UILabel alloc]initWithFrame:calendar_tableView.frame];
        month.alpha=0.5f;
        month.backgroundColor=[UIColor blackColor];//显示黑色的几月 如8月黑色背景
        month.textAlignment=NSTextAlignmentCenter;
        month.font=[UIFont boldSystemFontOfSize:17.0f];
        month.textColor=[UIColor whiteColor];
        
    }
}

//事件表
- (void)loadEventTable {
    if (!event_tableView) {
        event_tableView = [[UITableView alloc] initWithFrame: self.displayMode ? event_Table_Month_F : event_Table_Month_F];
        event_tableView.delegate = self;
        event_tableView.dataSource = self;
        event_tableView.tag=1;
        
        event_tableView.backgroundColor=[UIColor whiteColor];//设置事件表格背景为白色
        
        
        [self addSubview:event_tableView];
        needReload = YES;
    }
    
    
}

//到顶或到底箭头
- (void)loadTodayBtn {
    goBackbtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [goBackbtn setBackgroundImage:[UIImage imageNamed:@"go_back_today.png"] forState:UIControlStateNormal];
    goBackbtn.backgroundColor=[UIColor clearColor];
    [goBackbtn setFrame:CGRectMake(self.frame.size.width-50, self.frame.size.height-50, 30, 30)];
    [goBackbtn setHidden:YES];
    [goBackbtn addTarget:self action:@selector(goBackToday) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:goBackbtn];
}


- (void)setDisplayMode:(CLCalendarDisplayMode)displayMode {
    _displayMode = displayMode;
    isshow=NO;
    [UIView animateWithDuration:0.8 animations:^{
        switch (_displayMode) {
            case CLCalendarViewModeMonth:
                event_tableView.frame = event_Table_Month_F;
                calendar_tableView.frame = calendar_Table_Month_F;
                [calendar_tableView setBounces:YES];
                calendar_tableView.pagingEnabled = NO;
                break;
                
            case CLCalendarViewModeWeek:
                event_tableView.frame = event_Table_Week_F;
                calendar_tableView.frame = calendar_Table_Week_F;
                [calendar_tableView setBounces:NO];
                calendar_tableView.pagingEnabled = YES;
                
                if (selectDate[0] !=-1) {
                    [calendar_tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:selectDate[0] inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:YES];
                }
                break;
                
            default:
                break;
        }
    }];
}








- (void)setToDayRow:(int)row Index:(int)index
{
    toDayDate[0] = row;
    toDayDate[1] = index;
}

//向上或向下跳到今天的日历处
- (void)goBackToday
{
    
    if (self.displayMode == CLCalendarViewModeMonth) {
        [calendar_tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:toDayDate[0]-2 inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:YES];
    } else {
        [calendar_tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:toDayDate[0] inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:YES];
    }
    
    [event_tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:toDayDate[0]*7 +toDayDate[1]] atScrollPosition:UITableViewScrollPositionTop animated:YES] ;
    [_delegate calendartitle:[NSString stringWithFormat:@"Today %@",[[PublicMethodsViewController getPublicMethods] getcurrentTime:@"dd/M"]]];

    
}

#pragma mark - UITableViewDataSource
//tableview的区
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if (tableView == event_tableView) {  //事件表
        NSArray *calendararr=[Calendar MR_findAll];
        NSMutableArray *anyeventArr=[NSMutableArray arrayWithCapacity:0];
        for (Calendar *ca in calendararr) {
            if ([ca.isVisible intValue]==1) {
                NSPredicate *nspre=[NSPredicate predicateWithFormat:@"calendar==%@",ca];
                NSArray *arr=[AnyEvent MR_findAllWithPredicate:nspre];
                for (AnyEvent *event in arr) {
                    [anyeventArr addObject:event];
                }
             }
        }
        eventArr=anyeventArr;
        dateArr = [self.dataSuorce dateSourceWithCalendarView:self];
        return (dateArr) ? dateArr.count*7 : 1;
    }
    return 1;
}

//表头
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    if (tableView == event_tableView) {
        CGPoint offset = event_tableView.contentOffset;
        CGRect bounds = event_tableView.bounds;
        UIEdgeInsets inset = event_tableView.contentInset;
        NSInteger currentOffset = offset.y + bounds.size.height-inset.bottom;
        NSLog(@"----->%ld",(long)currentOffset);
        int row = section / 7;
        int index = section % 7;
        UIView* headview=[[UIView alloc]initWithFrame:CGRectMake(0, 0, self.frame.size.width, headHeight)];
        UILabel* titlelabel=[[UILabel alloc]initWithFrame:headview.frame];
        titlelabel.font=[UIFont boldSystemFontOfSize:15.0f];
        titlelabel.textAlignment=NSTextAlignmentCenter;
        titlelabel.textColor=[UIColor whiteColor];
        CLDay *clDay=[[dateArr objectAtIndex:row] objectAtIndex:index] ;
        NSString* table_title=[clDay description];
        NSDateFormatter *formatter =[[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"YYYY年 M月dd日"];
        NSDate* date=[formatter dateFromString:table_title];
        NSString* weakStr=[[PublicMethodsViewController getPublicMethods] getWeekdayFromDate:date];
        table_title=[table_title stringByReplacingOccurrencesOfString:@"年 " withString:@"/"];
        table_title=[table_title stringByReplacingOccurrencesOfString:@"月" withString:@"/"];
        table_title=[table_title stringByReplacingOccurrencesOfString:@"日" withString:@"/"];
        NSArray* array=[table_title componentsSeparatedByString:@"/"];
        titlelabel.text=[NSString stringWithFormat:@"%@  %@/%@",weakStr,[array objectAtIndex:2],[array objectAtIndex:1]];
        
//       区头的颜色
        if (clDay.isToday) {
            titlelabel.backgroundColor =purple;
            //titlelabel.alpha=0.8f;
        }else{
            titlelabel.backgroundColor = [UIColor lightGrayColor];
           // titlelabel.alpha=0.3f;
        }
        [headview addSubview:titlelabel];
        return headview;
    }
    return nil;
}



//表头高
-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    if (tableView == event_tableView) {
        return headHeight;//46
    }
    return 0;
}

//tableview的row数
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (tableView == calendar_tableView) {
        dateArr = [self.dataSuorce dateSourceWithCalendarView:self];
        return (dateArr) ? dateArr.count : 0;
    }else if (tableView == event_tableView) {
       
        int row = section/ 7;
        int index = section % 7;
        NSString* str=[[[dateArr objectAtIndex:row] objectAtIndex:index] description];
        NSMutableArray *constArr=[NSMutableArray arrayWithCapacity:0];
        for (AnyEvent *anyEvent in eventArr) {
            NSString*  temstr=[[PublicMethodsViewController getPublicMethods] formatStringWithString:anyEvent.startDate];
            if ([str isEqualToString:temstr]) {
                [constArr addObject:anyEvent];
            }
        }
        
        return constArr.count==0?1:constArr.count;
        
    }else {
        return 0;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{

    if (tableView == calendar_tableView) {   //日历表
        if (_time.length > 0) {
            CLCalendarCell* cell = [tableView dequeueReusableCellWithIdentifier:cellID];
            if (cell == nil) {
                cell = [[CLCalendarCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID];
                cell.detelegate = self;
            }
            cell.tag = indexPath.row;
            if (indexPath.row < dateArr.count) {
                
                int i = (tableView.contentOffset.y + 50) / 44;
                if (i >= dateArr.count) {
                    i = dateArr.count-1;
                }
                CLDay *day = [[dateArr objectAtIndex:i] objectAtIndex:0];
                NSMutableArray* temarray=[[NSMutableArray alloc]initWithCapacity:0];
                
                for (int i=0;i<[eventArr count];i++) {
                    AnyEvent *anyEvent=[eventArr objectAtIndex:i];
                    NSString*  str=[[PublicMethodsViewController getPublicMethods] formatStringWithString:anyEvent.startDate];
                    str=[str stringByReplacingOccurrencesOfString:@"年" withString:@"/"];
                    str=[str stringByReplacingOccurrencesOfString:@"月" withString:@"/"];
                    str=[str stringByReplacingOccurrencesOfString:@"日" withString:@"/"];
                    NSArray* array=[str componentsSeparatedByString:@"/"];
                    [temarray addObject:array];
                }
                
                for (NSArray* arr in temarray ) {
                    if (day.month==[[arr objectAtIndex:1] integerValue]&&day.day==[[arr objectAtIndex:2] integerValue]) {
                        cell.imageview.image=[UIImage imageNamed:@"Icon_HaveEvent"];
                       
                    NSLog(@"%lu---dsdsdsdsdsd-%lu",(unsigned long)day.month,(unsigned long)day.day);
                    }
                }
                if (showMonth != day.month) {
                    showMonth = day.month;
                    month.text=[NSString stringWithFormat:@"%lu Month",(unsigned long)day.month];
                    [self.delegate calendarDidToMonth:day.month year:day.year CalendarView:self];
                }
                
                cell.weekArr = [dateArr objectAtIndex:indexPath.row];
            }else {
                [tableView reloadData];
            }
            return cell;
        }else{
            CalendarCell* cell = [tableView dequeueReusableCellWithIdentifier:cellID];
            if (cell == nil) {
                cell = [[CalendarCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID];
                cell.detelegate = self;
            }
            cell.tag = indexPath.row;
            
            if (indexPath.row < dateArr.count) {
                
                int i = (tableView.contentOffset.y + 50) / 44;
                if (i >= dateArr.count) {
                    i = dateArr.count-1;
                }
                CLDay *day = [[dateArr objectAtIndex:i] objectAtIndex:0];
                if (showMonth != day.month) {
                    showMonth = day.month;
                    month.text=[NSString stringWithFormat:@"%lu Month",(unsigned long)day.month];
                    [self.delegate calendarDidToMonth:day.month year:day.year CalendarView:self];
                }
                cell.weekArr = [dateArr objectAtIndex:indexPath.row];
            } else {
                [tableView reloadData];
            }
            return cell;
        }
    }else {  //事件表
        EventCell *cell = [tableView dequeueReusableCellWithIdentifier:eventCellID];
        if (!cell) {
            cell = (EventCell*)[[[NSBundle mainBundle] loadNibNamed:@"EventCell" owner:self options:nil] objectAtIndex:0];
        }
        int row = indexPath.section / 7;
        int index = indexPath.section % 7;
        NSString* str=[[[dateArr objectAtIndex:row] objectAtIndex:index] description];
        NSMutableArray *dataEvent=[NSMutableArray arrayWithArray:0];
        for (AnyEvent *anyEvent in eventArr) {
             NSString*  temstr=[[PublicMethodsViewController getPublicMethods] formatStringWithString:anyEvent.startDate];
            if ([str isEqualToString:temstr]) {
                [dataEvent addObject:anyEvent];
             }
        }
        if (dataEvent.count>0) {
            AnyEvent *anyEvent=[dataEvent objectAtIndex:indexPath.row];
            NSString* starttime=anyEvent.startDate;
            NSRange range=[starttime rangeOfString:@"日"];
            NSString* startstrs=[starttime substringWithRange:NSMakeRange(range.location+1,starttime.length-range.location-1)];
            
            cell.starttimelabel.font=[UIFont fontWithName:@"ProximaNova-Semibold" size:14.0];
            
            NSString *intervalTime=[[PublicMethodsViewController getPublicMethods]  timeDifference:anyEvent.endDate getStrart:anyEvent.startDate];//得到开始时间和结束时间的差值
            
            cell.timelabel.font=[UIFont fontWithName:@"ProximaNova-Semibold" size:8.0];
            
//            NSDate *  senddate=[NSDate date];
            NSDateFormatter  *dateformatter=[[NSDateFormatter alloc] init];
            [dateformatter setDateFormat:@"HH:MM"];
//            NSString *  locationString=[dateformatter stringFromDate:senddate];
//            NSString* keyStr=[NSString stringWithFormat:@"%@%@",temstr,locationString];
            cell.timelabel.text=intervalTime;
            NSLog(@"strtime->>>>%@",starttime);
            cell.starttimelabel.text=[NSString stringWithFormat:@"%@",startstrs];

            NSString* strtitle=anyEvent.eventTitle;
            cell.content.text=[strtitle uppercaseString];
            cell.content.font=[UIFont fontWithName:@"ProximaNova-Semibold" size:18.0];
            cell.content.textColor=[UIColor blackColor];
            
            Calendar *caObj=anyEvent.calendar;
            
            CircleDrawView *cd=[[CircleDrawView alloc] init];
            cd.frame=cell.cirPoint.frame;
            cd.hexString=caObj.backgroundColor;
            [cell.cirPoint addSubview: cd];
        }
        if ([cell.content.text isEqualToString:@""]) {
            cell.textLabel.text=@"FREE DAY";
            cell.textLabel.font=[UIFont boldSystemFontOfSize:17.0f];
            cell.textLabel.textAlignment=NSTextAlignmentCenter;
            cell.textLabel.textColor=[UIColor whiteColor];
            cell.content.hidden=YES;
            cell.starttimelabel.hidden=YES;
            cell.timelabel.hidden=YES;
            cell.backImage.hidden=YES;
            
        }
        return cell;
    }
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView==calendar_tableView) {
        
    }
}


#pragma mark - table delegate
- (void)tableView:(UITableView *)tableView didEndDisplayingCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath*)indexPath {
    if (tableView == event_tableView) {
        if (isshow) {//在滚动事件cell是默认显示周视图
            [self setDisplayMode:CLCalendarViewModeWeek];
        }/*else{
            [self setDisplayMode:CLCalendarViewModeMonth];
        }*/
        int i = tableView.contentOffset.y / (headHeight + [tableView numberOfRowsInSection:indexPath.row]*rowHeight);
        int s = i /7;
        int index = i %7;
        if (needReload) {
            selectDate[0] = s;
            selectDate[1] = index;
            [calendar_tableView reloadData];
        } else if (selectDate[0] == s && selectDate[1] == index){
            needReload = YES;
        }
        int temrow = indexPath.section / 7;
        int temindex = indexPath.section % 7;
        NSDateFormatter *df=[[NSDateFormatter alloc] init];
        [df setDateFormat:@"YYYY年 M月d日"];
        NSDate *date1=[NSDate date];
        NSDate *date2=[df dateFromString:[[[dateArr objectAtIndex:temrow] objectAtIndex:temindex]description]];
        if (toDayDate[0] == s && toDayDate[1] == index) {
            [goBackbtn setHidden:YES];
        } else {
            [goBackbtn setHidden:NO];
            switch ([date1 compare:date2]) {
                case NSOrderedSame:{
                    
                }
                    break;
                case NSOrderedAscending:{
                    [goBackbtn setBackgroundImage:[UIImage imageNamed:@"go_back_today"] forState:UIControlStateNormal];
                }
                    break;
                case NSOrderedDescending:
                {
                    [goBackbtn setBackgroundImage:[UIImage imageNamed:@"go_back_today"] forState:UIControlStateNormal];
                }
                    break;
            }

        }
        
        if (self.displayMode == CLCalendarViewModeWeek) {
            [calendar_tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:selectDate[0] inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:YES];
        } else {
            [calendar_tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:selectDate[0]-2 inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:YES];
        }
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    NSLog(@"%li====%ld",(long)indexPath.row,(long)indexPath.section);
    if (event_tableView == tableView) {
        
        int row = indexPath.section / 7;
        int index = indexPath.section % 7;
        NSString* str=[[[dateArr objectAtIndex:row] objectAtIndex:index] description];
        NSMutableArray *dataEvent=[NSMutableArray arrayWithArray:0];
        for (AnyEvent *anyEvent in eventArr) {
            NSString*  temstr=[[PublicMethodsViewController getPublicMethods] formatStringWithString:anyEvent.startDate];
            if ([str isEqualToString:temstr]) {
                [dataEvent addObject:anyEvent];
            }
        }
        CLDay *day = [[dateArr objectAtIndex:row] objectAtIndex:index];
        CLEvent *event = nil;
        if (day.events) {
            event = [day.events objectAtIndex:indexPath.row];
        }

        if (dataEvent.count>0) {
            AnyEvent *anyEvent=[dataEvent objectAtIndex:indexPath.row];
            [self.delegate calendarSelectEvent:self day:day event:anyEvent AllEvent:dataEvent];
        }else{
            [self.delegate calendarSelectEvent:self day:day event:nil AllEvent:dataEvent];
        }
    }
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (event_tableView==tableView) {
        return rowHeight;
    }
    return 44.0f;
}

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView
{
    if (calendar_tableView == scrollView) {
        [calendar_tableView reloadData];
    }
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
     if (calendar_tableView == scrollView) {
         [month removeFromSuperview];
     }
    if (!decelerate) {
        if (calendar_tableView == scrollView) {
            [calendar_tableView reloadData];
        }
    }
}


-(void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{
     if (calendar_tableView == scrollView) {
         [self addSubview:month];
         [self setDisplayMode:CLCalendarViewModeMonth];
     }else{
         isshow=YES;
     }
    NSLog(@"开始拖拽图片");
}


- (void)scrollViewWillBeginDecelerating:(UIScrollView *)scrollView
{
//     if (calendar_tableView == scrollView) {
//        [self addSubview:month];
//     }
    
}


- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    if (calendar_tableView == scrollView) {
        [calendar_tableView reloadData];
        [month removeFromSuperview];

    }else{
        EventCell* cell=[[event_tableView visibleCells] objectAtIndex:1];
        NSIndexPath* path=[event_tableView indexPathForCell:cell];
        NSString* table_title=[[[dateArr objectAtIndex:path.section/7] objectAtIndex:path.section%7] description];
        NSDateFormatter *formatter =[[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"YYYY年 M月dd日"];
        NSDate* date=[formatter dateFromString:table_title];
        NSString* weakStr=[[PublicMethodsViewController getPublicMethods] getWeekdayFromDate:date];
        table_title=[table_title stringByReplacingOccurrencesOfString:@"年 " withString:@"/"];
        table_title=[table_title stringByReplacingOccurrencesOfString:@"月" withString:@"/"];
        table_title=[table_title stringByReplacingOccurrencesOfString:@"日" withString:@"/"];
        NSArray* array=[table_title componentsSeparatedByString:@"/"];
        [_delegate calendartitle:[NSString stringWithFormat:@"%@   %@/%@",weakStr,[array objectAtIndex:2],[array objectAtIndex:1]]];
        [event_tableView scrollToRowAtIndexPath:path atScrollPosition:UITableViewScrollPositionTop animated:YES];
    }
}



#pragma mark - cell delegate

- (void)selectDate:(CLCalendarCell*)cell weekDay:(NSInteger)index
{
    
//    if (_time.length>0) {
//        [self setDisplayMode:CLCalendarViewModeWeek];
//    }
    selectDate[0] = cell.tag;
    selectDate[1] = index;
    
    needReload = NO;
    [event_tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:selectDate[0]*7 +selectDate[1]] atScrollPosition:UITableViewScrollPositionTop animated:YES] ;
    
    [calendar_tableView reloadData];
}

- (int)getShowMonth
{
    return showMonth;
}

- (int)getShowSelectDay:(CLCalendarCell*)cell
{
    if (cell.tag == selectDate[0]) {
        return selectDate[1];
    }
    return -1;
}

#pragma mark - cells delegate

- (void)selectDates:(CalendarCell*)cell weekDay:(NSInteger)index
{
    if (_time.length>0) {
        [self setDisplayMode:CLCalendarViewModeWeek];
    }
    selectDate[0] = cell.tag;
    selectDate[1] = index;
    
    needReload = NO;
    [event_tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:selectDate[0]*7 +selectDate[1]] atScrollPosition:UITableViewScrollPositionTop animated:YES] ;
    
    [calendar_tableView reloadData];
}

- (int)getShowMonths
{
    return showMonth;
}

- (int)getShowSelectDays:(CalendarCell*)cell
{
    if (cell.tag == selectDate[0]) {
        return selectDate[1];
    }
    return -1;
}



@end
