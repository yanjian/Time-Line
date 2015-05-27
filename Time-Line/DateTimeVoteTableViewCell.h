//
//  DateTimeVoteTableViewCell.h
//  Go2
//
//  Created by IF on 15/4/7.
//  Copyright (c) 2015年 zhilifang. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DateTimeVoteTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *startTimeLab;
@property (weak, nonatomic) IBOutlet UILabel *endTimeLab;
@property (weak, nonatomic) IBOutlet UILabel *suggestLab;
@property (weak, nonatomic) IBOutlet UILabel *voteCount;

@end
