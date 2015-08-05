//
//  SetingViewController.m
//  Go2
//
//  Created by IF on 14-10-11.
//  Copyright (c) 2014年 zhilifang. All rights reserved.
//

#import "SetingViewController.h"
#import "VisibleCalendarsViewController.h"
#import "NotificationViewController.h"
#import "PreferenceViewController.h"
#import "GoogleCalendarData.h"
#import "GoogleLoginViewController.h"
#import "AccountViewController.h"
//#import "IBActionSheet.h"
#import "LoginViewController.h"
#import "AT_Account.h"
#import "UserInfoTableViewController.h"

@interface SetingViewController () <UITableViewDataSource, UITableViewDelegate, ASIHTTPRequestDelegate, UIActionSheetDelegate> {
	BOOL isUserInfo;
	BOOL isLogout;
}

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, retain) NSMutableArray *dataArr;
@property (nonatomic, retain) NSMutableArray *titleHeadArr;
@property (nonatomic, retain) NSMutableArray *settingDataArr;
@property (nonatomic, retain) NSMutableArray *moreDataArr;

@property (nonatomic, retain) NSMutableArray *calendarArray;

@property (nonatomic, retain) NSMutableArray *calendarListArr;
@end

@implementation SetingViewController
@synthesize settingDataArr, accountDataArr, moreDataArr, dataArr;


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
	self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
	if (self) {
        self.title = @"Settings" ;
	}
	return self;
}

- (void)viewDidLoad {
	[super viewDidLoad];
	dataArr = [NSMutableArray arrayWithCapacity:0];
	accountDataArr =  [NSMutableArray arrayWithCapacity:0];
	self.calendarArray = [NSMutableArray arrayWithCapacity:0];

	self.titleHeadArr = [[NSMutableArray alloc] initWithObjects:@"SETTINGS", @"ACCOUNTS", @"MORE", nil];

	settingDataArr =  [[NSMutableArray alloc] initWithObjects:@"Visible Calendars", @"Notifications", @"Preference", nil];
	moreDataArr    =  [[NSMutableArray alloc] initWithObjects:/*@"Support",@"Rate in App Store",*/ @"Profile", @"Logout", nil];
	self.tableView =  [[UITableView alloc]initWithFrame:CGRectMake(0, 0, kScreen_Width, kScreen_Height) style:UITableViewStyleGrouped];

	[dataArr addObject:settingDataArr];
	[dataArr addObject:accountDataArr];
	[dataArr addObject:moreDataArr];

	self.tableView.dataSource = self;
	self.tableView.delegate = self;
    self.view = self.tableView;
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	[accountDataArr removeAllObjects];

	self.calendarListArr = [[AT_Account MR_findAll] mutableCopy];//[g_AppDelegate loadDataFromFile:calendarList];
	// if (g_NetStatus==NotReachable) {
	if (self.calendarListArr) {
		for (AT_Account *atAccount in self.calendarListArr) {
			[accountDataArr addObject:atAccount];
		}
		[accountDataArr addObject:@"Add Account"];
		[self.tableView reloadData];
	}
	// }
//    ASIHTTPRequest *request=[t_Network httpGet:nil Url:LoginUser_GetUserInfo Delegate:self Tag:LoginUser_GetUserInfo_Tag];
//    [request startAsynchronous];
}

- (void)viewDidDisappear:(BOOL)animated {
	[super viewDidDisappear:animated];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return self.titleHeadArr.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	NSArray *arr = [dataArr objectAtIndex:section];
	if (arr) {
		return arr.count;
	}
	else {
		return 0;
	}
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
	return self.titleHeadArr[section];
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 40.f;
}

