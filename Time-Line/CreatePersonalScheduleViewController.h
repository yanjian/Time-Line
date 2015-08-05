//
//  CreatePersonalScheduleViewController.h
//  Go2
//
//  Created by IF on 15/8/3.
//  Copyright (c) 2015年 zhilifang. All rights reserved.
//

#import <UIKit/UIKit.h>

@class CreatePersonalScheduleViewController;

@protocol CreatePersonalScheduleViewControllerDelegate <NSObject>

@optional
-(void)createPersonalScheduleViewControllerDelegate:(CreatePersonalScheduleViewController *)createPersonSchelduleVC buttonTag:(NSInteger) tag;

@end

@interface CreatePersonalScheduleViewController : UIViewController

@property (nonatomic,assign) id<CreatePersonalScheduleViewControllerDelegate> delegate ;

@end
