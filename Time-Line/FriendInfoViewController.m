//
//  FriendInfoViewController.m
//  Go2
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
#import "FriendAddTableViewController.h"
#import "FriendsInfoTableViewController.h"
#import "UIImageView+WebCache.h"
#import "FriendInfoTableViewCell.h"
@interface FriendInfoViewController () <HeadViewDelegate, UITableViewDelegate, UITableViewDataSource, UIActionSheetDelegate, ASIHTTPRequestDelegate>
{
	
	NSMutableArray *_groupArr;
	NSMutableArray *_friendsArr;
}
@property (strong, nonatomic)  UITableView * tableView;
@property (strong, nonatomic)  UIButton    * addBtn;
@property (strong, nonatomic)  UIButton    * addFriendBtn ;

@end

@implementation FriendInfoViewController


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
    {
        self.title = @"Friends"; 
    }
    return self;
}

- (void)viewDidLoad {
	[super viewDidLoad];
    
	CGRect frame = CGRectMake(0, 0, kScreen_Width, kScreen_Height);
	self.view.frame = frame;
//    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Search" style:UIBarButtonItemStylePlain target:self action:@selector(searchFriendInfo)];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:self.addFriendBtn];
    
    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height - naviHigth) style:UITableViewStyleGrouped];
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    [self.view addSubview:self.tableView];
   
    [self.view addSubview:self.addBtn];
    [self setupRefresh];

	[self loadData];//加载数据

}

-(UIButton *)addFriendBtn{
    if (!_addFriendBtn) {
        _addFriendBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_addFriendBtn setFrame:CGRectMake(0, 0, 20 , 20)];
        [_addFriendBtn setTag:1];
        [_addFriendBtn setBackgroundImage:[UIImage imageNamed:@"Friends_Normal"] forState:UIControlStateNormal] ;
        [_addFriendBtn addTarget:self action:@selector(addFriendView) forControlEvents:UIControlEventTouchUpInside] ;
    }
    return _addFriendBtn ;
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


-(void)searchFriendInfo{

}

-(void)addFriendView{
    //暂时屏蔽
//    FriendAddTableViewController *fAddVc = [[FriendAddTableViewController alloc] init];
//    fAddVc.hidesBottomBarWhenPushed = YES ;
//    [self.navigationController pushViewController:fAddVc animated:YES];
    FriendSearchViewController * friendSearchVc = [[FriendSearchViewController alloc] init] ;
    friendSearchVc.hidesBottomBarWhenPushed = YES ;
    [self.navigationController pushViewController:friendSearchVc animated:YES] ;
}

