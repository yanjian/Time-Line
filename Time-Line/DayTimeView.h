//
//  DayTimeView.h
//  Go2
//
//  Created by IF on 15/4/24.
//  Copyright (c) 2015年 zhilifang. All rights reserved.
//
#import <UIKit/UIKit.h>
#import "DayTimeView.h"
#import "MADayView.h"

@class MAEventKitDataSource;
@class MAEvent;

@protocol DayTimeViewDelegate;

@interface DayTimeView : UIView<MADayViewDataSource,MADayViewDelegate>{
    MAEventKitDataSource *_eventKitDataSource;
    MAEvent *_event;
}
@property (nonatomic,copy) NSString * title;
@property (nonatomic,assign) id<DayTimeViewDelegate> delegate ;

@property (nonatomic,strong) MAEvent *event;
@end

@protocol DayTimeViewDelegate <NSObject>

@optional

-(void)clickDayTimeToolLeftButton:(UIBarButtonItem *) barButtonItem ;

- (void)leveyPopListView:(UIView *)popListView didSelectedIndex:(NSInteger)anIndex;
- (void)leveyPopListViewDidCancel;
@end
