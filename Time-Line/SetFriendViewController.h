//
//  SetFriendViewController.h
//  Go2
//
//  Created by IF on 14/12/18.
//  Copyright (c) 2014年 zhilifang. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol SetFriendViewControllerDelegate;
@interface SetFriendViewController : UIViewController

@property (nonatomic, retain) id <SetFriendViewControllerDelegate> delegate;

@end


@protocol SetFriendViewControllerDelegate <NSObject>

@optional
/**
 *  点击保存按钮回调的代理
 *
 *  @param secondSetFriendViewController 弹出的窗体控制器
 *  @param friendArr                     选择的好友数组
 */
- (void)saveButtonClicked:(SetFriendViewController *)secondSetFriendViewController didSelectFriend:(NSArray *)friendArr;

@end
