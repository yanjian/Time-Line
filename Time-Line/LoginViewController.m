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
#import "LocalCalendarData.h"
#import "GoogleCalendarData.h"
#import "NSString+StringManageMd5.h"
#import "AT_Account.h"
#import "AnyEvent.h"
#import "Calendar.h"

@interface LoginViewController ()<ASIHTTPRequestDelegate,UITextFieldDelegate>{
NSArray *accountBindsArrs;//用户绑定的账号
}

@property (nonatomic,strong) NSMutableArray *calendarListArr;
@property(nonatomic,strong) NSMutableArray *requestQueue;
@property (nonatomic,strong) NSString *emailStr;
@property(nonatomic,strong) NSMutableArray *accountArr;
@end

@implementation LoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _calendarListArr=[NSMutableArray arrayWithCapacity:0];
    
     _requestQueue = @[].mutableCopy;
    
    self.navigationController.navigationBar.backgroundColor=[UIColor clearColor];
    [self.keyboardScorllView contentSizeToFit];
    self.username.delegate=self;
    self.passwordBtn.delegate=self;
    
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
}


-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    self.accountArr=[NSMutableArray arrayWithCapacity:0];
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
    
    if (sender.tag==10) {//login with Google button
        GoogleLoginViewController *glvc=[[GoogleLoginViewController alloc] initWithNibName:@"GoogleLoginViewController" bundle:nil];
        glvc.isLogin=YES;
        UINavigationController *googleNav=[[UINavigationController alloc] initWithRootViewController:glvc];
        googleNav.modalTransitionStyle=UIModalTransitionStyleCrossDissolve;
        googleNav.navigationBar.translucent=NO;
        [self presentViewController:googleNav animated:YES completion:nil];
    }else if (sender.tag==11){//Login button
        NSMutableDictionary *paramDic=[NSMutableDictionary dictionaryWithCapacity:0];
        if ([@"" isEqualToString:self.username.text]) {
            [ShowHUD showTextOnly:@"Please enter your user name" configParameter:^(ShowHUD *config) {
                config.animationStyle=MBProgressHUDAnimationFade;
                config.margin          = 20.f;    // 边缘留白
                config.opacity         = 0.7f;    // 设定透明度
                config.cornerRadius    = 10.f;     // 设定圆角
                config.textFont        = [UIFont systemFontOfSize:14.f];
            } duration:2 inView:self.view];
            return;
        }
        if ([@"" isEqualToString:self.passwordBtn.text]) {
            [ShowHUD showTextOnly:@"Please enter the password" configParameter:^(ShowHUD *config) {
                config.animationStyle=MBProgressHUDAnimationZoomOut;
                config.margin          = 20.f;    // 边缘留白
                config.opacity         = 0.7f;    // 设定透明度
                config.cornerRadius    = 10.f;     // 设定圆角
                config.textFont        = [UIFont systemFontOfSize:14.f];
            } duration:2 inView:self.view];
            return;
        }
        [paramDic setObject:self.username.text forKey:@"uName"];
        NSString *md5Pw= [[NSString stringWithString:self.passwordBtn.text] md5];
        [paramDic setObject:md5Pw forKey:@"uPw"];
        [paramDic setObject:@(UserLoginTypeLocal) forKey:@"type"];
        [self addNetWorkRequest:paramDic];
    }else if (sender.tag==12){//sign up button
        LoginRegisterViewController *loginRegist=[[LoginRegisterViewController alloc] init];
        
        [self.navigationController pushViewController:loginRegist animated:YES];
       
    }
}

-(void)addNetWorkRequest:(NSMutableDictionary *) dic{
    ASIHTTPRequest *request= [t_Network httpGet:dic Url:LOGIN_USER Delegate:self Tag:LOGIN_USER_TAG];
    [g_ASIQuent addOperation:request];
    [self addRequestTAG:LOGIN_USER_TAG];
}


-(void)addRequestTAG:(int) TAG
{
    [_requestQueue addObject:[[NSNumber numberWithInt:TAG] stringValue]];
}


