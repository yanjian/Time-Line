//
//  ComplicatedEventTableViewCell.m
//  Time-Line
//
//  Created by IF on 15/3/19.
//  Copyright (c) 2015年 zhilifang. All rights reserved.
//

#import "ComplicatedEventTableViewCell.h"

@implementation ComplicatedEventTableViewCell

- (void)awakeFromNib {
    self.activeImg.layer.cornerRadius = 5;
    self.activeImg.layer.masksToBounds = YES ;
    self.shieldLab.layer.cornerRadius = 5;
    self.shieldLab.layer.masksToBounds = YES ;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
