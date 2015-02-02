//
//  UserAgreeAndReTableViewCell.h
//  Time-Line
//
//  Created by IF on 15/1/30.
//  Copyright (c) 2015年 zhilifang. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UserAgreeAndReTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *userHead;
@property (weak, nonatomic) IBOutlet UILabel *msgInfo;

- (void)setFriendMsgInfo:(NSString *)msgStr;
@end
