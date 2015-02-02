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


NSString *const kXMPPmyJID = @"anytime_yan@ubuntu";
NSString *const kXMPPmyPassword = @"qq123456";

@interface AppDelegate () <ASIHTTPRequestDelegate> {
	HomeViewController *homeVC;
	UINavigationController *nav;
}
@property (strong, nonatomic) SloppySwiper *swiper;
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

	[MagicalRecord setupCoreDataStackWithStoreNamed:@"TimeLine.sqlite"];//coreData 类的加载

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

	NSTimeInterval timeInterval = [self getRefreshFetchTimetimeInterval];
	if (timeInterval == 0) {
		timeInterval = UIApplicationBackgroundFetchIntervalNever;
	}
	[application setMinimumBackgroundFetchInterval:timeInterval];


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

	_isread = YES;

	[self initMainView];

	return YES;
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

- (void)initLoginView:(id)target {
	LoginViewController *loginVc = [[LoginViewController alloc] init];
	UINavigationController *navLogin = [[UINavigationController alloc] initWithRootViewController:loginVc];
	navLogin.navigationBar.hidden = YES;
	self.swiper = [[SloppySwiper alloc] initWithNavigationController:nav];
	navLogin.delegate = self.swiper;
	[target presentViewController:navLogin animated:YES completion:nil];
}

