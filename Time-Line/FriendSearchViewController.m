//
//  FriendSearchViewController.m
//  Go2
//
//  Created by IF on 14/12/9.
//  Copyright (c) 2014年 zhilifang. All rights reserved.
//

#import "FriendSearchViewController.h"
#import "FriendsProfilesTableViewController.h"
#import "FriendInfoTableViewCell.h"
#import "Friend.h"
#import "UIImageView+WebCache.h"
#import "LPPopupListView.h"
@interface FriendSearchViewController () <UITableViewDelegate, UITableViewDataSource,UISearchBarDelegate, LPPopupListViewDelegate> {
	NSMutableArray *searchFriendArr;
	NSIndexPath *selectIndexPath;//用户选择的行数
}
@property (strong, nonatomic) IBOutlet UITextField *searchText;
@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) IBOutlet UIButton *searchBtn;
@end

@implementation FriendSearchViewController

- (void)viewDidLoad {
	[super viewDidLoad];
	self.view.frame = CGRectMake(0, 0, kScreen_Width, kScreen_Height);
    self.title = @"Add a friend" ;
    UIButton *leftBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [leftBtn setFrame:CGRectMake(0, 2, 22, 14)];
    [leftBtn setBackgroundImage:[UIImage imageNamed:@"go2_arrow_left"] forState:UIControlStateNormal] ;
    [leftBtn addTarget:self action:@selector(backToAddFriendsView) forControlEvents:UIControlEventTouchUpInside] ;
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:leftBtn] ;
    self.navigationController.interactivePopGestureRecognizer.delegate = (id)self;

    [self createTableHead];
}

#pragma mark -创建搜索视图
- (void)createTableHead {
	
    UISearchBar * searchBar = [[UISearchBar alloc] init];
    searchBar.frame = CGRectMake(0, 0, self.tableView.bounds.size.width, 0);
    searchBar.delegate = self;
    searchBar.placeholder = @"Account name /Email";
    searchBar.backgroundColor = [UIColor clearColor];
    searchBar.translucent = YES ;
//    [[[[searchBar.subviews objectAtIndex : 0 ] subviews ] objectAtIndex : 0 ] removeFromSuperview ];
//    
//    [searchBar setBackgroundColor :[ UIColor clearColor ]];
    searchBar.tintColor = [UIColor whiteColor];
    [searchBar sizeToFit];
    self.tableView.tableHeaderView = searchBar ;
    self.tableView.separatorInset  = UIEdgeInsetsMake(0, 60, 0, 0);
    self.tableView.tableFooterView = [UIView new];
}

- (void)didReceiveMemoryWarning {
	[super didReceiveMemoryWarning];
	// Dispose of any resources that can be recreated.
}


- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar{
    [searchBar resignFirstResponder];
    [self searchFriendAdd:searchBar.text];
    
}

