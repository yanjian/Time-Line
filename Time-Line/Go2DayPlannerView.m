//
//  Go2DayPlanerVIew.m
//  CalendarGoUtil
//
//  Created by IF on 15/7/16.
//  Copyright (c) 2015年 IF. All rights reserved.
//

#import "Go2DayPlannerView.h"
#import "Go2TimeRowsView.h"
#import "Go2StandardEventView.h"
#import "GoAlertView.h"
#import "GoTimeSelectAlert.h"
#import "UIColor+HexString.h"
@interface Go2DayPlannerView()<UIScrollViewDelegate,Go2StandardEventViewDelegate,GoTimeSelectAlertDelegate>

@property (nonatomic,retain) UIScrollView * timeScrollView ;
@property (nonatomic ,retain) Go2TimeRowsView * go2TimeRowsView ;
@property (nonatomic) CGSize dayColumnSize ;
@property (nonatomic,retain) UILabel * showAllDayLab;
@property (nonatomic, retain)UIButton * timeBtn ;

@property  (nonatomic,assign) CGFloat hourSlotHeight;

@property (nonatomic ,assign) NSInteger numberOfVisibleDays;
@property  (nonatomic,assign) CGFloat timeColumnWidth ;//时间显示的宽度 00：00
@property  (nonatomic,assign) CGFloat eventsViewInnerMargin ;

@property (nonatomic,retain)   UIScrollView * dayTimeView ;

@property (nonatomic,retain)    UIView * dayHeadView  ;//日历头

@property (nonatomic,retain)   UIScrollView *dayScrollHeadView;

@property (nonatomic,assign)   CGFloat eventsViewInnerHeight;//显示事件的视图高度
@property (nonatomic,assign)   CGFloat dayDateHeight ;//日历头的高度
@property (nonatomic,retain)  NSMutableArray * showDayDateArr ;//存放的时显示在日历上面的日期：Tue 14， Web 15 实际存放的是nsdate
@property (nonatomic,assign)   CGFloat dayShowLabHeight;//日期lable的高度

@property (nonatomic,retain) NSDateFormatter * formatter;
@end

@implementation Go2DayPlannerView

-(instancetype)initWithFrame:(CGRect)frame{
     self  =  [super initWithFrame:frame];
    if (self) {
         [self setup] ;
    }
    return self;
}


- (void)setup
{
    _numberOfVisibleDays = 5;
    _hourSlotHeight = 60.;
    _timeColumnWidth = 40.;
    _eventsViewInnerMargin = 45.;
    _eventsViewInnerHeight = 60. ;
    _dayDateHeight = 60. ;
    _dayShowLabHeight = 40. ;
    
    _showDayCount = 30 ;
    
    self.showDayDateArr = [[NSMutableArray alloc] initWithCapacity:0];
    
    for(int i=-2;i< _showDayCount;i++){
        NSDate * dateDay = [NSDate dateWithTimeIntervalSinceNow:i * 24 * 60 * 60];
        dateDay = [self extractDate:dateDay] ;
        [self.showDayDateArr addObject:dateDay] ;
    }

    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidReceiveMemoryWarning:) name:UIApplicationDidReceiveMemoryWarningNotification object:nil];
}


