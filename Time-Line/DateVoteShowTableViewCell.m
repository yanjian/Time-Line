//
//  DateVoteShowTableViewCell.m
//  Go2
//
//  Created by IF on 15/3/30.
//  Copyright (c) 2015年 zhilifang. All rights reserved.
//

#import "DateVoteShowTableViewCell.h"

@implementation DateVoteShowTableViewCell

- (void)awakeFromNib {
    // Initialization code
    self.showTimeInterval.layer.masksToBounds = YES ;
    self.showTimeInterval.layer.cornerRadius = self.showTimeInterval.bounds.size.width/2 ;
    
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
