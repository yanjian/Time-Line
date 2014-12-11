//
//  AppDelegate.h
//  Time-Line
//
//  Created by IF on 14-9-1.
//  Copyright (c) 2014年 zhilifang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Reachability.h"
#import "ASINetworkQueue.h"
#import "FlipBoardNavigationController.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (readwrite, nonatomic) BOOL isread;

@property (nonatomic,strong) FlipBoardNavigationController *flipNC;

@property (nonatomic,retain) ASINetworkQueue *netWorkQueue; //g_ASIQueue
@property (nonatomic,assign) NetworkStatus netWorkStatus; //g_NetStatus



+(AppDelegate *)getAppDelegate;


-(void) initLoginView:(id )target;

-(void)autoUserWithLogin;
-(void)initMainView;
//清理存储在NSUserDefaults中的信息
-(void) clearUserDefault:(NSUserDefaults *) userInfo;
//文件归档
- (void) saveFileWithArray: (NSMutableArray*)activityArray fileName:(NSString *) name;
//文件解档
- (NSMutableArray *)loadDataFromFile:(NSString *)fileName;
@end
