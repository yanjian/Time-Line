//
//  VotedTableViewController.h
//  Go2
//
//  Created by IF on 15/4/17.
//  Copyright (c) 2015年 zhilifang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "XLPagerTabStripViewController.h"
@interface VotedTableViewController : UITableViewController<XLPagerTabStripChildItem>
@property (nonatomic , strong) NSArray * voteMemberArr ;//对某个时间投票的人员；
@end
