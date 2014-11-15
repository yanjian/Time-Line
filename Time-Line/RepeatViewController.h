//
//  RepeatViewController.h
//  Time-Line
//
//  Created by IF on 14/11/12.
//  Copyright (c) 2014年 zhilifang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RecurrenceModel.h"
@protocol RepeatViewControllerDelegate;
@interface RepeatViewController : UIViewController
@property (nonatomic,copy) NSString * repeatParam;
@property (nonatomic,copy) NSString *onDays;//1,2,3
@property (nonatomic,retain) id<RepeatViewControllerDelegate> delegate;
@property (nonatomic,retain)  RecurrenceModel *recurrObj;
@end

@protocol RepeatViewControllerDelegate <NSObject>

-(void)selectValueWithDateString:(NSString *) dateString repeatRecurrence:(RecurrenceModel *)recurrence;

@end