//
//  Go2StandardEventView.h
//  CalendarGoUtil
//
//  Created by IF on 15/7/16.
//  Copyright (c) 2015年 IF. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol Go2StandardEventViewDelegate ;
@interface Go2StandardEventView : UIView


@property (nonatomic, copy)	NSString *title;

@property (nonatomic, copy)	NSString *subtitle;

@property (nonatomic, copy)	NSString *detail;

@property (nonatomic) UIColor *color;

@property (nonatomic) UIFont *font;

@property (nonatomic) BOOL selected;


//
@property (nonatomic) NSDictionary * selectDic ;

@property (nonatomic ) id<Go2StandardEventViewDelegate> delegate;

@end


@protocol Go2StandardEventViewDelegate <NSObject>


-(void)deleteGo2StandardEventView:(Go2StandardEventView *) eventView deleteSelectDateDic:(NSDictionary *)selectDateDic ;
@end