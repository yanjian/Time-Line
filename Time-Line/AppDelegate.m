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

@interface AppDelegate ()

@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Override point for customization after application launch.
    self.window=[[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.backgroundColor=[UIColor whiteColor];
    [GMSServices provideAPIKey:GOOGLE_API_KEY];
   
    HomeViewController *homeVC=[[HomeViewController alloc] initWithNibName:@"HomeViewController" bundle:nil];
    UINavigationController *nav=[[UINavigationController alloc] initWithRootViewController:homeVC];
    nav.navigationBarHidden=YES;
    self.window.rootViewController=nav;
    nav=nil;
     //_flipNC=[[FlipBoardNavigationController alloc] initWithRootViewController:homeVC];
     // self.window.rootViewController = _flipNC;
    homeVC=nil;
    
     [self.window makeKeyAndVisible];
    
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
    
    //初始化 MBProgressHUD控件
    _HUD=[[MBProgressHUD alloc] initWithView:self.window];
    [self.window addSubview:_HUD];
    
    
    
    UILocalNotification *localNotif =
	[launchOptions objectForKey:UIApplicationLaunchOptionsLocalNotificationKey];
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
    return YES;
}




//网络状态发生变化
- (void)reachabilityChanged:(NSNotification *)note
{
    Reachability* curReach = [note object];
    NSParameterAssert([curReach isKindOfClass: [Reachability class]]);
    NetworkStatus status = [curReach currentReachabilityStatus];
    self.netWorkStatus = status;
    
    if([curReach isReachable]){
        NSLog(@"yyyyyyyyyyyyyyyyyyyyyy");
    }else{
        
        NSLog(@"nnnnnnnnnnnnnnnnnnnnnn");
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
   // [self.window.rootViewController presentViewController:[LoginViewController new] animated:YES completion:nil];
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

@end
