//
//  FriendsProfilesTableViewController.h
//  Go2
//
//  Created by IF on 15/3/16.
//  Copyright (c) 2015年 zhilifang. All rights reserved.
//
typedef void(^FriendsAddProfileBlank)(void) ;

typedef NS_ENUM(NSInteger, ShowButtonType) {
    ShowButtonType_Accept = 0,
    ShowButtonType_Friend = 1,
    ShowButtonType_Add    = 2,
    ShowButtonType_Send   = 3
};


#import <UIKit/UIKit.h>
#import "NoticesMsgModel.h"
#import "Friend.h"

@interface FriendsProfilesTableViewController : UITableViewController
@property (nonatomic , retain) NoticesMsgModel * noticesMsg;
@property (nonatomic , retain) Friend *friend;
@property (nonatomic , assign) BOOL              isAddSuccess;//添加好友是否成功或是否是好友
@property (nonatomic , assign) BOOL              isSendRequest; //是否发送好友请求或添加好友
@property (nonatomic , copy) FriendsAddProfileBlank  friendsAddProfileblack;

@end
