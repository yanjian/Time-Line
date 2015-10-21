//
//  EventTitleAndDescCellTableViewCell.h
//  Go2
//
//  Created by IF on 15/10/12.
//  Copyright © 2015年 zhilifang. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface EventTitleAndDescCellTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIView *eventContentView;
@property (weak, nonatomic) IBOutlet UITextField *eventTitle;
@property (weak, nonatomic) IBOutlet UITextView *descriptionText;

@end