- (IBAction)searchFriendAdd:(NSString *)searchText {
	

	if (searchText && ![searchText isEqualToString:@""]) {
        searchFriendArr = [NSMutableArray array];
		[MBProgressHUD showMessage:@"Search..."];
		ASIHTTPRequest *request = [t_Network httpGet:@{ @"uid":searchText }.mutableCopy Url:anyTime_FindUser Delegate:nil Tag:anyTime_FindUser_tag];
		__block ASIHTTPRequest *searchRequest = request;
		[request setCompletionBlock: ^{
		    NSString *responseStr = [searchRequest responseString];
		    NSLog(@"%@", responseStr);
		    NSDictionary *tmpObj = [responseStr objectFromJSONString];
		    NSString *statusCode = [tmpObj objectForKey:@"statusCode"];
		    if ([statusCode isEqualToString:@"1"]) {
		        id friendObj = [tmpObj objectForKey:@"data"];
		        if ([friendObj isKindOfClass:[NSArray class]]) {
		            NSArray *friendArr = (NSArray *)friendObj;
		            for (NSDictionary *dic in friendArr) {
		                NSString *nickName = [dic objectForKeyedSubscript:@"nickName"];
		                NSMutableDictionary *ndic = [NSMutableDictionary dictionaryWithDictionary:dic];
		                [ndic removeObjectForKey:@"nickName"];
		                if (nickName)
							[ndic setObject:nickName forKey:@"nickname"];
		                Friend * friend = [Friend friendWithDict:ndic];
		                [searchFriendArr addObject:friend];
					}
				}
			}
		    [MBProgressHUD hideHUD];
		}];
		[request setFailedBlock: ^{
		    [MBProgressHUD hideHUD];
		    [MBProgressHUD showError:@"Network error!"];
		}];
		[request startSynchronous];
		[self.tableView reloadData];
	}
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return searchFriendArr.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	return 55.f;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	static NSString *cellIdentifier = @"cellFriendId";

	FriendInfoTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
	if (!cell) {
		cell = (FriendInfoTableViewCell *)[[[NSBundle mainBundle] loadNibNamed:@"FriendInfoTableViewCell" owner:self options:nil] lastObject];
	}

	Friend *friend = searchFriendArr[indexPath.section];


	NSString *_urlStr = [[NSString stringWithFormat:@"%@/%@", BASEURL_IP, friend.imgSmall] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
	NSLog(@"%@", _urlStr);
	NSURL *url = [NSURL URLWithString:_urlStr];
	[cell.userHead sd_setImageWithURL:url placeholderImage:[UIImage imageNamed:@"smile_1"] completed:nil];

	//cell.textLabel.textColor = friend.isVip ? [UIColor redColor] : [UIColor blackColor];
    
	cell.nickName.text = friend.username;
	cell.userNote.text = friend.email;
    [cell.addFriendBtn addTarget:self action:@selector(addFriendEventTouch:) forControlEvents:UIControlEventTouchUpInside];
    [cell.addFriendBtn setTag:indexPath.section];
	return cell;
}


-(void)addFriendEventTouch:(UIButton *) sender {
    Friend *friend = searchFriendArr[sender.tag];
    
    FriendsProfilesTableViewController * friendsProfileVC = [[FriendsProfilesTableViewController alloc] init] ;
    friendsProfileVC.isSendRequest = YES ;
    friendsProfileVC.friend = friend ;
    friendsProfileVC.friendsAddProfileblack = ^(NSString *groupId){
        ASIHTTPRequest *addFriendRequest = [t_Network httpPostValue:@{ @"fid":friend.Id, @"tid":groupId, @"name":friend.username }.mutableCopy Url:anyTime_AddFriend Delegate:nil Tag:anyTime_AddFriend_tag];
        __block ASIHTTPRequest *friendRequest = addFriendRequest;
        [addFriendRequest setCompletionBlock: ^{
            NSString *responseStr = [friendRequest responseString];
            NSLog(@"%@", responseStr);
            id objTmp = [responseStr objectFromJSONString];
            NSString *statusCode = [objTmp objectForKey:@"statusCode"];
            if ([statusCode isEqualToString:@"1"]) {
                [MBProgressHUD showSuccess:@"Friend request sent. Please wait for confirmation"];
            }else {
                [MBProgressHUD showError:@"Fail to send friend request"];
            }
        }];
        [addFriendRequest setFailedBlock: ^{
            [MBProgressHUD showError:@"Fail to send friend request"];
        }];
        [addFriendRequest startAsynchronous];
    };
    
    [self.navigationController pushViewController:friendsProfileVC animated:YES];

}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
//	selectIndexPath = indexPath;
//    Friend *friend = searchFriendArr[indexPath.section];
//    
//    FriendsProfilesTableViewController * friendsProfileVC = [[FriendsProfilesTableViewController alloc] init] ;
//    friendsProfileVC.isSendRequest = YES ;
//    friendsProfileVC.friend = friend ;
//    friendsProfileVC.friendsAddProfileblack = ^(NSString *groupId){
//        ASIHTTPRequest *addFriendRequest = [t_Network httpPostValue:@{ @"fid":friend.Id, @"tid":groupId, @"name":friend.username }.mutableCopy Url:anyTime_AddFriend Delegate:nil Tag:anyTime_AddFriend_tag];
//        __block ASIHTTPRequest *friendRequest = addFriendRequest;
//        [addFriendRequest setCompletionBlock: ^{
//            NSString *responseStr = [friendRequest responseString];
//            NSLog(@"%@", responseStr);
//            id objTmp = [responseStr objectFromJSONString];
//            NSString *statusCode = [objTmp objectForKey:@"statusCode"];
//            if ([statusCode isEqualToString:@"1"]) {
//                [MBProgressHUD showSuccess:@"Friend request sent. Please wait for confirmation"];
//            }else {
//                [MBProgressHUD showError:@"Fail to send friend request"];
//            }
//        }];
//        [addFriendRequest setFailedBlock: ^{
//            [MBProgressHUD showError:@"Fail to send friend request"];
//        }];
//        [addFriendRequest startAsynchronous];
//    };
//    
//    [self.navigationController pushViewController:friendsProfileVC animated:YES];
    
//	LPPopupListView *lpopView = [[LPPopupListView alloc] initWithTitle:@"Select Group" list:nil selectedIndexes:nil point:CGPointMake(20, 70) size:CGSizeMake(kScreen_Width - 40, kScreen_Height - 100) multipleSelection:NO];
//	lpopView.titleLabel.textAlignment = NSTextAlignmentCenter;
//	lpopView.delegate = self;
//	[lpopView showInView:self.view animated:YES];
}

#pragma mark -LPPopupListView的代理
- (void)popupListView:(LPPopupListView *)popupListView didSelectFriendGroup:(FriendGroup *)selectFriendGroup {
}


-(void)backToAddFriendsView{
    [self.navigationController popViewControllerAnimated:YES] ;
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
