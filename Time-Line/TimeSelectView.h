//
//  TimeSelect.h
//  Go2
//
//  Created by IF on 15/4/24.
//  Copyright (c) 2015年 zhilifang. All rights reserved.
//

typedef NS_ENUM(NSInteger, ClickWho_StartAndEnd) {
    ClickWho_StartAndEnd_Default = 0,
    ClickWho_StartAndEnd_Start = 1 ,
    ClickWho_StartAndEnd_End = 2
};

#define startTime @"start"
#define endTime   @"end"

#import <UIKit/UIKit.h>
@protocol TimeSelectViewDelegate ;

@interface TimeSelectView : UIView

@property (nonatomic,assign) id<TimeSelectViewDelegate> timeViewDelegate ;

@property(nonatomic, retain) NSMutableDictionary * dataDic ;//投票结束时间和开始时间

@end


@protocol TimeSelectViewDelegate <NSObject>


-(void)timeSelectView:(TimeSelectView *) selectView dateDic:(NSDictionary *) dateDic ;

@optional

-(void)clickTimeSelectToolLeftButton:(UIBarButtonItem *) barButtonItem ;
-(void)clickTimeSelectToolRightButton:(UIBarButtonItem *) barButtonItem ;
@end
