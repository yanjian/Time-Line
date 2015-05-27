//
//  DayViewController.h
//  Go2
//
//  Created by connor on 14-4-9.
//  Copyright (c) 2014年 connor. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MADayView.h"


@protocol popListViewDelegate;
@class MAEventKitDataSource;
@class MAEvent;



@interface DayViewController : UIViewController<MADayViewDataSource,MADayViewDelegate> {
    MAEventKitDataSource *_eventKitDataSource;
    MAEvent *_event;
}
@property (nonatomic,strong) MAEvent *event;
@property (nonatomic, assign) id<popListViewDelegate> delegate;
@end


@protocol popListViewDelegate <NSObject>
- (void)leveyPopListView:(UIView *)popListView didSelectedIndex:(NSInteger)anIndex;
- (void)leveyPopListViewDidCancel;
@end