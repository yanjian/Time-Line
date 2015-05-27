//
//  ActiveSetingShowTableViewCell.h
//  Go2
//
//  Created by IF on 15/4/9.
//  Copyright (c) 2015年 zhilifang. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ActiveSetingShowTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *activeImg;
@property (weak, nonatomic) IBOutlet UILabel *activeTitle;
@property (weak, nonatomic) IBOutlet UILabel *activeDesc;
@property (weak, nonatomic) IBOutlet UILabel *showNoImgTitle;

@end
