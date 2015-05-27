//
//  InviteesTimeTableViewCell.h
//  Go2
//
//  Created by IF on 15/4/9.
//  Copyright (c) 2015年 zhilifang. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface InviteesTimeTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *joinCount;
@property (weak, nonatomic) IBOutlet UILabel *noJoinCount;
@property (weak, nonatomic) IBOutlet UILabel *noReplyCount;

@end