-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 0.01f;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	NSString *cellIdentifier = @"SetingId";
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
	if (cell == nil) {
		cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
	}
	cell.tag = [[NSString stringWithFormat:@"%ld%ld", (long)indexPath.section, (long)indexPath.row] intValue];
	cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;

	NSArray *viewarr = [cell.contentView subviews];
	for (UIView *view in viewarr) {
		[view removeFromSuperview];
	}

	NSArray *arr = [dataArr objectAtIndex:indexPath.section];
	id tmpObj = arr[indexPath.row];
	if ([tmpObj isKindOfClass:[NSString class]]) {
		cell.textLabel.text = tmpObj;
	}
	else if ([tmpObj isKindOfClass:[AT_Account class]]) {
		AT_Account *atAccount = (AT_Account *)tmpObj;
		UILabel *lab = [self createUILabe];
		UILabel *contextLab = [[UILabel alloc] initWithFrame:CGRectMake(lab.bounds.size.width, 2, 215, 40)];
		contextLab.lineBreakMode = NSLineBreakByTruncatingMiddle;
		[contextLab setBackgroundColor:[UIColor clearColor]];
		if ([atAccount.accountType intValue] == AccountTypeGoogle) {
			lab.text = @"G";
			[contextLab setText:atAccount.account];
		}
		else if ([atAccount.accountType intValue] == AccountTypeLocal) {
			lab.text = @"IF";
			[contextLab setText:atAccount.account];
		}
		[cell.contentView addSubview:lab];
		[cell.contentView addSubview:contextLab];
	}
	return cell;
}

