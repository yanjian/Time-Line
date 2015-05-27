//
//  SimpleEventTableViewCell.h
//  Go2
//
//  Created by IF on 15/3/19.
//  Copyright (c) 2015年 zhilifang. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SimpleEventTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIView *dayAndWeekView;//主要用来隐藏号数和周几的
@property (weak, nonatomic) IBOutlet UILabel *dayNumber;
@property (weak, nonatomic) IBOutlet UILabel *weekNumber;
@property (weak, nonatomic) IBOutlet UILabel *eventColor;

@property (weak, nonatomic) IBOutlet UILabel *eventTitle;
@property (weak, nonatomic) IBOutlet UILabel *eventTime;
@end
