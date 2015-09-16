//
//  NoticesViewController.m
//  Go2
//
//  Created by IF on 14/12/5.
//  Copyright (c) 2014年 zhilifang. All rights reserved.
//

#import "NoticesViewController.h"
#import "MJRefresh.h"
#import "ActiveDestinationViewController.h"
#import "NotiveMsgPageBaseMode.h"
#import "ActiveModifyMsgModel.h"
#import "NoticesMsgModel.h"
#import "CalendarDateUtil.h"
#import "UIImageView+WebCache.h"
#import "FriendGroupShowViewController.h"
#import "UIViewController+MJPopupViewController.h"
#import "ActiveInvitationsNotifictionTableViewCell.h"
#import "FriendsProfilesTableViewController.h"

#import "UIColor+HexString.h"
#import "NoticesMsgManagedModel.h"


@interface NoticesViewController () <UITableViewDataSource, UITableViewDelegate> {
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
    self.tableView.separatorInset = UIEdgeInsetsMake(0, 60, 0, 0);
    //self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;//去掉分割线
	self.view =self.tableView;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(fetchFriendOptionInfo:) name:FRIENDS_OPTIONSNOTIFICTION object:nil] ;
    
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

//- (void)viewWillAppear:(BOOL)animated {
//    [super viewWillAppear:animated];
//    
//    self.navigationController.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName:[UIColor blackColor]};
//    [self.navigationController.navigationBar setBarTintColor:[UIColor whiteColor]];
//}

