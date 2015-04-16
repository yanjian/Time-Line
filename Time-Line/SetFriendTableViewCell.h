//
//  SetFriendTableViewCell.h
//  Time-Line
//
//  Created by IF on 14/12/19.
//  Copyright (c) 2014年 zhilifang. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SetFriendTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *userHead;
@property (weak, nonatomic) IBOutlet UILabel *nickName;
@property (weak, nonatomic) IBOutlet UILabel *userNote;
@property (assign, nonatomic) BOOL isSelect;
@end
