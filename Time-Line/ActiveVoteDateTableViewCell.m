//
//  ActiveVoteDateTableViewCell.m
//  Time-Line
//
//  Created by IF on 14/12/30.
//  Copyright (c) 2014年 zhilifang. All rights reserved.
//

#import "ActiveVoteDateTableViewCell.h"

@implementation ActiveVoteDateTableViewCell

- (void)awakeFromNib {
	// Initialization code
	[self.voteBtn setBackgroundImage:[UIImage imageNamed:@"selecte_friend_cycle"] forState:UIControlStateNormal];
	[self.voteBtn setBackgroundImage:[UIImage imageNamed:@"selecte_friend_tick"] forState:UIControlStateSelected];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
	[super setSelected:selected animated:animated];

	// Configure the view for the selected state
}

- (IBAction)voteClickEvent:(UIButton *)sender {
	if (sender.selected) {
		sender.selected = NO;
	}
	else {
		sender.selected = YES;
	}
	if (self.delegate && [self.delegate respondsToSelector:@selector(activeVoteDateTableViewCell:isVoteTimeOrOption:ParamDictionnary:isSelectForBtn:)]) {
		[self.delegate activeVoteDateTableViewCell:self isVoteTimeOrOption:self.voteTimeOrOption ParamDictionnary:self.paramDic isSelectForBtn:sender.selected];
	}
}

- (IBAction)showVoteMemberList:(UIButton *)sender {
	if (self.delegate && [self.delegate respondsToSelector:@selector(activeVoteDateTableViewCell:isVoteTimeOrOption:ParamArray:)]) {
		[self.delegate activeVoteDateTableViewCell:self isVoteTimeOrOption:self.voteTimeOrOption ParamArray:self.memberArr];
	}
}

@end
