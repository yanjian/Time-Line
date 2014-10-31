//
//  LoginRegisterViewController.m
//  Time-Line
//
//  Created by IF on 14-9-28.
//  Copyright (c) 2014年 zhilifang. All rights reserved.
//

#import "LoginRegisterViewController.h"
#import "LoginViewController.h"
#import "GoogleLoginViewController.h"
@interface LoginRegisterViewController ()<ASIHTTPRequestDelegate>

@end

@implementation LoginRegisterViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Do any additional setup after loading the view from its nib.
}
- (IBAction)commonAllEvent:(UIButton *)sender {
    if (sender.tag==12) {
        LoginViewController *loginView=[[LoginViewController alloc] init];
        [self presentViewController:loginView animated:YES completion:nil];
    }else if (sender.tag==11){
        NSMutableDictionary *paramDic=[NSMutableDictionary dictionaryWithCapacity:0];
        if (self.userNameTextField.text) {
            [g_AppDelegate showActivityView:@"userName empty" interval:5];
            return;
        }if (self.passwordTextField.text) {
            [g_AppDelegate showActivityView:@"password empty" interval:5];
            return;
        }if (self.emailTextField.text) {
            [g_AppDelegate showActivityView:@"email empty" interval:5];
            return;
        }
        [paramDic setObject:self.userNameTextField.text forKey:@"uName"];
        [paramDic setObject:self.passwordTextField.text forKey:@"uPw"];
        [paramDic setObject:self.emailTextField.text forKey:@"email"];
        [paramDic setObject:@(UserLoginTypeLocal) forKey:@"type"];
       ASIHTTPRequest *request= [t_Network httpGet:paramDic Url:LOGIN_REGISTER_URL Delegate:self Tag:LOGIN_REGISTER_URL_TAG];
        [request startAsynchronous];
    }else if (sender.tag==10){
         GoogleLoginViewController *glvc=[[GoogleLoginViewController alloc] initWithNibName:@"GoogleLoginViewController" bundle:nil];
        glvc.isLogin=NO;//不是登陆，不注册本地账号，注册googl账号直接登陆
        UINavigationController *googleNav=[[UINavigationController alloc] initWithRootViewController:glvc];
        [self presentViewController:googleNav animated:YES completion:nil];

    }
    
}

- (void)requestFinished:(ASIHTTPRequest *)request
{
    NSString *responseStr=[request responseString];
    if ([@"1" isEqualToString:responseStr]) {
        GoogleLoginViewController *glvc=[[GoogleLoginViewController alloc] initWithNibName:@"GoogleLoginViewController" bundle:nil];
        glvc.isBind=YES;//注册本地账号是否要绑定google账号
        UINavigationController *googleNav=[[UINavigationController alloc] initWithRootViewController:glvc];
        [self presentViewController:googleNav animated:YES completion:nil];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
