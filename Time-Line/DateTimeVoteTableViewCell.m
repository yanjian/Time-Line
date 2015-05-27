//
//  DateTimeVoteTableViewCell.m
//  Go2
//
//  Created by IF on 15/4/7.
//  Copyright (c) 2015年 zhilifang. All rights reserved.
//

#import "DateTimeVoteTableViewCell.h"

@implementation DateTimeVoteTableViewCell

- (void)awakeFromNib {
    self.voteCount.layer.masksToBounds = YES ;
    self.voteCount.layer.cornerRadius = self.voteCount.frame.size.width/2 ;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
