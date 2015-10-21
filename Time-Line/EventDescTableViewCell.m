//
//  EventDescTableViewCell.m
//  Go2
//
//  Created by IF on 15/10/13.
//  Copyright © 2015年 zhilifang. All rights reserved.
//

#import "EventDescTableViewCell.h"

@implementation EventDescTableViewCell

- (void)awakeFromNib {
    self.eventBgView.layer.cornerRadius  = 2;
    //    self.subContentView.layer.masksToBounds = YES ;
    self.eventBgView.layer.shadowColor   = [UIColor blackColor].CGColor;
    self.eventBgView.layer.shadowOffset  = CGSizeMake(1, 1);
    self.eventBgView.layer.shadowOpacity = 0.8 ;
    self.eventBgView.layer.shadowRadius  = 2;
    self.eventDesc.verticalAlignment =VerticalAlignmentTop ;
    self.eventCreatorImg.layer.masksToBounds = YES;
    self.eventCreatorImg.layer.cornerRadius =  self.eventCreatorImg.bounds.size.width/2;
   

}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}


@end