-(void)layoutSubviews{
    [super layoutSubviews];
    
    self.dayHeadView.frame =  CGRectMake(0, 0, kScreen_Width,self.dayDateHeight ) ;
    if (!self.dayHeadView.superview) {
        [self addSubview:self.dayHeadView] ;
    }
    
    self.dayScrollHeadView.frame = CGRectMake(_timeColumnWidth, 0, kScreen_Width - _timeColumnWidth, self.dayDateHeight) ;
    self.dayScrollHeadView.contentSize = CGSizeMake(self.dayColumnSize.width*self.showDayDateArr.count, 0);
    if (!self.dayScrollHeadView.superview) {
        [self.dayHeadView addSubview:self.dayScrollHeadView] ;
    }
    
    self.showAllDayLab.frame = CGRectMake(0, self.dayScrollHeadView.frame.origin.y+_dayShowLabHeight-1, _timeColumnWidth, self.dayDateHeight-_dayShowLabHeight+1) ;
    if (!self.showAllDayLab.superview) {
        [self.dayHeadView addSubview:self.showAllDayLab] ;
    }

   
    self.timeScrollView.frame = CGRectMake(0, 60, self.bounds.size.width, self.bounds.size.height-self.dayDateHeight);
    self.timeScrollView.contentSize = CGSizeMake(self.bounds.size.width, self.dayColumnSize.height-self.dayDateHeight);
    
    self.go2TimeRowsView.frame = CGRectMake(0, 0, self.timeScrollView.contentSize.width, self.timeScrollView.contentSize.height);
    
    if (!self.timeScrollView.superview) {
        [self addSubview:self.timeScrollView];
    }
    
    self.dayTimeView.frame =  CGRectMake(_timeColumnWidth, 10, kScreen_Width - _timeColumnWidth, self.dayColumnSize.height-2*_eventsViewInnerMargin);
    self.dayTimeView.contentSize = CGSizeMake(self.dayColumnSize.width*self.showDayDateArr.count, 0);
    
    if (!self.dayTimeView.superview) {
        [self.timeScrollView addSubview:self.dayTimeView];
    }
    
    
    if (!self.timeBtn.superview) {
         [self addSubview:self.timeBtn];
    }
}


-(UIScrollView *)timeScrollView{
    if (!_timeScrollView) {
        _timeScrollView = [[UIScrollView alloc]initWithFrame:CGRectZero];
        _timeScrollView.backgroundColor = [UIColor clearColor];
        _timeScrollView.delegate = self;
        _timeScrollView.showsVerticalScrollIndicator = NO;
        _timeScrollView.decelerationRate = UIScrollViewDecelerationRateFast;
        _timeScrollView.scrollEnabled = YES;
        _timeScrollView.bounces = YES ;
        
        _go2TimeRowsView = [[Go2TimeRowsView alloc]initWithFrame:CGRectZero];
        _go2TimeRowsView.contentMode = UIViewContentModeRedraw;
        [_timeScrollView addSubview:_go2TimeRowsView];
    }
    return _timeScrollView ;
}


-(UILabel *) showAllDayLab {
    if (!_showAllDayLab) {
        _showAllDayLab = [[UILabel alloc] initWithFrame:CGRectZero];
        _showAllDayLab.textAlignment = NSTextAlignmentCenter ;
        _showAllDayLab.font = [UIFont systemFontOfSize:12] ;
        _showAllDayLab.text = @"All Day" ;
        _showAllDayLab.backgroundColor = [UIColor lightGrayColor] ;
    }
    return _showAllDayLab;
}

