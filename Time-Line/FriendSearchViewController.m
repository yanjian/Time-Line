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
	__block NSMutableArray *searchFriendArr;
	NSIndexPath *selectIndexPath;//用户选择的行数
}
@property (strong, nonatomic) UIButton *leftBtn;
@property (strong, nonatomic) UISearchBar * searchBar;
@property (strong, nonatomic) IBOutlet UITextField *searchText;
@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) IBOutlet UIButton *searchBtn;
@end

@implementation FriendSearchViewController

- (void)viewDidLoad {
	[super viewDidLoad];
	self.view.frame = CGRectMake(0, 0, kScreen_Width, kScreen_Height);
    self.title = @"Add a friend" ;
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:self.leftBtn] ;
    self.navigationController.interactivePopGestureRecognizer.delegate = (id)self;
   
    self.tableView.tableHeaderView = self.searchBar ;
    self.tableView.separatorInset  = UIEdgeInsetsMake(0, 60, 0, 0);
    self.tableView.tableFooterView = [UIView new];
}

-(UIButton *)leftBtn{
    if (!_leftBtn) {
        _leftBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_leftBtn setFrame:CGRectMake(0, 2, 22, 14)];
        [_leftBtn setBackgroundImage:[UIImage imageNamed:@"go2_arrow_left"] forState:UIControlStateNormal] ;
        [_leftBtn addTarget:self action:@selector(backToAddFriendsView) forControlEvents:UIControlEventTouchUpInside] ;
    }
    return _leftBtn ;
}

#pragma mark -创建搜索视图
-(UISearchBar *)searchBar{
    if (!_searchBar) {
        _searchBar = [[UISearchBar alloc] init];
        _searchBar.frame = CGRectMake(0, 0, self.tableView.bounds.size.width, 0);
        _searchBar.delegate = self;
        _searchBar.placeholder = @"Account name /Email";
        _searchBar.backgroundColor = [UIColor clearColor];
        _searchBar.translucent = YES ;
        
        _searchBar.tintColor = [UIColor whiteColor];
        [_searchBar sizeToFit];

    }
    return _searchBar;
}

- (void)didReceiveMemoryWarning {
	[super didReceiveMemoryWarning];
}


- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar{
    [searchBar resignFirstResponder];
    [self searchFriendAdd:searchBar.text];
    
}

- (IBAction)searchFriendAdd:(NSString *)searchText {
	

	if (searchText && ![searchText isEqualToString:@""]) {
        searchFriendArr = [NSMutableArray array];
		[MBProgressHUD showMessage:@"Search..."];
		ASIHTTPRequest *request = [t_Network httpGet:@{@"method":@"queryUser",@"text":searchText }.mutableCopy
                                                 Url:Go2_Friends
                                            Delegate:nil
                                                 Tag:Go2_Friends_queryUser_Tag];
		__block typeof(request) searchRequest = request;
		[request setCompletionBlock: ^{
		    NSString *responseStr = [searchRequest responseString];
		    NSLog(@"%@", responseStr);
		    NSDictionary *tmpObj = [responseStr objectFromJSONString];
		    int statusCode = [[tmpObj objectForKey:@"statusCode"] intValue];
		    if ( statusCode ==1 ) {
		        id friendObj = [tmpObj objectForKey:@"datas"];
		        if ([friendObj isKindOfClass:[NSArray class]]) {
		            NSArray *friendArr = (NSArray *)friendObj;
                    
                    [friendArr enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                         Friend  * friend = [Friend modelWithDictionary:obj];
                         [searchFriendArr addObject:friend];
                    }];
//		            for (NSDictionary *dic in friendArr) {
//		                NSString *nickName = [dic objectForKeyedSubscript:@"nickName"];
//		                NSMutableDictionary *ndic = [NSMutableDictionary dictionaryWithDictionary:dic];
//		                [ndic removeObjectForKey:@"nickName"];
//		                if (nickName)
//							[ndic setObject:nickName forKey:@"nickname"];
//		                Friend * friend = [Friend friendWithDict:ndic];
//		                [searchFriendArr addObject:friend];
//					}
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

	NSString *_urlStr = [[NSString stringWithFormat:@"%@/%@", BaseGo2Url_IP, friend.thumbnail] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
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
    friendsProfileVC.friendsAddProfileblack = ^(){
        ASIHTTPRequest *addFriendRequest = [t_Network httpPostValue:@{@"method":@"sendFriendInvitee",@"fid":friend.Id }.mutableCopy Url:Go2_Friends Delegate:nil Tag:Go2_Friends_sendFriendInvitee_Tag];
        __block typeof(addFriendRequest) friendRequest = addFriendRequest;
        
        [addFriendRequest setCompletionBlock: ^{
            NSString *responseStr = [friendRequest responseString];
            NSLog(@"%@", responseStr);
            id objTmp = [responseStr objectFromJSONString];
            int statusCode = [[objTmp objectForKey:@"statusCode"] intValue];
            if ( statusCode == 1 ) {
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
}

#pragma mark -LPPopupListView的代理
- (void)popupListView:(LPPopupListView *)popupListView didSelectFriendGroup:(FriendGroup *)selectFriendGroup {
}


-(void)backToAddFriendsView{
    [self.navigationController popViewControllerAnimated:YES] ;
}


@end
