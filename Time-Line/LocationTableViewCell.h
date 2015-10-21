//
//  LocationTableViewCell.h
//  Go2
//
//  Created by IF on 15/10/12.
//  Copyright © 2015年 zhilifang. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LocationTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIView *commonShowView;
@property (weak, nonatomic) IBOutlet UILabel *selectContentLable;
@property (weak, nonatomic) IBOutlet UILabel *descLable;
@property (weak, nonatomic) IBOutlet UIImageView *decorativeIcon;
@property (weak, nonatomic) IBOutlet UIView *locationContentView;

-(void)modifLoctionContentViewHeight:(CGFloat)height;
@end
