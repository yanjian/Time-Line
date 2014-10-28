//
//  EventCell.h
//  Time-Line
//
//  Created by connor on 14-3-26.
//  Copyright (c) 2014年 connor. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface EventCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *starttimelabel;
@property (weak, nonatomic) IBOutlet UILabel *timelabel;
@property (weak, nonatomic) IBOutlet UILabel *content;
@property (weak, nonatomic) IBOutlet UIView *contxtView;
@property (weak, nonatomic) IBOutlet UILabel *cirPoint;
@property (weak, nonatomic) IBOutlet UIImageView *backImage;
@end
