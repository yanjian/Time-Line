//
//  EventTitleAndDescCellTableViewCell.m
//  Go2
//
//  Created by IF on 15/10/12.
//  Copyright © 2015年 zhilifang. All rights reserved.
//

#import "EventTitleAndDescCellTableViewCell.h"

@implementation EventTitleAndDescCellTableViewCell

- (void)awakeFromNib {
    self.eventContentView.layer.cornerRadius  = 2;
    //    self.subContentView.layer.masksToBounds = YES ;
    self.eventContentView.layer.shadowColor   = [UIColor blackColor].CGColor;
    self.eventContentView.layer.shadowOffset  = CGSizeMake(1, 1);
    self.eventContentView.layer.shadowOpacity = 0.8 ;
    self.eventContentView.layer.shadowRadius  = 2;
    
    [self.eventTitle becomeFirstResponder];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