- (void)requestFinished:(ASIHTTPRequest *)request {
	NSString *str = [request responseString];
	switch (request.tag) {
		case LOGIN_USER_TAG:
			if ([@"1" isEqualToString:str]) {
				NSLog(@"登陆成功");
			}
			else if ([@"2" isEqualToString:str]) {
				NSLog(@"已经登陆");
			}
			else {
				NSLog(@"登陆错误");
			}

			break;

		case LoginUser_GetUserInfo_Tag: {
			if ([@"-1000" isEqualToString:str]) {
				[self userLogin];
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
			[paramDic setObject:currUserInfo.username forKey:@"uName"];
			[paramDic setObject:currUserInfo.password forKey:@"uPw"];
			[paramDic setObject:@(UserLoginTypeLocal) forKey:@"type"];
			ASIHTTPRequest *request = [t_Network httpGet:paramDic Url:LOGIN_USER Delegate:self Tag:LOGIN_USER_TAG];
			[request startAsynchronous];
		}
		else if (isAccount == AccountTypeGoogle) {//google登陆
			if (currUserInfo.email)
				[paramDic setObject:currUserInfo.email forKey:@"email"];
			if (currUserInfo.authCode) {
				[paramDic setObject:currUserInfo.authCode forKey:@"authCode"];
				[paramDic setObject:@(UserLoginTypeGoogle) forKey:@"type"];
				ASIHTTPRequest *request = [t_Network httpGet:paramDic Url:LOGIN_USER Delegate:self Tag:LOGIN_USER_TAG];
				[request startAsynchronous];
			}
		}
	}
}

//初始化mian界面
- (void)initMainView {
	homeVC = [[HomeViewController alloc] initWithNibName:@"HomeViewController" bundle:nil];

	homeVC.isRefreshUIData = YES;//初始化的时候刷新ui加载数据
	nav = [[UINavigationController alloc] initWithRootViewController:homeVC];
	nav.navigationBar.translucent = NO;
	self.window.rootViewController = nav;
	[self.window makeKeyAndVisible];
}

- (void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification {
	if (notification) {
		UIApplicationState state = application.applicationState;

		if (state == UIApplicationStateActive) {
			UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"ALERT"
			                                                message:notification.alertBody
			                                               delegate:nil
			                                      cancelButtonTitle:@"确定"
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
	ASIHTTPRequest *request = [t_Network httpGet:nil Url:LoginUser_GetUserInfo Delegate:self Tag:LoginUser_GetUserInfo_Tag];
	[request startAsynchronous];
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

//网络改变
- (void)noReachabilityChanged {
//    UIAlertView *alert;
//    alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"请检查你的网络连接" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil];
//    [alert show];
	NSLog(@"无网络连接");
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
	//
	// The XMPPStream is the base class for all activity.
	// Everything else plugs into the xmppStream, such as modules/extensions and delegates.

	xmppStream = [[XMPPStream alloc] init];

#if !TARGET_IPHONE_SIMULATOR
	{
		// Want xmpp to run in the background?
		//
		// P.S. - The simulator doesn't support backgrounding yet.
		//        When you try to set the associated property on the simulator, it simply fails.
		//        And when you background an app on the simulator,
		//        it just queues network traffic til the app is foregrounded again.
		//        We are patiently waiting for a fix from Apple.
		//        If you do enableBackgroundingOnSocket on the simulator,
		//        you will simply see an error message from the xmpp stack when it fails to set the property.

		xmppStream.enableBackgroundingOnSocket = YES;
	}
#endif

	// Setup reconnect
	//
	// The XMPPReconnect module monitors for "accidental disconnections" and
	// automatically reconnects the stream for you.
	// There's a bunch more information in the XMPPReconnect header file.

	xmppReconnect = [[XMPPReconnect alloc] init];

	// Setup roster
	//
	// The XMPPRoster handles the xmpp protocol stuff related to the roster.
	// The storage for the roster is abstracted.
	// So you can use any storage mechanism you want.
	// You can store it all in memory, or use core data and store it on disk, or use core data with an in-memory store,
	// or setup your own using raw SQLite, or create your own storage mechanism.
	// You can do it however you like! It's your application.
	// But you do need to provide the roster with some storage facility.

	xmppRosterStorage = [[XMPPRosterCoreDataStorage alloc] init];
	//	xmppRosterStorage = [[XMPPRosterCoreDataStorage alloc] initWithInMemoryStore];

	xmppRoster = [[XMPPRoster alloc] initWithRosterStorage:xmppRosterStorage];

	xmppRoster.autoFetchRoster = YES;
	xmppRoster.autoAcceptKnownPresenceSubscriptionRequests = YES;

	// Setup vCard support
	//
	// The vCard Avatar module works in conjuction with the standard vCard Temp module to download user avatars.
	// The XMPPRoster will automatically integrate with XMPPvCardAvatarModule to cache roster photos in the roster.

	xmppvCardStorage = [XMPPvCardCoreDataStorage sharedInstance];
	xmppvCardTempModule = [[XMPPvCardTempModule alloc] initWithvCardStorage:xmppvCardStorage];

	xmppvCardAvatarModule = [[XMPPvCardAvatarModule alloc] initWithvCardTempModule:xmppvCardTempModule];

	// Setup capabilities
	//
	// The XMPPCapabilities module handles all the complex hashing of the caps protocol (XEP-0115).
	// Basically, when other clients broadcast their presence on the network
	// they include information about what capabilities their client supports (audio, video, file transfer, etc).
	// But as you can imagine, this list starts to get pretty big.
	// This is where the hashing stuff comes into play.
	// Most people running the same version of the same client are going to have the same list of capabilities.
	// So the protocol defines a standardized way to hash the list of capabilities.
	// Clients then broadcast the tiny hash instead of the big list.
	// The XMPPCapabilities protocol automatically handles figuring out what these hashes mean,
	// and also persistently storing the hashes so lookups aren't needed in the future.
	//
	// Similarly to the roster, the storage of the module is abstracted.
	// You are strongly encouraged to persist caps information across sessions.
	//
	// The XMPPCapabilitiesCoreDataStorage is an ideal solution.
	// It can also be shared amongst multiple streams to further reduce hash lookups.

	xmppCapabilitiesStorage = [XMPPCapabilitiesCoreDataStorage sharedInstance];
	xmppCapabilities = [[XMPPCapabilities alloc] initWithCapabilitiesStorage:xmppCapabilitiesStorage];

	xmppCapabilities.autoFetchHashedCapabilities = YES;
	xmppCapabilities.autoFetchNonHashedCapabilities = NO;

	// Activate xmpp modules

	[xmppReconnect activate:xmppStream];
	[xmppRoster activate:xmppStream];
	[xmppvCardTempModule activate:xmppStream];
	[xmppvCardAvatarModule activate:xmppStream];
	[xmppCapabilities activate:xmppStream];

	// Add ourself as a delegate to anything we may be interested in

	[xmppStream addDelegate:self delegateQueue:dispatch_get_main_queue()];
	[xmppRoster addDelegate:self delegateQueue:dispatch_get_main_queue()];

	// Optional:
	//
	// Replace me with the proper domain and port.
	// The example below is setup for a typical google talk account.
	//
	// If you don't supply a hostName, then it will be automatically resolved using the JID (below).
	// For example, if you supply a JID like 'user@quack.com/rsrc'
	// then the xmpp framework will follow the xmpp specification, and do a SRV lookup for quack.com.
	//
	// If you don't specify a hostPort, then the default (5222) will be used.

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

// It's easy to create XML elments to send and to read received XML elements.
// You have the entire NSXMLElement and NSXMLNode API's.
//
// In addition to this, the NSXMLElement+XMPP category provides some very handy methods for working with XMPP.
//
// On the iPhone, Apple chose not to include the full NSXML suite.
// No problem - we use the KissXML library as a drop in replacement.
//
// For more information on working with XML elements, see the Wiki article:
// https://github.com/robbiehanson/XMPPFramework/wiki/WorkingWithElements

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

	NSString *myJID = [[NSUserDefaults standardUserDefaults] stringForKey:kXMPPmyJID];
	NSString *myPassword = [[NSUserDefaults standardUserDefaults] stringForKey:kXMPPmyPassword];

	//
	// If you don't want to use the Settings view to set the JID,
	// uncomment the section below to hard code a JID and password.
	//
	// myJID = @"user@gmail.com/xmppframework";
	// myPassword = @"";

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

/**
 * Allows a delegate to hook into the TLS handshake and manually validate the peer it's connecting to.
 *
 * This is only called if the stream is secured with settings that include:
 * - GCDAsyncSocketManuallyEvaluateTrust == YES
 * That is, if a delegate implements xmppStream:willSecureWithSettings:, and plugs in that key/value pair.
 *
 * Thus this delegate method is forwarding the TLS evaluation callback from the underlying GCDAsyncSocket.
 *
 * Typically the delegate will use SecTrustEvaluate (and related functions) to properly validate the peer.
 *
 * Note from Apple's documentation:
 *   Because [SecTrustEvaluate] might look on the network for certificates in the certificate chain,
 *   [it] might block while attempting network access. You should never call it from your main thread;
 *   call it only from within a function running on a dispatch queue or on a separate thread.
 *
 * This is why this method uses a completionHandler block rather than a normal return value.
 * The idea is that you should be performing SecTrustEvaluate on a background thread.
 * The completionHandler block is thread-safe, and may be invoked from a background queue/thread.
 * It is safe to invoke the completionHandler block even if the socket has been closed.
 *
 * Keep in mind that you can do all kinds of cool stuff here.
 * For example:
 *
 * If your development server is using a self-signed certificate,
 * then you could embed info about the self-signed cert within your app, and use this callback to ensure that
 * you're actually connecting to the expected dev server.
 *
 * Also, you could present certificates that don't pass SecTrustEvaluate to the client.
 * That is, if SecTrustEvaluate comes back with problems, you could invoke the completionHandler with NO,
 * and then ask the client if the cert can be trusted. This is similar to how most browsers act.
 *
 * Generally, only one delegate should implement this method.
 * However, if multiple delegates implement this method, then the first to invoke the completionHandler "wins".
 * And subsequent invocations of the completionHandler are ignored.
 **/
- (void)   xmppStream:(XMPPStream *)sender didReceiveTrust:(SecTrustRef)trust
    completionHandler:(void (^)(BOOL shouldTrustPeer))completionHandler {
	DDLogVerbose(@"%@: %@", THIS_FILE, THIS_METHOD);

	// The delegate method should likely have code similar to this,
	// but will presumably perform some extra security code stuff.
	// For example, allowing a specific self-signed certificate that is known to the app.

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
	DDLogVerbose(@"%@: %@", THIS_FILE, THIS_METHOD);

	// A simple example of inbound message handling.

	if ([message isChatMessageWithBody]) {
		XMPPUserCoreDataStorageObject *user = [xmppRosterStorage userForJID:[message from]
		                                                         xmppStream:xmppStream
		                                               managedObjectContext:[self managedObjectContext_roster]];

		NSString *body = [[message elementForName:@"body"] stringValue];
		NSString *displayName = [user displayName];

		if ([[UIApplication sharedApplication] applicationState] == UIApplicationStateActive) {
			UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:displayName
			                                                    message:body
			                                                   delegate:nil
			                                          cancelButtonTitle:@"Ok"
			                                          otherButtonTitles:nil];
			[alertView show];
		}
		else {
			// We are not active, so use a local notification instead
			UILocalNotification *localNotification = [[UILocalNotification alloc] init];
			localNotification.alertAction = @"Ok";
			localNotification.alertBody = [NSString stringWithFormat:@"From: %@\n\n%@", displayName, body];

			[[UIApplication sharedApplication] presentLocalNotificationNow:localNotification];
		}
	}
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

@end
