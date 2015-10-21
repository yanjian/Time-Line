//
//  EventConfirmTimeTableViewController.h
//  Go2
//
//  Created by IF on 15/4/10.
//  Copyright (c) 2015年 zhilifang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EventConfirmTimeTableViewController.h"
#import "ActiveTimeVoteMode.h"
@protocol EventConfirmTimeTableViewControllerDelegate;

@interface EventConfirmTimeTableViewController : UITableViewController

@property (nonatomic , retain) NSMutableArray * timeArr ;
@property (nonatomic , retain) NSMutableArray * etArr;
@property (nonatomic , copy)   NSString * eid;
@property (nonatomic , retain) id<EventConfirmTimeTableViewControllerDelegate> delegate ;
@end


@protocol EventConfirmTimeTableViewControllerDelegate <NSObject>
@optional
/**
 *  用户pop该视图时回调该方法
 *
 *  @param eventConfiremVC 该视图
 */
-(void)popEventConfirmTimeTableViewController:(EventConfirmTimeTableViewController *)eventConfiremVC;


/**
 *  创建者投票成功后回调该方法（网络请求成功）
 *
 *  @param eventConfirmVC 该控制器
 *  @param tid            时间的id
 */
-(void)eventConfirmTimeTableViewControllerDelegate:(EventConfirmTimeTableViewController *) eventConfirmVC setTimeId:(NSString *)tid ;
@end