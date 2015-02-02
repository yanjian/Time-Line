//
//  FriendInfoViewController.m
//  Time-Line
//
//  Created by IF on 14/12/29.
//  Copyright (c) 2014年 zhilifang. All rights reserved.
//

#import "FriendInfoViewController.h"
#import "MJRefresh.h"
#import "FriendGroup.h"
#import "Friend.h"
#import "HeadView.h"
#import "FriendSearchViewController.h"
#import "FriendsInfoTableViewController.h"
#import "UIImageView+WebCache.h"
#import "FriendInfoTableViewCell.h"
@interface FriendInfoViewController () <HeadViewDelegate, UITableViewDelegate, UITableViewDataSource, UIActionSheetDelegate, ASIHTTPRequestDelegate>
{
	UIButton *addBtn;
	NSMutableArray *_groupArr;
	NSMutableArray *_friendsArr;
}
@property (strong, nonatomic)  UITableView *tableView;

@end

@implementation FriendInfoViewController

- (void)viewDidLoad {
	[super viewDidLoad];
	CGRect frame = CGRectMake(0, 0, kScreen_Width, kScreen_Height);
	self.view.frame = frame;

	[self loadData];//加载数据

	self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height - naviHigth) style:UITableViewStyleGrouped];
	self.tableView.dataSource = self;
	self.tableView.delegate = self;
	[self.view addSubview:self.tableView];
	[self setupRefresh];
	[self createAddFriendBtn];
}

/**
 *  集成刷新控件
 */
- (void)setupRefresh {
	// 1.下拉刷新(进入刷新状态就会调用self的headerRereshing)
	//    [self.tableView addHeaderWithTarget:self action:@selector(headerRereshing)];
	// dateKey用于存储刷新时间，可以保证不同界面拥有不同的刷新时间
	[self.tableView addHeaderWithTarget:self action:@selector(headerRereshing) dateKey:@"friendView"];
}

#pragma mark 开始进入刷新状态
- (void)headerRereshing {
	[self loadData];//刷新数据
	[self.tableView headerEndRefreshing];
}

- (void)footerRereshing {
	[self.tableView footerEndRefreshing];
}

#pragma mark -创建一个添加组或添加好友的按钮
- (void)createAddFriendBtn {
	addBtn = [UIButton buttonWithType:UIButtonTypeCustom];
	addBtn.frame = CGRectMake(kScreen_Width - 65, kScreen_Height - 130, 45, 45);
	[addBtn setBackgroundImage:[UIImage imageNamed:@"add_friend_default"] forState:UIControlStateNormal];
	[addBtn setBackgroundImage:[UIImage imageNamed:@"add_friend_press"] forState:UIControlStateHighlighted];
	[addBtn addTarget:self action:@selector(addNewFriendsAndGroups:) forControlEvents:UIControlEventTouchUpInside];
	[self.view addSubview:addBtn];
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
}

#pragma mark 加载数据
- (void)loadData {
	ASIHTTPRequest *_friendGroups = [t_Network httpGet:nil Url:anyTime_GetFTlist Delegate:self Tag:anyTime_GetFTlist_tag];
	[_friendGroups setDownloadCache:g_AppDelegate.anyTimeCache];
	[_friendGroups setCachePolicy:ASIFallbackToCacheIfLoadFailsCachePolicy | ASIAskServerIfModifiedWhenStaleCachePolicy];
	[_friendGroups setCacheStoragePolicy:ASICachePermanentlyCacheStoragePolicy];
	[_friendGroups startAsynchronous];
}

