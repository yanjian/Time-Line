//
//  UserInfoTableViewController.h
//  Go2
//
//  Created by IF on 14/12/3.
//  Copyright (c) 2014年 zhilifang. All rights reserved.
//

#import <UIKit/UIKit.h>
@ class UserInfoTableViewController;
typedef void (^UserInfoBlank)(UserInfoTableViewController *userInfoViewController, UserInfo *userInfo);
@interface UserInfoTableViewController : UITableViewController

@property (nonatomic, copy) UserInfoBlank userInfoBlank;
@end
