//
//  FriendsInfoTableViewController.m
//  Time-Line
//
//  Created by IF on 15/1/19.
//  Copyright (c) 2015年 zhilifang. All rights reserved.
//

#import "FriendsInfoTableViewController.h"
#import "UIImageView+WebCache.h"
#import "SJAvatarBrowser.h"
#import "AliasModifyViewController.h"
@interface FriendsInfoTableViewController () <UIActionSheetDelegate> {
	NSString *_modifyAlias;
}
@property (strong, nonatomic) IBOutlet UIView *tableHead;
@property (weak, nonatomic) IBOutlet UIImageView *friendHead;

@end

@implementation FriendsInfoTableViewController
@synthesize  friendInfo;

- (void)viewDidLoad {
	[super viewDidLoad];
	self.view.frame = CGRectMake(0, 0, kScreen_Width, kScreen_Height);
	self.title = @"Profile";
//	NSDictionary *attributes = [NSDictionary dictionaryWithObjectsAndKeys:
//
//	                            [UIColor whiteColor], NSForegroundColorAttributeName, nil];
//
//	[self.navigationController.navigationBar setTitleTextAttributes:attributes];

    UIButton *leftBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [leftBtn setFrame:CGRectMake(0, 2, 22, 14)];
    [leftBtn setBackgroundImage:[UIImage imageNamed:@"Arrow_Left_Blue.png"] forState:UIControlStateNormal] ;
    [leftBtn addTarget:self action:@selector(backFromEventTouchUpInside:) forControlEvents:UIControlEventTouchUpInside] ;
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:leftBtn] ;
    self.navigationController.interactivePopGestureRecognizer.delegate = (id)self;

	if (self.friendDeleteBlock) {
		UIView *footerView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 45)];
		UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
		button.backgroundColor = purple;
		button.frame = CGRectMake(20, 5, 280, 40);
		[button setTitle:@"Delete friend" forState:UIControlStateNormal];
		[button.layer setMasksToBounds:YES];
		[button.layer setCornerRadius:5.f];
		[button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
		[button addTarget:self action:@selector(deleteSelectFriendTouchUpInside) forControlEvents:UIControlEventTouchUpInside];
		[footerView addSubview:button];
		self.tableView.tableFooterView = footerView;
	}
	else {
		self.tableView.tableFooterView = [UIView new];
	}

	self.tableView.tableHeaderView = self.tableHead;
	self.tableView.separatorInset  = UIEdgeInsetsZero;

	NSString *_urlStr = [[NSString stringWithFormat:@"%@/%@", BASEURL_IP, self.friendInfo.imgBig] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
	NSLog(@"%@", _urlStr);
	NSURL *url = [NSURL URLWithString:_urlStr];
	[self.friendHead sd_setImageWithURL:url placeholderImage:[UIImage imageNamed:@"smile_1"] completed: ^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
	}];
	self.friendHead.layer.cornerRadius = self.friendHead.frame.size.width / 2;
	self.friendHead.layer.masksToBounds = YES;
}

- (void)didReceiveMemoryWarning {
	[super didReceiveMemoryWarning];
}

#pragma mark - Table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	// Return the number of rows in the section.
	return 5;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	static NSString *tableCellId = @"FriendHeadId";
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:tableCellId];
	if (!cell) {
		cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:tableCellId];
	}
	if (indexPath.row == 0) {
		cell.textLabel.text = @"Account:";
		cell.detailTextLabel.text = friendInfo.username;
	}
	else if (indexPath.row == 1) {
		cell.textLabel.text = @"Alias:";
		if (_modifyAlias) {
			cell.detailTextLabel.text =  _modifyAlias;
		}
		else {
			cell.detailTextLabel.text =  friendInfo.alias;
		}
		cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
	}
	else if (indexPath.row == 2) {
		cell.textLabel.text = @"Phone:";
		cell.detailTextLabel.text = @"";
	}
	else if (indexPath.row == 3) {
		cell.textLabel.text = @"Nick Name:";
		cell.detailTextLabel.text = friendInfo.nickname;
	}
	else if (indexPath.row == 4) {
		cell.textLabel.text = @"Gender:";
		cell.detailTextLabel.text = friendInfo.gender == 0 ? @"Female" : @"Male";
	}


	return cell;
}

- (IBAction)checkBIgPicture:(UIButton *)sender {
	[SJAvatarBrowser showImage:self.friendHead];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
	if (indexPath.section == 0) {
		if (indexPath.row == 1) {
			AliasModifyViewController *aliasVC = [[AliasModifyViewController alloc] initWithNibName:@"AliasModifyViewController" bundle:nil];
			aliasVC.fid = friendInfo.fid;

			aliasVC.alias = (_modifyAlias == nil || [_modifyAlias isEqualToString:@""]) ? friendInfo.alias : _modifyAlias;
			aliasVC.aliasModify = ^(AliasModifyViewController *selfViewCOntroller, NSString *modifyAlias) {
				NSLog(@">>>>>>>>>>>>>>>>> Alias === %@", modifyAlias);
				_modifyAlias = modifyAlias;
				[MBProgressHUD showSuccess:@"Operation success"];
				for (UIViewController *viewController in selfViewCOntroller.navigationController.viewControllers) {
					if ([viewController isKindOfClass:[FriendsInfoTableViewController class]]) {
						[self.tableView reloadData];
						[selfViewCOntroller.navigationController popToViewController:viewController animated:YES];
						break;
					}
				}
			};
			[self.navigationController pushViewController:aliasVC animated:YES];
		}
	}
}

- (void)deleteSelectFriendTouchUpInside {
	UIActionSheet *deleteSheet = [[UIActionSheet alloc] initWithTitle:@"Delete friend" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:@"Confirm" otherButtonTitles:nil, nil];
	[deleteSheet showInView:self.view];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
	if (buttonIndex == 0) {
		if (self.friendDeleteBlock) {
			self.friendDeleteBlock(self);
		}
	}
}


- (void)backFromEventTouchUpInside:(UIButton *)sender {
				[self.navigationController popViewControllerAnimated:YES];
}

@end
