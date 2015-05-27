//
//  UserInfoTableViewController.m
//  Go2
//
//  Created by IF on 14/12/3.
//  Copyright (c) 2014年 zhilifang. All rights reserved.
//

#import "UserInfoTableViewController.h"
#import "camera.h"
#import "utilities.h"
#import "UIImageView+WebCache.h"
#import "SJAvatarBrowser.h"


#define  SMALL @"small"
#define  BIG   @"big"

@interface UserInfoTableViewController () <UIImagePickerControllerDelegate, UIActionSheetDelegate, UIAlertViewDelegate> {
	UIActionSheet *action;
	BOOL isSelectSex;
	BOOL isClickNick;
}
@property (strong, nonatomic) IBOutlet UIView *viewHeader;
@property (weak, nonatomic) IBOutlet UIImageView *imageUser;
@property (nonatomic, strong) NSMutableArray *userFixationArr;
@property (weak, nonatomic) IBOutlet UITextField *filedNickName;
@property (nonatomic, strong) UserInfo *userInfo;
@end

@implementation UserInfoTableViewController

- (void)viewDidLoad {
	[super viewDidLoad];
	self.title = @"Profile";
    UIButton *leftBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [leftBtn setTag:1];
    [leftBtn setFrame:CGRectMake(0, 2, 22, 14)];
    [leftBtn setBackgroundImage:[UIImage imageNamed:@"Arrow_Left_Blue.png"] forState:UIControlStateNormal] ;
    [leftBtn addTarget:self action:@selector(profileTobackSetingView:) forControlEvents:UIControlEventTouchUpInside] ;
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:leftBtn] ;
    self.navigationController.interactivePopGestureRecognizer.delegate = (id)self;
    
	self.userInfo = [UserInfo currUserInfo];
	NSDictionary *attributes = [NSDictionary dictionaryWithObjectsAndKeys:
	                            [UIColor blackColor], NSForegroundColorAttributeName, nil];

	[self.navigationController.navigationBar setTitleTextAttributes:attributes];

	UIButton *rightBtn = [UIButton buttonWithType:UIButtonTypeCustom];
	[rightBtn setTag:2];
    [rightBtn setBackgroundImage:[UIImage imageNamed:@"go2_blueTick"] forState:UIControlStateNormal];
	[rightBtn setFrame:CGRectMake(0, 0, 22, 14)];
	[rightBtn addTarget:self action:@selector(profileTobackSetingView:) forControlEvents:UIControlEventTouchUpInside];
	self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithCustomView:rightBtn];

	self.tableView.tableHeaderView = self.viewHeader;
	self.tableView.separatorInset  = UIEdgeInsetsZero;

	self.userFixationArr = [NSMutableArray arrayWithObjects:@"Nick Name", @"Account", @"Phone", @"Gender", nil];

	NSString *_urlStr = [[NSString stringWithFormat:@"%@/%@", BASEURL_IP, self.userInfo.imgUrl] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
	NSLog(@"%@", _urlStr);
	NSURL *url = [NSURL URLWithString:_urlStr];
	[self.imageUser sd_setImageWithURL:url placeholderImage:[UIImage imageNamed:@"smile_1"] completed: ^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
	}];
	self.imageUser.layer.cornerRadius  = self.imageUser.frame.size.width / 2;
	self.imageUser.layer.masksToBounds = YES;
}

- (void)didReceiveMemoryWarning {
	[super didReceiveMemoryWarning];
}

#pragma mark - Table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return self.userFixationArr.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	static NSString *userInforCell = @"userInfoCellId";
	UITableViewCell *userCell = [tableView dequeueReusableCellWithIdentifier:userInforCell];
	if (!userCell) {
		userCell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:userInforCell];
	}
	NSString *titleStr = self.userFixationArr[indexPath.row];
	if (indexPath.row == 0) {
		userCell.accessoryType  = UITableViewCellAccessoryDisclosureIndicator;
		userCell.textLabel.text = titleStr;
		userCell.detailTextLabel.text = self.userInfo.nickname;
	}
	else if (indexPath.row == 1) {
		userCell.textLabel.text = titleStr;
		userCell.detailTextLabel.text = self.userInfo.username;
	}
	else if (indexPath.row == 2) {
		userCell.accessoryType  = UITableViewCellAccessoryDisclosureIndicator;
		userCell.textLabel.text = titleStr;
		userCell.detailTextLabel.text = self.userInfo.phone;
	}
	else if (indexPath.row == 3) {
		userCell.accessoryType  = UITableViewCellAccessoryDisclosureIndicator;
		userCell.textLabel.text = titleStr;
		userCell.detailTextLabel.text = self.userInfo.gender == 0 ? @"Female" : @"Male";
	}
	return userCell;
}

