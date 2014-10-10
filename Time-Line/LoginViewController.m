//
//  LoginViewController.m
//  Time-Line
//
//  Created by IF on 14-9-26.
//  Copyright (c) 2014年 zhilifang. All rights reserved.
//

#import "LoginViewController.h"
#import "TPKeyboardAvoidingScrollView.h"
#import "GoogleLoginViewController.h"
#import "LoginRegisterViewController.h"

@interface LoginViewController ()<ASIHTTPRequestDelegate,UITextFieldDelegate>
@property (nonatomic,assign) BOOL isGetUserInfo;
@end

@implementation LoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationController.navigationBar.backgroundColor=[UIColor clearColor];
    [self.keyboardScorllView contentSizeToFit];
    self.username.delegate=self;
    self.passwordBtn.delegate=self;
    
}


-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField{
    self.ErrerMsg.text=@"";
    return YES;

}

//登陆页上按钮事件
- (IBAction)commonButtonEvent:(UIButton *)sender {
    
    if (sender.tag==10) {//login with Google button
        GoogleLoginViewController *glvc=[[GoogleLoginViewController alloc] initWithNibName:@"GoogleLoginViewController" bundle:nil];
        glvc.isLogin=YES;
        UINavigationController *googleNav=[[UINavigationController alloc] initWithRootViewController:glvc];
        googleNav.modalTransitionStyle=UIModalTransitionStyleCrossDissolve;
        [self presentViewController:googleNav animated:YES completion:nil];
    }else if (sender.tag==11){//Login button
        NSMutableDictionary *paramDic=[NSMutableDictionary dictionaryWithCapacity:0];
        [paramDic setObject:self.username.text forKey:@"uName"];
        [paramDic setObject:self.passwordBtn.text forKey:@"uPw"];
        [paramDic setObject:@(UserLoginTypeLocal) forKey:@"type"];
        ASIHTTPRequest *request= [t_Network httpGet:paramDic Url:LOGIN_USER Delegate:self Tag:LOGIN_USER_TAG];
        [request startAsynchronous];
    }else if (sender.tag==12){//sign up button
        LoginRegisterViewController *loginRegist=[[LoginRegisterViewController alloc] init];
        loginRegist.modalTransitionStyle=UIModalTransitionStyleCrossDissolve;
        [self presentViewController:loginRegist animated:YES completion:nil];
    }
}

- (void)requestFinished:(ASIHTTPRequest *)request
{
    NSUserDefaults *userInfo=[NSUserDefaults standardUserDefaults];
     NSString *responseStr=[request responseString];
    if (!self.isGetUserInfo) {
        if ([@"1" isEqualToString:responseStr]) {
            ASIHTTPRequest *request= [t_Network httpGet:nil Url:LoginUser_GetUserInfo Delegate:self Tag:LoginUser_GetUserInfo_Tag];
            [request startAsynchronous];
            
            [userInfo setValue:self.username.text forKey:@"userName"];
            [userInfo setValue:@(UserLoginStatus_YES) forKey:@"loginStatus"];
            
            GoogleLoginViewController *glvc=[[GoogleLoginViewController alloc] initWithNibName:@"GoogleLoginViewController" bundle:nil];
            glvc.isBind=YES;
            
            UINavigationController *googleNav=[[UINavigationController alloc] initWithRootViewController:glvc];
            [self presentViewController:googleNav animated:YES completion:nil];
        }else{
            self.ErrerMsg.text=@"account or password error!";
        }
        self.isGetUserInfo=YES;
    }else{
       id loginUser= [responseStr objectFromJSONString];
        if ([loginUser isKindOfClass:[NSDictionary class]]) {
           NSString *statusCode= [loginUser objectForKey:@"statusCode"];
            if ([@"1" isEqualToString:statusCode]) {
                NSDictionary *userInfoDic=[loginUser objectForKey:@"data"];
                [userInfo setValue:[userInfoDic objectForKey:@"accountBinds"] forKey:@"accountBinds"];
                [userInfo setValue:[loginUser objectForKey:@"email"] forKey:@"email"];
            }
        }
    }
    [userInfo synchronize];
    
}

@end
