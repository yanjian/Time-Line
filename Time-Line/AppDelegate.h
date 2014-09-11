//
//  AppDelegate.h
//  Time-Line
//
//  Created by IF on 14-9-1.
//  Copyright (c) 2014年 zhilifang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MBProgressHUD.h"
#import "Reachability.h"
#import "ASINetworkQueue.h"
#import "FlipBoardNavigationController.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (readwrite, nonatomic) BOOL isread;

@property (nonatomic,strong) FlipBoardNavigationController *flipNC;

@property (nonatomic,strong) MBProgressHUD *HUD;
@property (nonatomic,assign) NetworkStatus netWorkStatus; //g_NetStatus
@property (nonatomic,retain) ASINetworkQueue *netWorkQueue; //g_ASIQueue

+(AppDelegate *)getAppDelegate;

#pragma mark - MBProgressHuD Method
//显示带时限的等待进度提示框
- (void)showActivityView:(NSString*)text interval:(NSTimeInterval)time;

//持续显示的提示框
- (void)showActivityView:(NSString *)text;

//显示普通的文字提示框
- (void)showNormalyTextView:(NSString *)text interval:(NSTimeInterval)time;

//隐藏提示框
- (void)hideActivityView ;

@end
