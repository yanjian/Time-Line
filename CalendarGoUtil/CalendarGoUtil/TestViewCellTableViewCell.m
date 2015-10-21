//
//  TestViewCellTableViewCell.m
//  CalendarGoUtil
//
//  Created by IF on 15/9/29.
//  Copyright © 2015年 IF. All rights reserved.
//

#import "TestViewCellTableViewCell.h"

@implementation TestViewCellTableViewCell

- (void)awakeFromNib {
    self.border.layer.cornerRadius = 5;
    self.border.layer.masksToBounds = YES ;
    
    
    self.border.layer.shadowOffset = CGSizeMake(2, 106);
    self.border.layer.shadowColor  = [UIColor blackColor].CGColor;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
