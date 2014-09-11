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
#define calendar_Table_Month_H  220   //只显示一周此处改为44
#define calendar_Table_Week_H   110

#define calendar_Table_Month_F CGRectMake(0, 20, self.bounds.size.width, calendar_Table_Month_H)
#define calendar_Table_Week_F  CGRectMake(0, 20, self.bounds.size.width, calendar_Table_Week_H)

#define event_Table_Month_F CGRectMake(0, 20+calendar_Table_Month_H, self.bounds.size.width, self.bounds.size.height - calendar_Table_Month_H-20 )

#define event_Table_Week_F CGRectMake(0, calendar_Table_Week_H-46, self.bounds.size.width, self.bounds.size.height - calendar_Table_Week_H+46 )

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
        self.backgroundColor = [UIColor blackColor];
        
        
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
        lab.textColor = [UIColor whiteColor]; // color
        lab.backgroundColor = [UIColor clearColor]; // 透明
        if (_time.length<=0) {
           lab.textColor=[UIColor blackColor];
//            星期背景色
           lab.backgroundColor=[UIColor whiteColor];
        }

        lab.text = [array objectAtIndex:i];
        lab.textAlignment = NSTextAlignmentCenter; // 直线居中
        UIView *lineview=[[UIView alloc]initWithFrame:CGRectMake(0, 237, self.frame.size.width, 1)];
        lineview.backgroundColor=[UIColor whiteColor];
        [self addSubview:lineview];
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
        month.alpha=0.8f;
        month.backgroundColor=[UIColor blackColor];
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
        
        event_tableView.backgroundColor=[UIColor blackColor];
        
        
        [self addSubview:event_tableView];
        needReload = YES;
    }
    
    
}

//到顶或到底剪头
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
    [_delegate calendartitle:[NSString stringWithFormat:@"Today  %@",[[PublicMethodsViewController getPublicMethods] getcurrentTime:@"dd/M"]]];

    
}

#pragma mark - UITableViewDataSource
//tableview的区
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if (tableView == event_tableView) {  //事件表
        dateArr = [self.dataSuorce dateSourceWithCalendarView:self];
        return (dateArr) ? dateArr.count*7 : 1;
    }

    return 1;
}

//- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
//{
//    if (tableView == event_tableView) {
//        int row = section / 7;
//        int index = section % 7;
//        return [[[dateArr objectAtIndex:row] objectAtIndex:index] description];
//    }
//    else
//        return nil;
//}

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
        UIView* headview=[[UIView alloc]initWithFrame:CGRectMake(0, 0, self.frame.size.width, 46)];
        UILabel* titlelabel=[[UILabel alloc]initWithFrame:headview.frame];
        titlelabel.font=[UIFont boldSystemFontOfSize:20.0f];
        titlelabel.textAlignment=NSTextAlignmentCenter;
        titlelabel.textColor=[UIColor whiteColor];
        NSString* table_title=[[[dateArr objectAtIndex:row] objectAtIndex:index] description];
        NSDateFormatter *formatter =[[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"YYYY年 M月dd日"];
        NSDate* date=[formatter dateFromString:table_title];
        NSString* weakStr=[[PublicMethodsViewController getPublicMethods] getWeekdayFromDate:date];
        table_title=[table_title stringByReplacingOccurrencesOfString:@"年 " withString:@"/"];
        table_title=[table_title stringByReplacingOccurrencesOfString:@"月" withString:@"/"];
        table_title=[table_title stringByReplacingOccurrencesOfString:@"日" withString:@"/"];
        NSArray* array=[table_title componentsSeparatedByString:@"/"];
        titlelabel.text=[NSString stringWithFormat:@"%@  %@/%@",weakStr,[array objectAtIndex:2],[array objectAtIndex:1]];
//        
//        titlelabel.backgroundColor=[UIColor blackColor];
        
//       区头的颜色
        titlelabel.backgroundColor = [UIColor colorWithRed:244.0f/255.0f green:10.0f/255.0f blue:115.0f/255.0f alpha:1];
        [headview addSubview:titlelabel];
        return headview;
    }

    return nil;
}

//表头高
-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    if (tableView == event_tableView) {
        return 46;
    }
    return 0;
}

