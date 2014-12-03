//
//  AppDelegate.m
//  Time-Line
//
//  Created by IF on 14-9-1.
//  Copyright (c) 2014年 zhilifang. All rights reserved.
//

#import "AppDelegate.h"
#import "HomeViewController.h"
#import <GoogleMaps/GoogleMaps.h>
#import "AddEventViewController.h"
#import "LoginViewController.h"
#import "CoreDataUtil.h"
#import "SloppySwiper.h"
@interface AppDelegate ()<ASIHTTPRequestDelegate>{
LoginViewController *loginVc;
HomeViewController *homeVC;
UINavigationController *nav;
}
@property (strong, nonatomic) SloppySwiper *swiper;
@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Override point for customization after application launch.
    self.window=[[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.backgroundColor=[UIColor whiteColor];
    [GMSServices provideAPIKey:GOOGLE_API_KEY];
    //[CoreDataUtil launch];
    
    [MagicalRecord setupCoreDataStackWithStoreNamed:@"TimeLine.sqlite"];
    
    // 监测网络情况
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(reachabilityChanged:)
                                                 name: kReachabilityChangedNotification
                                               object: nil];
    Reachability *hostReach = [Reachability reachabilityWithHostname:@"www.baidu.com"];
    [hostReach startNotifier];
    
    
    //ASI QUENE
    _netWorkQueue= [[ASINetworkQueue alloc] init];
    [_netWorkQueue setShouldCancelAllRequestsOnFailure:NO];
    
    _netWorkStatus = ReachableViaWiFi;
    
    NSTimeInterval timeInterval= [self getRefreshFetchTimetimeInterval];
    if (timeInterval==0) {
        timeInterval= UIApplicationBackgroundFetchIntervalNever;
    }
    [application setMinimumBackgroundFetchInterval:timeInterval];

    
   //[[UIApplication sharedApplication] cancelAllLocalNotifications];

    
    
    //初始化 MBProgressHUD控件
    _HUD=[[MBProgressHUD alloc] initWithView:self.window];
    [self.window addSubview:_HUD];
    
    UILocalNotification *localNotif =[launchOptions objectForKey:UIApplicationLaunchOptionsLocalNotificationKey];
    if (localNotif) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"ALERT"
                                                        message:localNotif.alertBody
                                                       delegate:nil
                                              cancelButtonTitle:@"确定"
                                              otherButtonTitles:nil];
        [alert show];
        application.applicationIconBadgeNumber = 0;
	}
    
    _isread=YES;
    
    [self initMainView];
    
    return YES;
}

-(void)userLogin{
    if ([USER_DEFAULT objectForKey:@"userName"]) {
        NSMutableDictionary *paramDic=[NSMutableDictionary dictionaryWithCapacity:0];
        BOOL isAccount=[[USER_DEFAULT objectForKey:@"accountType"] boolValue];
        if (isAccount) {//本地账号
            [paramDic setObject:[USER_DEFAULT objectForKey:@"userName"]forKey:@"uName"];
            [paramDic setObject:[USER_DEFAULT objectForKey:@"pwd"] forKey:@"uPw"];
            [paramDic setObject:@(UserLoginTypeLocal) forKey:@"type"];
            ASIHTTPRequest *request=[t_Network httpGet:paramDic Url:LOGIN_USER Delegate:self Tag:LOGIN_USER_TAG];
            [request startAsynchronous];
            return;
        }
        if([USER_DEFAULT objectForKey:@"email"] )
          [paramDic setObject:[USER_DEFAULT objectForKey:@"email"] forKey:@"email"];
        if ([USER_DEFAULT objectForKey:@"authCode"]) {
            [paramDic setObject:[USER_DEFAULT objectForKey:@"authCode"] forKey:@"authCode"];
            [paramDic setObject:@(UserLoginTypeGoogle) forKey:@"type"];
            ASIHTTPRequest *request=[t_Network httpGet:paramDic Url:LOGIN_USER Delegate:self Tag:LOGIN_USER_TAG];
            [request startAsynchronous];
        }
    }
}

