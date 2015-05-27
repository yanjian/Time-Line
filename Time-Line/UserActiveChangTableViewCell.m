//
//  UserActiveChangTableViewCell.m
//  Go2
//
//  Created by IF on 15/1/30.
//  Copyright (c) 2015年 zhilifang. All rights reserved.
//

#import "UserActiveChangTableViewCell.h"

@implementation UserActiveChangTableViewCell

- (void)awakeFromNib {
	self.userHeadImg.layer.cornerRadius = self.userHeadImg.frame.size.width / 2;
	self.userHeadImg.layer.masksToBounds = YES;

	// Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
	[super setSelected:selected animated:animated];

	// Configure the view for the selected state
}

- (void)setActivechangInfo:(NSString *)str {
	UIFont *tfont = [UIFont systemFontOfSize:12.f];
	_changMsgLab.font = tfont;
	_changMsgLab.lineBreakMode = NSLineBreakByTruncatingMiddle;
	_changMsgLab.numberOfLines = 2;

	_changMsgLab.text = str;
	NSDictionary *tdic = [NSDictionary dictionaryWithObjectsAndKeys:tfont, NSFontAttributeName, nil];
	CGSize actualsize = [str boundingRectWithSize:CGSizeMake(260, 60) options:NSStringDrawingUsesLineFragmentOrigin attributes:tdic context:nil].size;
	_changMsgLab.frame = CGRectMake(66, 10, actualsize.width, actualsize.height);
}

@end
