//
//  LoginViewController.m
//  Go2
//
//  Created by IF on 14-9-26.
//  Copyright (c) 2014年 zhilifang. All rights reserved.
//

#import "LoginViewController.h"
#import "TPKeyboardAvoidingScrollView.h"
#import "GoogleLoginViewController.h"
#import "LoginRegisterViewController.h"
#import "AnyEvent.h"
#import "Calendar.h"

@interface LoginViewController ()<ASIHTTPRequestDelegate,UITextFieldDelegate>{
   NSArray  * accountBindsArrs;//用户绑定的账号
   UserInfo * uInfo;
}

@property(nonatomic,strong) NSMutableArray *requestQueue;
@end

@implementation LoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
     _requestQueue = @[].mutableCopy;
    
    self.navigationController.navigationBar.backgroundColor = [UIColor clearColor];
    [self.keyboardScorllView contentSizeToFit];
    self.username.delegate    = self;
    self.passwordBtn.delegate = self;
    
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
}


-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    //启动网络请求队列
    [g_ASIQuent go];
}


-(void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
}


#pragma  mark - 取消网络请求队列
-(void)cancelNetWorkrequestQueue{
    for (ASIHTTPRequest *request in g_ASIQuent.operations) {
        if (request) {
            [_requestQueue enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                int requestTag = [obj intValue];
                if (request.tag == requestTag) {
                    NSLog(@"取消网络请求队列.......%d",requestTag);
                    [request clearDelegatesAndCancel];
                }
            }];
        }
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



#pragma mark - 登陆页上按钮事件
- (IBAction)commonButtonEvent:(UIButton *)sender {
    
    if (sender.tag == 10) {//login with Google button
        GoogleLoginViewController *glvc=[[GoogleLoginViewController alloc] initWithNibName:@"GoogleLoginViewController" bundle:nil];
        glvc.isLogin=YES;
        UINavigationController *googleNav=[[UINavigationController alloc] initWithRootViewController:glvc];
        googleNav.modalTransitionStyle=UIModalTransitionStyleCrossDissolve;
        googleNav.navigationBar.translucent=NO;
        [self presentViewController:googleNav animated:YES completion:nil];
    }else if (sender.tag == 11){//Login button
        NSMutableDictionary *paramDic=[NSMutableDictionary dictionaryWithCapacity:0];
        NSString * usernsme = [self.username.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];//去掉左右空格
         NSString * password = [self.passwordBtn.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        if ([ @"" isEqualToString:usernsme ]) {
            [MBProgressHUD showError:@"Please enter your user name"];
            return;
        }
        if ([ @"" isEqualToString:password ]) {
            [MBProgressHUD showError:@"Please enter the password"];
            return;
        }
        [paramDic setObject:usernsme forKey:@"username"];
        [paramDic setObject:password forKey:@"pwd"];
#if !TARGET_IPHONE_SIMULATOR
        NSString * deviceStr = [USER_DEFAULT objectForKey:DeviceTokenKey];
        if( deviceStr ){
            [paramDic setObject:@(0) forKey:@"type"];
            
        }else{
            [paramDic setObject:@(1) forKey:@"type"];  
        }

        [paramDic setObject:deviceStr forKey:@"deviceToken"];
#endif
        [self addNetWorkRequest:paramDic];
    }else if (sender.tag == 12){//sign up button
        LoginRegisterViewController *loginRegist=[[LoginRegisterViewController alloc] init];
        [self.navigationController pushViewController:loginRegist animated:YES];
       
    }
}

-(void)addNetWorkRequest:(NSMutableDictionary *) dic{
//    if (g_NetStatus == NotReachable) {
//         [MBProgressHUD showError:@"Network connection failure"];
//        return;
//    }
    [MBProgressHUD showMessage:@"Loading..."];
    ASIHTTPRequest *request= [t_Network httpGet:dic Url:Go2_UserLogin Delegate:self Tag:Go2_UserLogin_Tag];
    [g_ASIQuent addOperation:request];
    [self addRequestTAG:LOGIN_USER_TAG];
}


-(void)addRequestTAG:(int) TAG
{
    [_requestQueue addObject:[[NSNumber numberWithInt:TAG] stringValue]];
}


- (void)requestFinished:(ASIHTTPRequest *)request
{
    NSString *responseStr=[request responseString];
    NSLog(@"%@",responseStr);
    switch (request.tag) {
        case Go2_UserLogin_Tag:{//用户登录
             [MBProgressHUD hideHUD] ;
            id loginUser= [responseStr objectFromJSONString];
            if ([loginUser isKindOfClass:[NSDictionary class]]) {
                NSString *statusCode= [loginUser objectForKey:@"statusCode"];
                if ( 1 == [statusCode intValue]) {

                    [USER_DEFAULT removeObjectForKey:CURRENTUSERINFO];
                    [USER_DEFAULT removeObjectForKey:XMPP_ANYTIMENAME];
                    [USER_DEFAULT removeObjectForKey:XMPP_ANYTIMEPWD];
                    [USER_DEFAULT synchronize];
                    
                    uInfo = [UserInfo currUserInfo];//当前用户信息对象

                    uInfo.username = self.username.text ;
                    uInfo.password = [NSString stringWithString:self.passwordBtn.text] ;
                    uInfo.loginStatus = UserLoginStatus_YES ;
                    uInfo.accountType = AccountTypeLocal ;
                    
                    NSMutableDictionary *userInfoDic=[NSMutableDictionary dictionaryWithDictionary:[loginUser objectForKey:@"data"]] ;//请求到的用信息
                    
                    [uInfo parseDictionary:userInfoDic];
                    uInfo.gender=[[userInfoDic objectForKey:@"gender"] intValue]==0?gender_woman:gender_man;
                    uInfo.imgUrl=[userInfoDic objectForKey:@"imgBig"];
                    uInfo.imgUrlSmall=[userInfoDic objectForKey:@"imgBig"];
        

                    GoogleLoginViewController *glvc=[[GoogleLoginViewController alloc] initWithNibName:@"GoogleLoginViewController" bundle:nil];
                    glvc.isBind=YES;
                    glvc.isSync=YES;
                    glvc.isSeting=YES;
                    UINavigationController *googleNav=[[UINavigationController alloc] initWithRootViewController:glvc];
                    googleNav.navigationBar.translucent=NO;
                    [self presentViewController:googleNav animated:YES completion:^{
                        
                        NSData * userInfoData = [NSKeyedArchiver archivedDataWithRootObject:uInfo];
                        [USER_DEFAULT setValue:[NSString stringWithFormat:@"anytime_%@@ubuntu",uInfo.username] forKey:XMPP_ANYTIMENAME];
                        [USER_DEFAULT setValue:[NSString stringWithFormat:XMPP_PWD] forKey:XMPP_ANYTIMEPWD];
                        
                        [USER_DEFAULT setObject:userInfoData forKey:CURRENTUSERINFO];
                        [USER_DEFAULT synchronize];
                        [g_AppDelegate connect]; //链接到openfire上
                       
                        ASIHTTPRequest *localRequest= [t_Network httpGet:nil Url:Go2_GetCalendars Delegate:self Tag:Go2_GetCalendars_Tag];
                        
                        [g_ASIQuent addOperation:localRequest];
                        [self addRequestTAG:Go2_GetCalendars_Tag];
                    }];
                }else{
                    [MBProgressHUD showError:@"account or password error!"];
                 }
            }
            break;
        }
        case Go2_GetCalendars_Tag:{//日历列表
            id loginUser = [responseStr objectFromJSONString];
            if ([loginUser isKindOfClass:[NSDictionary class]]) {
                NSString *statusCode= [loginUser objectForKey:@"statusCode"];
                if (1 == [statusCode intValue]) {
                    
                    NSArray * dataArr = [loginUser objectForKey:@"datas"] ;//请求到的用信息
                    [dataArr enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                        Calendar * clm      = [Calendar MR_createEntity];
                        clm.cid             = [obj objectForKey:@"id"];
                        clm.account         = [UserInfo currUserInfo].username;
                        clm.summary         = [obj objectForKey:@"name"];
                        clm.backgroundColor = [obj objectForKey:@"color"];
                        clm.baid            = [obj objectForKey:@"baid"];
                        clm.type            = @(AccountTypeLocal) ;
                        if( [[obj objectForKey:@"name"] caseInsensitiveCompare:@"work"] == NSOrderedSame ){
                            clm.isDefault   = @(CalendarList_IsDefault_Yes) ;
                        }else{
                            clm.isDefault   = @(CalendarList_IsDefault_No) ;
                        }
                        clm.isNotification  = @(CalendarList_IsNotification_Yes);
                        clm.isVisible = @(CalendarList_IsVisible_Yes);
                        
                        ASIHTTPRequest *localRequest= [t_Network httpGet:@{@"method":@"query",@"cid":clm.cid}.mutableCopy Url:Go2_Local_privateEvent Delegate:self Tag:Go2_Local_privateEvent_Tag userInfo:@{@"calendar":clm}];
                        
                        [g_ASIQuent addOperation:localRequest];
                        [self addRequestTAG:Go2_Local_privateEvent_Tag];

                    }] ;
                }
            }
            break;
        }
        case Go2_Local_privateEvent_Tag:{
            id localEvent = [responseStr objectFromJSONString];
            if ([localEvent isKindOfClass:[NSDictionary class]]) {
                NSString * statusCode = [localEvent objectForKey:@"statusCode"];
                if (1 == [statusCode intValue]) {
                    Calendar * ca = [[request userInfo] objectForKey:@"calendar"];
                    NSArray * dataArr = [localEvent objectForKey:@"datas"] ;//请求到的用信息
                    [dataArr enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                        NSDictionary * dataDic = (NSDictionary *) obj ;
                        [self paseSaveLocalEvent:dataDic calendar:ca] ;
                    }];
                }
            }
        }break;
    }
}


