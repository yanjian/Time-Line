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
	NSDictionary *attributes = [NSDictionary dictionaryWithObjectsAndKeys:

	                            [UIColor whiteColor], NSForegroundColorAttributeName, nil];

	[self.navigationController.navigationBar setTitleTextAttributes:attributes];

	// 导航
	self.navigationController.navigationBar.barTintColor = blueColor;

	//左边的按钮
	UIButton *leftButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
	leftButton.frame = CGRectMake(15, 30, 21, 25);
	leftButton.backgroundColor = [UIColor clearColor];
	[leftButton setBackgroundImage:[UIImage imageNamed:@"Icon_BackArrow"] forState:UIControlStateNormal];
	leftButton.tag = 1;
	[leftButton addTarget:self action:@selector(eventTouchUpInside:) forControlEvents:UIControlEventTouchUpInside];
	self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:leftButton];


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
	// Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
#warning Potentially incomplete method implementation.
	// Return the number of sections.
	return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
#warning Incomplete method implementation.
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

- (void)eventTouchUpInside:(UIButton *)sender {
	switch (sender.tag) {
		case 1: {
			// [self.navigationController popViewControllerAnimated:YES] ;
			[self.navigationController popViewControllerAnimated:YES];
		} break;

		default:
			break;
	}
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

/*
   // Override to support conditional editing of the table view.
   - (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
   }
 */

/*
   // Override to support editing the table view.
   - (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }
   }
 */

/*
   // Override to support rearranging the table view.
   - (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
   }
 */

/*
   // Override to support conditional rearranging of the table view.
   - (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
   }
 */

/*
   #pragma mark - Table view delegate

   // In a xib-based application, navigation from a table can be handled in -tableView:didSelectRowAtIndexPath:
   - (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    // Navigation logic may go here, for example:
    // Create the next view controller.
    <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:<#@"Nib name"#> bundle:nil];

    // Pass the selected object to the new view controller.

    // Push the view controller.
    [self.navigationController pushViewController:detailViewController animated:YES];
   }
 */

/*
   #pragma mark - Navigation

   // In a storyboard-based application, you will often want to do a little preparation before navigation
   - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
   }
 */

@end
