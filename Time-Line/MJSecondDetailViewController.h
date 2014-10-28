//
//  MJSecondDetailViewController.h
//  MJPopupViewControllerDemo
//
//  Created by Martin Juhasz on 24.06.12.
//  Copyright (c) 2012 martinjuhasz.de. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MADayView.h"
@protocol MJSecondPopupDelegate;
@protocol popListViewDelegate;
@class MAEventKitDataSource;
@class MAEvent;


@interface MJSecondDetailViewController : UIViewController<MADayViewDataSource,MADayViewDelegate> {
    MAEventKitDataSource *_eventKitDataSource;
    MAEvent *_event;
}
@property (nonatomic,strong) MAEvent *event;
@property (nonatomic, assign) id<popListViewDelegate> delegate;

@property (assign, nonatomic) id <MJSecondPopupDelegate> mjdelegate;

@end



@protocol MJSecondPopupDelegate<NSObject>

- (void)leveyPopListView:(UIView *)popListView didSelectedIndex:(NSInteger)anIndex;
- (void)leveyPopListViewDidCancel;

@optional
- (void)cancelButtonClicked:(MJSecondDetailViewController*)secondDetailViewController;
@end