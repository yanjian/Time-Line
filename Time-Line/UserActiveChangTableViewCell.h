//
//  UserActiveChangTableViewCell.h
//  Go2
//
//  Created by IF on 15/1/30.
//  Copyright (c) 2015年 zhilifang. All rights reserved.
// 作废-----yj

#import <UIKit/UIKit.h>
#import "ActiveBaseInfoMode.h"
@interface UserActiveChangTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *activeImg;
@property (weak, nonatomic) IBOutlet UILabel *activeStateLab;
@property (weak, nonatomic) IBOutlet UILabel *monthLab;
@property (weak, nonatomic) IBOutlet UILabel *dayCountLab;
@property (weak, nonatomic) IBOutlet UILabel *activeNameLab;
@property (weak, nonatomic) IBOutlet UILabel *activeDesLab;
@property (weak, nonatomic) IBOutlet UIView *activeChangView;
@property (weak, nonatomic) IBOutlet UIImageView *userHeadImg;
@property (weak, nonatomic) IBOutlet UILabel *changMsgLab;

@property (strong, nonatomic) ActiveBaseInfoMode *activeEvent;

- (void)setActivechangInfo:(NSString *)str;
@end
