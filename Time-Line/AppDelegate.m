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
@interface AppDelegate ()<ASIHTTPRequestDelegate>

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
    
    
    [self initMainView];
    
    [self.window makeKeyAndVisible];

    
    
    //初始化 MBProgressHUD控件
    _HUD=[[MBProgressHUD alloc] initWithView:self.window];
    [self.window addSubview:_HUD];
    
    UILocalNotification *localNotif =[launchOptions objectForKey:UIApplicationLaunchOptionsLocalNotificationKey];
    if (localNotif) {
		NSLog(@"｀｀｀｀｀｀｀｀｀｀｀｀ %@",localNotif);
        
	}
    
    _isread=YES;
    NSArray *familyNames =[[NSArray alloc]initWithArray:[UIFont familyNames]];
    NSArray *fontNames;
    NSInteger indFamily, indFont;
    NSLog(@"[familyNames count]===%ld",[familyNames count]);
    for(indFamily=0;indFamily<[familyNames count];++indFamily)
        
    {
        NSLog(@"Family name: %@", [familyNames objectAtIndex:indFamily]);
        fontNames =[[NSArray alloc]initWithArray:[UIFont fontNamesForFamilyName:[familyNames objectAtIndex:indFamily]]];
        
        for(indFont=0; indFont<[fontNames count]; ++indFont)
            
        {
            NSLog(@"Font name: %@",[fontNames objectAtIndex:indFont]);
            
        }
        
    }
    NSInteger loginStatus=[USER_DEFAULT integerForKey:@"loginStatus"];
    if (1!=loginStatus) {
         [self initLoginView];
    }else{
        NSMutableDictionary *paramDic=[NSMutableDictionary dictionaryWithCapacity:0];
        [paramDic setObject:[USER_DEFAULT objectForKey:@"email"] forKey:@"email"];
        [paramDic setObject:[USER_DEFAULT objectForKey:@"authCode"] forKey:@"authCode"];
        [paramDic setObject:@(UserLoginTypeGoogle) forKey:@"type"];
        ASIHTTPRequest *request=[t_Network httpGet:paramDic Url:LOGIN_USER Delegate:self Tag:LOGIN_USER_TAG];
        [request startSynchronous];
    }
    NSTimeInterval timeInterval= [self getRefreshFetchTimetimeInterval];
    if (timeInterval==0) {
       timeInterval= UIApplicationBackgroundFetchIntervalNever;
    }
    [application setMinimumBackgroundFetchInterval:timeInterval];
    return YES;
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

-(void) initLoginView{
    LoginViewController *loginVc = [[LoginViewController alloc] init];
    [self.window.rootViewController presentViewController:loginVc animated:YES completion:nil];
}

- (void)requestFinished:(ASIHTTPRequest *)request{
    NSString *str=[request responseString];
    if ([@"1" isEqualToString:str]) {
        NSLog(@"登陆成功");
    }else if ([@"2" isEqualToString:str]){
         NSLog(@"已经登陆");
    }else {
        NSLog(@"登陆错误");
    }

}
//初始化mian界面
-(void)initMainView
{
    HomeViewController *homeVC=[[HomeViewController alloc] initWithNibName:@"HomeViewController" bundle:nil];
    UINavigationController *nav=[[UINavigationController alloc] initWithRootViewController:homeVC];
    nav.navigationBarHidden=YES;
    self.window.rootViewController=nav;
}


- (void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"ALERT"
                                                    message:notification.alertBody
                                                   delegate:nil
                                          cancelButtonTitle:@"确定"
                                          otherButtonTitles:nil];
    [alert show];
    //这里，你就可以通过notification的useinfo，干一些你想做的事情了
   // application.applicationIconBadgeNumber-=1;
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
    }else{
        NSLog(@"网络不可用NO");
        [self reachabilityChanged];
    }
}

//网络改变
-(void)reachabilityChanged
{
    UIAlertView *alert;
    alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"请检查你的网络连接" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil];
    [alert show];
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