-(UIButton *) timeBtn{
    if (!_timeBtn) {
        _timeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _timeBtn.frame = CGRectMake(kScreen_Width-70, kScreen_Height-130, 50, 50);
        _timeBtn.layer.cornerRadius  = _timeBtn.frame.size.width/2;
        [_timeBtn setBackgroundColor:purple];
        
        _timeBtn.layer.shadowOffset  = CGSizeMake(1, 3);
        _timeBtn.layer.shadowOpacity = .75f;
        _timeBtn.layer.shadowRadius  = 1;
        _timeBtn.layer.shadowColor   = [UIColor blackColor].CGColor;
        
        _timeBtn.titleLabel.font     = [UIFont systemFontOfSize:16];
        [_timeBtn setTitle:@"1h" forState:UIControlStateNormal];
        [_timeBtn addTarget:self action:@selector(clickTimeBlockOfEventDay:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _timeBtn;
}


-(CGSize )dayColumnSize{
    CGFloat height = roundf((self.hourSlotHeight * 24) + 2 * self.eventsViewInnerMargin);
    NSUInteger numberOfDays = self.numberOfVisibleDays;
    CGFloat width = roundf((self.bounds.size.width - self.timeColumnWidth) / numberOfDays);
    return CGSizeMake(width, height);
}


-(UIScrollView *)dayTimeView{
    if (!_dayTimeView) {
        _dayTimeView = [[UIScrollView alloc] initWithFrame:CGRectZero];
        _dayTimeView.backgroundColor = [UIColor clearColor];
        _dayTimeView.delegate = self;
        _dayTimeView.showsVerticalScrollIndicator   = NO;
        _dayTimeView.showsHorizontalScrollIndicator = NO;
        _dayTimeView.decelerationRate = UIScrollViewDecelerationRateFast;
        _dayTimeView.scrollEnabled = YES;
        _dayTimeView.bounces = NO ;
        _dayTimeView.pagingEnabled = YES ;
        
        for (int i=0; i < self.showDayDateArr.count; i++) {
            UILabel * dayLab = [[UILabel alloc] initWithFrame:CGRectMake(i*self.dayColumnSize.width, 0, 1, self.dayColumnSize.height-2*_eventsViewInnerMargin)];
            dayLab.backgroundColor = [UIColor lightGrayColor];
            dayLab.tag = i ;
            [_dayTimeView addSubview:dayLab];
        }
        
        UITapGestureRecognizer * tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapHandle:)];
        [_dayTimeView addGestureRecognizer:tapGestureRecognizer];
    }
    return _dayTimeView ;
}


-(UIView *)dayHeadView{
    if (!_dayHeadView) {
        _dayHeadView = [[UIView alloc] initWithFrame:CGRectZero];
        _dayHeadView.backgroundColor = [UIColor whiteColor] ;
    }
    return _dayHeadView ;
}

-(UIScrollView *)dayScrollHeadView{
    if (!_dayScrollHeadView) {
        _dayScrollHeadView = [[UIScrollView alloc] initWithFrame:CGRectZero];
        _dayScrollHeadView.backgroundColor = [UIColor lightGrayColor];
        _dayScrollHeadView.delegate = self;
        _dayScrollHeadView.showsVerticalScrollIndicator   = NO;
        _dayScrollHeadView.showsHorizontalScrollIndicator = NO;
        _dayScrollHeadView.decelerationRate = UIScrollViewDecelerationRateFast;
        _dayScrollHeadView.scrollEnabled = YES;
        _dayScrollHeadView.bounces = NO ;
        
        NSDateFormatter * formatter = [[NSDateFormatter alloc] init];
        [formatter setTimeZone:[NSTimeZone defaultTimeZone]];
        [formatter setDateFormat:@"EEE d"];

        for (int i=0; i < self.showDayDateArr.count; i++) {
            UILabel * dayLab = [[UILabel alloc] initWithFrame:CGRectMake(i*self.dayColumnSize.width, 0, self.dayColumnSize.width, 40)];
            dayLab.backgroundColor = [UIColor whiteColor];
            dayLab.textAlignment = NSTextAlignmentCenter ;
            dayLab.layer.borderWidth = 1;
            dayLab.layer.borderColor = [UIColor lightGrayColor].CGColor;
            
            dayLab.tag = i ;
            [dayLab setFont:[UIFont systemFontOfSize:14]];
            NSDate * dateTmp = [self.showDayDateArr objectAtIndex:i];
            dayLab.text = [NSString stringWithFormat:@"%@",[formatter stringFromDate:dateTmp]] ;
           
            [_dayScrollHeadView addSubview:dayLab];
            
            [self setNeedsLayout];
        }
    }
    return _dayScrollHeadView;
}


-(NSFormatter *)formatter{
    if (!_formatter) {
        _formatter = [[NSDateFormatter alloc] init];
        NSTimeZone *timeZone = [NSTimeZone timeZoneWithName:@"UTC"];
        [_formatter setTimeZone:timeZone];
    }
    return _formatter ;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    if (scrollView == _dayTimeView || scrollView == _dayScrollHeadView) {
        if (scrollView == _dayTimeView) {
            _dayScrollHeadView.contentOffset = CGPointMake(scrollView.contentOffset.x, scrollView.contentOffset.y) ;
        }else{
            _dayTimeView.contentOffset = CGPointMake(scrollView.contentOffset.x, scrollView.contentOffset.y) ;
        }
    }
}


-(void)tapHandle:(UITapGestureRecognizer *)recognizer{
    CGPoint point = [recognizer locationInView:self.dayTimeView] ;
    
    NSLog(@"----------  x=%f---y=%f",point.x,point.y);
    
    CGFloat tmpFloat = point.x/self.dayColumnSize.width ;
    
    int indexDate =   (int) floorf( tmpFloat );
    
    NSDate * selectDate = [self.showDayDateArr objectAtIndex:indexDate];
    
    //计算开始的时间 HH:ss
    int startHourTime =  (int) (self.hourSlotHeight/60 * point.y/self.hourSlotHeight);
    int startMinTime  =  (int) floorf(point.y) % 60 ;//这里的60 为60分钟
    //计算结束的时间 HH:ss
    int endHour =  (int) self.hourSlotHeight/60 *(point.y+self.eventsViewInnerHeight)/ self.hourSlotHeight;
    int endMinTime  =  (int) floorf(point.y+self.eventsViewInnerHeight) % 60 ;//这里的60 为60分钟
    
    int endHourTime ;
    if(endHour>=24){
        endHourTime = endHour%24 ;
    }else{
        endHourTime = endHour ;
    }
    //开始和结束时间hh:ss的字符串
    NSString * startTimeStr = [NSString stringWithFormat:@"%02i:%02i",startHourTime,startMinTime];
    NSString * endTimeStr = [NSString stringWithFormat:@"%02i:%02i",endHourTime,endMinTime];
   
    NSLog(@" Now Click startTime is:  %@  endTime is %@" ,startTimeStr,endTimeStr) ;
    
    NSTimeInterval dateStartInt = [selectDate timeIntervalSince1970];
    
    
    //选择的开始时间和结束时间---具体日期。
    NSDate * startDate =  [NSDate dateWithTimeIntervalSince1970:dateStartInt+startHourTime*60*60+startMinTime*60] ;
    NSDate * endDate   =  [NSDate dateWithTimeIntervalSince1970:dateStartInt+endHour*3600+endMinTime*60] ;
    
    NSDictionary * selectDic = @{startTime:startDate,endTime:endDate} ;
    
    
    Go2StandardEventView * eventView =[[Go2StandardEventView alloc] initWithFrame:CGRectMake(indexDate*self.dayColumnSize.width, point.y, self.dayColumnSize.width-1, self.eventsViewInnerHeight)];
    eventView.title = [NSString stringWithFormat:@"%@ ~ %@", startTimeStr,endTimeStr ];
    eventView.color = [UIColor whiteColor] ;
    eventView.backgroundColor = [UIColor colorWithHexString:@"31aaeb"];
    eventView.delegate  = self ;
    eventView.selected = YES ;
    eventView.selectDic = selectDic ;
    [self.dayTimeView addSubview:eventView] ;
    if (self.delegate && [self.delegate respondsToSelector:@selector(go2DayPlannerView:didSelectDateDic:)]) {
       [self.delegate go2DayPlannerView:self didSelectDateDic:selectDic] ;
    }
}

-(void)showEventView:(NSArray *) eventDateArr {
    if (!eventDateArr || eventDateArr.count <= 0) {
        return ;
    }

    [eventDateArr enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        NSDictionary * timeDic = (NSDictionary *)obj ;
        NSString  * timeStart = [timeDic objectForKey:@"start"];
        NSString  * timeEnd   = [timeDic objectForKey:@"end"];
        NSString  * timeId   = [timeDic objectForKey:@"id"];
        
        [self.formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
        
        NSDate * showStartDate = [self.formatter dateFromString:timeStart];
      
        NSDate * startDate = [self extractDate:showStartDate]; //这里的时间没有时分秒
        __block NSInteger  currDateIndex = -1;//-1 表示没有找到......
        [self.showDayDateArr enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            NSDate * tmpDate = (NSDate *)obj ;//这里的时间没有时分秒
            int compare =  [PublicMethodsViewController compareOneDay:tmpDate withAnotherDay:startDate];
            if (compare == 0) {
                currDateIndex = [self.showDayDateArr indexOfObject:tmpDate] ;
                stop = YES ;
            }
        }];
        
        if (currDateIndex != -1) {
          
            NSTimeInterval  startTimeInterval = fabs([showStartDate timeIntervalSince1970] - [startDate timeIntervalSince1970]) ;
            int yPoint =(int) startTimeInterval/60 * (self.hourSlotHeight/60);
            
            
            NSDate *showEndDate = [self.formatter dateFromString:timeEnd];
            NSTimeInterval  endTimeInterval =  [showEndDate timeIntervalSince1970] - [showStartDate timeIntervalSince1970];
            
            int showEventHeight = endTimeInterval/60 * (self.hourSlotHeight/60) ;
            
            NSDictionary * selectDic = @{startTime:showStartDate,endTime:showEndDate,@"id":timeId} ;
            
            Go2StandardEventView * eventView =[[Go2StandardEventView alloc] initWithFrame:CGRectMake(currDateIndex*self.dayColumnSize.width, yPoint, self.dayColumnSize.width-1, showEventHeight)];
            [self.formatter setDateFormat:@"HH:mm"];
            eventView.title = [NSString stringWithFormat:@"%@ ~ %@", [self.formatter stringFromDate:showStartDate],[self.formatter stringFromDate:showEndDate] ];
            eventView.color = [UIColor whiteColor] ;
            eventView.backgroundColor = [UIColor colorWithHexString:@"31aaeb"];
            eventView.delegate  = self ;
            eventView.selectDic = selectDic ;
            [self.dayTimeView addSubview:eventView] ;
            
            if (self.delegate && [self.delegate respondsToSelector:@selector(go2DayPlannerView:didSelectDateDic:)]) {
                [self.delegate go2DayPlannerView:self didSelectDateDic:selectDic] ;
            }
        }
        
    }];
}

