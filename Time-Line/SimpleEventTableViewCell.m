//
//  SimpleEventTableViewCell.m
//  Go2
//
//  Created by IF on 15/3/19.
//  Copyright (c) 2015年 zhilifang. All rights reserved.
//

#import "SimpleEventTableViewCell.h"

@implementation SimpleEventTableViewCell

- (void)awakeFromNib {
    self.eventColor.layer.cornerRadius = 5;
    self.eventColor.layer.masksToBounds = YES ;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
