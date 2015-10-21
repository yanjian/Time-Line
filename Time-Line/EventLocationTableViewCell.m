//
//  EventLocationTableViewCell.m
//  Go2
//
//  Created by IF on 15/10/13.
//  Copyright © 2015年 zhilifang. All rights reserved.
//

#import "EventLocationTableViewCell.h"

@implementation EventLocationTableViewCell

- (void)awakeFromNib {
    self.locationbgView.layer.cornerRadius  = 2;
    //    self.subContentView.layer.masksToBounds = YES ;
    self.locationbgView.layer.shadowColor   = [UIColor blackColor].CGColor;
    self.locationbgView.layer.shadowOffset  = CGSizeMake(1, 1);
    self.locationbgView.layer.shadowOpacity = 0.8 ;
    self.locationbgView.layer.shadowRadius  = 2;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
