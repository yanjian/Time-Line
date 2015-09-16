//
//  AccountViewController.m
//  Go2
//
//  Created by IF on 14-10-13.
//  Copyright (c) 2014年 zhilifang. All rights reserved.
//

#import "AccountViewController.h"
#import "GoogleCalendarData.h"
#import "IBActionSheet.h"
#import "AT_Account.h"

#import "Go2Account.h"
@interface AccountViewController () <UITableViewDataSource, UITableViewDelegate, ASIHTTPRequestDelegate, IBActionSheetDelegate>
@property (nonatomic, retain) UITableView *tableView;
@end

@implementation AccountViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
	self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
	if (self) {
	}
	return self;
}

- (void)viewDidLoad {
	[super viewDidLoad];
    self.title = @"Disconnect" ;
    UIButton *leftBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [leftBtn setFrame:CGRectMake(0, 2, 22, 14)];
    [leftBtn setBackgroundImage:[UIImage imageNamed:@"go2_arrow_left"] forState:UIControlStateNormal] ;
    [leftBtn addTarget:self action:@selector(visibleCaTobackSetingView) forControlEvents:UIControlEventTouchUpInside] ;
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:leftBtn] ;
    self.navigationController.interactivePopGestureRecognizer.delegate = (id)self;

	self.tableView = [[UITableView alloc] initWithFrame:[[UIScreen mainScreen] bounds] style:UITableViewStyleGrouped];
	self.tableView.dataSource = self;
	self.tableView.delegate = self;
	[self.view addSubview:self.tableView];
}

- (void)didReceiveMemoryWarning {
	[super didReceiveMemoryWarning];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return self.accountArr.count;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
	return @"INFO";
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
	return 35.f;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	NSString *cellIdentifier = @"cellDisconnect";
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
	if (cell == nil) {
		cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
	}

	for (UIView *view in[cell.contentView subviews]) {
		[view removeFromSuperview];
	}

	id rowAccount = self.accountArr[indexPath.section];
	if ([rowAccount isKindOfClass:[Go2Account class]]) {
		Go2Account *account = (Go2Account *)rowAccount;
		UILabel *lab = [self createUILabe];
		UILabel *contextLab = [[UILabel alloc] initWithFrame:CGRectMake(lab.bounds.size.width, 2, 215, 40)];
		[contextLab setBackgroundColor:[UIColor clearColor]];
		contextLab.lineBreakMode = NSLineBreakByTruncatingMiddle;
		lab.text = @"Account: ";
		[contextLab setText:account.account];
		[cell.contentView addSubview:lab];
		[cell.contentView addSubview:contextLab];
	}
	return cell;
}

- (UILabel *)createUILabe {
	UILabel *lab = [[UILabel alloc] initWithFrame:CGRectMake(0, 2, 90, 40)];
	[lab setTextAlignment:NSTextAlignmentCenter];
	[lab setBackgroundColor:[UIColor clearColor]];
	[lab setFont:[UIFont fontWithName:@"Verdana-Bold" size:17.f]];
	return lab;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
	return 80.f;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
	UIView *footview = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreen_Width, 420)];
	[footview setBackgroundColor:[UIColor clearColor]];
	UIButton *disconnectBtn = [UIButton buttonWithType:UIButtonTypeSystem];
	[disconnectBtn setFrame:CGRectMake(10, 20, kScreen_Width-2*10, 40)];
	[disconnectBtn.layer setMasksToBounds:YES];
	[disconnectBtn.layer setCornerRadius:5.f];
	[disconnectBtn setTitle:@"Disconnect Account" forState:UIControlStateNormal];
	[disconnectBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];


	id rowAccount = self.accountArr[section];
	if ([rowAccount isKindOfClass:[Go2Account class]]) {
		Go2Account *account = (Go2Account *)rowAccount;
		if ([account.type intValue] == AccountTypeGoogle) {
			[disconnectBtn setBackgroundColor:[UIColor redColor]];
			[disconnectBtn addTarget:self action:@selector(disconnectAccount:) forControlEvents:UIControlEventTouchUpInside];
		}
		else if ([account.type intValue] == AccountTypeLocal) {
			[disconnectBtn setBackgroundColor:[UIColor grayColor]];
			[disconnectBtn setEnabled:NO];
		}
	}
	[footview addSubview:disconnectBtn];
	return footview;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (void)visibleCaTobackSetingView {
	[self.navigationController popViewControllerAnimated:YES];
}

- (void)disconnectAccount:(UIButton *)sender {
	IBActionSheet *ibActionSheet = [[IBActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:@"Disconnect Account" otherButtonTitles:nil, nil];
	[ibActionSheet showInView:self.navigationController.view];
}

- (void)actionSheet:(IBActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
	if (buttonIndex == 0) {
		id accountData = [self.accountArr lastObject];
		
        if ([accountData isKindOfClass:[Go2Account class]]) {
			Go2Account *  account   = (Go2Account *) accountData;
            
            ASIHTTPRequest *request = [t_Network httpGet:@{@"accountId": account.accountId }.mutableCopy Url:Go2_Google_removeBind Delegate:self Tag:Go2_Google_removeBind_Tag];
            [request startSynchronous];
            [self.navigationController popViewControllerAnimated:YES];
		}
	}
}

- (void)requestFinished:(ASIHTTPRequest *)request {
    switch ([request tag]) {
        case Go2_Google_removeBind_Tag:{
            
            NSLog(@"%@", [request responseString]);
            id responseData = [[request responseString] objectFromJSONString];
            if ([responseData isKindOfClass:[NSDictionary class]]) {
                int  statusCode = [[responseData objectForKey:@"statusCode"] intValue];
                if ( statusCode == 1 ) {
                    Go2Account * account = [self.accountArr lastObject];
                    [account MR_deleteEntity];
                    [[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreAndWait];
                }
            }
            
        }break;
            
        default:
            break;
    }
}

@end