- (UILabel *)createUILabe {
	UILabel *lab = [[UILabel alloc] initWithFrame:CGRectMake(0, 2, 40, 40)];
	[lab setTextAlignment:NSTextAlignmentCenter];
	[lab setBackgroundColor:[UIColor clearColor]];
	[lab setFont:[UIFont fontWithName:@"Verdana-Bold" size:12.f]];
	return lab;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
	UITableViewCell *selectCell = [tableView cellForRowAtIndexPath:indexPath];
	if (selectCell.tag == 0) {
		VisibleCalendarsViewController *vc = [[VisibleCalendarsViewController alloc] init];
        vc.hidesBottomBarWhenPushed = YES ;
		[self.navigationController pushViewController:vc animated:YES];
	}
	else if (selectCell.tag == 1) {
		NotificationViewController *notificationVC = [[NotificationViewController alloc] init];
         notificationVC.hidesBottomBarWhenPushed = YES ;
		[self.navigationController pushViewController:notificationVC animated:YES];
	}
	else if (selectCell.tag == 2) {
		PreferenceViewController *preferenceVC = [[PreferenceViewController alloc] init];
         preferenceVC.hidesBottomBarWhenPushed = YES ;
		[self.navigationController pushViewController:preferenceVC animated:YES];
	}
	else if (selectCell.tag == 22) {
        
	}
	else if (selectCell.tag == 21) {
        UIActionSheet *activeSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Logout", nil];
        [activeSheet showInView:self.view];
	}
	else if (selectCell.tag == 20) {
		UserInfoTableViewController *userInfoVC = [[UserInfoTableViewController alloc] initWithNibName:@"UserInfoTableViewController" bundle:nil];
        userInfoVC.hidesBottomBarWhenPushed = YES ;
		userInfoVC.userInfoBlank = ^(UserInfoTableViewController *userInfoViewController, UserInfo *userInfo) {
			ASIHTTPRequest *userRequest = [t_Network httpGet:@{ @"tel":(userInfo.phone == nil ? @"" : userInfo.phone), @"name":(userInfo.nickname == nil ? @"" : userInfo.nickname), @"gender":@(userInfo.gender) }.mutableCopy Url:UserInfo_UpdateUserInfo Delegate:nil Tag:UserInfo_UpdateUserInfo_tag];

			__block ASIHTTPRequest *request = userRequest;
			[userRequest setCompletionBlock: ^{
			    NSLog(@"数据更新成功：%@", [request responseString]);
			    NSDictionary *tmpObj = [[request responseString] objectFromJSONString];
			    if ([@"1" isEqualToString:[tmpObj objectForKey:@"statusCode"]]) {
			        [MBProgressHUD showSuccess:@"Operation success"];
			        [UserInfo userInfoWithArchive:userInfo];
				}
			}];

			[userRequest setFailedBlock: ^{
			    NSLog(@"请求失败：%@", [request responseString]);
			}];
			[userRequest startAsynchronous];

			for (UIViewController *viewController in userInfoViewController.navigationController.viewControllers) {
				if ([viewController isKindOfClass:[SetingViewController class]]) {
					[userInfoViewController.navigationController popToViewController:viewController animated:YES];
					break;
				}
			}
		};
		[self.navigationController pushViewController:userInfoVC animated:YES];
	}
	else {
		id rowData = [[dataArr objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
		if ([rowData isKindOfClass:[NSString class]]) {
			if ([@"Add Account" isEqualToString:rowData]) {
				GoogleLoginViewController *glvc = [[GoogleLoginViewController alloc] initWithNibName:@"GoogleLoginViewController" bundle:nil];
                glvc.hidesBottomBarWhenPushed = YES ;
				glvc.isBind = YES;
				glvc.isSeting = YES;
				[self.navigationController pushViewController:glvc animated:YES];
			}
		}
		else if ([rowData isKindOfClass:[AT_Account class]]) {
			AccountViewController *accountVC = [[AccountViewController alloc] init];
            accountVC.hidesBottomBarWhenPushed = YES ;
			accountVC.accountArr = [NSMutableArray arrayWithObjects:rowData, nil];
			[self.navigationController pushViewController:accountVC animated:YES];
		}
	}
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
	if (buttonIndex == 0) {
		isLogout = YES;
		ASIHTTPRequest *request =  [t_Network httpGet:nil Url:account_Logoff Delegate:self Tag:account_Logoff_Tag];
		[request startAsynchronous];
		NSPredicate *pre = [NSPredicate predicateWithFormat:@"account==%@", [UserInfo currUserInfo].email];
		NSArray *atAccountArr = [AT_Account MR_findAllWithPredicate:pre];

		for (AT_Account *atAccount in atAccountArr) {
			[atAccount MR_deleteEntity];
			[[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreAndWait];
		}
		if (self.delegate && [self.delegate respondsToSelector:@selector(setingViewControllerDelegate:)]) {
			[self.delegate setingViewControllerDelegate:self];
		}
    }
}

- (void)requestFinished:(ASIHTTPRequest *)request {
	NSString *dataStr = [request responseString];
	if (isLogout) {
		id objId = [dataStr objectFromJSONString];
		//{"statusCode":"1","message":"成功","data":[{"account":"yanjaya5201314@gmail.com","type":"1","uid":"74"}]}
		if ([objId isKindOfClass:[NSDictionary class]]) {
			NSDictionary *Datadic = (NSDictionary *)objId;
			NSString *statusCode = [Datadic objectForKey:@"statusCode"];
			if ([@"1" isEqualToString:statusCode]) {
				if (!isUserInfo) {
					[accountDataArr removeAllObjects];
					NSDictionary *userInfoDic = [Datadic objectForKey:@"data"];
					[accountDataArr addObject:[userInfoDic objectForKey:@"email"]];
					ASIHTTPRequest *request = [t_Network httpGet:nil Url:get_AccountBindList Delegate:self Tag:get_AccountBindList_Tag];
					[request startAsynchronous];
					isUserInfo = YES;
				}
				else {
					NSArray *bindArr = [Datadic objectForKey:@"data"];
					for (NSDictionary *dataDic in bindArr) {
						[accountDataArr addObject:[dataDic objectForKey:@"account"]];
					}
					isUserInfo = NO;
					[self.accountDataArr addObject:@"Add Account"];
					[self.tableView reloadData];
				}
			}
		} else {
//            dataStr = [dataStr stringByReplacingOccurrencesOfString:@"\r\n" withString:@""];
//			if ([@"1" isEqualToString:dataStr]) {
                [UserInfo currUserInfo].loginStatus = UserLoginStatus_NO ; //登陆状态改为没有登陆
                [UserInfo userInfoWithArchive:[UserInfo currUserInfo]];
                [g_AppDelegate initLoginView:LoginOrLogoutType_ModelOpen];
//			}
			isLogout = NO;
		}
	}
}

- (void)didReceiveMemoryWarning {
	[super didReceiveMemoryWarning];
}
@end
