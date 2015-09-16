//
//  AppDelegate.m
//  Go2
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

#import "NavigationController.h"
#import "HomeViewController.h"
#import "SetingViewController.h"
#import "ManageViewController.h"
#import "FriendInfoViewController.h"
#import "NoticesViewController.h"
#import "NoticesMsgManagedModel.h"
#import "ManageAndScheduleParentViewController.h"


#import "GCDAsyncSocket.h"
#import "XMPP.h"
#import "XMPPLogging.h"
#import "XMPPReconnect.h"
#import "XMPPCapabilitiesCoreDataStorage.h"
#import "XMPPRosterCoreDataStorage.h"
#import "XMPPvCardAvatarModule.h"
#import "XMPPvCardCoreDataStorage.h"

#import "DDLog.h"
#import "DDTTYLogger.h"
#if DEBUG
static const int ddLogLevel = LOG_LEVEL_VERBOSE;
#else
static const int ddLogLevel = LOG_LEVEL_INFO;
#endif

@interface AppDelegate () <ASIHTTPRequestDelegate> {
	HomeViewController *homeVC;
	UINavigationController *nav;
}
- (void)setupStream;
- (void)teardownStream;

- (void)goOnline;
- (void)goOffline;
@end

@implementation AppDelegate
@synthesize xmppStream;
@synthesize xmppReconnect;
@synthesize xmppRoster;
@synthesize xmppRosterStorage;
@synthesize xmppvCardTempModule;
@synthesize xmppvCardAvatarModule;
@synthesize xmppCapabilities;
@synthesize xmppCapabilitiesStorage;



- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
	self.window.backgroundColor = [UIColor whiteColor];
    
	[GMSServices provideAPIKey:GOOGLE_API_KEY];//google地图key值

	[MagicalRecord setupCoreDataStackWithStoreNamed:@"Go2.sqlite"];//coreData 类的加载

	[self createAnyTimeCache];//创建自定义缓存....

	// 监测网络情况
	[[NSNotificationCenter defaultCenter] addObserver:self
	                                         selector:@selector(reachabilityChanged:)
	                                             name:kReachabilityChangedNotification
	                                           object:nil];
	Reachability *hostReach = [Reachability reachabilityWithHostname:@"www.baidu.com"];
	[hostReach startNotifier];

	//ASI QUENE
	_netWorkQueue = [[ASINetworkQueue alloc] init];
	[_netWorkQueue setShouldCancelAllRequestsOnFailure:NO];

	_netWorkStatus = ReachableViaWiFi;

    [self setupStream]; //开启xmpp流
    [self go2AppInitData];//初始化程序数据

    
	NSTimeInterval timeInterval = [self getRefreshFetchTimetimeInterval];
	if (timeInterval == 0) {
		timeInterval = UIApplicationBackgroundFetchIntervalNever;
	}
	[application setMinimumBackgroundFetchInterval:timeInterval];
    
    self.isRead =@( UNREADMESSAGE_NO );//默认信息是没有读取的 ;
    
    
    // IOS8 新系统需要使用新的代码咯
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0){
        [[UIApplication sharedApplication] registerUserNotificationSettings:[UIUserNotificationSettings
                                                                             settingsForTypes:(UIUserNotificationTypeSound | UIUserNotificationTypeAlert | UIUserNotificationTypeBadge)
                                                                             categories:nil]];
        [[UIApplication sharedApplication] registerForRemoteNotifications];
    }else {
         [[UIApplication sharedApplication] registerForRemoteNotificationTypes:
         (UIUserNotificationTypeBadge | UIUserNotificationTypeSound | UIUserNotificationTypeAlert)];
    }
    
	[[UIApplication sharedApplication] cancelAllLocalNotifications];
    
   
	UILocalNotification *localNotif = [launchOptions objectForKey:UIApplicationLaunchOptionsLocalNotificationKey];
	if (localNotif) {
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"ALERT"
		                                                message:localNotif.alertBody
		                                               delegate:nil
		                                      cancelButtonTitle:@"确定"
		                                      otherButtonTitles:nil];
		[alert show];
		application.applicationIconBadgeNumber = 0;
	}
    
    [self setupViewControllers];
    
	return YES;
}


