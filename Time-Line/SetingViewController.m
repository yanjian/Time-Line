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
#import "UserInfoTableViewController.h"


#import "Calendar.h"
#import "Go2Account.h"
@interface SetingViewController () <UITableViewDataSource, UITableViewDelegate, ASIHTTPRequestDelegate, UIActionSheetDelegate> {
	BOOL isUserInfo;
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

	self.calendarListArr = [[Go2Account MR_findAll] mutableCopy];
    
	if (self.calendarListArr) {
        [self.calendarListArr enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            [accountDataArr addObject:obj];
        }];
		[accountDataArr addObject:@"Add Account"];
		[self.tableView reloadData];
	}
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
	else if ([tmpObj isKindOfClass:[Go2Account class]]) {
		Go2Account *atAccount = (Go2Account *)tmpObj;
		UILabel *lab = [self createUILabe];
		UILabel *contextLab = [[UILabel alloc] initWithFrame:CGRectMake(lab.bounds.size.width, 2, 215, 40)];
		contextLab.lineBreakMode = NSLineBreakByTruncatingMiddle;
		[contextLab setBackgroundColor:[UIColor clearColor]];
		if ([atAccount.type intValue] == AccountTypeGoogle) {
			lab.text = @"G";
			[contextLab setText:atAccount.account];
		}
		else if ([atAccount.type intValue] == AccountTypeLocal) {
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
			ASIHTTPRequest *userRequest = [t_Network httpGet:@{@"id":userInfo.Id, @"username":userInfo.username,@"phone":(userInfo.phone == nil ? @"" : userInfo.phone), @"nickname":(userInfo.nickname == nil ? @"" : userInfo.nickname), @"gender":@(userInfo.gender) }.mutableCopy Url:Go2_updateUser Delegate:nil Tag:Go2_updateUser_Tag ];

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
		else if ([rowData isKindOfClass:[Go2Account class]]) {
			AccountViewController *accountVC = [[AccountViewController alloc] init];
            accountVC.hidesBottomBarWhenPushed = YES ;
			accountVC.accountArr = [NSMutableArray arrayWithObjects:rowData, nil];
			[self.navigationController pushViewController:accountVC animated:YES];
		}
	}
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
	if (buttonIndex == 0) {
        NSArray * caArr = [Calendar MR_findAll];
        
        NSArray * go2AccountArr = [Go2Account MR_findAll];
        if (go2AccountArr.count>0) {//有没有绑定的google账号
            [go2AccountArr enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                Go2Account * go2Account = (Go2Account *) obj ;
                [go2Account.ca enumerateObjectsUsingBlock:^(id obj, BOOL *stop) {//
                    Calendar * calendar = (Calendar *) obj;
                    if (![go2Account.account isEqualToString:calendar.account]) {
                        [go2Account MR_deleteEntity];
                        [[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreAndWait];
                    }
                }];
            }];
            
            //删除本地账号的日历数据和日历列表
            [caArr enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                Calendar * calendar = (Calendar *) obj;
                if ([calendar.type intValue] == AccountTypeLocal) {
                    [calendar MR_deleteEntity];
                    [[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreAndWait];
                }
            }];
        }else{
            [caArr enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                [obj MR_deleteEntity];
                [[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreAndWait];
            }];
        }

        if (self.delegate && [self.delegate respondsToSelector:@selector(setingViewControllerDelegate:)]) {
			[self.delegate setingViewControllerDelegate:self];
		}
        
        //测试登陆是用，删除
        [UserInfo currUserInfo].loginStatus = UserLoginStatus_NO ; //登陆状态改为没有登陆
        [UserInfo userInfoWithArchive:[UserInfo currUserInfo]];
        [g_AppDelegate initLoginView:LoginOrLogoutType_ModelOpen];
    }
}

- (void)didReceiveMemoryWarning {
	[super didReceiveMemoryWarning];
}
@end