- (void)requestFinished:(ASIHTTPRequest *)request {
	NSString *responeStr = [request responseString];
	NSLog(@"%@", [request responseString]);
	id groupObj = [responeStr objectFromJSONString];
	switch (request.tag) {
		case anyTime_GetFTlist_tag: {
			if ([groupObj isKindOfClass:[NSDictionary class]]) {
				NSMutableArray *fgArray = [NSMutableArray array];

				NSString *statusCode = [groupObj objectForKey:@"statusCode"];
				if ([statusCode isEqualToString:@"1"]) {
					NSArray *groupArr = [groupObj objectForKey:@"data"];
					for (NSDictionary *dic in groupArr) {
						FriendGroup *friendGroup = [FriendGroup friendGroupWithDict:dic];
						[fgArray addObject:friendGroup];
					}
					//发送得到好友
					ASIHTTPRequest *_friend = [t_Network httpGet:nil Url:anyTime_GetFriendList Delegate:self Tag:anyTime_GetFriendList_tag];
					[_friend setDownloadCache:g_AppDelegate.anyTimeCache];
					[_friend setCachePolicy:ASIFallbackToCacheIfLoadFailsCachePolicy | ASIAskServerIfModifiedWhenStaleCachePolicy];
					[_friend setCacheStoragePolicy:ASICachePermanentlyCacheStoragePolicy];
					[_friend startAsynchronous];
				}
				_groupArr = fgArray;
			}
			[self.tableView reloadData];
		}
		break;

		case anyTime_GetFriendList_tag: {
			if ([groupObj isKindOfClass:[NSDictionary class]]) {
				NSString *statusCode = [groupObj objectForKey:@"statusCode"];
				if ([statusCode isEqualToString:@"1"]) {
					NSDictionary *friendDic = [groupObj objectForKey:@"data"];
					for (FriendGroup *fg in _groupArr) {
						NSMutableArray *frArray = [NSMutableArray array];
						NSArray *frArr = [friendDic objectForKey:[NSString stringWithFormat:@"%@", fg.Id]];
						for (NSDictionary *dic in frArr) {
							Friend *friend = [Friend friendWithDict:dic];
							[frArray addObject:friend];
						}
						fg.friends = frArray;
					}
				}
				[self.tableView reloadData];
			}
		}
		break;

		default:
			break;
	}
}

- (void)requestFailed:(ASIHTTPRequest *)request {
}

/**
 *  添加组或朋友按钮的单击事件
 *
 *  @param sender
 */
