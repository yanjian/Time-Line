//
//  DateVoteShowTableViewCell.h
//  Go2
//
//  Created by IF on 15/3/30.
//  Copyright (c) 2015年 zhilifang. All rights reserved.
//

#import <UIKit/UIKit.h>
@class DateVoteShowTableViewCell ;


@interface DateVoteShowTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *showTimeInterval;
@property (weak, nonatomic) IBOutlet UILabel *startTimeOrDay;
@property (weak, nonatomic) IBOutlet UILabel *timeOrEenTime;
@end
