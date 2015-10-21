//
//  EventInteeTableViewCell.h
//  Go2
//
//  Created by IF on 15/10/13.
//  Copyright © 2015年 zhilifang. All rights reserved.
//

#import <UIKit/UIKit.h>
static NSString * FriendInfoTableViewCellId = @"FriendInfoTableViewCellID" ;

@protocol EventInvitedTableViewDataSource,EventInvitedTableViewDelegate ;
@interface EventInteeTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIView *eventBgView;
@property (weak, nonatomic) IBOutlet UILabel *eventInvitedCount;
@property (weak, nonatomic) IBOutlet UITableView *eventInvitedTableView;
@property (weak, nonatomic) IBOutlet UIButton *showAllBtn;
@property (weak, nonatomic) IBOutlet UIImageView *inviteesIcon;


@property (strong,nonatomic) id<EventInvitedTableViewDataSource> dataSource;
@property (strong,nonatomic) id<EventInvitedTableViewDelegate> delegate;
@end

@protocol EventInvitedTableViewDelegate <NSObject>

@optional
- (CGFloat)eventInvitedTableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath;
- (CGFloat)eventInvitedTableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section;
- (CGFloat)eventInvitedTableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section;


-(void)showAllInviteesMemberWithEventCell:(EventInteeTableViewCell *) eventInteeCell;

@end

@protocol EventInvitedTableViewDataSource <NSObject>

- (NSInteger)eventInvitedTableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section;

- (UITableViewCell *)eventInvitedTableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath;
@end