#pragma mark -创建一个添加组或添加好友的按钮
-(UIButton *)addBtn{
    if (!_addBtn) {
        _addBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _addBtn.frame = CGRectMake(kScreen_Width - 65, kScreen_Height - 130, 45, 45);
        [_addBtn setBackgroundImage:[UIImage imageNamed:@"add_friend_default"] forState:UIControlStateNormal];
        [_addBtn setBackgroundImage:[UIImage imageNamed:@"add_friend_press"] forState:UIControlStateHighlighted];
        [_addBtn addTarget:self action:@selector(addNewFriendsAndGroups:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _addBtn ;
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
}

#pragma mark 加载数据
- (void)loadData {
    ASIHTTPRequest * _friendGroups = [t_Network httpGet:@{@"method":@"queryFriends"}.mutableCopy
                                                   Url:Go2_Friends
                                              Delegate:self
                                                   Tag:Go2_Friends_queryUser_Tag];
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
//		case anyTime_GetFTlist_tag: {
//			if ([groupObj isKindOfClass:[NSDictionary class]]) {
//				NSMutableArray *fgArray = [NSMutableArray array];
//
//				NSString *statusCode = [groupObj objectForKey:@"statusCode"];
//				if ([statusCode isEqualToString:@"1"]) {
//					NSArray *groupArr = [groupObj objectForKey:@"data"];
//					for (NSDictionary *dic in groupArr) {
//						FriendGroup *friendGroup = [FriendGroup friendGroupWithDict:dic];
//						[fgArray addObject:friendGroup];
//					}
//					//发送得到好友
//					ASIHTTPRequest *_friend = [t_Network httpGet:nil Url:anyTime_GetFriendList Delegate:self Tag:anyTime_GetFriendList_tag];
//					[_friend setDownloadCache:g_AppDelegate.anyTimeCache];
//					[_friend setCachePolicy:ASIFallbackToCacheIfLoadFailsCachePolicy | ASIAskServerIfModifiedWhenStaleCachePolicy];
//					[_friend setCacheStoragePolicy:ASICachePermanentlyCacheStoragePolicy];
//					[_friend startAsynchronous];
//				}
//				_groupArr = fgArray;
//			}
//			[self.tableView reloadData];
//		}
//		break;

		case Go2_Friends_queryUser_Tag: {
			if ([groupObj isKindOfClass:[NSDictionary class]]) {
				int statusCode = [[groupObj objectForKey:@"statusCode"] intValue];
				if ( statusCode == 1 ) {
					NSArray * friendArr = [groupObj objectForKey:@"datas"];
                    __block NSMutableArray *frArray = [NSMutableArray array];
                    [friendArr enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                        Friend * friend = [Friend modelWithDictionary:obj];
                        [frArray addObject:friend];
                    }];
                    _groupArr = frArray;
				}
				[self.tableView reloadData];
			}
		}break;

		default:
            NSLog(@"default execute");
			break;
	}
}

- (void)requestFailed:(ASIHTTPRequest *)request {
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // return _groupArr.count
	return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
//	FriendGroup *friendGroup = _groupArr[section];
//	NSInteger count = friendGroup.isOpened ? friendGroup.friends.count : 0;
	return _groupArr.count;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 0.01f;
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

	//FriendGroup *friendGroup = _groupArr[indexPath.section];
    Friend * friend =  _groupArr[indexPath.row] ;// friendGroup.friends[indexPath.row];

	NSString *_urlStr = [[NSString stringWithFormat:@"%@/%@", BaseGo2Url_IP, friend.thumbnail] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
	NSLog(@"%@", _urlStr);
	NSURL *url = [NSURL URLWithString:_urlStr];
    [cell.addFriendBtn setHidden:YES] ;//隐藏添加朋友按钮
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

//- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
//	HeadView * headView = [[HeadView alloc] initWithFrame:CGRectMake(0, 0, kScreen_Width, 40)];
//	headView.delegate = self;
//    headView.friendGroup = _groupArr[section];
//    
//    headView.headGroupNewFriendBlock=^(NSString * groupName){
//        __block FriendGroup *friendGroup = [[FriendGroup alloc] init];
//        friendGroup.name = groupName;
//        ASIHTTPRequest *addGroupsRequest = [t_Network httpPostValue:@{ @"name": friendGroup.name }.mutableCopy Url:anyTime_AddFTeam Delegate:nil Tag:anyTime_AddFTeam_tag];
//        __block ASIHTTPRequest *groupsRequest = addGroupsRequest;
//        [addGroupsRequest setCompletionBlock: ^{//请求成功
//            NSString *responseStr = [groupsRequest responseString];
//            NSLog(@"%@", responseStr);
//            id objGroup = [responseStr objectFromJSONString];
//            if ([objGroup isKindOfClass:[NSDictionary class]]) {
//                NSString *statusCode = [objGroup objectForKey:@"statusCode"];
//                if ([statusCode isEqualToString:@"1"]) {
//                    NSDictionary *tmpDic = [objGroup objectForKey:@"data"];
//                    friendGroup = [friendGroup initWithDict:tmpDic];
//                }
//            }
//        }];
//
//        [addGroupsRequest setFailedBlock: ^{//请求失败
//            NSLog(@"%@", [groupsRequest responseString]);
//        }];
//        
//        [addGroupsRequest startAsynchronous];
//        
//        [_groupArr addObject:friendGroup];
//        [self.tableView reloadData];
//    };
//	return headView;
//}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	[tableView deselectRowAtIndexPath:indexPath animated:YES];

	FriendsInfoTableViewController *fiVC = [[FriendsInfoTableViewController alloc] initWithNibName:@"FriendsInfoTableViewController" bundle:nil];
    fiVC.hidesBottomBarWhenPushed = YES ;
//	FriendGroup *friendGroup = _groupArr[indexPath.section];
//	Friend *friend = friendGroup.friends[indexPath.row];
    
    Friend * friend =  _groupArr[indexPath.row];
	fiVC.friendInfo = friend ;
	fiVC.friendDeleteBlock = ^(FriendsInfoTableViewController *selfTabeViewController) {
        
		ASIHTTPRequest *acceptFriendRequest = [t_Network httpPostValue:@{@"method":@"delete",@"fid":friend.Id}.mutableCopy
                                                                   Url:Go2_Friends
                                                              Delegate:nil
                                                                   Tag:Go2_Friends_delete_Tag];
		__block ASIHTTPRequest *acceptRequest = acceptFriendRequest;
		[acceptFriendRequest setCompletionBlock: ^{
		    NSString * responseStr = [acceptRequest responseString];
		    id obtTmp =  [responseStr objectFromJSONString];
		    if ([obtTmp isKindOfClass:[NSDictionary class]]) {
		        int statusCode = [[obtTmp objectForKey:@"statusCode"] intValue];
		        if ( statusCode == 1 ) {
		            [MBProgressHUD showSuccess:@"Delete success"];
		            [_groupArr removeObject:friend];  //删除数据；
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
}

@end
