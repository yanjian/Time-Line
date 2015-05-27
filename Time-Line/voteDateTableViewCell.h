//
//  voteDateTableViewCell.h
//  Go2
//
//  Created by IF on 14/12/16.
//  Copyright (c) 2014年 zhilifang. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface voteDateTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *showDateLab;//显示年月日时间
@property (weak, nonatomic) IBOutlet UILabel *showTimeLab;//显示小时，分钟
@property (weak, nonatomic) IBOutlet UILabel *intervalTime;//开始时间和结束时间的差值
@property (weak, nonatomic) IBOutlet UILabel *allDayLab;

@end
