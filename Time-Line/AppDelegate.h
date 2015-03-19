//
//  AppDelegate.h
//  Time-Line
//
//  Created by IF on 14-9-1.
//  Copyright (c) 2014年 zhilifang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>
#import "Reachability.h"
#import "ASINetworkQueue.h"
#import "ASIDownloadCache.h"
#import "FlipBoardNavigationController.h"
#import "ChatContentModel.h"
#import "XMPPFramework.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate, XMPPRosterDelegate>
{
	XMPPStream *xmppStream;
	XMPPReconnect *xmppReconnect;
	XMPPRoster *xmppRoster;
	XMPPRosterCoreDataStorage *xmppRosterStorage;
	XMPPvCardCoreDataStorage *xmppvCardStorage;
	XMPPvCardTempModule *xmppvCardTempModule;
	XMPPvCardAvatarModule *xmppvCardAvatarModule;
	XMPPCapabilities *xmppCapabilities;
	XMPPCapabilitiesCoreDataStorage *xmppCapabilitiesStorage;

	NSString *password;

	BOOL customCertEvaluation;

	BOOL isXmppConnected;
}

@property (nonatomic, strong, readonly) XMPPStream *xmppStream;
@property (nonatomic, strong, readonly) XMPPReconnect *xmppReconnect;
@property (nonatomic, strong, readonly) XMPPRoster *xmppRoster;
@property (nonatomic, strong, readonly) XMPPRosterCoreDataStorage *xmppRosterStorage;
@property (nonatomic, strong, readonly) XMPPvCardTempModule *xmppvCardTempModule;
@property (nonatomic, strong, readonly) XMPPvCardAvatarModule *xmppvCardAvatarModule;
@property (nonatomic, strong, readonly) XMPPCapabilities *xmppCapabilities;
@property (nonatomic, strong, readonly) XMPPCapabilitiesCoreDataStorage *xmppCapabilitiesStorage;

@property (strong, nonatomic) UIWindow *window;
@property (nonatomic, strong) FlipBoardNavigationController *flipNC;
@property (nonatomic, retain) ASINetworkQueue *netWorkQueue; //g_ASIQueue
@property (nonatomic, assign) NetworkStatus netWorkStatus; //g_NetStatus
@property (nonatomic, retain) ASIDownloadCache *anyTimeCache;
@property (strong, nonatomic) NSNumber * isRead; //信息是否读取

@property (strong, nonatomic) UITabBarController *tabBarController;


+ (AppDelegate *)getAppDelegate;


- (NSManagedObjectContext *)managedObjectContext_roster;
- (NSManagedObjectContext *)managedObjectContext_capabilities;

- (BOOL)connect;
- (void)disconnect;

//初始化登陆页面
- (void)initLoginView;

//pragma mark -保存聊天信息
-(ChatContentModel *)saveChatInfoForActive:(NSDictionary * ) bodyDic;
- (void)autoUserWithLogin;
- (void)initMainView;
//文件归档
- (void)saveFileWithArray:(NSMutableArray *)activityArray fileName:(NSString *)name;
//文件解档
- (NSMutableArray *)loadDataFromFile:(NSString *)fileName;
@end
