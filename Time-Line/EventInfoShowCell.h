//
//  EventInfoShowCell.h
//  Time-Line
//
//  Created by IF on 15/3/12.
//  Copyright (c) 2015年 zhilifang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ActiveEventMode.h"
@interface EventInfoShowCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *activePic;
@property (weak, nonatomic) IBOutlet UILabel *activeTitle;
@property (weak, nonatomic) IBOutlet UILabel *latestModifyUserName;
@property (weak, nonatomic) IBOutlet UILabel *latestModifyMsg;
@property (weak, nonatomic) IBOutlet UILabel *latestTime;
@property (weak, nonatomic) IBOutlet UILabel *unReadCount;

@property (strong, nonatomic) ActiveBaseInfoMode *activeEvent;
@end
