//
//  UserApplyTableViewCell.m
//  Time-Line
//
//  Created by IF on 14/12/6.
//  Copyright (c) 2014年 zhilifang. All rights reserved.
//

#import "UserApplyTableViewCell.h"

@implementation UserApplyTableViewCell

- (void)awakeFromNib {
	// Initialization code
	_userHead.layer.cornerRadius = _userHead.frame.size.width / 2;
	_userHead.layer.masksToBounds = YES;
	self.acceptBtn.tag = 1;
	[self.acceptBtn addTarget:self action:@selector(touchUpInside:) forControlEvents:UIControlEventTouchUpInside];
	self.denyBtn.tag = 2;
	[self.denyBtn addTarget:self action:@selector(touchUpInside:) forControlEvents:UIControlEventTouchUpInside];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
	[super setSelected:selected animated:animated];

	// Configure the view for the selected state
}

- (void)setFriendRequestInfo:(NSString *)str {
	UIFont *tfont = [UIFont systemFontOfSize:17.f];
	_userRequestInfo.font = tfont;
	_userRequestInfo.lineBreakMode = NSLineBreakByTruncatingTail;
	_userRequestInfo.numberOfLines = 2;

	_userRequestInfo.text = str;
	NSDictionary *tdic = [NSDictionary dictionaryWithObjectsAndKeys:tfont, NSFontAttributeName, nil];
	CGSize actualsize = [str boundingRectWithSize:CGSizeMake(260, 60) options:NSStringDrawingUsesLineFragmentOrigin attributes:tdic context:nil].size;
	_userRequestInfo.frame = CGRectMake(65, 15, actualsize.width, actualsize.height);
}

- (void)touchUpInside:(UIButton *)sender {
	BOOL isAccept = (sender.tag == 1 ? YES : NO);
	if (self.delegate && [self.delegate respondsToSelector:@selector(userApplyTableViewCell:paramNoticesMsgModel:isAcceptAndDeny:)]) {
		[self.delegate userApplyTableViewCell:self paramNoticesMsgModel:self.noticesMsg isAcceptAndDeny:isAccept];
	}
}

@end
