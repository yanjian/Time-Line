//
//  ActiveDestinationViewController.m
//  Go2
//
//  Created by IF on 15/4/2.
//  Copyright (c) 2015年 zhilifang. All rights reserved.
//

#import "ActiveDestinationViewController.h"
#import "ActiveInfoTableViewController.h"
#import "ActiveVotingViewController.h"
#import "ChatViewController.h"
#import "ActiveAlbumsTableViewController.h"
#import "ActiveEventMode.h"
#import "ActiveSetingTableViewController.h"
#import "TimeVoteModel.h"

@interface ActiveDestinationViewController ()<ASIHTTPRequestDelegate>
{
    ActiveEventMode  * ac;
}
@end

@implementation ActiveDestinationViewController

-(instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
       
    }
    return self ;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"Event";
    self.containerView.bounces = NO ; //XLButtonBarPagerTabStripViewController中的属性  
    [self colorWithNavigationBar];
    
    UIButton *leftBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [leftBtn setFrame:CGRectMake(0, 0, 22, 14)];
    [leftBtn setTag:1];
    [leftBtn setBackgroundImage:[UIImage imageNamed:@"go2_arrow_left"] forState:UIControlStateNormal] ;
    [leftBtn addTarget:self action:@selector(backToEventView:) forControlEvents:UIControlEventTouchUpInside] ;
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:leftBtn] ;
    
    UIButton *rightBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [rightBtn setFrame:CGRectMake(0, 0, 22, 17)];
    [rightBtn setTag:2];
    [rightBtn setBackgroundImage:[UIImage imageNamed:@"Icon_Menu"] forState:UIControlStateNormal] ;
    [rightBtn addTarget:self action:@selector(backToEventView:) forControlEvents:UIControlEventTouchUpInside] ;
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:rightBtn] ;
    
    self.navigationController.interactivePopGestureRecognizer.delegate =(id) self ;
}


-(ActiveEventMode * )loadActiveData{
    __block ActiveEventMode *activeEvent = nil;
    ASIHTTPRequest *activeRequest = [t_Network httpGet:@{ @"eid":self.activeEventInfo.Id }.mutableCopy Url:anyTime_Events Delegate:nil Tag:anyTime_Events_tag];
    [activeRequest setDownloadCache:g_AppDelegate.anyTimeCache];
    [activeRequest setCachePolicy:ASIFallbackToCacheIfLoadFailsCachePolicy | ASIAskServerIfModifiedWhenStaleCachePolicy];
    [activeRequest setCacheStoragePolicy:ASICachePermanentlyCacheStoragePolicy];
    __block ASIHTTPRequest *request = activeRequest;
    [activeRequest setCompletionBlock: ^{
        NSError *error = [request error];
        if (error) {
            return;
        }
        NSString *responseStr = [request responseString];
        id objData =  [responseStr objectFromJSONString];
        if ([objData isKindOfClass:[NSDictionary class]]) {
            NSDictionary *objDataDic = (NSDictionary *)objData;
            NSString *statusCode = [objDataDic objectForKey:@"statusCode"];
            if ([statusCode isEqualToString:@"1"]) {
                id tmpObj = [objDataDic objectForKey:@"data"];
                if ([tmpObj isKindOfClass:[NSDictionary class]]) {
                    NSDictionary *trueDataObj = (NSDictionary *)tmpObj;
                    ActiveEventMode *_tmpActiveEvent = [[ActiveEventMode alloc] init];
                    [_tmpActiveEvent parseDictionary:trueDataObj];
                    activeEvent = _tmpActiveEvent;
                }
            }
        }
    }];
    
    [activeRequest setFailedBlock: ^{
        [MBProgressHUD showError:@"Load data failed, please check your network"];
    }];
    
    [activeRequest startSynchronous];
    return activeEvent ;
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self colorWithNavigationBar];
}


-(NSArray *)childViewControllersForPagerTabStripViewController:(XLPagerTabStripViewController *)pagerTabStripViewController{
    
    ac = [self loadActiveData];

    ActiveInfoTableViewController * activeInfoVc  = [[ActiveInfoTableViewController alloc]   init];
    activeInfoVc.activeEvent = ac ;
    
    activeInfoVc.activeDestinationBlank = ^(){
        [pagerTabStripViewController moveToViewControllerAtIndex:1];//这里
    };
    
    ActiveVotingViewController * activeVotingVc   = [[ActiveVotingViewController alloc] init];
    activeVotingVc.activeEvent = ac ;
    
    ChatViewController *chatVc = [[ChatViewController alloc] init] ;
    chatVc.activeEvent = ac ;
    
    ActiveAlbumsTableViewController * activeAlbumsVc   = [[ActiveAlbumsTableViewController alloc] init];
    activeAlbumsVc.eid = ac.Id ;
    return @[activeInfoVc,activeVotingVc,chatVc,activeAlbumsVc];
}


/**
 *配置NavigationBar的颜色，和字体的颜色
 */
-(void)colorWithNavigationBar{
    self.navigationController.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName:[UIColor whiteColor]};
    [self.navigationController.navigationBar setBarTintColor:[UIColor colorWithHexString:@"31aaeb"]];
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)backToEventView:(UIButton *) sender{
    switch (sender.tag) {
        case 1:{
               [self.navigationController popViewControllerAnimated:YES] ;
            }break;
        case 2:{
                ActiveSetingTableViewController * activeSetingVC = [[ActiveSetingTableViewController alloc] init];
                activeSetingVC.activeEvent = ac ;
                [self.navigationController pushViewController:activeSetingVC animated:YES];
            }break;
        default:
            break;
    }
}
@end
