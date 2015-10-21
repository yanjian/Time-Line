//
//  ActiveVotingViewController.h
//  Go2
//
//  Created by IF on 15/4/2.
//  Copyright (c) 2015年 zhilifang. All rights reserved.
//

typedef NS_ENUM(NSInteger, VoteTimeType) {
    voteTimeType_Vote = 1,
    voteTimeType_cancel = 2
};

#import <UIKit/UIKit.h>
#import "ARSegmentControllerDelegate.h"
#import "XLPagerTabStripViewController.h"
#import "ActiveTimeVoteMode.h"
#import "ActiveEventModel.h"
@protocol ActiveVotingViewControllerDelegate ;
@interface ActiveVotingViewController : UITableViewController
/**活动数据对象*/
@property (strong, nonatomic) ActiveEventModel *activeEvent ;
/**代理*/
@property (nonatomic,assign) id<ActiveVotingViewControllerDelegate> delegate ;

@end

@protocol ActiveVotingViewControllerDelegate <NSObject>

/**
 *  刷新并关闭控制器视图
 *
 *  @param vc      本视图控制器
 *  @param refresh 是否刷新数据
 */
-(void)refreshDataWithCloseController:(ActiveVotingViewController *) vc isRefresh:(BOOL) refresh;

@end