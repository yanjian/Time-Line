//
//  FriendsInfoTableViewController.h
//  Time-Line
//
//  Created by IF on 15/1/19.
//  Copyright (c) 2015年 zhilifang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Friend.h"
@ class FriendsInfoTableViewController;

typedef void (^FriendDeleteBlock)(FriendsInfoTableViewController *selfTabeViewController);
@interface FriendsInfoTableViewController : UITableViewController


@property (nonatomic, strong) Friend *friendInfo;

@property (nonatomic, copy) FriendDeleteBlock friendDeleteBlock;


@end
