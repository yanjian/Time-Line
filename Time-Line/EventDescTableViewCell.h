//
//  EventDescTableViewCell.h
//  Go2
//
//  Created by IF on 15/10/13.
//  Copyright © 2015年 zhilifang. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "DescLable.h"

@interface EventDescTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIView *eventBgView;
@property (weak, nonatomic) IBOutlet UILabel *eventTitle;
@property (weak, nonatomic) IBOutlet DescLable *eventDesc;
@property (weak, nonatomic) IBOutlet UILabel *eventCreatName;
@property (weak, nonatomic) IBOutlet UIImageView *eventCreatorImg;

@end
