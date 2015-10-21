//
//  EventInteeTableViewCell.m
//  Go2
//
//  Created by IF on 15/10/13.
//  Copyright © 2015年 zhilifang. All rights reserved.
//

#import "EventInteeTableViewCell.h"
@interface EventInteeTableViewCell()<UITableViewDataSource,UITableViewDelegate>{
}
@end


@implementation EventInteeTableViewCell

- (void)awakeFromNib {
    self.eventBgView.layer.cornerRadius  = 2;
    self.eventBgView.layer.shadowColor   = [UIColor blackColor].CGColor;
    self.eventBgView.layer.shadowOffset  = CGSizeMake(1, 1);
    self.eventBgView.layer.shadowOpacity = 0.8 ;
    self.eventBgView.layer.shadowRadius  = 2;
    
    [self.showAllBtn addTarget:self action:@selector(showAllInviteesOfMember:) forControlEvents:UIControlEventTouchUpInside];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}


/**
 *
 *用于显示活动邀请的所有成员....
 **/
-(void)showAllInviteesOfMember:(UIButton *)sender{
    if (self.delegate && [self.delegate respondsToSelector:@selector(showAllInviteesMemberWithEventCell:)]) {
        [self.delegate showAllInviteesMemberWithEventCell:self];
    }
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [self.dataSource eventInvitedTableView:tableView numberOfRowsInSection:section];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    return [self.dataSource eventInvitedTableView:tableView cellForRowAtIndexPath:indexPath];
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (self.delegate && [self.delegate respondsToSelector:@selector(eventInvitedTableView:heightForRowAtIndexPath:)]) {
        return [self.delegate eventInvitedTableView:tableView heightForRowAtIndexPath:indexPath];
    }
    return 44.f;
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    if (self.delegate && [self.delegate respondsToSelector:@selector(eventInvitedTableView:heightForHeaderInSection:)]) {
        return [self.delegate eventInvitedTableView:tableView heightForHeaderInSection:section];
    }
    return 0.01f;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    if (self.delegate && [self.delegate respondsToSelector:@selector(eventInvitedTableView:heightForFooterInSection:)]) {
        return [self.delegate eventInvitedTableView:tableView heightForFooterInSection:section];
    }
    return 0.01f;
}
@end