- (void)setupViewControllers {
    UIViewController *manageViewController = [[ManageAndScheduleParentViewController alloc] init];
    NavigationController *manageNavigationController = [[NavigationController alloc]
                                                   initWithRootViewController:manageViewController];
    
    UIViewController *noticesViewController = [[NoticesViewController alloc] init];
    NavigationController *notesNavigationController = [[NavigationController alloc]
                                                   initWithRootViewController:noticesViewController];
    
    UIViewController *friendInfoViewController = [[FriendInfoViewController alloc] init];
    NavigationController *friendInfoNavigationController = [[NavigationController alloc]
                                                   initWithRootViewController:friendInfoViewController];
    UIViewController *setingViewController = [[SetingViewController alloc] init];
    NavigationController *setingNavigationController = [[NavigationController alloc]
                                                   initWithRootViewController:setingViewController];

    self.tabBarController = [[UITabBarController alloc] init];
    
    self.tabBarController.viewControllers = [NSArray arrayWithObjects:manageNavigationController,notesNavigationController,friendInfoNavigationController,setingNavigationController, nil];

    UITabBar *tabBar = _tabBarController.tabBar;
    UITabBarItem *eventItem = [tabBar.items objectAtIndex:0];
    UITabBarItem *invitationItem = [tabBar.items objectAtIndex:1];
    UITabBarItem *friendItem = [tabBar.items objectAtIndex:2];
    UITabBarItem *setingItem = [tabBar.items objectAtIndex:3];
    eventItem.selectedImage = [[UIImage imageNamed:@"Updates_Filled"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    eventItem.image = [[UIImage imageNamed:@"Updates_NoFill"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    
    invitationItem.selectedImage = [[UIImage imageNamed:@"Invitations_Filled"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    invitationItem.image = [[UIImage imageNamed:@"Invitations_NoFill"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    
    friendItem.selectedImage = [[UIImage imageNamed:@"Friends_Filled"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    friendItem.image = [[UIImage imageNamed:@"Friends_NoFill"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    
    setingItem.selectedImage = [[UIImage imageNamed:@"Settings_Filled"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    setingItem.image = [[UIImage imageNamed:@"Settings_NoFill"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    
    self.window.rootViewController = self.tabBarController;
    [self.window makeKeyAndVisible];
}

-(UITabBarController *)tabBarController {
    if(!_tabBarController){
        _tabBarController = [[UITabBarController alloc] init];
        _tabBarController.tabBar.translucent = NO;
        _tabBarController.selectedIndex = DEFAULT_TAB;
    }
    return _tabBarController ;
}


- (NSTimeInterval)getRefreshFetchTimetimeInterval {
	//@"15 minutes",@"30 minutes",@"1 hour",@"2 hour",@"never"
	NSString *timeStr = [USER_DEFAULT objectForKey:@"refTime"];
	double timeMs = 0;
	if ([@"15 minutes" isEqualToString:timeStr]) {
		timeMs = 15 * 60 * 1000;
	}
	else if ([@"30 minutes" isEqualToString:timeStr]) {
		timeMs = 30 * 60 * 1000;
	}
	else if ([@"1 hour" isEqualToString:timeStr]) {
		timeMs = 60 * 60 * 1000;
	}
	else if ([@"2 hour" isEqualToString:timeStr]) {
		timeMs = 120 * 60 * 1000;
	}
	return timeMs;
}

- (void)initLoginView:(LoginOrLogoutType)loginOrLogoutType {
	LoginViewController *loginVc   = [[LoginViewController alloc] init];
	NavigationController *navLogin = [[NavigationController alloc] initWithRootViewController:loginVc];
	navLogin.navigationBar.hidden  = YES;
    if (loginOrLogoutType == LoginOrLogoutType_SetupMainOpen) {
        self.window.rootViewController = navLogin;
        [self.window makeKeyAndVisible];
    }else if(loginOrLogoutType == LoginOrLogoutType_ModelOpen){
       [self.tabBarController presentViewController:navLogin animated:YES completion:nil];
    }
}

- (void)requestFinished:(ASIHTTPRequest *)request {
	NSString *str = [request responseString];
	switch (request.tag) {
        case Go2_UserLogin_Tag:{
            id tmpDic = [str objectFromJSONString];
            if ([tmpDic isKindOfClass:[NSDictionary class]]) {
                int tmpNoLogin = [[tmpDic objectForKey:@"statusCode"] intValue];
                if ( 1 == tmpNoLogin ) {
                    [self connect];
                    NSLog(@"登陆成功");
                }else if ( 2== tmpNoLogin ) {
                    NSLog(@"已经登陆");
                }else {
                    NSLog(@"登陆错误");
                }

            }
        }break;
		case Go2_getUserInfo_Tag: {
            id tmpDic = [str objectFromJSONString];
            if ([tmpDic isKindOfClass:[NSDictionary class]]) {
                int tmpNoLogin = [[tmpDic objectForKey:@"statusCode"] intValue];
                if ( -1000 == tmpNoLogin ) {
                    [self userLogin];
                }
            }
			
			break;
		}
		default:
			break;
	}
}

- (void)userLogin {
	UserInfo *currUserInfo = [UserInfo currUserInfo];
	if (currUserInfo) {
		NSMutableDictionary *paramDic = [NSMutableDictionary dictionaryWithCapacity:0];
		AccountType isAccount = currUserInfo.accountType;
		if (isAccount == AccountTypeLocal) {//本地账号
			[paramDic setObject:currUserInfo.username forKey:@"username"];
			[paramDic setObject:currUserInfo.password forKey:@"pwd"];
			[paramDic setObject:@(UserLoginTypeLocal) forKey:@"type"];
			ASIHTTPRequest *request = [t_Network httpGet:paramDic Url:Go2_UserLogin Delegate:self Tag:Go2_UserLogin_Tag];
			[request startSynchronous];
		}
		else if (isAccount == AccountTypeGoogle) {//google登陆
			if (currUserInfo.email)
				[paramDic setObject:currUserInfo.email forKey:@"email"];
			if (currUserInfo.authCode) {
				[paramDic setObject:currUserInfo.authCode forKey:@"authCode"];
				[paramDic setObject:@(UserLoginTypeGoogle) forKey:@"type"];
				ASIHTTPRequest *request = [t_Network httpGet:paramDic Url:LOGIN_USER Delegate:self Tag:LOGIN_USER_TAG];
				[request startSynchronous];
			}
		}
	}
}

////初始化mian界面
//- (void)initMainView {
//	homeVC = [[HomeViewController alloc] initWithNibName:@"HomeViewController" bundle:nil];
//
//	homeVC.isRefreshUIData = YES;//初始化的时候刷新ui加载数据
//	nav = [[UINavigationController alloc] initWithRootViewController:homeVC];
//	nav.navigationBar.translucent = NO;
//	self.window.rootViewController = nav;
//	[self.window makeKeyAndVisible];
//}

- (void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification {
	if (notification) {
		UIApplicationState state = application.applicationState;

		if (state == UIApplicationStateActive) {
			UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"ALERT"
			                                                message:notification.alertBody
			                                               delegate:nil
			                                      cancelButtonTitle:@"Confirm"
			                                      otherButtonTitles:nil];
			[alert show];
		}


		application.applicationIconBadgeNumber = 0;
		int count = [[[UIApplication sharedApplication] scheduledLocalNotifications] count];
		if (count > 0) {
			NSMutableArray *newarry = [NSMutableArray arrayWithCapacity:0];
			for (NSUInteger i = 0; i < count; i++) {
				UILocalNotification *notif = [[[UIApplication sharedApplication] scheduledLocalNotifications] objectAtIndex:i];
				notif.applicationIconBadgeNumber = i + 1;
				[newarry addObject:notif];
			}
			[[UIApplication sharedApplication] cancelAllLocalNotifications];
			if (newarry.count > 0) {
				for (NSUInteger i = 0; i < newarry.count; i++) {
					UILocalNotification *notif = [newarry objectAtIndex:i];
					[[UIApplication sharedApplication] scheduleLocalNotification:notif];
				}
			}
		}
	}
}

- (void)autoUserWithLogin {
	//检查用户是否在登录状态 返回-1000表示没有登录
	ASIHTTPRequest *request = [t_Network httpGet:nil Url:Go2_getUserInfo Delegate:self Tag:Go2_getUserInfo_Tag];
	[request startSynchronous];
}

//网络状态发生变化
- (void)reachabilityChanged:(NSNotification *)note {
	Reachability *curReach = [note object];
	NSParameterAssert([curReach isKindOfClass:[Reachability class]]);
	NetworkStatus status = [curReach currentReachabilityStatus];
	self.netWorkStatus = status;
	if ([curReach isReachable]) {
		NSLog(@"网络可用YES");
		// [self autoUserWithLogin];
	}
	else {
		NSLog(@"网络不可用NO");
		[self noReachabilityChanged];
	}
}

//go2---app启动是初始化的数据
-(void)go2AppInitData{
    if (![USER_DEFAULT objectForKey:@"eventTime"]) {
        [USER_DEFAULT setObject:@(EventsAlertTime_AtTimeEvent) forKey:@"eventTime"];
    }
    if (![USER_DEFAULT objectForKey:@"allDay"]) {
        [USER_DEFAULT setObject:@(EventsAllDayAlert_8Hour) forKey:@"allDay"];
    }
    
    [USER_DEFAULT synchronize];
}

//网络改变
- (void)noReachabilityChanged {
    UIAlertView *alert;
    alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"请检查你的网络连接" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil];
    [alert show];

}

- (void)application:(UIApplication *)application performFetchWithCompletionHandler:(void (^)(UIBackgroundFetchResult result))completionHandler {
	UINavigationController *navs = (UINavigationController *)self.window.rootViewController;
	id fetchViewControl = navs.topViewController;
	if ([fetchViewControl respondsToSelector:@selector(fetchDataResult:)]) {
		if ([fetchViewControl isKindOfClass:[HomeViewController class]]) {
			HomeViewController *home = (HomeViewController *)fetchViewControl;
			[home fetchDataResult:completionHandler];
		}
	}
}

#ifdef __IPHONE_8_0
- (void)application:(UIApplication *)application didRegisterUserNotificationSettings:(UIUserNotificationSettings *)notificationSettings
{
    [application registerForRemoteNotifications];
}

#endif


- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken
{
    [self addDeviceToken:deviceToken];
     NSLog(@"device token:%@",deviceToken);
}

#pragma mark 获取device token失败后
-(void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error{
    NSLog(@"didFailToRegisterForRemoteNotificationsWithError:%@",error.localizedDescription);
    [self addDeviceToken:nil];
}

#pragma mark 接收到推送通知之后
-(void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo{
    NSLog(@"receiveRemoteNotification,userInfo is %@",userInfo);
}

/**
 *  添加设备令牌到服务器端
 *  @param deviceToken 设备令牌
 */
-(void)addDeviceToken:(NSData *)deviceToken{
    NSString *key=@"DeviceToken";
    NSString *oldToken= [[NSUserDefaults standardUserDefaults] objectForKey:key];
    
    NSString * deviceTokenStr = [[[[deviceToken description] stringByReplacingOccurrencesOfString:@"<" withString:@""]                  stringByReplacingOccurrencesOfString:@">" withString:@""]                 stringByReplacingOccurrencesOfString:@" " withString: @""];
    //如果偏好设置中的已存储设备令牌和新获取的令牌不同则存储新令牌并且发送给服务器端
    if (![oldToken isEqualToString:deviceTokenStr]) {
        [[NSUserDefaults standardUserDefaults] setObject:deviceTokenStr forKey:key];
        [self sendDeviceTokenWidthOldDeviceToken:oldToken newDeviceToken:deviceTokenStr];
    }
}


-(void)sendDeviceTokenWidthOldDeviceToken:(NSString *)oldToken newDeviceToken:(NSString *)newToken{
    NSString *urlStr=[anyTime_UpdateDeviceToken stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSURL *url=[NSURL URLWithString:urlStr];
    NSMutableURLRequest *requestM=[NSMutableURLRequest requestWithURL:url cachePolicy:0 timeoutInterval:10.0];
    [requestM setHTTPMethod:@"POST"];
    NSString *bodyStr=[NSString stringWithFormat:@"token=%@",newToken];
    NSData *body=[bodyStr dataUsingEncoding:NSUTF8StringEncoding];
    [requestM setHTTPBody:body];
    NSURLSession *session=[NSURLSession sharedSession];
    NSURLSessionDataTask *dataTask= [session dataTaskWithRequest:requestM completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (error) {
            NSLog(@"Send failure,error is :%@",error.localizedDescription);
        }else{
            NSLog(@"Send Success!");
        }
    }];
    [dataTask resume];
}


- (void)applicationWillResignActive:(UIApplication *)application {
	// Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
	// Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
	// Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
	// If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
	// Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
	[self autoUserWithLogin];
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
	// Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
	application.applicationIconBadgeNumber = 0;
	int count = [[[UIApplication sharedApplication] scheduledLocalNotifications] count];
	if (count > 0) {
		NSMutableArray *newarry = [NSMutableArray arrayWithCapacity:0];
		for (NSUInteger i = 0; i < count; i++) {
			UILocalNotification *notif = [[[UIApplication sharedApplication] scheduledLocalNotifications] objectAtIndex:i];
			notif.applicationIconBadgeNumber = i + 1;
			[newarry addObject:notif];
		}
		[[UIApplication sharedApplication] cancelAllLocalNotifications];
		if (newarry.count > 0) {
			for (NSUInteger i = 0; i < newarry.count; i++) {
				UILocalNotification *notif = [newarry objectAtIndex:i];
				[[UIApplication sharedApplication] scheduleLocalNotification:notif];
			}
		}
	}
}

- (void)applicationWillTerminate:(UIApplication *)application {
	// Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

+ (AppDelegate *)getAppDelegate {
	return (AppDelegate *)[[UIApplication sharedApplication] delegate];
}

- (void)saveFileWithArray:(NSMutableArray *)activityArray fileName:(NSString *)name {
	NSData *data = [NSKeyedArchiver archivedDataWithRootObject:activityArray];
	NSString *path = t_getSysDocumentsDir(name);
	NSLog(@"-->%@", path);        // PATH OF YOUR PLIST FILE
	BOOL didWriteSuccessfull = [data writeToFile:path atomically:YES];
	if (didWriteSuccessfull) {
		NSLog(@"store succsessfully");
	}
	else {
		NSLog(@"Error in Storing");
	}
}

- (NSMutableArray *)loadDataFromFile:(NSString *)fileName {
	NSArray *myArray = [[NSArray alloc]init];
	NSString *path = t_getSysDocumentsDir(fileName);
	if ([[NSFileManager defaultManager] fileExistsAtPath:path]) {
		NSLog(@"exist");
		myArray = [[NSArray alloc]initWithArray:[NSKeyedUnarchiver unarchiveObjectWithData:[NSData dataWithContentsOfFile:path]]];
		return [NSMutableArray arrayWithArray:myArray];
	}
	else {
		NSLog(@"not exist");
		return nil;
	}
}

- (void)createAnyTimeCache {
	//自定义缓存
	ASIDownloadCache *cache = [[ASIDownloadCache alloc] init];
	self.anyTimeCache = cache;

	//设置缓存路径
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *documentDirectory = [paths objectAtIndex:0];
	[self.anyTimeCache setStoragePath:[documentDirectory stringByAppendingPathComponent:@"anyTimeCache"]];
	[self.anyTimeCache setDefaultCachePolicy:ASIOnlyLoadIfNotCachedCachePolicy];
}

- (void)dealloc {
	[self teardownStream];
}

- (NSManagedObjectContext *)managedObjectContext_roster {
	return [xmppRosterStorage mainThreadManagedObjectContext];
}

- (NSManagedObjectContext *)managedObjectContext_capabilities {
	return [xmppCapabilitiesStorage mainThreadManagedObjectContext];
}

- (void)setupStream {
	NSAssert(xmppStream == nil, @"Method setupStream invoked multiple times");

	// Setup xmpp stream
    xmppStream = [[XMPPStream alloc] init];

#if !TARGET_IPHONE_SIMULATOR
	{
        xmppStream.enableBackgroundingOnSocket = YES;
	}
#endif

	// Setup reconnect

	xmppReconnect = [[XMPPReconnect alloc] init];

	xmppRosterStorage = [[XMPPRosterCoreDataStorage alloc] init];
	//	xmppRosterStorage = [[XMPPRosterCoreDataStorage alloc] initWithInMemoryStore];

	xmppRoster = [[XMPPRoster alloc] initWithRosterStorage:xmppRosterStorage];

	xmppRoster.autoFetchRoster = YES;
	xmppRoster.autoAcceptKnownPresenceSubscriptionRequests = YES;

	xmppvCardStorage = [XMPPvCardCoreDataStorage sharedInstance];
	xmppvCardTempModule = [[XMPPvCardTempModule alloc] initWithvCardStorage:xmppvCardStorage];

	xmppvCardAvatarModule = [[XMPPvCardAvatarModule alloc] initWithvCardTempModule:xmppvCardTempModule];

	xmppCapabilitiesStorage = [XMPPCapabilitiesCoreDataStorage sharedInstance];
	xmppCapabilities = [[XMPPCapabilities alloc] initWithCapabilitiesStorage:xmppCapabilitiesStorage];

	xmppCapabilities.autoFetchHashedCapabilities = YES;
	xmppCapabilities.autoFetchNonHashedCapabilities = NO;


	[xmppReconnect activate:xmppStream];
	[xmppRoster activate:xmppStream];
	[xmppvCardTempModule activate:xmppStream];
	[xmppvCardAvatarModule activate:xmppStream];
	[xmppCapabilities activate:xmppStream];

	[xmppStream addDelegate:self delegateQueue:dispatch_get_main_queue()];
	[xmppRoster addDelegate:self delegateQueue:dispatch_get_main_queue()];

	[xmppStream setHostName:@"58.64.162.184"];
	[xmppStream setHostPort:5222];


	// You may need to alter these settings depending on the server you're connecting to
	customCertEvaluation = YES;
}

- (void)teardownStream {
	[xmppStream removeDelegate:self];
	[xmppRoster removeDelegate:self];

	[xmppReconnect         deactivate];
	[xmppRoster            deactivate];
	[xmppvCardTempModule   deactivate];
	[xmppvCardAvatarModule deactivate];
	[xmppCapabilities      deactivate];

	[xmppStream disconnect];

	xmppStream = nil;
	xmppReconnect = nil;
	xmppRoster = nil;
	xmppRosterStorage = nil;
	xmppvCardStorage = nil;
	xmppvCardTempModule = nil;
	xmppvCardAvatarModule = nil;
	xmppCapabilities = nil;
	xmppCapabilitiesStorage = nil;
}

- (void)goOnline {
	XMPPPresence *presence = [XMPPPresence presence]; // type="available" is implicit

	NSString *domain = [xmppStream.myJID domain];

	//Google set their presence priority to 24, so we do the same to be compatible.

	if ([domain isEqualToString:@"gmail.com"]
	    || [domain isEqualToString:@"gtalk.com"]
	    || [domain isEqualToString:@"talk.google.com"]) {
		NSXMLElement *priority = [NSXMLElement elementWithName:@"priority" stringValue:@"24"];
		[presence addChild:priority];
	}

	[[self xmppStream] sendElement:presence];
}

- (void)goOffline {
	XMPPPresence *presence = [XMPPPresence presenceWithType:@"unavailable"];

	[[self xmppStream] sendElement:presence];
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark Connect/disconnect
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

- (BOOL)connect {
	if (![xmppStream isDisconnected]) {
		return YES;
	}

	NSString *myJID = [USER_DEFAULT stringForKey:XMPP_ANYTIMENAME];
	NSString *myPassword = [USER_DEFAULT stringForKey:XMPP_ANYTIMEPWD];

	if (myJID == nil || myPassword == nil) {
		return NO;
	}

	[xmppStream setMyJID:[XMPPJID jidWithString:myJID]];
	password = myPassword;

	NSError *error = nil;
	if (![xmppStream connectWithTimeout:XMPPStreamTimeoutNone error:&error]) {
		UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error connecting"
		                                                    message:@"See console for error details."
		                                                   delegate:nil
		                                          cancelButtonTitle:@"Ok"
		                                          otherButtonTitles:nil];
		[alertView show];

		DDLogError(@"Error connecting: %@", error);

		return NO;
	}

	return YES;
}

- (void)disconnect {
	[self goOffline];
	[xmppStream disconnect];
}

- (void)xmppStream:(XMPPStream *)sender socketDidConnect:(GCDAsyncSocket *)socket {
	DDLogVerbose(@"%@: %@", THIS_FILE, THIS_METHOD);
}

- (void)xmppStream:(XMPPStream *)sender willSecureWithSettings:(NSMutableDictionary *)settings {
	DDLogVerbose(@"%@: %@", THIS_FILE, THIS_METHOD);

	NSString *expectedCertName = [xmppStream.myJID domain];
	if (expectedCertName) {
		[settings setObject:expectedCertName forKey:(NSString *)kCFStreamSSLPeerName];
	}

	if (customCertEvaluation) {
		[settings setObject:@(YES) forKey:GCDAsyncSocketManuallyEvaluateTrust];
	}
}


- (void)xmppStream:(XMPPStream *)sender didReceiveTrust:(SecTrustRef)trust
    completionHandler:(void (^)(BOOL shouldTrustPeer))completionHandler {
	DDLogVerbose(@"%@: %@", THIS_FILE, THIS_METHOD);
	dispatch_queue_t bgQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
	dispatch_async(bgQueue, ^{
		SecTrustResultType result = kSecTrustResultDeny;
		OSStatus status = SecTrustEvaluate(trust, &result);

		if (status == noErr && (result == kSecTrustResultProceed || result == kSecTrustResultUnspecified)) {
		    completionHandler(YES);
		}
		else {
		    completionHandler(NO);
		}
	});
}

- (void)xmppStreamDidSecure:(XMPPStream *)sender {
	DDLogVerbose(@"%@: %@", THIS_FILE, THIS_METHOD);
}

- (void)xmppStreamDidConnect:(XMPPStream *)sender {
	DDLogVerbose(@"%@: %@", THIS_FILE, THIS_METHOD);

	isXmppConnected = YES;

	NSError *error = nil;

	if (![[self xmppStream] authenticateWithPassword:password error:&error]) {
		DDLogError(@"Error authenticating: %@", error);
	}
}

- (void)xmppStreamDidAuthenticate:(XMPPStream *)sender {
	DDLogVerbose(@"%@: %@", THIS_FILE, THIS_METHOD);

	[self goOnline];
}

- (void)xmppStream:(XMPPStream *)sender didNotAuthenticate:(NSXMLElement *)error {
	DDLogVerbose(@"%@: %@", THIS_FILE, THIS_METHOD);
}

- (BOOL)xmppStream:(XMPPStream *)sender didReceiveIQ:(XMPPIQ *)iq {
	DDLogVerbose(@"%@: %@", THIS_FILE, THIS_METHOD);

	return NO;
}

- (void)xmppStream:(XMPPStream *)sender didReceiveMessage:(XMPPMessage *)message {
    
	if ([message isChatMessageWithBody]) {
//		XMPPUserCoreDataStorageObject *user = [xmppRosterStorage userForJID:[message from]
//		                                                         xmppStream:xmppStream
//		                                               managedObjectContext:[self managedObjectContext_roster]];

		NSString *body = [[message elementForName:@"body"] stringValue];
		//NSString *displayName = [user displayName];
        NSDictionary *bodyDic = [body objectFromJSONString] ;
        
        NSString * msgType = [NSString stringWithFormat:@"%@",[bodyDic objectForKey:@"type"]];
        if(![ @"4"  isEqualToString: msgType ]){//4.表示删除。。。。不推送通知
            if( [ @"1"  isEqualToString: msgType ] ||[ @"2"  isEqualToString: msgType ] || [ @"3"  isEqualToString: msgType ] || [ @"11"  isEqualToString: msgType ]){//1.对方要添加你为好友信息 ,2.同意添加对方为好友 , 3.拒绝添加对方为好友 ,11.活动新增或邀请成员
                NoticesMsgManagedModel * noticeMsgManaged = [NoticesMsgManagedModel MR_createEntity];
                noticeMsgManaged.nId       = [bodyDic objectForKey:@"id"] ;
                noticeMsgManaged.isReceive = @([[bodyDic objectForKey:@"isReceive"] integerValue]);
                noticeMsgManaged.message   = [[bodyDic objectForKey:@"message"] JSONString];
                noticeMsgManaged.time      = [bodyDic objectForKey:@"createTime"];
                noticeMsgManaged.type      = @([msgType integerValue]);
                noticeMsgManaged.uid       = [bodyDic objectForKey:@"uid"];
                noticeMsgManaged.isRead    = self.isRead; //未读//在这里的信息都表示没有读取的
                [[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreWithCompletion:^(BOOL contextDidSave, NSError *error) {
                    if (contextDidSave) {
                         [[NSNotificationCenter defaultCenter] postNotificationName:FRIENDS_OPTIONSNOTIFICTION object:self userInfo:@{FRIENDS_OPTIONSINFO:noticeMsgManaged}];
                    }
                }];
            }else{
                ChatContentModel * chatContent = [self saveChatInfoForActive:bodyDic];
                //发送通知
                [[NSNotificationCenter defaultCenter] postNotificationName:CHATGROUP_ACTIVENOTIFICTION object:self userInfo:@{CHATGROUP_USERINFO:chatContent}];
            }
        }
//		if ([[UIApplication sharedApplication] applicationState] == UIApplicationStateActive) {
//			UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:displayName
//			                                                    message:body
//			                                                   delegate:nil
//			                                          cancelButtonTitle:@"Ok"
//			                                          otherButtonTitles:nil];
//			[alertView show];
//		}
//		else {
//			// We are not active, so use a local notification instead
//			UILocalNotification *localNotification = [[UILocalNotification alloc] init];
//			localNotification.alertAction = @"Ok";
//			localNotification.alertBody = [NSString stringWithFormat:@"From: %@\n\n%@", displayName, body];
//
//			[[UIApplication sharedApplication] presentLocalNotificationNow:localNotification];
//		}
	}
}

#pragma mark -保存聊天信息
-(ChatContentModel *)saveChatInfoForActive:(NSDictionary * ) bodyDic{
    ChatContentModel * chatContent = [ChatContentModel MR_createEntity];
    chatContent.eid =  [bodyDic objectForKey:@"eid"];
    NSString * chatType = [NSString stringWithFormat:@"%@" , [bodyDic objectForKey:@"type"]];
    
    if ( [ @"15" isEqualToString: chatType ] ) {//聊天信息
        int msgType = [[bodyDic objectForKey:@"msg_type"] intValue] ; //信息类型：0.表示文本信息，1.表示图片信息，2表示语音信息
        if( msgType == 0 ){
           chatContent.text = [bodyDic objectForKey:@"content"] || ![@"" isEqualToString:[bodyDic objectForKey:@"content"]] ? [bodyDic objectForKey:@"content"] : @"" ;

        }else if ( msgType == 1 ){
            chatContent.imgBig =  [bodyDic objectForKey:@"url"];//大图url
            NSString *imgsmall = [bodyDic objectForKey:@"thumbnail"] ;//小图
            
            NSData * imgSmallData = [NSData dataWithContentsOfURL:[NSURL URLWithString:[[NSString stringWithFormat:@"%@%@",BaseGo2Url_IP,imgsmall] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]] ;
            chatContent.imgSmall =  [imgSmallData base64String];
            chatContent.text = @"[Picture]";
        }else if ( msgType == 2 ){
             NSString * voiceUrl = [bodyDic objectForKey:@"url"];
             NSData * voiceData = [NSData dataWithContentsOfURL:[NSURL URLWithString:[[NSString stringWithFormat:@"%@%@",BaseGo2Url_IP,voiceUrl] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]] ;
            NSLog(@"%@",[voiceData base64String]);
            chatContent.voiceAac = [voiceData base64String];
            chatContent.text = [bodyDic objectForKey:@"content"] ;
        }
        
    }else if( [@"10" isEqualToString:chatType] ){
        NSDictionary * eventMsgDic = [self dictionaryWithJsonString: [bodyDic objectForKey:@"message"]]; ;
        if ([eventMsgDic isKindOfClass:[NSDictionary class]]) {
            NSDictionary * eventMsgTmpDic = [[eventMsgDic objectForKey:@"eventMsg"] lastObject];
            chatContent.text = [eventMsgTmpDic objectForKey:@"message"] ;
        }
    }
    
    chatContent.msg_type = [bodyDic objectForKey:@"msg_type"] ;
    chatContent.time =  [bodyDic objectForKey:@"createTime"];
    chatContent.type =   chatType ;
    chatContent.uid  =  [bodyDic objectForKey:@"uid"];
    chatContent.username =  [bodyDic objectForKey:@"username"];
    chatContent.unreadMessage = self.isRead; //未读//在这里的信息都表示没有读取的
    [[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreAndWait];
    
    return chatContent ;
}

- (void)xmppStream:(XMPPStream *)sender didReceivePresence:(XMPPPresence *)presence {
	DDLogVerbose(@"%@: %@ - %@", THIS_FILE, THIS_METHOD, [presence fromStr]);
}

- (void)xmppStream:(XMPPStream *)sender didReceiveError:(id)error {
	DDLogVerbose(@"%@: %@", THIS_FILE, THIS_METHOD);
}

- (void)xmppStreamDidDisconnect:(XMPPStream *)sender withError:(NSError *)error {
	DDLogVerbose(@"%@: %@", THIS_FILE, THIS_METHOD);

	if (!isXmppConnected) {
		DDLogError(@"Unable to connect to server. Check xmppStream.hostName");
	}
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark XMPPRosterDelegate
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

- (void)xmppRoster:(XMPPRoster *)sender didReceiveBuddyRequest:(XMPPPresence *)presence {
	DDLogVerbose(@"%@: %@", THIS_FILE, THIS_METHOD);

	XMPPUserCoreDataStorageObject *user = [xmppRosterStorage userForJID:[presence from]
	                                                         xmppStream:xmppStream
	                                               managedObjectContext:[self managedObjectContext_roster]];

	NSString *displayName = [user displayName];
	NSString *jidStrBare = [presence fromStr];
	NSString *body = nil;

	if (![displayName isEqualToString:jidStrBare]) {
		body = [NSString stringWithFormat:@"Buddy request from %@ <%@>", displayName, jidStrBare];
	}
	else {
		body = [NSString stringWithFormat:@"Buddy request from %@", displayName];
	}


	if ([[UIApplication sharedApplication] applicationState] == UIApplicationStateActive) {
		UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:displayName
		                                                    message:body
		                                                   delegate:nil
		                                          cancelButtonTitle:@"Not implemented"
		                                          otherButtonTitles:nil];
		[alertView show];
	}
	else {
		// We are not active, so use a local notification instead
		UILocalNotification *localNotification = [[UILocalNotification alloc] init];
		localNotification.alertAction = @"Not implemented";
		localNotification.alertBody = body;

		[[UIApplication sharedApplication] presentLocalNotificationNow:localNotification];
	}
}


/*!
 * @brief 把格式化的JSON格式的字符串转换成字典
 * @param jsonString JSON格式的字符串
 * @return 返回字典
 */
- (NSDictionary *)dictionaryWithJsonString:(NSString *)jsonString {
    if (jsonString == nil) {
        return nil;
    }
    
    NSData *jsonData = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
    NSError *err;
    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:jsonData
                                                        options:NSJSONReadingMutableContainers
                                                          error:&err];
    if(err) {
        NSLog(@"json解析失败：%@",err);
        return nil;
    }
    return dic;
}
@end