//tableview的row数
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (tableView == calendar_tableView) {
        dateArr = [self.dataSuorce dateSourceWithCalendarView:self];
        return (dateArr) ? dateArr.count : 0;
    }
    else if (tableView == event_tableView) {
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentsDirectory = [paths objectAtIndex:0];
        NSString *plistPath = [documentsDirectory stringByAppendingPathComponent:@"addtime.plist"];
        NSMutableDictionary *data = [[NSMutableDictionary alloc] initWithContentsOfFile:plistPath];
        int row = section/ 7;
        int index = section % 7;
        NSString* str=[[[dateArr objectAtIndex:row] objectAtIndex:index] description];
        for (NSString* temstr in [data allKeys]) {
            if ([str isEqualToString:temstr]) {
                return [[data objectForKey:temstr] count];
            }
        }
        return 1;
        
    }
    else {
        return 0;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *plistPath = [documentsDirectory stringByAppendingPathComponent:@"addtime.plist"];
    NSMutableDictionary *data = [[NSMutableDictionary alloc] initWithContentsOfFile:plistPath];
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
                for (int i=0;i<[[data allKeys] count];i++) {
                    NSString*  str=[[data allKeys]objectAtIndex:i];
                    str=[str stringByReplacingOccurrencesOfString:@"年" withString:@"/"];
                    str=[str stringByReplacingOccurrencesOfString:@"月" withString:@"/"];
                    str=[str stringByReplacingOccurrencesOfString:@"日" withString:@"/"];
                    NSArray* array=[str componentsSeparatedByString:@"/"];
                    [temarray addObject:array];
                }
                
                for (NSArray* arr in temarray ) {
                    if (day.month==[[arr objectAtIndex:1] integerValue]&&day.day==[[arr objectAtIndex:2] integerValue]) {
                        cell.imageview.image=[UIImage imageNamed:@"Rectangle_13.png"];
                    NSLog(@"%lu---dsdsdsdsdsd-%lu",(unsigned long)day.month,(unsigned long)day.day);
                    }
                }
                if (showMonth != day.month) {
                    showMonth = day.month;
                    month.text=[NSString stringWithFormat:@"%lu Month",(unsigned long)day.month];
                    [self.delegate calendarDidToMonth:day.month year:day.year CalendarView:self];
                }
                cell.weekArr = [dateArr objectAtIndex:indexPath.row];
            }
            else {
                [tableView reloadData];
            }
            return cell;
        }
        else{
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
  
        
    }
    else {  //事件表
        EventCell *cell = [tableView dequeueReusableCellWithIdentifier:eventCellID];
        if (!cell) {
            cell = (EventCell*)[[[NSBundle mainBundle] loadNibNamed:@"EventCell" owner:self options:nil] objectAtIndex:0];
        }

        int row = indexPath.section / 7;
        int index = indexPath.section % 7;
        NSString* str=[[[dateArr objectAtIndex:row] objectAtIndex:index] description];
        for (NSString* temstr in [data allKeys]) {
            if ([str isEqualToString:temstr]) {
                NSDictionary* dic=[[data objectForKey:temstr] objectAtIndex:indexPath.row];
                NSString* strtime=[dic objectForKey:@"start"];
                NSRange range=[strtime rangeOfString:@"日"];
                NSString* strs=[strtime substringWithRange:NSMakeRange(range.location+1,strtime.length-range.location-1)];
                NSString* endtime=[dic objectForKey:@"end"];
                NSRange ranges=[endtime rangeOfString:@"日"];
                NSString* endstrs=[endtime substringWithRange:NSMakeRange(ranges.location+1,endtime.length-ranges.location-1)];
                cell.starttimelabel.font=[UIFont fontWithName:@"ProximaNova-Semibold" size:14.0];
                NSString* time=[[PublicMethodsViewController getPublicMethods]getseconde:strs];
                cell.timelabel.font=[UIFont fontWithName:@"ProximaNova-Semibold" size:14.0];
                
                
                
                NSDate *  senddate=[NSDate date];
                NSDateFormatter  *dateformatter=[[NSDateFormatter alloc] init];
                [dateformatter setDateFormat:@"HH:MM"];
                NSString *  locationString=[dateformatter stringFromDate:senddate];
                NSString* keyStr=[NSString stringWithFormat:@"%@%@",temstr,locationString];
                
                NSLog(@"%@temstr%@locationString",temstr,locationString);
                
                NSString* endStr=[[PublicMethodsViewController getPublicMethods] timeDifference:[dic objectForKey:@"end"] getStrart:keyStr];
                
                
                NSLog(@"%@----1---1--%@",endStr,str);
                

                if ([time isEqualToString:@"0小时0分钟"]) {
                    cell.timelabel.hidden=YES;
                }else{
                    cell.timelabel.text=time;
                    
                    NSLog(@"strtime->>>>%@",strtime);
                    NSLog(@"%@  time",time);
                    
                }
                
                if ([[endStr substringWithRange:NSMakeRange(endStr.length-3, 3)] isEqualToString:@"day"]) {
                    cell.starttimelabel.text=@"ALL DAY";
                    
                    cell.timelabel.hidden=YES;
                }else{
                    cell.starttimelabel.text=[NSString stringWithFormat:@"%@  -  %@",strs,endstrs];
                    
                    
                    NSLog(@"%@   strs",strs);
                    NSLog(@"%@  endstrs",endstrs);
                    
                    
                    
                }
                
                NSString* strtitle=[dic objectForKey:@"title"];
                cell.content.text=[strtitle uppercaseString];
                cell.content.font=[UIFont fontWithName:@"ProximaNova-Semibold" size:18.0];

                if ([[dic objectForKey:@"url"] isEqualToString:@"photo.png"]) {
                    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
                    NSString *documentsDirectory = [paths objectAtIndex:0];
                    NSString *plistPath = [documentsDirectory stringByAppendingPathComponent:@"photo.png"];
                    cell.backImage.image=[UIImage imageWithContentsOfFile:plistPath];
                }else{
                cell.backImage.image=[UIImage imageNamed:[dic objectForKey:@"url"]];
                }
            }
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

#pragma mark - table delegate
- (void)tableView:(UITableView *)tableView didEndDisplayingCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath*)indexPath {
    if (tableView == event_tableView) {
        if (isshow) {
            [self setDisplayMode:CLCalendarViewModeWeek];
        }
        int i = tableView.contentOffset.y / (46 + [tableView numberOfRowsInSection:indexPath.row]*139);
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
       
        //        NSLog(@"section->%i", i);
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (event_tableView == tableView) {
        CLDay *day = [[dateArr objectAtIndex:indexPath.section / 7] objectAtIndex:indexPath.section % 7];
        CLEvent *event = nil;
        if (day.events) {
            event = [day.events objectAtIndex:indexPath.row];
        }
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentsDirectory = [paths objectAtIndex:0];
        NSString *plistPath = [documentsDirectory stringByAppendingPathComponent:@"addtime.plist"];
        NSMutableDictionary *data = [[NSMutableDictionary alloc] initWithContentsOfFile:plistPath];
        NSArray* temarr=[data objectForKey:[NSString stringWithFormat:@"%@",day]];
        [self.delegate calendarSelectEvent:self day:day event:[temarr objectAtIndex:indexPath.row] AllEvent:temarr];
    }
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (event_tableView==tableView) {
//        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
//        NSString *documentsDirectory = [paths objectAtIndex:0];
//        NSString *plistPath = [documentsDirectory stringByAppendingPathComponent:@"addtime.plist"];
//        NSMutableDictionary *data = [[NSMutableDictionary alloc] initWithContentsOfFile:plistPath];
//        int row = indexPath.section / 7;
//        int index = indexPath.section % 7;
//        NSString* str=[[[dateArr objectAtIndex:row] objectAtIndex:index] description];
//        for (NSString* temstr in [data allKeys]) {
//            if ([str isEqualToString:temstr]) {
//                return 139.0f;
//            }        }
          return 139.0f;
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
     }else{
         isshow=YES;
     }
    
    
    NSLog(@"开始拖拽图片");
    
    
}


- (void)scrollViewWillBeginDecelerating:(UIScrollView *)scrollView
{
     if (calendar_tableView == scrollView) {
    [self addSubview:month];
     }
    
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
    
    if (_time.length>0) {
        [self setDisplayMode:CLCalendarViewModeWeek];
    }
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
