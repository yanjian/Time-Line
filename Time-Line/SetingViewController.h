//
//  SetingViewController.h
//  Go2
//
//  Created by IF on 14-10-11.
//  Copyright (c) 2014年 zhilifang. All rights reserved.
//

#import <UIKit/UIKit.h>
@class SetingViewController;
@protocol SetingViewControllerDelegate <NSObject>

- (void)setingViewControllerDelegate:(SetingViewController *)selfViewController;

@end

@interface SetingViewController : UIViewController

@property (nonatomic, retain) id <SetingViewControllerDelegate> delegate;
@property (nonatomic, strong) NSMutableArray *accountDataArr;//用户账号信息
@end
