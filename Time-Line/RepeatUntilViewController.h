//
//  RepeatUntilViewController.h
//  Time-Line
//
//  Created by IF on 14/11/12.
//  Copyright (c) 2014年 zhilifang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CLDay.h"
@protocol RepeatUntilViewControllerDelegate;
@interface RepeatUntilViewController : UIViewController
@property (nonatomic,retain) id<RepeatUntilViewControllerDelegate> delegate;
@end


@protocol RepeatUntilViewControllerDelegate <NSObject>

-(void)selectedDidDate:(CLDay *)selectDate;

@end