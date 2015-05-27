//
//  ActiveSetingShowTableViewCell.m
//  Go2
//
//  Created by IF on 15/4/9.
//  Copyright (c) 2015年 zhilifang. All rights reserved.
//

#import "ActiveSetingShowTableViewCell.h"

@implementation ActiveSetingShowTableViewCell

- (void)awakeFromNib {
    self.activeImg.layer.masksToBounds = YES ;
    self.activeImg.layer.cornerRadius = self.activeImg.bounds.size.width / 2 ;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
