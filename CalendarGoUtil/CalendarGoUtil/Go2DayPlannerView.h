//
//  Go2DayPlanerVIew.h
//  CalendarGoUtil
//
//  Created by IF on 15/7/16.
//  Copyright (c) 2015年 IF. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Go2DayPlannerView ;

@protocol Go2DayPlannerViewDelegate <NSObject>

-(void)go2DayPlannerView:(Go2DayPlannerView *) plannerView didSelectDateDic:(NSDictionary *) didSelectDic;

-(void)deleteSelectDateDic:(NSDictionary *) willDeleteDateDic ;

@end

@interface Go2DayPlannerView : UIView


@property (nonatomic,assign) id<Go2DayPlannerViewDelegate> delegate ;

-(instancetype)initWithFrame:(CGRect)frame;

@end
