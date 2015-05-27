//
//  ActiveInvitationsNotifictionTableViewCell.m
//  Go2
//
//  Created by IF on 15/3/13.
//  Copyright (c) 2015年 zhilifang. All rights reserved.
//

#import "ActiveInvitationsNotifictionTableViewCell.h"

@implementation ActiveInvitationsNotifictionTableViewCell

- (void)awakeFromNib {
    self.showImg.layer.cornerRadius = self.showImg.frame.size.width / 2;
    self.showImg.layer.masksToBounds = YES;
    self.pointLab.layer.cornerRadius = self.pointLab.frame.size.width / 2;
    self.pointLab.layer.masksToBounds = YES;

}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
