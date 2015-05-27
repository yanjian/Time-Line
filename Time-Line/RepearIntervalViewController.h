//
//  RepearIntervalViewController.h
//  Go2
//
//  Created by IF on 14/11/12.
//  Copyright (c) 2014年 zhilifang. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol RepearIntervalViewControllerDelegate;

@interface RepearIntervalViewController : UIViewController

@property (nonatomic, copy) NSString *repeatParam;
@property (nonatomic, retain) id <RepearIntervalViewControllerDelegate> delegate;

@end

@protocol RepearIntervalViewControllerDelegate <NSObject>

- (void)selectValueWithInterval:(NSString *)interval;

@end
