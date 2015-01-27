//
//  AliasModifyViewController.m
//  Time-Line
//
//  Created by IF on 15/1/19.
//  Copyright (c) 2015年 zhilifang. All rights reserved.
//

#import "AliasModifyViewController.h"

@interface AliasModifyViewController ()
@property (weak, nonatomic) IBOutlet UITextField *aliasText;

@end

@implementation AliasModifyViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"Alias Modify";
    self.navigationItem.hidesBackButton = YES ;
    
    UIButton * leftButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    leftButton.frame = CGRectMake(15, 30, 21, 25);
    leftButton.backgroundColor = [UIColor clearColor];
    [leftButton setBackgroundImage:[UIImage imageNamed:@"Icon_BackArrow"] forState:UIControlStateNormal];
    leftButton.tag = 1;
    [leftButton addTarget:self action:@selector(aliasTouchUpInside:) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:leftButton];
    
    UIButton*  rightBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [rightBtn setTag:2];
    [rightBtn setBackgroundImage:[UIImage imageNamed:@"Icon_Tick.png"] forState:UIControlStateNormal];
    [rightBtn setFrame:CGRectMake(0, 2, 30, 25)];
    [rightBtn addTarget:self action:@selector(aliasTouchUpInside:) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithCustomView:rightBtn];
    if (self.alias && ![self.alias isEqualToString:@""]) {
        [self.aliasText setText:self.alias] ;
    }
    [self.aliasText resignFirstResponder];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}


-(void)aliasTouchUpInside:(UIButton *) sender {
    switch (sender.tag) {
        case 1:{
            [self.navigationController popViewControllerAnimated:YES ] ;
        }break;
        case 2:{
            NSString *aliasName = [self.aliasText.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
            if (!self.aliasText.text || [@"" isEqualToString:aliasName]) {
                [MBProgressHUD showError:@"Please enter an alias"];
                return;
            }
            
            ASIHTTPRequest * request = [t_Network httpGet:@{@"fid":self.fid,@"name":aliasName }.mutableCopy Url:anyTime_UpdateFriendNickName Delegate:nil Tag:anyTime_UpdateFriendNickName_tag] ;
            __block ASIHTTPRequest * aliasRequest = request;
            [request setCompletionBlock:^{
                NSString * responseStr = [aliasRequest responseString];
                id objGroup = [responseStr objectFromJSONString];
                if ([objGroup isKindOfClass:[NSDictionary class]]) {
                    NSString *statusCode = [objGroup objectForKey:@"statusCode"];
                    if ([statusCode isEqualToString:@"1"]) {
                        if (self.aliasModify) {
                            self.aliasModify(self,aliasName);
                        }
                    }
                }
            }];
            [request setFailedBlock:^{
                [MBProgressHUD showError:@"Network error!"] ;
            }];
            [request startAsynchronous] ;
        }break;
        default:
            break;
    }
    
}

@end
