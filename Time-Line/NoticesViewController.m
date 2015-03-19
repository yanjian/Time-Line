//
//  NoticesViewController.m
//  Time-Line
//
//  Created by IF on 14/12/5.
//  Copyright (c) 2014年 zhilifang. All rights reserved.
//

#import "NoticesViewController.h"
#import "MJRefresh.h"
#import "NotiveMsgPageBaseMode.h"
#import "ActiveModifyMsgModel.h"
#import "ActivedetailsViewController.h"
#import "NoticesMsgModel.h"
#import "CalendarDateUtil.h"
#import "UIImageView+WebCache.h"
#import "FriendGroupShowViewController.h"
#import "UIViewController+MJPopupViewController.h"
#import "ActiveInvitationsNotifictionTableViewCell.h"
#import "FriendsProfilesTableViewController.h"

@interface NoticesViewController () <UITableViewDataSource, UITableViewDelegate, ActivedetailsViewControllerDelegate> {
	NSMutableArray *_noticeArr;
	NSInteger currPageNum;  //当前页码
}
@property (strong, nonatomic)  UITableView *tableView;

@end

@implementation NoticesViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
    {
        self.title = @"Invitations" ;
        [self.tabBarItem setImage:[UIImage imageNamed:@"Invitations_NoFill"]];
        self.tabBarItem.title = @"Invitations";
    }
    return self;
}


- (void)viewDidLoad {
	[super viewDidLoad];
    
	CGRect frame = CGRectMake(0, 0, kScreen_Width, kScreen_Height);
	self.view.frame = frame;
	_noticeArr = [NSMutableArray array];
	self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height - naviHigth) style:UITableViewStyleGrouped];

	self.tableView.dataSource = self;
	self.tableView.delegate = self;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;//去掉分割线
	[self.view addSubview:self.tableView];
	[self setupRefresh];
}

/**
 *  集成刷新控件
 */
- (void)setupRefresh {
	// 1.下拉刷新(进入刷新状态就会调用self的headerRereshing)
	// dateKey用于存储刷新时间，可以保证不同界面拥有不同的刷新时间
	[self.tableView addHeaderWithTarget:self action:@selector(headerRereshing) dateKey:@"noticeView"];

	[self.tableView headerBeginRefreshing];


	// 2.上拉加载更多(进入刷新状态就会调用self的footerRereshing)
	[self.tableView addFooterWithTarget:self action:@selector(footerRereshing)];
}

#pragma mark 开始进入刷新状态
- (void)headerRereshing {
	[_noticeArr removeAllObjects];
	[self loadUserRequestInfo:1];
	[self.tableView headerEndRefreshing];
}

- (void)footerRereshing {
	currPageNum = currPageNum + 1;
	[self loadUserRequestInfo:currPageNum + 1];
	[self.tableView footerEndRefreshing];
}

- (void)loadUserRequestInfo:(NSInteger)num {
	ASIHTTPRequest *msgRequest = [t_Network httpGet:@{ @"num":@(num) }.mutableCopy Url:anyTime_GetUserMessage2 Delegate:nil Tag:anyTime_GetUserMessage2_tag];
	[msgRequest setDownloadCache:g_AppDelegate.anyTimeCache];
	[msgRequest setCachePolicy:ASIFallbackToCacheIfLoadFailsCachePolicy | ASIAskServerIfModifiedWhenStaleCachePolicy];
	[msgRequest setCacheStoragePolicy:ASICachePermanentlyCacheStoragePolicy];
	__block ASIHTTPRequest *msgReq = msgRequest;
	[msgRequest setCompletionBlock: ^{
	    NSString *responseStr = [msgReq responseString];
	    id objTmp =  [responseStr objectFromJSONString];
	    if ([objTmp isKindOfClass:[NSDictionary class]]) {
	        NSDictionary *objDic = (NSDictionary *)objTmp;
	        NSString *statusCode = [objDic objectForKey:@"statusCode"];
	        if ([statusCode isEqualToString:@"1"]) {
	            id dataDic = [objDic objectForKey:@"data"];
	            if ([dataDic isKindOfClass:[NSDictionary class]]) {
	                NotiveMsgPageBaseMode *notiveMsgPage = [NotiveMsgPageBaseMode new];
	                [notiveMsgPage parseDictionary:dataDic];
	                if (notiveMsgPage.records) {
	                    for (NSDictionary *dic in notiveMsgPage.records) {
	                        NSLog(@"%@", dic);
	                        NoticesMsgModel *noticeMsg = [NoticesMsgModel new];
	                        [noticeMsg parseDictionary:dic];
	                        [_noticeArr addObject:noticeMsg];
						}
					}
				}
	            [_tableView reloadData];  //刷新table
			}
	        else {
			}
		}
	}];

	[msgRequest setFailedBlock: ^{
	    [MBProgressHUD showError:@"Network error!"];
	}];

	[msgRequest startAsynchronous];
}