- (void)loadUserRequestInfo:(NSInteger)num {
	ASIHTTPRequest *msgRequest = [t_Network httpGet:@{ @"pageNum":@(num) }.mutableCopy Url:Go2_queryInviteesInfo Delegate:nil Tag:Go2_queryInviteesInfo_Tag];
	[msgRequest setDownloadCache:g_AppDelegate.anyTimeCache];
	[msgRequest setCachePolicy:ASIFallbackToCacheIfLoadFailsCachePolicy | ASIAskServerIfModifiedWhenStaleCachePolicy];
	[msgRequest setCacheStoragePolicy:ASICachePermanentlyCacheStoragePolicy];
	__block ASIHTTPRequest *msgReq = msgRequest;
	[msgRequest setCompletionBlock: ^{
	    NSString *responseStr = [msgReq responseString];
	    id objTmp =  [responseStr objectFromJSONString];
	    if ([objTmp isKindOfClass:[NSDictionary class]]) {
	        NSDictionary *objDic = (NSDictionary *)objTmp;
	        int statusCode = [[objDic objectForKey:@"statusCode"] intValue];
	        if ( statusCode  == 1 ) {
	            id dataDic = [objDic objectForKey:@"data"];
	            if ([dataDic isKindOfClass:[NSDictionary class]]) {
                    NotiveMsgPageBaseMode *notiveMsgPage = [NotiveMsgPageBaseMode modelWithDictionary:dataDic];
                    
                    [notiveMsgPage.beanList enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                          NoticesMsgModel *noticeMsg = [NoticesMsgModel modelWithDictionary:obj];
                          if ([noticeMsg.type integerValue] != 4) {//是表示对方删除我得信息---排除在外......
                              [_noticeArr addObject:noticeMsg];
                           }
                     }];
				}
	            [_tableView reloadData];  //刷新table
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
	return 0.1f;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
	return 0.1f;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	
    static NSString *activeCellID = @"activeMsgCellId";
    
    ActiveInvitationsNotifictionTableViewCell *activeCell = [tableView dequeueReusableCellWithIdentifier:activeCellID];
    if (!activeCell) {
        activeCell = (ActiveInvitationsNotifictionTableViewCell *)[[[NSBundle mainBundle] loadNibNamed:@"ActiveInvitationsNotifictionTableViewCell" owner:self options:nil] firstObject];
        [activeCell.pointLab setHidden:YES];
    }
    if (_noticeArr.count > 0) {
        NoticesMsgModel *noticeMsg = [_noticeArr objectAtIndex:indexPath.row];
        if ([noticeMsg.type integerValue] < 10) {
            if ([noticeMsg.type integerValue] == 1) { //好友请求
                NSDictionary *msgDic =  noticeMsg.message;
                if (msgDic) {
                    NSString *tmpUrl = [msgDic objectForKey:@"imgBig"] ;
                    NSString *_urlStr = [[NSString stringWithFormat:@"%@/%@", BaseGo2Url_IP, tmpUrl] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
                    NSLog(@"%@", _urlStr);
                    NSURL *url = [NSURL URLWithString:_urlStr];
                    [activeCell.showImg sd_setImageWithURL:url placeholderImage:[UIImage imageNamed:@"smile_1"] completed:nil];
                    [activeCell.titleAndName setTextColor: defineBlueColor];
                    [activeCell.titleAndName setText:[msgDic objectForKey:@"fname"]];
                    [activeCell.note setText:[msgDic objectForKey:@"msg"]]  ;
                    if([noticeMsg.isRead intValue] == 1 ){
                        // [activeCell.pointLab setHidden:YES]; 暂时
                    }else{
                        [activeCell.pointLab setHidden:NO];
                        [activeCell.pointLab setBackgroundColor:defineBlueColor];
                    }
                    
                }
                return activeCell ;
            }else if ([noticeMsg.type integerValue] == 2 ||  [noticeMsg.type integerValue] == 3) { //对方同意 信息  //对方拒绝添加 你为
                NSDictionary *msgDic =  noticeMsg.message;
                if (msgDic) {
                    NSString *tmpUrl = [msgDic objectForKey:@"imgBig"];
                    NSString *_urlStr = [[NSString stringWithFormat:@"%@/%@", BaseGo2Url_IP, tmpUrl] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
                    NSLog(@"%@", _urlStr);
                    NSURL *url = [NSURL URLWithString:_urlStr];
                    [activeCell.showImg sd_setImageWithURL:url placeholderImage:[UIImage imageNamed:@"smile_1"] completed:nil];
                    [activeCell.titleAndName setTextColor: defineBlueColor];
                    [activeCell.titleAndName setText:[msgDic objectForKey:@"fname"]];
                    [activeCell.note setText:[msgDic objectForKey:@"msg"]]  ;
                    if([noticeMsg.isRead intValue] == 1 ){
                        [activeCell.pointLab setHidden:YES];
                    }else{
                        [activeCell.pointLab setHidden:NO];
                        [activeCell.pointLab setBackgroundColor:defineBlueColor];
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
        }else {
            
            if ([noticeMsg.message isKindOfClass:[NSDictionary class]]) {
                NSDictionary *msgDic = [noticeMsg.message objectForKey:@"event"];
                ActiveEventModel *activeEvent = [[ActiveEventModel alloc] initWithDictionary:msgDic];
                //显示活动图片 ---网络下载的图片
//                if (activeEvent.imgUrl && ![@"" isEqualToString:activeEvent.imgUrl]) {
//                    activeCell.showShotTitle.hidden = YES ;
//                    NSString *_urlStr = [[NSString stringWithFormat:@"%@/%@", BASEURL_IP, activeEvent.imgUrl] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
//                    NSLog(@"%@", _urlStr);
//                    NSURL *url = [NSURL URLWithString:_urlStr];
//                    [activeCell.showImg sd_setImageWithURL:url placeholderImage:[UIImage imageNamed:@"go2_grey"]];
//                }else{
//                    activeCell.showShotTitle.hidden = NO ;
//                    [activeCell.showImg setBackgroundColor:[UIColor colorWithHexString:@"2e9ef1"]];
//                    activeCell.showShotTitle.text = [[activeEvent.title substringToIndex:1] uppercaseString];
//                }
                [activeCell.showImg setImage:[UIImage imageNamed:@"invitations_social_event"]];
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
    }
    return activeCell ;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
	NoticesMsgModel *noticeMsg = [_noticeArr objectAtIndex:indexPath.row];
	if ([noticeMsg.type integerValue] == 10 || [noticeMsg.type integerValue] == 11) {
		NSDictionary *msgDic = [noticeMsg.message objectForKey:@"event"];
        if (!msgDic) {
            [MBProgressHUD showError:@"You already out of the activity"];
            return;
        }
		ActiveEventModel *activeEvent = [[ActiveEventModel alloc] initWithDictionary:msgDic];
		
        UIStoryboard *storyboarb = [UIStoryboard storyboardWithName:@"ActiveDestination" bundle:[NSBundle mainBundle]];
        ActiveDestinationViewController * activeDesc =( ActiveDestinationViewController *)  [storyboarb instantiateViewControllerWithIdentifier:@"ActiveDescriptionId"];
        activeDesc.activeEventInfo = activeEvent;
        activeDesc.hidesBottomBarWhenPushed = YES ;
        [self.navigationController pushViewController:activeDesc animated:YES];
        
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


-(void)fetchFriendOptionInfo:(NSNotification *) notification {
    NoticesMsgManagedModel * notiv = [notification.userInfo objectForKey:FRIENDS_OPTIONSINFO];
    NoticesMsgModel * noticesMsg = [NoticesMsgModel new];
    noticesMsg.Id          = notiv.nId ;
    noticesMsg.isRead      = notiv.isRead ;
    noticesMsg.isReceive   = notiv.isReceive ;
    noticesMsg.message     = [self dictionaryWithJsonString:notiv.message] ;
    noticesMsg.time        = notiv.time ;
    noticesMsg.type        = notiv.type ;
    [_noticeArr insertObject:noticesMsg atIndex:0];
    [self.tableView reloadData] ;
}

/*!
 * @brief 把格式化的JSON格式的字符串转换成字典
 * @param jsonString JSON格式的字符串
 * @return 返回字典
 */
- (NSDictionary *)dictionaryWithJsonString:(NSString *)jsonString {
    if (jsonString == nil) {
        return nil;
    }
    
    NSData *jsonData = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
    NSError *err;
    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:jsonData
                                                        options:NSJSONReadingMutableContainers
                                                          error:&err];
    if(err) {
        NSLog(@"json解析失败：%@",err);
        return nil;
    }
    return dic;
}


@end
