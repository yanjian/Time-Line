//
//  RepearOnDaysViewController.h
//  Time-Line
//
//  Created by IF on 14/11/12.
//  Copyright (c) 2014年 zhilifang. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol RepearOnDaysViewControllerDelegate;
@interface RepearOnDaysViewController : UIViewController
@property (nonatomic, copy) NSString *onDayStr;
@property (nonatomic, retain) id <RepearOnDaysViewControllerDelegate> delegate;
@end

@protocol RepearOnDaysViewControllerDelegate <NSObject>

- (void)selectRepeatWtihDay:(NSString *)dayString;

@end
