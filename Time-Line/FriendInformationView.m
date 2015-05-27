//
//  FriendInformationView.m
//  Go2
//
//  Created by IF on 14/12/29.
//  Copyright (c) 2014年 zhilifang. All rights reserved.
//

#import "FriendInformationView.h"

@implementation FriendInformationView

+(instancetype)initFriendInfoView{
    NSArray *fridArr = [[NSBundle mainBundle] loadNibNamed:@"FriendInformationView" owner:self options:nil];
    FriendInformationView * friV = (FriendInformationView *) fridArr[0];
    friV.friendHeadimg.layer.cornerRadius = friV.friendHeadimg.frame.size.width / 2;
    friV.friendHeadimg.layer.masksToBounds = YES;
    return fridArr[0];
}


-(instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if(self){
        self.friendHeadimg.layer.cornerRadius = self.friendHeadimg.frame.size.width / 2;
        self.friendHeadimg.layer.masksToBounds = YES;
    }
    return self;
}

@end
