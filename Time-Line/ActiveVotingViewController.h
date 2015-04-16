//
//  ActiveVotingViewController.h
//  Time-Line
//
//  Created by IF on 15/4/2.
//  Copyright (c) 2015年 zhilifang. All rights reserved.
//

typedef NS_ENUM(NSInteger, VoteTimeType) {
    voteTimeType_Vote = 1,
    voteTimeType_cancel = 2
};

#import <UIKit/UIKit.h>
#import "XLPagerTabStripViewController.h"
#import "ActiveTimeVoteMode.h"

@interface ActiveVotingViewController : UITableViewController<XLPagerTabStripChildItem>

@property (strong, nonatomic) NSArray * timeArr ;

@end