- (void)requestFinished:(ASIHTTPRequest *)request
{
    
    NSUserDefaults *userInfo=[NSUserDefaults standardUserDefaults];
    NSString *responseStr=[request responseString];
    NSLog(@"%@",responseStr);
    switch (request.tag) {
        case LOGIN_USER_TAG:{//用户登录
            if ([@"1" isEqualToString:responseStr]) {
                ASIHTTPRequest *userInfoRequest= [t_Network httpGet:nil Url:LoginUser_GetUserInfo Delegate:self Tag:LoginUser_GetUserInfo_Tag];
                [g_ASIQuent addOperation:userInfoRequest];
                [self addRequestTAG:LoginUser_GetUserInfo_Tag];
                [userInfo setValue:self.username.text forKey:@"userName"];
                [userInfo setValue:[[NSString stringWithString:self.passwordBtn.text] md5] forKey:@"pwd"];
                [userInfo setValue:@(UserLoginStatus_YES) forKey:@"loginStatus"];
                [userInfo setValue:@(AccountTypeLocal) forKey:@"accountType"];
                GoogleLoginViewController *glvc=[[GoogleLoginViewController alloc] initWithNibName:@"GoogleLoginViewController" bundle:nil];
                glvc.isBind=YES;
                glvc.isSync=YES;
                glvc.isSeting=YES;
                UINavigationController *googleNav=[[UINavigationController alloc] initWithRootViewController:glvc];
                googleNav.navigationBar.translucent=NO;
                [self presentViewController:googleNav animated:YES completion:nil];
            }else{
                [ShowHUD showTextOnly:@"account or password error!" configParameter:^(ShowHUD *config) {
                    config.animationStyle=MBProgressHUDAnimationZoomOut;
                    config.margin          = 20.f;    // 边缘留白
                    config.opacity         = 0.7f;    // 设定透明度
                    config.cornerRadius    = 10.f;     // 设定圆角
                    config.textFont        = [UIFont systemFontOfSize:14.f];
                } duration:2 inView:self.view];
            }
            break;
        }
        case LoginUser_GetUserInfo_Tag:{//用户信息
            id loginUser= [responseStr objectFromJSONString];
            if ([loginUser isKindOfClass:[NSDictionary class]]) {
                NSString *statusCode= [loginUser objectForKey:@"statusCode"];
                if ([@"1" isEqualToString:statusCode]) {
                    ASIHTTPRequest *bindListRequest= [t_Network httpGet:nil Url:Local_CalendarOperation Delegate:self Tag:Local_CalendarOperation_Tag];
                   
                    [g_ASIQuent addOperation:bindListRequest];
                    [self addRequestTAG:Local_CalendarOperation_Tag];
                    NSDictionary *userInfoDic=[loginUser objectForKey:@"data"];
                    //accountBinds =     ({account = "yanjaya5201314@gmail.com";type = 1;uid = 76;})
                    NSArray *accountBinds=[userInfoDic objectForKey:@"accountBinds"] ;
                    if (accountBinds.count>0) {
                         ASIHTTPRequest *googleBindListRequest= [t_Network httpGet:nil Url:Get_Google_GetCalendarList Delegate:self Tag:Get_Google_GetCalendarList_Tag];
                        [g_ASIQuent addOperation:googleBindListRequest];
                        [self addRequestTAG:Get_Google_GetCalendarList_Tag];
                         [userInfo setValue:[userInfoDic objectForKey:@"accountBinds"] forKey:@"accountBinds"];
                    }
                   
                    AT_Account *atAcount=[AT_Account MR_createEntity];
                    NSString *userEmail=[userInfoDic objectForKey:@"email"];
                    atAcount.account=userEmail;
                    atAcount.accountType=@(AccountTypeLocal);
                    
                    [self.accountArr addObject:atAcount];
                    
                    self.emailStr=userEmail;
                    [userInfo setValue:userEmail forKey:@"email"];
                }
            }
            break;
        }
        case Local_CalendarOperation_Tag:{//得到本地日历
            NSMutableDictionary *localDataDic=[responseStr objectFromJSONString];
            NSString *statusCode=[localDataDic objectForKey:@"statusCode"];
            accountBindsArrs=[userInfo objectForKey:@"accountBinds"];
            
            if ([@"1" isEqualToString:statusCode]) {//成功取得本地日历列表
                NSArray *arr=[localDataDic objectForKey:@"data"];
                AT_Account *atAccount;
                for (AT_Account *at in self.accountArr) {
                    if ([at.accountType intValue]==AccountTypeLocal) {
                        atAccount=at;
                    }
                }
                
                NSMutableArray *localArr=[NSMutableArray arrayWithCapacity:0];
                for (NSDictionary *dic in arr) {
                    NSLog(@"%@",dic);
                    LocalCalendarData *ld=[[LocalCalendarData alloc] init];
                    [ld parseDictionary:dic];
                    [ld setEmailAccount:self.emailStr];
                    [ld setIsLocalAccount:YES];//代表本地账号
                    [localArr addObject:ld];
                }
                
                
                NSMutableSet *caArr=[NSMutableSet setWithCapacity:0];
                for (LocalCalendarData *local in localArr) {
                    Calendar *ca=[Calendar MR_createEntity];
                    ca.cid=local.Id;
                    ca.account=local.emailAccount;
                    ca.summary=local.calendarName;
                    ca.timeZone=[[NSTimeZone defaultTimeZone] name];
                    ca.backgroundColor=local.color;
                    ca.isVisible=@(1);
                    ca.type= @(AccountTypeLocal);
                    ca.isVisible=@(1);
                    ca.isNotification=@(1);
                    ca.isDefault=@(1);
                    ca.atAccount=atAccount;
                    [caArr addObject:ca];
                    [self synLocalEventData:ca];//同步本地事件
                }
                [atAccount addCa:caArr];
             }
            break;
        }
        case Get_Google_GetCalendarList_Tag:{//得到google日历
            if (![@"0" isEqualToString:responseStr]) {
                NSMutableDictionary *googleDataDic=[responseStr objectFromJSONString];
                NSArray *arr=[googleDataDic objectForKey:@"items"];
                
                NSMutableArray *googleArr=[NSMutableArray arrayWithCapacity:0];
                NSString *accountStr;
                for (NSDictionary *dic in arr) {
                    NSString *tmpstr=[dic objectForKey:@"id"];
                    if ([tmpstr hasSuffix:@"@gmail.com"]) {
                        accountStr=tmpstr;
                    }
                    NSLog(@"%@",dic);
                    GoogleCalendarData *gcd=[[GoogleCalendarData alloc] init];
                    [gcd parseDictionary:dic];
                    [gcd setAccount:accountStr];
                    [googleArr addObject:gcd];
                }
                
                [self.calendarListArr addObject:googleArr];
                
                NSArray *accountArr=[userInfo objectForKey:@"accountBinds"];
                NSMutableArray *accArr=[NSMutableArray arrayWithCapacity:0];
                if (accountArr&&accountArr.count>0) {
                    for (NSDictionary *accountDic in accountArr) {
                         AT_Account *atAccount=[AT_Account MR_createEntity];
                         atAccount.account=[accountDic objectForKey:@"account"];
                         atAccount.accountType=@(AccountTypeGoogle);
                        [accArr addObject:atAccount];
                    }
                }
                
                for (AT_Account *atAccount in accArr) {
                    NSMutableSet *caArr=[NSMutableSet setWithCapacity:0];
                    for (GoogleCalendarData *googleData in googleArr) {
                        Calendar *ca=[Calendar MR_createEntity];
                        ca.cid=googleData.Id;
                        ca.account=googleData.account;
                        ca.summary=googleData.summary;
                        ca.timeZone=googleData.timeZone;
                        ca.backgroundColor=googleData.backgroundColor;
                        ca.isVisible=@(1);
                        ca.type= @(AccountTypeGoogle);
                        ca.isVisible=@(1);
                        ca.isNotification=@(1);
                        ca.isDefault=@(1);
                        ca.atAccount=atAccount;
                        [caArr addObject:ca];
                    }
                    [atAccount addCa:caArr];
                    [[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreAndWait];
                }
                
            }
            [self cancelNetWorkrequestQueue];//取消网络请求队列
            break;
        }
        case Local_SingleEventOperation_Tag:{
            [self paseLocalEventRequest:responseStr request:request];
            if (accountBindsArrs.count<=0) {
                [self cancelNetWorkrequestQueue];//取消网络请求队列
            }
            break;
        }
        default:
            break;
       [userInfo synchronize];
    }
}


-(void)synLocalEventData:(Calendar *)localca{
    ASIHTTPRequest *localRequest=[t_Network httpGet:@{@"cid":localca.cid}.mutableCopy Url:Local_SingleEventOperation Delegate:self Tag:Local_SingleEventOperation_Tag userInfo:@{@"localData":localca}];
      [g_ASIQuent addOperation:localRequest];
    [self addRequestTAG:Local_SingleEventOperation_Tag];
}

//下面在CalendarListViewController中也存在 需优化解决
-(void)paseLocalEventRequest:(NSString *) responseStr request:(ASIHTTPRequest *)request{
    NSDictionary *eventDic=[responseStr objectFromJSONString];
    NSString *status=[eventDic objectForKey:@"statusCode"];
    if ([@"1" isEqualToString:status]) {//状态成功
        Calendar *calendar= (Calendar *)[request.userInfo objectForKey:@"localData"];
        id eventData=[eventDic objectForKey:@"data"];
        NSMutableSet *localSet=[NSMutableSet setWithCapacity:0];
        if ([eventData isKindOfClass:[NSArray class]]) {
                NSArray *eventArr=(NSArray *)eventData;
                for (NSMutableDictionary *event in eventArr) {
                     NSMutableDictionary *eventDic=[event mutableCopy];
                    [eventDic setObject:calendar forKey:@"calendar"];
                    [localSet addObject:[self paseLocalEventData:eventDic] ];
                }
            }
            [calendar addAnyEvent:localSet];
        }
     [[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreAndWait];
}
-(AnyEvent *)paseLocalEventData:(NSDictionary *) dataDic{
    AnyEvent *anyEvent=[AnyEvent MR_createEntity];
    
    NSString *statrstring=[[PublicMethodsViewController getPublicMethods] stringFormaterDate:@"YYYY年 M月d日HH:mm" dateString:[dataDic objectForKey:@"startTime"]];
    
    anyEvent.eventTitle=[dataDic objectForKey:@"title"];
    if ([dataDic objectForKey:@"location"]) {
        anyEvent.location= [dataDic objectForKey:@"location"];
    }
    anyEvent.eId=[dataDic objectForKey:@"id"];
    anyEvent.sequence=[dataDic objectForKey:@"sequence"];
    anyEvent.created=[[PublicMethodsViewController getPublicMethods] rfc3339DateFormatter:[NSDate new]];
    anyEvent.updated=[[PublicMethodsViewController getPublicMethods] rfc3339DateFormatter:[NSDate new]];
    anyEvent.status=[[dataDic objectForKey:@"status"] isEqualToString:cancelled]?[NSString stringWithFormat:@"%i",eventStatus_cancelled] :[NSString stringWithFormat:@"%i",eventStatus_confirmed];

    anyEvent.startDate= statrstring;
    anyEvent.isAllDay=@([[dataDic objectForKey:@"allDay"] intValue]);//是否是全天事件
    anyEvent.endDate= [[PublicMethodsViewController getPublicMethods] stringFormaterDate:@"YYYY年 M月d日HH:mm" dateString:[dataDic objectForKey:@"endTime"]];
    
    if ([dataDic objectForKey:@"note"]) {
        anyEvent.note= [dataDic objectForKey:@"note"];
    }
    if ([dataDic objectForKey:@"calendar"]) {
        Calendar *ca=[dataDic objectForKey:@"calendar"];
        anyEvent.calendar=ca;
        anyEvent.creator=ca.account;
        anyEvent.creatorDisplayName=ca.summary;
        anyEvent.organizer =ca.account;
        anyEvent.orgDisplayName=ca.summary;
    }
    anyEvent.isSync=@(isSyncData_YES);//表示已经是同步的数据
    return anyEvent;
}

@end
