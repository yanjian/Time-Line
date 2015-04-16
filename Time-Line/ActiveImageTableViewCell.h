//
//  ActiveImageTableViewCell.h
//  Time-Line
//
//  Created by IF on 15/3/25.
//  Copyright (c) 2015年 zhilifang. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ActiveImageTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *activeImag;

@property (weak, nonatomic) IBOutlet UIImageView *placeholderImage;

@end