- (void)requestFailed:(ASIHTTPRequest *)request{
    NSError *error = [request error];
    [MBProgressHUD hideHUD] ;
    if (error) {
        NSLog(@"%@",[error userInfo]);
        [MBProgressHUD showError:@"Error"];
    }
}

-(void)paseSaveLocalEvent:(NSDictionary *) dataDic calendar:(Calendar *) ca {
    if (dataDic) {
        AnyEvent * anyEvent = [AnyEvent MR_createEntity];
        anyEvent.isSync = @(isSyncData_YES);
        
        anyEvent.eventTitle = [dataDic objectForKey:@"title"];
        anyEvent.note = [dataDic objectForKey:@"description"];
        anyEvent.isAllDay = [dataDic objectForKey:@"isAllDay"] ;
        NSString *location = [dataDic objectForKey:@"location"];
        if (![location isEqualToString:@""] && location) {
            anyEvent.location = [dataDic objectForKey:@"location"];
        }
        anyEvent.eId = [dataDic objectForKey:@"id"];
        NSString *repeat = [dataDic objectForKey:@"repeat"];
        if (![@"" isEqualToString:repeat]) {
            anyEvent.repeat = repeat;
            
        }
        
        NSString *originalStartTime = [dataDic objectForKey:@"originalStartTime"] ;
        if (![originalStartTime isEqualToString:@""]&&originalStartTime) {
            anyEvent.originalStartTime = originalStartTime;
        }
        
        NSString *recurringEventId = [dataDic objectForKey:@"recurringEventId"];
        if (![@"" isEqualToString:recurringEventId]&&recurringEventId) {
            anyEvent.recurringEventId = recurringEventId;
        }
        
        NSString *statrstring = [[PublicMethodsViewController getPublicMethods] stringFormaterDate:@"YYYY年 M月d日HH:mm" dateString:[dataDic objectForKey:@"start"]];
        anyEvent.sequence = [dataDic objectForKey:@"sequence"];
        
        NSString *recurrence = [dataDic objectForKey:@"recurrence"];
        if (![@"" isEqualToString:recurrence]&&recurrence) {
            anyEvent.recurrence = [dataDic objectForKey:@"recurrence"];
        }
        anyEvent.created = [[PublicMethodsViewController getPublicMethods] rfc3339DateFormatter:[NSDate new]];
        anyEvent.updated = [[PublicMethodsViewController getPublicMethods] rfc3339DateFormatter:[NSDate new]];
        anyEvent.status  = [NSString stringWithFormat:@"%i", [[dataDic objectForKey:@"status"] intValue]];
        anyEvent.startDate= statrstring;
        anyEvent.endDate   = [[PublicMethodsViewController getPublicMethods] stringFormaterDate:@"YYYY年 M月d日HH:mm" dateString:[dataDic objectForKey:@"end"]];
        if (ca) {
            anyEvent.calendar           = ca;
            anyEvent.creator            = ca.account;
            anyEvent.creatorDisplayName = ca.summary;
            anyEvent.organizer          = ca.account;
            anyEvent.orgDisplayName     = ca.summary;
            anyEvent.calendarAccount    = ca.summary ;
            [ca addAnyEventObject:anyEvent];
        }
        [[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreAndWait];
    }
}

@end
