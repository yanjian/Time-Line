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
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(void)setFriendRequestInfo:(NSString *) str{
    UIFont * tfont = [UIFont systemFontOfSize:17.f];
    _userRequestInfo.font = tfont ;
    _userRequestInfo.lineBreakMode = NSLineBreakByTruncatingTail;
    _userRequestInfo.numberOfLines = 2;
    
    _userRequestInfo.text = str ;
    NSDictionary * tdic = [NSDictionary dictionaryWithObjectsAndKeys:tfont,NSFontAttributeName,nil];
    CGSize  actualsize =[str boundingRectWithSize:CGSizeMake(260,60) options:NSStringDrawingUsesLineFragmentOrigin  attributes:tdic context:nil].size;
    _userRequestInfo.frame =CGRectMake(75,10, actualsize.width, actualsize.height);
}

@end
