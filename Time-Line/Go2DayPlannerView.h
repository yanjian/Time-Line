//
//  Go2DayPlanerVIew.h
//  CalendarGoUtil
//
//  Created by IF on 15/7/16.
//  Copyright (c) 2015年 IF. All rights reserved.
//

#import <UIKit/UIKit.h>
#define startTime @"start"
#define endTime   @"end"

@class Go2DayPlannerView ;

@protocol Go2DayPlannerViewDelegate <NSObject>

-(void)go2DayPlannerView:(Go2DayPlannerView *) plannerView didSelectDateDic:(NSDictionary *) didSelectDic;

-(void)deleteSelectDateDic:(NSDictionary *) willDeleteDateDic ;

@end

@interface Go2DayPlannerView : UIView


@property (nonatomic,assign) id<Go2DayPlannerViewDelegate> delegate ;
@property (nonatomic,assign) NSInteger showDayCount ; //显示日的数量 默认显示30天
-(instancetype)initWithFrame:(CGRect)frame;

-(void)showEventView:(NSArray *) eventDateArr;

@end
