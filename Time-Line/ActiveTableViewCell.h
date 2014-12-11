//
//  ActiveTableViewCell.h
//  Time-Line
//
//  Created by IF on 14/12/6.
//  Copyright (c) 2014年 zhilifang. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ActiveTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *activeImg;
@property (weak, nonatomic) IBOutlet UILabel *activeStateLab;
@property (weak, nonatomic) IBOutlet UILabel *monthLab;
@property (weak, nonatomic) IBOutlet UILabel *dayCountLab;
@property (weak, nonatomic) IBOutlet UILabel *activeNameLab;
@property (weak, nonatomic) IBOutlet UILabel *activeDesLab;

@end