#pragma mark -用户点击的是用户头像执行的方法
- (IBAction)accountPhoto:(UIButton *)sender {
	isSelectSex = NO;//不是选择的性别
	action = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Camera", @"Photo", @"View the big picture", nil];
	[action showInView:self.view];
}

#pragma mark -选择完相片后回调的方法
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
	UIImage *image = info[UIImagePickerControllerEditedImage];
	if (image.size.width > 140) {
		image = ResizeImage(image, 140, 140);
	}
	self.imageUser.image = image;
	//上传头像
	NSURL *url = [NSURL URLWithString:[UserInfo_UploadImg stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
	ASIFormDataRequest *uploadImageRequest = [ASIFormDataRequest requestWithURL:url];
	NSData *data = UIImagePNGRepresentation(self.imageUser.image);
	NSMutableData *imageData = [NSMutableData dataWithData:data];
	[uploadImageRequest setStringEncoding:NSUTF8StringEncoding];
	[uploadImageRequest setRequestMethod:@"POST"];
	[uploadImageRequest setPostFormat:ASIMultipartFormDataPostFormat];
	NSString *tmpDate = [[PublicMethodsViewController getPublicMethods] getcurrentTime:@"yyyyMMddss"];
	[uploadImageRequest addData:imageData withFileName:[NSString stringWithFormat:@"%@.jpg", tmpDate]  andContentType:@"image/jpeg" forKey:@"f1"];
	[uploadImageRequest setTag:UserInfo_UploadImg_tag];
	__block ASIFormDataRequest *uploadRequest = uploadImageRequest;
	[uploadImageRequest setCompletionBlock: ^{
	    NSString *responseStr = [uploadRequest responseString];
	    NSLog(@"数据更新成功：%@", responseStr);
	    id obj = [responseStr objectFromJSONString];
	    if ([obj isKindOfClass:[NSDictionary class]]) {
	        NSDictionary *tmpDic = (NSDictionary *)obj;
	        int statusCode = [[tmpDic objectForKey:@"statusCode"] integerValue];
	        if (statusCode == 1) {
	            NSDictionary *dicData = [tmpDic objectForKey:@"data"];
	            NSString *smallPath = [dicData objectForKey:SMALL];
	            if (smallPath) {
	                self.userInfo.imgUrlSmall = smallPath;
				}
	            NSString *bigPath = [dicData objectForKey:BIG];
	            if (bigPath) {
	                self.userInfo.imgUrl = bigPath;
				}
	            [UserInfo userInfoWithArchive:self.userInfo];
			}
		}
	}];
	[uploadImageRequest setFailedBlock: ^{
	    NSLog(@"请求失败：%@", [uploadRequest responseString]);
	}];
	[uploadImageRequest startAsynchronous];
	[picker dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark -该方法是UIActionsheet的回调
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
	NSLog(@"%i", buttonIndex);
	if (buttonIndex == 0) {
		if (isSelectSex) {
			self.userInfo.gender = gender_woman;
			[self.tableView reloadData];
		}
		else {
			ShouldStartCamera(self, YES);
		}
	}
	else if (buttonIndex == 1) {
		if (isSelectSex) {
			self.userInfo.gender = gender_man;
			[self.tableView reloadData];
		}
		else {
			ShouldStartPhotoLibrary(self, YES);
		}
	}
	else if (buttonIndex == 2) {
		if (!isSelectSex) {
			[SJAvatarBrowser showImage:self.imageUser];
		}
	}
}

- (void)profileTobackSetingView:(UIButton *)sender {
	switch (sender.tag) {
		case 1: {
			[self.navigationController popViewControllerAnimated:YES];
		} break;

		case 2: {
			if (self.userInfo) {
				self.userInfoBlank(self, self.userInfo);
			}
		} break;

		default:
			break;
	}
}

#pragma mark -用户选择的行 Table view delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
	if (indexPath.row == 0) {
		isClickNick = YES;
		UIAlertView *textNick = [[UIAlertView alloc] initWithTitle:@"Enter Nick Name" message:nil delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Confirm", nil];
		textNick.delegate = self;
		textNick.alertViewStyle = UIAlertViewStylePlainTextInput;
		[textNick show];
	}
	else if (indexPath.row == 2) {
		isClickNick = NO;
		UIAlertView *textPhone = [[UIAlertView alloc] initWithTitle:@"Enter Phone" message:nil delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Confirm", nil];
		textPhone.delegate = self;
		textPhone.alertViewStyle = UIAlertViewStylePlainTextInput;
		[textPhone show];
	}
	else if (indexPath.row == 3) {
		isSelectSex = YES;
		action = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Female", @"Male", nil];
		[action showInView:self.view];
	}
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
	if (buttonIndex == 1) {
		if (isClickNick) {
			self.userInfo.nickname = [alertView textFieldAtIndex:0].text;
		}
		else {
			self.userInfo.phone = [alertView textFieldAtIndex:0].text;
		}
		[self.tableView reloadData];
	}
}

@end