- (void)addNewFriendsAndGroups:(UIButton *)sender {
	[UIView animateWithDuration:0.2f animations:nil completion: ^(BOOL finished) {
	    addBtn.hidden = YES;
	}];

	UIActionSheet *fgSheet = [[UIActionSheet alloc] initWithTitle:@"add Friends Or Groups" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Add Friends", @"Add Groups", nil];
	[fgSheet showInView:self.view];
}

#pragma mark -UIActionSheet的代理
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex; {
	if (buttonIndex == 0) {//add friends
		FriendSearchViewController *searchVc = [[FriendSearchViewController alloc] init];
		self.modalPresentationStyle = UIModalPresentationCurrentContext;
		[self presentViewController:searchVc animated:YES completion:nil];
	}
	else if (buttonIndex == 1) {//add groups
		UIAlertView *gAlertView = [[UIAlertView alloc] initWithTitle:@"Add Groups" message:nil delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Confirm", nil];
		gAlertView.alertViewStyle = UIAlertViewStylePlainTextInput;
		[gAlertView show];
	}
	addBtn.hidden = NO;
}


#pragma mark -UIAlertView的代理
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
	if (buttonIndex == 1) {
		__block FriendGroup *friendGroup = [[FriendGroup alloc] init];
		friendGroup.name = [alertView textFieldAtIndex:0].text;

		ASIHTTPRequest *addGroupsRequest = [t_Network httpPostValue:@{ @"name": friendGroup.name }.mutableCopy Url:anyTime_AddFTeam Delegate:nil Tag:anyTime_AddFTeam_tag];
		__block ASIHTTPRequest *groupsRequest = addGroupsRequest;
		[addGroupsRequest setCompletionBlock: ^{//请求成功
		    NSString *responseStr = [groupsRequest responseString];
		    NSLog(@"%@", responseStr);
		    id objGroup = [responseStr objectFromJSONString];
		    if ([objGroup isKindOfClass:[NSDictionary class]]) {
		        NSString *statusCode = [objGroup objectForKey:@"statusCode"];
		        if ([statusCode isEqualToString:@"1"]) {
		            NSDictionary *tmpDic = [objGroup objectForKey:@"data"];
		            friendGroup = [friendGroup initWithDict:tmpDic];
				}
			}
		}];

		[addGroupsRequest setFailedBlock: ^{//请求失败
		    NSLog(@"%@", [groupsRequest responseString]);
		}];

		[addGroupsRequest startAsynchronous];

		[_groupArr addObject:friendGroup];
		[self.tableView reloadData];
	}
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return _groupArr.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	FriendGroup *friendGroup = _groupArr[section];
	NSInteger count = friendGroup.isOpened ? friendGroup.friends.count : 0;
	return count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
	return 40.f;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
	return 0.5f;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	return 55.f;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	static NSString *cellIdentifier = @"cellFriendId";

	FriendInfoTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
	if (!cell) {
		cell = (FriendInfoTableViewCell *)[[[NSBundle mainBundle] loadNibNamed:@"FriendInfoTableViewCell" owner:self options:nil] lastObject];
		//  cell.selectionStyle = UITableViewCellSelectionStyleNone;
	}

	FriendGroup *friendGroup = _groupArr[indexPath.section];
	Friend *friend = friendGroup.friends[indexPath.row];

	NSString *_urlStr = [[NSString stringWithFormat:@"%@/%@", BASEURL_IP, friend.imgBig] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
	NSLog(@"%@", _urlStr);
	NSURL *url = [NSURL URLWithString:_urlStr];
	[cell.userHead sd_setImageWithURL:url placeholderImage:[UIImage imageNamed:@"smile_1"] completed:nil];

	cell.textLabel.textColor = friend.isVip ? [UIColor redColor] : [UIColor blackColor];
	if (friend.alias && ![@"" isEqualToString:friend.alias]) { //如果有别名就显示别名
		cell.nickName.text = friend.alias;
	}
	else {
		if (friend.nickname && ![@"" isEqualToString:friend.nickname]) {
			cell.nickName.text = friend.nickname;
		}
		else {
			cell.nickName.text = friend.username;
		}
	}

	// cell.userNote.text = friend.alias;
	return cell;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
	HeadView *headView = [[HeadView alloc] initWithFrame:CGRectMake(0, 0, kScreen_Width, 40)];
	headView.delegate = self;
	headView.friendGroup = _groupArr[section];

	return headView;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	[tableView deselectRowAtIndexPath:indexPath animated:YES];

	FriendsInfoTableViewController *fiVC = [[FriendsInfoTableViewController alloc] initWithNibName:@"FriendsInfoTableViewController" bundle:nil];
	FriendGroup *friendGroup = _groupArr[indexPath.section];
	Friend *friend = friendGroup.friends[indexPath.row];
	fiVC.friendInfo = friend;

	fiVC.friendDeleteBlock = ^(FriendsInfoTableViewController *selfTabeViewController) {
		ASIHTTPRequest *acceptFriendRequest = [t_Network httpPostValue:@{ @"fid":friend.fid, @"fname":friend.username }.mutableCopy Url:anyTime_DeleteFriend Delegate:nil Tag:anyTime_DeleteFriend_tag];
		__block ASIHTTPRequest *acceptRequest = acceptFriendRequest;
		[acceptFriendRequest setCompletionBlock: ^{
		    NSString *responseStr = [acceptRequest responseString];
		    id obtTmp =  [responseStr objectFromJSONString];
		    if ([obtTmp isKindOfClass:[NSDictionary class]]) {
		        NSString *statusCode = [obtTmp objectForKey:@"statusCode"];
		        if ([statusCode isEqualToString:@"1"]) {
		            [MBProgressHUD showSuccess:@"Delete success"];
		            [friendGroup.friends removeObject:friend];  //删除数据；
		            [self.tableView reloadData];
		            [selfTabeViewController.navigationController popViewControllerAnimated:YES];
				}
			}
		}];

		[acceptFriendRequest setFailedBlock: ^{
		    [MBProgressHUD showError:@"Network error"];
		}];
		[acceptFriendRequest startAsynchronous];
	};
	[self.navigationController pushViewController:fiVC animated:YES];
}

- (void)clickHeadView {
	[self.tableView reloadData];
}

- (void)didReceiveMemoryWarning {
	[super didReceiveMemoryWarning];
	// Dispose of any resources that can be recreated.
}

@end
