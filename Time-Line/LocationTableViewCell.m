//
//  LocationTableViewCell.m
//  Go2
//
//  Created by IF on 15/10/12.
//  Copyright © 2015年 zhilifang. All rights reserved.
//

#import "LocationTableViewCell.h"

@implementation LocationTableViewCell

- (void)awakeFromNib {
    //[self modifLoctionContentViewHeight:64.f];
    self.locationContentView.layer.cornerRadius  = 2;
    //    self.subContentView.layer.masksToBounds = YES ;
    self.locationContentView.layer.shadowColor   = [UIColor blackColor].CGColor;
    self.locationContentView.layer.shadowOffset  = CGSizeMake(1, 1);
    self.locationContentView.layer.shadowOpacity = 0.8 ;
    self.locationContentView.layer.shadowRadius  = 2;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

   
}

-(void)modifLoctionContentViewHeight:(CGFloat)height{
    if (height) {
        self.locationContentView.frame = CGRectMake(self.locationContentView.frame.origin.x, self.locationContentView.frame.origin.y, self.locationContentView.frame.size.width, height);
    }
}

@end
