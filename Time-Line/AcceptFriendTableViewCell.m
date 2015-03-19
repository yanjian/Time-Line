//
//  AcceptFriendTableViewCell.m
//  Time-Line
//
//  Created by IF on 15/3/16.
//  Copyright (c) 2015年 zhilifang. All rights reserved.
//

#import "AcceptFriendTableViewCell.h"

@implementation AcceptFriendTableViewCell

- (void)awakeFromNib {
    // Initialization code
    self.userHeadImg.layer.cornerRadius = self.userHeadImg.frame.size.width/2;
    self.userHeadImg.layer.masksToBounds= YES ;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