-(NSTimeInterval)getRefreshFetchTimetimeInterval{
    //@"15 minutes",@"30 minutes",@"1 hour",@"2 hour",@"never"
   NSString *timeStr= [USER_DEFAULT objectForKey:@"refTime"];
    double timeMs=0;
    if ([@"15 minutes" isEqualToString:timeStr]) {
        timeMs=15*60*1000;
    }else if([@"30 minutes" isEqualToString:timeStr]){
         timeMs=30*60*1000;
    }else if([@"1 hour" isEqualToString:timeStr]){
        timeMs=60*60*1000;
    }else if([@"2 hour" isEqualToString:timeStr]){
        timeMs=120*60*1000;
    }
    return timeMs;
}

-(void) initLoginView:(id )target{
    loginVc = [[LoginViewController alloc] init];
    nav=[[UINavigationController alloc] initWithRootViewController:loginVc];
    nav.navigationBar.hidden=YES;
    self.swiper = [[SloppySwiper alloc] initWithNavigationController:nav];
    nav.delegate = self.swiper;
    [target presentViewController:nav animated:YES completion:nil];
}

- (void)requestFinished:(ASIHTTPRequest *)request{
    NSString *str=[request responseString];
    switch (request.tag) {
        case LOGIN_USER_TAG:
            if ([@"1" isEqualToString:str]) {
                NSLog(@"登陆成功");
            }else if ([@"2" isEqualToString:str]){
                NSLog(@"已经登陆");
            }else {
                NSLog(@"登陆错误");
            }

            break;
        case LoginUser_GetUserInfo_Tag:{
            if ([@"-1000" isEqualToString:str]) {
                [self userLogin];
            }
            break;
        }
        default:
            break;
    }
}

//初始化mian界面
-(void)initMainView
{
    homeVC=[[HomeViewController alloc] initWithNibName:@"HomeViewController" bundle:nil];
    homeVC.isRefreshUIData=YES;//初始化的时候刷新ui加载数据
    nav=[[UINavigationController alloc] initWithRootViewController:homeVC];
    nav.navigationBarHidden=YES;
    nav.navigationBar.translucent=NO;
    self.window.rootViewController=nav;
    [self.window makeKeyAndVisible];
}


- (void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification
{
    
    if (notification)
    {
        UIApplicationState state = application.applicationState;
        
        if (state == UIApplicationStateActive) {
            
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"ALERT"
                                                            message:notification.alertBody
                                                           delegate:nil
                                                  cancelButtonTitle:@"确定"
                                                  otherButtonTitles:nil];
            [alert show];
        }
       
        
        application.applicationIconBadgeNumber=0;
        int count =[[[UIApplication sharedApplication] scheduledLocalNotifications] count];
        if(count>0)
        {
            NSMutableArray *newarry= [NSMutableArray arrayWithCapacity:0];
            for (int i=0; i<count; i++) {
                UILocalNotification *notif=[[[UIApplication sharedApplication] scheduledLocalNotifications] objectAtIndex:i];
                notif.applicationIconBadgeNumber=i+1;
                [newarry addObject:notif];
            }
            [[UIApplication sharedApplication] cancelAllLocalNotifications];
            if (newarry.count>0) {
                for (int i=0; i<newarry.count; i++) {
                    UILocalNotification *notif = [newarry objectAtIndex:i];
                    [[UIApplication sharedApplication] scheduleLocalNotification:notif];
                }
            }
        }
    }
}


//网络状态发生变化
- (void)reachabilityChanged:(NSNotification *)note
{
    Reachability* curReach = [note object];
    NSParameterAssert([curReach isKindOfClass: [Reachability class]]);
    NetworkStatus status = [curReach currentReachabilityStatus];
    self.netWorkStatus = status;
    if([curReach isReachable]){
        NSLog(@"网络可用YES");
        //检查用户是否在登录状态 返回-1000表示没有登录
        ASIHTTPRequest *request=[t_Network httpGet:nil Url:LoginUser_GetUserInfo Delegate:self Tag:LoginUser_GetUserInfo_Tag];
        [request startAsynchronous];
    }else{
        NSLog(@"网络不可用NO");
        [self noReachabilityChanged];
    }
}

//网络改变
-(void)noReachabilityChanged
{
//    UIAlertView *alert;
//    alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"请检查你的网络连接" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil];
//    [alert show];
    NSLog(@"无网络连接");
}