- (NSDate *)extractDate:(NSDate *)date {
    NSTimeInterval interval = [date timeIntervalSince1970];
    int daySeconds = 24 * 60 * 60;
    NSInteger allDays = interval / daySeconds;
    return [NSDate dateWithTimeIntervalSince1970:allDays * daySeconds];
}


-(void)clickTimeBlockOfEventDay:(UIButton *) sender {
    
    GoAlertView *alert = [[GoAlertView alloc] init];
    GoTimeSelectAlert *pickerView = [[GoTimeSelectAlert alloc] initWithFrame:CGRectMake(0, 0, 310, 215)];
    pickerView.backgroundColor = [UIColor whiteColor];
    pickerView.delegate = self ;
    alert.contentView = pickerView ;
    [alert show];
}


-(void)deleteGo2StandardEventView:(Go2StandardEventView *) eventView deleteSelectDateDic:(NSDictionary *)selectDateDic{
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(deleteSelectDateDic:)]) {
        [self.delegate deleteSelectDateDic:selectDateDic] ;
    }
}


-(void)goTimeSelectAlert:(GoTimeSelectAlert *) goTimeAlert selectValue:(NSArray *) selectArr {
    
    CGFloat  tmpVal = [[selectArr firstObject] integerValue] + [[selectArr lastObject] integerValue]/60.f  ;
    self.eventsViewInnerHeight = self.hourSlotHeight *tmpVal;
    
    NSLog(@"%f",self.eventsViewInnerHeight) ;
    
    if ([[selectArr lastObject] integerValue]!= 0) {
        [self.timeBtn setTitle:[NSString stringWithFormat:@"%.2fh",tmpVal] forState:UIControlStateNormal] ;
    }else{
        [self.timeBtn setTitle:[NSString stringWithFormat:@"%.0fh",tmpVal] forState:UIControlStateNormal] ;
    }
}

@end
