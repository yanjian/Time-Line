//
//  FriendInformationView.h
//  Go2
//
//  Created by IF on 14/12/29.
//  Copyright (c) 2014年 zhilifang. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FriendInformationView : UIView
@property (weak, nonatomic) IBOutlet UIImageView *friendHeadimg;
@property (weak, nonatomic) IBOutlet UILabel *friendNameLab;

@property (weak, nonatomic) IBOutlet UIButton *showFriendBtn;

+(instancetype)initFriendInfoView;
@end
