//
//  UserApplyTableViewCell.h
//  Time-Line
//
//  Created by IF on 14/12/6.
//  Copyright (c) 2014年 zhilifang. All rights reserved.
//作废----yj

#import <UIKit/UIKit.h>
#import "NoticesMsgModel.h"
@protocol UserApplyTableViewCellDelegate;
@interface UserApplyTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *userHead;
@property (weak, nonatomic) IBOutlet UILabel *userRequestInfo;
@property (weak, nonatomic) IBOutlet UIButton *acceptBtn;
@property (weak, nonatomic) IBOutlet UIButton *denyBtn;

@property (nonatomic, retain) NoticesMsgModel *noticesMsg;
- (void)setFriendRequestInfo:(NSString *)str;

@property (nonatomic, retain) id <UserApplyTableViewCellDelegate> delegate;
@end

@protocol UserApplyTableViewCellDelegate <NSObject>

- (void)userApplyTableViewCell:(UserApplyTableViewCell *)selfCell paramNoticesMsgModel:(NoticesMsgModel *)noticesMsg isAcceptAndDeny:(BOOL)isAccept;

@end
