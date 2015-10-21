//
//  EventTimeTableViewCell.h
//  Go2
//
//  Created by IF on 15/10/13.
//  Copyright © 2015年 zhilifang. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol EventTimeTableViewCellDelegate;
@class ActiveTimeVoteMode;
@interface EventTimeTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIView *eventTimebgView;
@property (weak, nonatomic) IBOutlet UILabel *eventTimeStatus;
@property (weak, nonatomic) IBOutlet UILabel *showDesc;
@property (weak, nonatomic) IBOutlet UILabel *eventTime;
@property (weak, nonatomic) IBOutlet UIImageView *eventIconImg;
@property (weak, nonatomic) IBOutlet UIImageView *eventTimeIcon;
@property (weak, nonatomic) IBOutlet UIButton *chooseAvailibilityBtn;

/**
 *@param createHost 显示不同的界面（初始化时）
 *YES:是活动的创建者--显示不同的数据和事件
 *NO：不是活动创建者--？
 **/
@property (assign, nonatomic, getter=isCreateHost) BOOL createHost;

/**
 *@param timeConfirmed 时间是否确定
 *YES:时间确定 
 *NO:同上相反
 *
 **/
@property (assign, nonatomic,getter=isTimeConfirmed) BOOL timeConfirmed ;

@property (assign, nonatomic) id<EventTimeTableViewCellDelegate> delegate;
/**确定的时间*/
@property (strong, nonatomic) ActiveTimeVoteMode * activeVoteTime ;

@end

@protocol EventTimeTableViewCellDelegate <NSObject>
/**
 *  关闭投票（ 即创建者对时间进行投票，投票的同时也就确定了该时间 ）
 *
 *  @param cell
 */
-(void)closePoll:(EventTimeTableViewCell *)cell ;

/**
 *  重新启动投票
 *
 *  @param cell
 */
-(void)reopenPoll:(EventTimeTableViewCell *)cell ;

/**
 *  普通用户对时间进行投票
 *
 *  @param cell 
 */
-(void)chooseYourAvailability:(EventTimeTableViewCell *)cell ;


@end