//
//  SetFriendViewController.m
//  Time-Line
//
//  Created by IF on 14/12/18.
//  Copyright (c) 2014年 zhilifang. All rights reserved.
//

#import "SetFriendViewController.h"
#import "FriendGroup.h"
#import "Friend.h"
#import "HeadView.h"
#import "FriendSearchViewController.h"
#import "UIImageView+WebCache.h"
#import "SetFriendTableViewCell.h"
@interface SetFriendViewController () <HeadViewDelegate, UITableViewDelegate, UITableViewDataSource, UIActionSheetDelegate, ASIHTTPRequestDelegate>
{
	UIButton *addBtn;
	NSMutableArray *_groupArr;
	NSMutableArray *_friendsArr;

	NSMutableArray *_selectFriendArr; //选择的好友

	NSMutableDictionary *_selectIndexPathDic; //用户选择的indexPath

	BOOL isSelect;
	NSInteger selectInviteesCount;

	UILabel *titlelabel;
}
@property (strong, nonatomic)  UITableView *tableView;
@end

@implementation SetFriendViewController

@synthesize  delegate;

- (void)viewDidLoad {
	[super viewDidLoad];
	_selectFriendArr = [NSMutableArray arrayWithCapacity:0];
	_selectIndexPathDic = [NSMutableDictionary dictionaryWithCapacity:0];

	CGRect frame = CGRectMake(5, 35, kScreen_Width - 10, kScreen_Height - 70);
	self.view.frame = frame;

	UIView *rview = [[UIView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, naviHigth)];
	rview.backgroundColor = blueColor;

	//   导航： 右边的按钮
	UIButton *rightBtn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
	rightBtn.frame = CGRectMake(frame.size.width - 40, 20, 30, 25);
	[rightBtn setBackgroundImage:[UIImage imageNamed:@"Icon_Tick.png"] forState:UIControlStateNormal];
	[rightBtn addTarget:self action:@selector(saveSelectFriend) forControlEvents:UIControlEventTouchUpInside];
	[rview addSubview:rightBtn];

//     UIButton *leftBtn = [UIButton buttonWithType:UIButtonTypeCustom];
//    [leftBtn setImage:[UIImage imageNamed:@"Icon_Cross.png"] forState:UIControlStateNormal];
//    [leftBtn setFrame:CGRectMake(0, 2, 25, 25)];
//    [leftBtn addTarget:self action:@selector(skipNotificationView) forControlEvents:UIControlEventTouchUpInside];
//    [rview addSubview:leftBtn];
	//  中间的标题
	titlelabel = [[UILabel alloc]initWithFrame:CGRectMake(60, 15, 180, 30)];
	titlelabel.textAlignment = NSTextAlignmentCenter;
	titlelabel.text = [NSString stringWithFormat:@"%i Invitees", selectInviteesCount];
	titlelabel.font = [UIFont fontWithName:@"Helvetica Neue" size:30.0];
	titlelabel.textColor = [UIColor whiteColor];
	[rview addSubview:titlelabel];


	[self loadData];

	self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, naviHigth, frame.size.width, frame.size.height - naviHigth) style:UITableViewStyleGrouped];
	self.tableView.dataSource = self;
	self.tableView.delegate = self;
	[self.view addSubview:self.tableView];
	[self.view addSubview:rview];
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

#pragma mark - 保存数据关闭弹出窗口
- (void)saveSelectFriend {
	if (delegate && [delegate respondsToSelector:@selector(saveButtonClicked:didSelectFriend:)]) {
		[delegate saveButtonClicked:self didSelectFriend:_selectFriendArr];
	}
}

#pragma mark - asihttprequest 的代理
- (void)requestFinished:(ASIHTTPRequest *)request {
	NSString *responeStr = [request responseString];
	NSLog(@"%@", [request responseString]);
	id groupObj = [responeStr objectFromJSONString];
	switch (request.tag) {
		case anyTime_GetFTlist_tag: {
			NSMutableArray *fgArray = [NSMutableArray array];
			if ([groupObj isKindOfClass:[NSDictionary class]]) {
				NSString *statusCode = [groupObj objectForKey:@"statusCode"];
				if ([statusCode isEqualToString:@"1"]) {
					NSArray *groupArr = [groupObj objectForKey:@"data"];
					for (NSDictionary *dic in groupArr) {
						FriendGroup *friendGroup = [FriendGroup friendGroupWithDict:dic];
						[fgArray addObject:friendGroup];
					}
					_groupArr = fgArray;

					ASIHTTPRequest *_friend = [t_Network httpGet:nil Url:anyTime_GetFriendList Delegate:self Tag:anyTime_GetFriendList_tag];
					[_friend setDownloadCache:g_AppDelegate.anyTimeCache];
					[_friend setCachePolicy:ASIFallbackToCacheIfLoadFailsCachePolicy | ASIAskServerIfModifiedWhenStaleCachePolicy];
					[_friend setCacheStoragePolicy:ASICachePermanentlyCacheStoragePolicy];
					[_friend startAsynchronous];
					[_tableView reloadData];
				}
			}
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
						[_tableView reloadData];
					}
				}
			}
		}
		break;

		default:
			break;
	}
}