- (void)didReceiveMemoryWarning {
	[super didReceiveMemoryWarning];
	// Dispose of any resources that can be recreated.
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView; {
	return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return _noticeArr.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 64.f;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
	return 5.f;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
	return 0.1f;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	NoticesMsgModel *noticeMsg = [_noticeArr objectAtIndex:indexPath.row];
    static NSString *activeCellID = @"activeMsgCellId";
    
    ActiveInvitationsNotifictionTableViewCell *activeCell = [tableView dequeueReusableCellWithIdentifier:activeCellID];
    if (!activeCell) {
        activeCell = (ActiveInvitationsNotifictionTableViewCell *)[[[NSBundle mainBundle] loadNibNamed:@"ActiveInvitationsNotifictionTableViewCell" owner:self options:nil] firstObject];
    }
    
	if ([noticeMsg.type integerValue] < 10) {
		if ([noticeMsg.type integerValue] == 1) { //好友请求
			NSDictionary *msgDic =  noticeMsg.message;
			if (msgDic) {
                    NSString *tmpUrl = [[msgDic objectForKey:@"imgBig"] stringByReplacingOccurrencesOfString:@"\\" withString:@"/"];
				NSString *_urlStr = [[NSString stringWithFormat:@"%@/%@", BASEURL_IP, tmpUrl] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
				NSLog(@"%@", _urlStr);
				NSURL *url = [NSURL URLWithString:_urlStr];
				[activeCell.showImg sd_setImageWithURL:url placeholderImage:[UIImage imageNamed:@"smile_1"] completed:nil];
                [activeCell.titleAndName setTextColor: blueColor];
                [activeCell.titleAndName setText:[msgDic objectForKey:@"fname"]];
                [activeCell.note setText:[msgDic objectForKey:@"msg"]]  ;
                if([noticeMsg.isRead intValue] == 1 ){
                    [activeCell.pointLab setHidden:YES];
                }else{
                     [activeCell.pointLab setHidden:NO];
                     [activeCell.pointLab setBackgroundColor:blueColor];
                }
               
			}
            return activeCell ;
		}else if ([noticeMsg.type integerValue] == 2 ||  [noticeMsg.type integerValue] == 3) { //对方同意 信息  //对方拒绝添加 你为
			NSDictionary *msgDic =  noticeMsg.message;
			if (msgDic) {
				NSString *tmpUrl = [[msgDic objectForKey:@"imgBig"] stringByReplacingOccurrencesOfString:@"\\" withString:@"/"];
				NSString *_urlStr = [[NSString stringWithFormat:@"%@/%@", BASEURL_IP, tmpUrl] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
				NSLog(@"%@", _urlStr);
				NSURL *url = [NSURL URLWithString:_urlStr];
                [activeCell.showImg sd_setImageWithURL:url placeholderImage:[UIImage imageNamed:@"smile_1"] completed:nil];
                [activeCell.titleAndName setTextColor: blueColor];
                [activeCell.titleAndName setText:[msgDic objectForKey:@"fname"]];
                [activeCell.note setText:[msgDic objectForKey:@"msg"]]  ;
                if([noticeMsg.isRead intValue] == 1 ){
                    [activeCell.pointLab setHidden:YES];
                }else{
                    [activeCell.pointLab setHidden:NO];
                    [activeCell.pointLab setBackgroundColor:blueColor];
                }
			}
			return activeCell;
		}else {
			static NSString *activeSysID = @"activeSystemId";
			UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:activeSysID];
			if (!cell) {
				cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:activeSysID];
			}
			NSDictionary *msgDic =  noticeMsg.message;
			if (msgDic) {
				cell.textLabel.text = [msgDic objectForKey:@"msg"];
			}
			return cell;
		}
	}
	else {
		NSDictionary *msgDic = [noticeMsg.message objectForKey:@"event"];
		ActiveBaseInfoMode *activeEvent = [ActiveBaseInfoMode new];
		if (msgDic) {
			[activeEvent parseDictionary:msgDic];
		}
        
        NSURL *url = nil;
        if (activeEvent.imgUrl && ![@"" isEqualToString:activeEvent.imgUrl]) {
            NSString *_urlStr = [[NSString stringWithFormat:@"%@/%@", BASEURL_IP, activeEvent.imgUrl] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
            NSLog(@"%@", _urlStr);
            url = [NSURL URLWithString:_urlStr];
        }
        [activeCell.showImg sd_setImageWithURL:url placeholderImage:[UIImage imageNamed:@"018.jpg"]];
        
        [activeCell.titleAndName setTextColor:[UIColor redColor]];
        
        activeCell.titleAndName.text = activeEvent.title ;
        
        if ([noticeMsg.message objectForKey:@"creater"]) {
             activeCell.note.text =[NSString stringWithFormat:@"hosted by Margaret %@",[noticeMsg.message objectForKey:@"creater"]]  ;
        }

//		if ([activeEvent.status integerValue] == ActiveStatus_upcoming) {
//			if ([activeEvent.type integerValue] == 2) {
//				activeCell.activeStateLab.text = @"UpComing(Voting)";
//			}
//			else {
//				activeCell.activeStateLab.text = @"UpComing";
//			}
//		}
//		else if ([activeEvent.status integerValue] == ActiveStatus_toBeConfirm) {
//			activeCell.activeStateLab.text = @"To be Confirm";
//		}
//		else if ([activeEvent.status integerValue] == ActiveStatus_confirmed) {
//			activeCell.activeStateLab.text = @"Confirmed";
//		}
//		else if ([activeEvent.status integerValue] == ActiveStatus_past) {
//			activeCell.activeStateLab.text = @"Past";
//		}
//		NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
//		[formatter setDateStyle:NSDateFormatterMediumStyle];
//		[formatter setTimeStyle:NSDateFormatterShortStyle];
//		[formatter setDateFormat:@"YYYY-MM-dd HH:mm"];
//		NSTimeZone *timeZone = [NSTimeZone defaultTimeZone];
//		[formatter setTimeZone:timeZone];
//
//		NSDate *createTime = [formatter dateFromString:activeEvent.createTime];
//		NSInteger currMonth = [CalendarDateUtil getMonthWithDate:createTime];
//		NSInteger currDay = [CalendarDateUtil getDayWithDate:createTime];
//		activeCell.monthLab.text = [self monthStringWithInteger:currMonth];
//		activeCell.dayCountLab.text = [NSString stringWithFormat:@"%ld", (long)currDay];

//
//		if ([noticeMsg.type integerValue] == 10) { //活动更新,
//			activeCell.activeEvent = activeEvent;
//			NSArray *msgDicArr = [noticeMsg.message objectForKey:@"eventMsg"];
//			ActiveModifyMsgModel *activeModifyMsg = [ActiveModifyMsgModel new];
//			if (msgDicArr) {
//				for (NSDictionary *dic  in msgDicArr) {//这里可能以后要修改 ，现在数组中仅且仅有一条数据
//					[activeModifyMsg parseDictionary:dic];
//				}
//			}
//			[activeCell setActivechangInfo:activeModifyMsg.message];
//		}
//		else if ([noticeMsg.type integerValue] == 11) {  //活动新增或邀请成员
//			[activeCell setActivechangInfo:@"Invite you to participate in the activity"];
//		}
		return activeCell;
	}
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
	NoticesMsgModel *noticeMsg = [_noticeArr objectAtIndex:indexPath.row];
	if ([noticeMsg.type integerValue] == 10 || [noticeMsg.type integerValue] == 11) {
		NSDictionary *msgDic = [noticeMsg.message objectForKey:@"event"];
		ActiveBaseInfoMode *activeEvent = [ActiveBaseInfoMode new];
		if (msgDic) {
			[activeEvent parseDictionary:msgDic];
		}
		else {
			[MBProgressHUD showError:@"You already out of the activity"];
			return;
		}

		ActivedetailsViewController *activeDetailVC = [[ActivedetailsViewController alloc] init];
        activeDetailVC.hidesBottomBarWhenPushed =YES ;
		activeDetailVC.delegate = self;
		activeDetailVC.activeEventInfo = activeEvent;
		[self.navigationController pushViewController:activeDetailVC animated:YES];
    }else if([noticeMsg.type integerValue] == 1){//好友请求
        
        FriendsProfilesTableViewController * friendPVC = [[FriendsProfilesTableViewController alloc] init] ;
        friendPVC.noticesMsg = noticeMsg;
        friendPVC.hidesBottomBarWhenPushed = YES ;
        if ([noticeMsg.isRead intValue] == 0) {
            friendPVC.isAddSuccess = NO ;
        }else{
            friendPVC.isAddSuccess = YES ;
        }
        [self.navigationController pushViewController:friendPVC animated:YES];
    }else if([noticeMsg.type integerValue] == 2){//好友同意信息
        FriendsProfilesTableViewController * friendPVC = [[FriendsProfilesTableViewController alloc] init] ;
        friendPVC.noticesMsg = noticeMsg;
        friendPVC.hidesBottomBarWhenPushed = YES ;
        friendPVC.isAddSuccess = YES ;
        [self.navigationController pushViewController:friendPVC animated:YES];
    }
}

- (void)cancelActivedetailsViewController:(ActivedetailsViewController *)activeDetailsViewVontroller {
	[activeDetailsViewVontroller.navigationController popViewControllerAnimated:YES];
}

#pragma mark -用户同意或拒绝请求
//- (void)userApplyTableViewCell:(UserApplyTableViewCell *)selfCell paramNoticesMsgModel:(NoticesMsgModel *)noticesMsg isAcceptAndDeny:(BOOL)isAccept {
//	NSDictionary *paramDic = noticesMsg.message;
//	if (!isAccept) {//表示用户不同意添加对方为好友
//		ASIHTTPRequest *acceptFriendRequest = [t_Network httpPostValue:@{ @"fid":[paramDic objectForKey:@"fid"], @"fname":[paramDic objectForKey:@"fname"], @"mid":noticesMsg.Id, @"type":@(1) }.mutableCopy Url:anyTime_DisposeFriendRequest Delegate:nil Tag:anyTime_DisposeFriendRequest_tag];
//
//		__block ASIHTTPRequest *acceptRequest = acceptFriendRequest;
//		[acceptFriendRequest setCompletionBlock: ^{
//		    NSString *responseStr = [acceptRequest responseString];
//		    id obtTmp =  [responseStr objectFromJSONString];
//		    if ([obtTmp isKindOfClass:[NSDictionary class]]) {
//		        NSString *statusCode = [obtTmp objectForKey:@"statusCode"];
//		        if ([statusCode isEqualToString:@"1"]) {
//		            //selfCell.acceptBtn.hidden = YES;
//		           // selfCell.denyBtn.hidden   = YES;
//		            [MBProgressHUD showSuccess:@"Success"];
//				}
//			}
//		}];
//
//		[acceptFriendRequest setFailedBlock: ^{
//		    [MBProgressHUD showError:@"Network error"];
//		}];
//		[acceptFriendRequest startAsynchronous];
//
//		return;
//	}
//
//	FriendGroupShowViewController *fgsVC = [[FriendGroupShowViewController alloc] initWithNibName:@"FriendGroupShowViewController" bundle:nil];
//
//	fgsVC.fBlock = ^(FriendGroupShowViewController *selfViewController, FriendGroup *friendGroup) {
//		ASIHTTPRequest *acceptFriendRequest = [t_Network httpPostValue:@{ @"fid":[paramDic objectForKey:@"fid"], @"tid":friendGroup.Id, @"fname":[paramDic objectForKey:@"fname"], @"mid":noticesMsg.Id }.mutableCopy Url:anyTime_DisposeFriendRequest Delegate:nil Tag:anyTime_DisposeFriendRequest_tag];
//
//		__block ASIHTTPRequest *acceptRequest = acceptFriendRequest;
//		[acceptFriendRequest setCompletionBlock: ^{
//		    NSString *responseStr = [acceptRequest responseString];
//		    id obtTmp =  [responseStr objectFromJSONString];
//		    if ([obtTmp isKindOfClass:[NSDictionary class]]) {
//		        NSString *statusCode = [obtTmp objectForKey:@"statusCode"];
//		        if ([statusCode isEqualToString:@"1"]) {
//		          //  selfCell.acceptBtn.hidden = YES;
//		          //  selfCell.denyBtn.hidden   = YES;
//		            [selfViewController dismissPopupViewControllerWithanimationType:MJPopupViewAnimationFade];
//		            [MBProgressHUD showSuccess:@"Success"];
//				}
//			}
//		}];
//		[acceptFriendRequest setFailedBlock: ^{
//		    [MBProgressHUD showError:@"Network error"];
//		}];
//		[acceptFriendRequest startAsynchronous];
//	};
//	[self presentPopupViewController:fgsVC animationType:MJPopupViewAnimationFade];
//}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
	return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
	if (editingStyle == UITableViewCellEditingStyleDelete) {
		NoticesMsgModel *noticesMsgModel = [_noticeArr objectAtIndex:indexPath.row];
		ASIHTTPRequest *deleteMsgRequest = [t_Network httpPostValue:@{ @"msgId":[@[@{ @"id":noticesMsgModel.Id }] JSONString] }.mutableCopy Url:anyTime_DelMessage Delegate:nil Tag:anyTime_DelMessage_tag];

		__block ASIHTTPRequest *magRequest = deleteMsgRequest;
		[deleteMsgRequest setCompletionBlock: ^{
		    NSString *responseStr = [magRequest responseString];
		    id obtTmp =  [responseStr objectFromJSONString];
		    if ([obtTmp isKindOfClass:[NSDictionary class]]) {
		        NSString *statusCode = [obtTmp objectForKey:@"statusCode"];
		        if ([statusCode isEqualToString:@"1"]) {
		            [_noticeArr removeObjectAtIndex:indexPath.row];
		            [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObjects:indexPath, nil] withRowAnimation:UITableViewRowAnimationTop];
		            [MBProgressHUD showSuccess:@"Success"];
				}
		        else {
		            [MBProgressHUD showError:@"Delete failed"];
				}
			}
		}];
		[deleteMsgRequest setFailedBlock: ^{
		    [MBProgressHUD showError:@"Network error"];
		}];
		[deleteMsgRequest startAsynchronous];
	}
	else if (editingStyle == UITableViewCellEditingStyleInsert) {
	}
}

- (NSString *)monthStringWithInteger:(NSUInteger)month {
	NSString *monthStr;
	switch (month) {
		case 1:
			monthStr = @"JAN";
			break;

		case 2:
			monthStr = @"FEB";
			break;

		case 3:
			monthStr = @"MAR";
			break;

		case 4:
			monthStr = @"APR";
			break;

		case 5:
			monthStr = @"MAY";
			break;

		case 6:
			monthStr = @"JUN";
			break;

		case 7:
			monthStr = @"JUL";
			break;

		case 8:
			monthStr = @"AUG";
			break;

		case 9:
			monthStr = @"SEP";
			break;

		case 10:
			monthStr = @"OCT";
			break;

		case 11:
			monthStr = @"NOV";
			break;

		case 12:
			monthStr = @"DEC";
			break;

		default:
			break;
	}
	return monthStr;
}

/*
   #pragma mark - Navigation

   // In a storyboard-based application, you will often want to do a little preparation before navigation
   - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
   }
 */

@end
