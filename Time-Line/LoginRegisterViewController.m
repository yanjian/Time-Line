//
//  LoginRegisterViewController.m
//  Go2
//
//  Created by IF on 14-9-28.
//  Copyright (c) 2014年 zhilifang. All rights reserved.
//

#import "LoginRegisterViewController.h"
#import "LoginViewController.h"
#import "NSString+StringManageMd5.h"
#import "GoogleLoginViewController.h"
@interface LoginRegisterViewController () <ASIHTTPRequestDelegate>

@end

@implementation LoginRegisterViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
	self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
	if (self) {
		// Custom initialization
	}
	return self;
}

- (void)viewDidLoad {
	[super viewDidLoad];
	UINavigationBar *navBar = [[UINavigationBar alloc] initWithFrame:CGRectMake(0, 0, 320, 64)];
	navBar.translucent = NO;
	UINavigationItem *navItem = [[UINavigationItem alloc] initWithTitle:@"REGISTER"];
	//创建一个左边按钮
	UIButton *leftBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [leftBtn setFrame:CGRectMake(0, 0, 22, 14)];
    [leftBtn setBackgroundImage:[UIImage imageNamed:@"go2_arrow_left"] forState:UIControlStateNormal] ;
	[leftBtn addTarget:self action:@selector(onClickClose) forControlEvents:UIControlEventTouchUpInside];

	UIBarButtonItem *leftButton = [[UIBarButtonItem alloc] initWithCustomView:leftBtn];
	navItem.leftBarButtonItem = leftButton;

	[navBar pushNavigationItem:navItem animated:NO];
	[self.view addSubview:navBar];
    self.navigationController.interactivePopGestureRecognizer.delegate =(id) self ;
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	self.navigationItem.hidesBackButton = YES;
}

- (IBAction)commonAllEvent:(UIButton *)sender {
	if (sender.tag == 12) {
		[self.navigationController popViewControllerAnimated:YES];
	}
	else if (sender.tag == 11) {
		if ([@"" isEqualToString:self.userNameTextField.text]) {
			[MBProgressHUD showError:@"UserName empty"];
			return;
		}
		if ([@"" isEqualToString:self.emailTextField.text]) {
			[MBProgressHUD showError:@"Email empty"];
			return;
		}
		if ([@"" isEqualToString:self.passwordTextField.text]) {
			[MBProgressHUD showError:@"Password empty"];
			return;
		}
		NSMutableDictionary *paramDic = [NSMutableDictionary dictionaryWithCapacity:0];
		[paramDic setObject:self.userNameTextField.text forKey:@"uName"];
		NSString *md5Pw = [[NSString stringWithString:self.passwordTextField.text] md5];
		NSLog(@"%@", md5Pw);
		[paramDic setObject:md5Pw forKey:@"uPw"];
		[paramDic setObject:self.emailTextField.text forKey:@"email"];
		[paramDic setObject:@(UserLoginTypeLocal) forKey:@"type"];
		ASIHTTPRequest *request = [t_Network httpGet:paramDic Url:LOGIN_REGISTER_URL Delegate:self Tag:LOGIN_REGISTER_URL_TAG];
		[request startAsynchronous];
	}
	else if (sender.tag == 10) {
		GoogleLoginViewController *glvc = [[GoogleLoginViewController alloc] initWithNibName:@"GoogleLoginViewController" bundle:nil];
		glvc.isLogin = NO;//不是登陆，不注册本地账号，注册googl账号直接登陆
		UINavigationController *googleNav = [[UINavigationController alloc] initWithRootViewController:glvc];
		googleNav.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
		googleNav.navigationBar.translucent = NO;
		[self presentViewController:googleNav animated:YES completion:nil];
	}
}

- (void)requestFinished:(ASIHTTPRequest *)request {
	NSString *responseStr = [request responseString];
	if ([@"1" isEqualToString:responseStr]) {
		GoogleLoginViewController *glvc = [[GoogleLoginViewController alloc] initWithNibName:@"GoogleLoginViewController" bundle:nil];
		glvc.isBind = YES;//注册本地账号是否要绑定google账号
		UINavigationController *googleNav = [[UINavigationController alloc] initWithRootViewController:glvc];
		[self presentViewController:googleNav animated:YES completion:nil];
	}
}

- (void)onClickClose {
	[self.navigationController popViewControllerAnimated:YES];
}

- (void)didReceiveMemoryWarning {
	[super didReceiveMemoryWarning];
	// Dispose of any resources that can be recreated.
}

@end