- (void)requestFailed:(ASIHTTPRequest *)request {
	NSError *error = [request error];
	if (error) {
		[MBProgressHUD showError:@"Newwork error"];
	}
}


#pragma mark -UIActionSheet的代理
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex; {
	if (buttonIndex == 0) {//add friends
		FriendSearchViewController *searchVc = [[FriendSearchViewController alloc] init];
		self.modalPresentationStyle = UIModalPresentationCurrentContext;
		[self presentViewController:searchVc animated:NO completion:nil];
	}
	else if (buttonIndex == 1) {//add groups
		
	}
	addBtn.hidden = NO;
}


#pragma mark -UIAlertView的代理
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
	if (buttonIndex == 1) {
		__block FriendGroup *friendGroup = [[FriendGroup alloc] init];
		friendGroup.name = [alertView textFieldAtIndex:0].text;

		ASIHTTPRequest *addGroupsRequest = [t_Network httpPostValue:@{ @"name": friendGroup.name }.mutableCopy Url:anyTime_AddFTeam Delegate:nil Tag:anyTime_AddFTeam_tag];
		__block ASIHTTPRequest *groupsRequest  = addGroupsRequest;
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
	static NSString *cellIdentifier = @"setFriendcell";

	SetFriendTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
	if (!cell) {
		cell = (SetFriendTableViewCell *)[[[NSBundle mainBundle] loadNibNamed:@"SetFriendTableViewCell" owner:self options:nil] lastObject];
        cell.accessoryView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"selecte_friend_tick"]];
		//  cell.selectionStyle = UITableViewCellSelectionStyleNone;
	}
	FriendGroup *friendGroup = _groupArr[indexPath.section];
	Friend *friend = friendGroup.friends[indexPath.row];

	NSString *_urlStr = [[NSString stringWithFormat:@"%@/%@", BASEURL_IP, friend.imgBig] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
	NSLog(@"%@", _urlStr);
	NSURL *url = [NSURL URLWithString:_urlStr];
	[cell.userHead sd_setImageWithURL:url placeholderImage:[UIImage imageNamed:@"smile_1"] completed:nil];

	cell.textLabel.textColor = friend.isVip ? [UIColor redColor] : [UIColor blackColor];
	cell.nickName.text = friend.nickname;
	cell.userNote.text = friend.alias;
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
	NSString *indexPathStr = [NSString stringWithFormat:@"%i%i", indexPath.section, indexPath.row];
	SetFriendTableViewCell *stv = (SetFriendTableViewCell *)[tableView cellForRowAtIndexPath:indexPath];
//	if (![_selectIndexPathDic objectForKey:indexPathStr]) {
//		stv.selectStyleImg.image = [UIImage imageNamed:@"selecte_friend_tick"];
//		FriendGroup *friendGroup = _groupArr[indexPath.section];
//		Friend *friend = friendGroup.friends[indexPath.row];
//		[_selectFriendArr addObject:friend];
//		[_selectIndexPathDic setObject:indexPath forKey:indexPathStr];
//
//		selectInviteesCount++;
//	}
//	else {
//		stv.selectStyleImg.image = [UIImage imageNamed:@"selecte_friend_cycle"];
//		FriendGroup *friendGroup = _groupArr[indexPath.section];
//		Friend *friend = friendGroup.friends[indexPath.row];
//		[_selectFriendArr removeObject:friend];
//		[_selectIndexPathDic removeObjectForKey:indexPathStr];
//		selectInviteesCount--;
//	}
	titlelabel.text = [NSString stringWithFormat:@"%i Invitees", selectInviteesCount];
}

- (void)clickHeadView {
	[self.tableView reloadData];
}

- (void)didReceiveMemoryWarning {
	[super didReceiveMemoryWarning];
	// Dispose of any resources that can be recreated.
}

@end
