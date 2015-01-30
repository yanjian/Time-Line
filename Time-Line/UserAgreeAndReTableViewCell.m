//
//  UserAgreeAndReTableViewCell.m
//  Time-Line
//
//  Created by IF on 15/1/30.
//  Copyright (c) 2015年 zhilifang. All rights reserved.
//

#import "UserAgreeAndReTableViewCell.h"

@implementation UserAgreeAndReTableViewCell

- (void)awakeFromNib {
    _userHead.layer.cornerRadius = _userHead.frame.size.width / 2;
    _userHead.layer.masksToBounds = YES;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(void)setFriendMsgInfo:(NSString *) msgStr
{
    UIFont * tfont = [UIFont systemFontOfSize:17.f];
    _msgInfo.font = tfont ;
    _msgInfo.lineBreakMode = NSLineBreakByTruncatingTail;
    _msgInfo.numberOfLines = 2;
    
    _msgInfo.text =[NSString stringWithFormat:@"  %@",msgStr]  ;
    NSDictionary * tdic = [NSDictionary dictionaryWithObjectsAndKeys:tfont,NSFontAttributeName,nil];
    CGSize  actualsize =[msgStr boundingRectWithSize:CGSizeMake(260,60) options:NSStringDrawingUsesLineFragmentOrigin  attributes:tdic context:nil].size;
    _msgInfo.frame =CGRectMake(70,10,actualsize.width, actualsize.height);
}
@end