- (void)application:(UIApplication *)application performFetchWithCompletionHandler:(void (^)(UIBackgroundFetchResult result))completionHandler
{
    
    UINavigationController *nav=(UINavigationController *)self.window.rootViewController;
    id fetchViewControl=nav.topViewController;
    if ([fetchViewControl respondsToSelector:@selector(fetchDataResult:)]) {
        if ([fetchViewControl isKindOfClass:[HomeViewController class]]) {
            HomeViewController *home=(HomeViewController *) fetchViewControl;
            [home fetchDataResult:completionHandler];
        }
    }
}

#pragma mark - MBProgressHuD Method
//显示带时限的等待进度提示框
-(void)showActivityView:(NSString *)text interval:(NSTimeInterval)time{
    if( _HUD ){
        _HUD.mode=MBProgressHUDModeIndeterminate;
        _HUD.labelText=text;
        if( [_HUD isHidden] ) {
            [_HUD show:YES];
        }
        [_HUD hide:YES afterDelay:time];
    }
}


//持续显示的提示框
-(void)showActivityView:(NSString *)text{
    if ( _HUD ) {
        _HUD.labelText=text;
        _HUD.mode=MBProgressHUDModeIndeterminate;
        [_HUD show:YES];
    }
}


//显示普通的文字提示框
- (void)showNormalyTextView:(NSString *)text interval:(NSTimeInterval)time
{
    if ( _HUD ) {
        if (text != nil && ![text isEqualToString:@""]) {
            _HUD.mode = MBProgressHUDModeText;
            _HUD.labelText = text;
            [_HUD show:YES];
            [_HUD hide:YES afterDelay:time];
        } else {
            [_HUD hide:YES];
        }
    }
}

//隐藏提示框
- (void)hideActivityView {
    if (_HUD) {
        [_HUD hide:YES];
    }
}



#pragma mark - LoginViewController Method
//显示带时限的等待进度提示框
- (void)push2LoginViewController
{
    [self.window.rootViewController presentViewController:[LoginViewController new] animated:YES completion:nil];
}




- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    application.applicationIconBadgeNumber=0;
    int count =[[[UIApplication sharedApplication] scheduledLocalNotifications] count];
    if(count>0)
    {
        NSMutableArray *newarry= [NSMutableArray arrayWithCapacity:0];
        for (int i=0; i<count; i++) {
            UILocalNotification *notif=[[[UIApplication sharedApplication] scheduledLocalNotifications] objectAtIndex:i];
            notif.applicationIconBadgeNumber=i+1;
            [newarry addObject:notif];
        }
        [[UIApplication sharedApplication] cancelAllLocalNotifications];
        if (newarry.count>0) {
            for (int i=0; i<newarry.count; i++) {
                UILocalNotification *notif = [newarry objectAtIndex:i];
                [[UIApplication sharedApplication] scheduleLocalNotification:notif];
            }
        }
    }
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}


+ (AppDelegate *)getAppDelegate
{
    return (AppDelegate *) [[UIApplication sharedApplication] delegate];
}



- (void) saveFileWithArray: (NSMutableArray*)activityArray fileName:(NSString *) name{
    NSData * data = [NSKeyedArchiver archivedDataWithRootObject:activityArray];
    NSString *path =t_getSysDocumentsDir(name);
    NSLog(@"-->%@",path);        // PATH OF YOUR PLIST FILE
    BOOL didWriteSuccessfull = [data writeToFile:path atomically:YES];
    if (didWriteSuccessfull) {
        NSLog(@"store succsessfully");
    }else {
        NSLog(@"Error in Storing");
    }
}


- (NSMutableArray *)loadDataFromFile:(NSString *)fileName {
    NSArray *myArray=[[NSArray alloc]init];
    NSString *path =t_getSysDocumentsDir(fileName);
    if ([[NSFileManager defaultManager] fileExistsAtPath:path]){
        NSLog(@"exist");
        myArray=[[NSArray alloc]initWithArray:[NSKeyedUnarchiver unarchiveObjectWithData:[NSData dataWithContentsOfFile:path]]];
        return [NSMutableArray arrayWithArray:myArray];
    } else{
        NSLog(@"not exist");
        return nil;
    }
}
@end
