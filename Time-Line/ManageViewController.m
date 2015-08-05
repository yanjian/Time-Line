//
//  ManageViewController.m
//  Go2
//
//  Created by IF on 14/12/5.
//  Copyright (c) 2014年 zhilifang. All rights reserved.

#define latestCount @"latestCount"
#define latestEventMsg @"latestEventMsg"
#define latestMsgTime @"latestMsgTime"
#define latestUserName @"latestUserName"

#import "ManageViewController.h"
#import "MJRefresh.h"
#import "ActiveEventMode.h"
//#import "ActiveTableViewCell.h"
#import "EventInfoShowCell.h"
#import "UIColor+HexString.h"
#import "UIImageView+WebCache.h"
#import "CalendarDateUtil.h"
#import "ActivedetailsViewController.h"
//#import "JCMSegmentPageController.h"

#import "AddNewActiveViewController.h"
//#import "AddActiveViewController.h"
#import "ActiveDestinationViewController.h"
#import "SimpleEventViewController.h"
#import "HomeViewController.h"

typedef NS_ENUM (NSInteger, ShowActiveType) {
	ShowActiveType_upcoming     = 0,
	ShowActiveType_toBeConfirm  = 1,
	ShowActiveType_confirmed    = 2,
	ShowActiveType_past         = 3,
	ShowActiveType_hide         = 4,
	ShowActiveType_All          = 5,
	ShowActiveType_refusedNot   = 6
};


@interface ManageViewController () <UITableViewDelegate, UITableViewDataSource,
                                    UIScrollViewDelegate, ASIHTTPRequestDelegate, ActivedetailsViewControllerDelegate,UISearchBarDelegate>
{
	NSMutableArray * _tmpActiveArr;   //抓取到的数据都放在这个里面的（除隐藏的活动，直接放到_activeArr中的）
	ShowActiveType   _showActiveType;
	NSMutableArray * _selectActiveBtnArr;
    NSArray        * _configs;

    NSMutableDictionary *  latestMsgDic ;//存放最新的活动数据
    NSMutableArray      *  resultDataArr;
}
@property (strong, nonatomic)     IBOutlet UITableView *tableView;
@property (nonatomic,assign)      BOOL isSearch ;
@property (nonatomic,retain )     UISearchBar  * mySearchBar ;

@property (nonatomic ,assign) BOOL isSearchExe;
@end

@implementation ManageViewController
@synthesize _activeArr;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
    {
        self.view.frame =  CGRectMake (0, 0, kScreen_Width, kScreen_Height);
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshEventData:) name:DELETEEVENTNOTI object:nil];
    }
    return self;
}


- (void)viewDidLoad {
	[super viewDidLoad];

	_activeArr = [NSMutableArray array];
    _selectActiveBtnArr = [NSMutableArray array];
    latestMsgDic = [NSMutableDictionary dictionary];
    
	_showActiveType = ShowActiveType_All; //默认查询所有的活动

    self.tableView.separatorInset  = UIEdgeInsetsMake(0, 50, 0, 0);
    self.tableView.tableFooterView = [UIView new] ;
    
    UIView *headerView = [[UISearchBar alloc] initWithFrame:self.mySearchBar.frame];
    self.tableView.tableHeaderView = headerView;
    [self.tableView addSubview:self.mySearchBar];
    
    //收到信息的通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(fetchChatGroupInfo:) name:CHATGROUP_ACTIVENOTIFICTION object:nil];

	 [self setupRefresh];
  }

- (BOOL)shouldAutomaticallyForwardAppearanceMethods {
    return YES;
}

-(UISearchBar *)mySearchBar{
    if (!_mySearchBar) {
        //创建searchbar
        _mySearchBar  = [[UISearchBar alloc] init];
        _mySearchBar.delegate = self;
        _mySearchBar.placeholder = @"Search";
        _mySearchBar.translucent = YES ;
        _mySearchBar.delegate = self ;
        [_mySearchBar sizeToFit];
    }
    return _mySearchBar ;
}

/**
 *  集成刷新控件
 */
- (void)setupRefresh {
	// 1.下拉刷新(进入刷新状态就会调用self的headerRereshing)
	// dateKey用于存储刷新时间，可以保证不同界面拥有不同的刷新时间
	[self.tableView addHeaderWithTarget:self action:@selector(headerRereshing) dateKey:@"mamageV"];

	[self.tableView headerBeginRefreshing];

	// 2.上拉加载更多(进入刷新状态就会调用self的footerRereshing)
	//[self.tableView addFooterWithTarget:self action:@selector(footerRereshing)];
}

#pragma mark 开始进入刷新状态
- (void)headerRereshing {
    NSInteger loginStatus = [UserInfo currUserInfo].loginStatus;
    if (1!=loginStatus) {//1表示用户登陆
        [g_AppDelegate initLoginView:LoginOrLogoutType_ModelOpen];
    }else{
        if (g_NetStatus!=NotReachable){//在有网络的情况下自动登录
            [g_AppDelegate autoUserWithLogin];
        }
    }
    [self loadActiveData:nil]; //刷新数据
	[self.tableView headerEndRefreshing];
}

- (void)footerRereshing {
	[self.tableView footerEndRefreshing];
}

//- (void)viewWillAppear:(BOOL)animated {
//	[super viewWillAppear:animated];
//    
//    self.navigationController.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName:[UIColor blackColor]};
//    [self.navigationController.navigationBar setBarTintColor:[UIColor whiteColor]];
//}


-(void)fetchChatGroupInfo:(NSNotification *)notification{
    ChatContentModel * chatContent = [notification.userInfo objectForKey:CHATGROUP_USERINFO];
    if(chatContent){
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setDateStyle:NSDateFormatterMediumStyle];
        [formatter setTimeStyle:NSDateFormatterShortStyle];
        [formatter setDateFormat:@"YYYY-MM-dd HH:mm:ss"];
        NSTimeZone *timeZone = [NSTimeZone defaultTimeZone];
        [formatter setTimeZone:timeZone];
        NSRange  timePointRange = [chatContent.time rangeOfString:@"."];
        NSDate * objDate1 = nil ;
        if (timePointRange.location == NSNotFound) {
             objDate1 = [formatter dateFromString:chatContent.time];
        }else{
            objDate1 = [formatter dateFromString:[chatContent.time substringToIndex:timePointRange.location]];
        }

        NSMutableDictionary * latestDic = [latestMsgDic objectForKey:chatContent.eid] ;
        if (latestDic) {
            NSInteger latestMsgCount = [[latestDic objectForKey:@"latestCount"] integerValue];
            latestMsgCount+=1;
            [latestMsgDic removeObjectForKey:chatContent.eid];
            [latestMsgDic setObject:@{latestCount:@(latestMsgCount),latestEventMsg:chatContent.text==nil?@"":chatContent.text,latestMsgTime:objDate1,latestUserName:chatContent.username}.mutableCopy forKey:chatContent.eid];
            
        }else{
            [latestMsgDic setObject:@{latestCount:@(1),latestEventMsg:chatContent.text==nil?@"":chatContent.text,latestMsgTime:objDate1,latestUserName:chatContent.username==nil?@"":chatContent.username }.mutableCopy forKey:chatContent.eid];
        }
        [self fefreshTableView ];
    }
}

//加载没读取的数据
-(void)loadUnreadMsg:(NSString *) eventId{
    NSPredicate *nspre=[NSPredicate predicateWithFormat:@"unreadMessage==%i&&eid==%@",UNREADMESSAGE_NO,eventId];
    NSArray *chatContentArr=[ChatContentModel MR_findAllWithPredicate:nspre];
    if(chatContentArr && chatContentArr.count >0){
        [chatContentArr sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
            ChatContentModel *objChat1 =  ( ChatContentModel *)obj1 ;
            ChatContentModel *objChat2 =  ( ChatContentModel *)obj2 ;
            NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
            [formatter setDateStyle:NSDateFormatterMediumStyle];
            [formatter setTimeStyle:NSDateFormatterShortStyle];
            [formatter setDateFormat:@"YYYY-MM-dd HH:mm"];// ----------设置你想要的格式,hh与HH的区别:分别表示12小时制,24小时制
            NSTimeZone *timeZone = [NSTimeZone defaultTimeZone];
            [formatter setTimeZone:timeZone];
            NSDate * objDate1 = [formatter dateFromString:objChat1.time];
            NSDate * objDate2 = [formatter dateFromString:objChat2.time];

            NSComparisonResult result =[objDate1 compare:objDate2];
            switch(result)
            {
                case NSOrderedAscending:
                    return NSOrderedDescending;
                case NSOrderedDescending:
                    return NSOrderedAscending;
                case NSOrderedSame:
                    return NSOrderedSame;
                default:
                    return NSOrderedSame;
            } // 时间从近到远（远近相对当前时间而言）
        }];
        
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setDateStyle:NSDateFormatterMediumStyle];
        [formatter setTimeStyle:NSDateFormatterShortStyle];
        [formatter setDateFormat:@"YYYY-MM-dd HH:mm:ss"];
        NSTimeZone *timeZone = [NSTimeZone defaultTimeZone];
        [formatter setTimeZone:timeZone];
        
        ChatContentModel * tmpModel = [chatContentArr lastObject] ;
        
        NSRange  timePointRange = [tmpModel.time rangeOfString:@"."];
        NSDate * objDate1 = nil ;
        if (timePointRange.location == NSNotFound) {
            objDate1 = [formatter dateFromString:tmpModel.time];
        }else{
            objDate1 = [formatter dateFromString:[tmpModel.time substringToIndex:timePointRange.location]];
        }

        
        NSMutableDictionary * latestDic = [latestMsgDic objectForKey:eventId] ;
         NSInteger latestMsgCount = chatContentArr.count ;
        if (latestDic) {
            [latestMsgDic removeObjectForKey:eventId];
            [latestMsgDic setObject:@{latestCount:@(latestMsgCount),latestEventMsg:tmpModel.text == nil?@"":tmpModel.text,latestMsgTime:objDate1,latestUserName:tmpModel.username}.mutableCopy forKey:eventId];
        }else{
            if(tmpModel.text){
               [latestMsgDic setObject:@{latestCount:@(latestMsgCount),latestEventMsg:tmpModel.text == nil?@"":tmpModel.text,latestMsgTime:objDate1,latestUserName:tmpModel.username}.mutableCopy forKey:eventId];
            }
        }
    }else{
         [latestMsgDic removeObjectForKey:eventId];
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView; {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    [self showActiveWhatWithActiveType:_showActiveType];
    
    if (self.isSearch) {
        return resultDataArr.count ;
    }else{
       return _activeArr.count ;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 64.f;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 0.01f;
}

-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 0.01f;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
       EventInfoShowCell *activeCell = (EventInfoShowCell *) [tableView cellForRowAtIndexPath:indexPath];
       if (!activeCell) {
			activeCell = (EventInfoShowCell *)[[[NSBundle mainBundle] loadNibNamed:@"EventInfoShowCell" owner:self options:nil] firstObject];
            activeCell.showShortTitle.hidden = YES ;
            
        }
		if (resultDataArr.count > 0 || _activeArr.count>0) {
             ActiveBaseInfoMode *activeEvent = nil;
             if (self.isSearch) {
                activeEvent = resultDataArr[indexPath.row];
             }else{
                activeEvent = _activeArr[indexPath.row];
             }
            [self loadUnreadMsg:activeEvent.Id];
			activeCell.activeEvent = activeEvent;

            if ( activeEvent.imgUrl && ![@"" isEqualToString:activeEvent.imgUrl] ) {
                activeCell.showShortTitle.hidden = YES ;
                NSString *_urlStr = [[NSString stringWithFormat:@"%@/%@", BASEURL_IP, activeEvent.imgUrl] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
                NSLog(@"%@", _urlStr);
                NSURL *url = [NSURL URLWithString:_urlStr];
                [activeCell.activePic sd_setImageWithURL:url placeholderImage:[UIImage imageNamed:@"go2_grey"]];
            }else{
                activeCell.showShortTitle.hidden = NO ;
                [activeCell.activePic setBackgroundColor: [UIColor colorWithHexString:@"2e9ef1"]];
                activeCell.showShortTitle.text = [[activeEvent.title substringToIndex:1] uppercaseString];
            }
			
			activeCell.activeTitle.text = activeEvent.title;
            
            NSDictionary *latestDic = [latestMsgDic objectForKey:activeEvent.Id];
            activeCell.latestModifyMsg.text = [latestDic objectForKey:latestEventMsg] ;
            NSString * reUserName = [latestDic objectForKey:latestUserName];
            if (reUserName && ![@"" isEqualToString:reUserName ]) {
                 activeCell.latestModifyUserName.text =[NSString stringWithFormat:@"%@:",reUserName]  ;
            }
            
            NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
            [formatter setTimeStyle:NSDateFormatterShortStyle];
            NSTimeZone *timeZone = [NSTimeZone defaultTimeZone];
            [formatter setTimeZone:timeZone];
            activeCell.latestTime.text =[formatter stringFromDate:[latestDic objectForKey:latestMsgTime]];
            NSNumber *unReadCount = [latestDic objectForKey:latestCount];
            if ( [unReadCount intValue] == 0) {
                [activeCell.unReadCount setHidden:YES];
            }else{
                [activeCell.unReadCount setHidden:NO];
                if ([unReadCount intValue]>=100) {
                    activeCell.unReadCount.text = [NSString stringWithFormat:@"99+"] ;
                }else{
                    activeCell.unReadCount.text = [unReadCount stringValue] ;
                }
            }
		}
		return activeCell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    ActiveBaseInfoMode *activeEvent = nil ;
    if (self.isSearch) {
        activeEvent = resultDataArr[indexPath.row];
    }else{
        activeEvent = _activeArr[indexPath.row];
    }
	[tableView deselectRowAtIndexPath:indexPath animated:YES];

    UIStoryboard *storyboarb = [UIStoryboard storyboardWithName:@"ActiveDestination" bundle:[NSBundle mainBundle]];
     ActiveDestinationViewController * activeDesc =( ActiveDestinationViewController *)  [storyboarb instantiateViewControllerWithIdentifier:@"ActiveDescriptionId"];
     activeDesc.activeEventInfo = activeEvent;
     activeDesc.manageViewController = self ;
     activeDesc.hidesBottomBarWhenPushed = YES ;
    [self.navigationController pushViewController:activeDesc animated:YES];
}

#pragma mark -抓取隐藏的活动
- (void)featchHideActivity {
	ASIHTTPRequest *hideRequest = [t_Network httpGet:nil Url:anyTime_GetEventByNotification Delegate:nil Tag:anyTime_GetEventByNotification_tag];
	[hideRequest setDownloadCache:g_AppDelegate.anyTimeCache];
	[hideRequest setCachePolicy:ASIFallbackToCacheIfLoadFailsCachePolicy | ASIAskServerIfModifiedWhenStaleCachePolicy];
	[hideRequest setCacheStoragePolicy:ASICachePermanentlyCacheStoragePolicy];
	__block ASIHTTPRequest *request = hideRequest;
	[hideRequest setCompletionBlock: ^{
	    NSError *error = [request error];
	    if (error) {
	        return;
		}
	    [_activeArr removeAllObjects]; //清理掉数组中得活动添加隐藏的活动

	    NSString *responseStr = [request responseString];
	    id objData =  [responseStr objectFromJSONString];
	    if ([objData isKindOfClass:[NSDictionary class]]) {
	        NSDictionary *objDataDic = (NSDictionary *)objData;
	        NSString *statusCode = [objDataDic objectForKey:@"statusCode"];
	        if ([statusCode isEqualToString:@"1"]) {
	            id tmpObj = [objDataDic objectForKey:@"data"];
	            if ([tmpObj isKindOfClass:[NSArray class]]) {
	                NSArray *trueDataArr = (NSArray *)tmpObj;

	                for (NSDictionary *trueDataObj in trueDataArr) {
	                    ActiveBaseInfoMode *_tmpActiveEvent = [[ActiveBaseInfoMode alloc] init];
	                    [_tmpActiveEvent parseDictionary:trueDataObj];
	                    _tmpActiveEvent.isHide = YES; //这里的数据都是隐藏的活动
	                    [_activeArr addObject:_tmpActiveEvent];
					}
				}
			}
		}
	    [self fefreshTableView ];
	}];
	[hideRequest setFailedBlock: ^{
	    [MBProgressHUD showError:@"Load data failed, please check your network"];
	}];
	[hideRequest startAsynchronous];
}

- (void)didReceiveMemoryWarning {
	[super didReceiveMemoryWarning];
}

- (void)loadActiveData:(void (^)())AddHUD {
	if (AddHUD) {
		AddHUD();
	}
	if (_showActiveType == ShowActiveType_hide) {//在隐藏的活动页面就单独抓取
		[self featchHideActivity];
	}else {
		_tmpActiveArr = [NSMutableArray arrayWithCapacity:0];
		
        ASIHTTPRequest *activeRequest = [t_Network httpGet:nil Url:anyTime_GetEventBasicInfo Delegate:self Tag:anyTime_GetEventBasicInfo_tag];
		[activeRequest setDownloadCache:g_AppDelegate.anyTimeCache];
		[activeRequest setCachePolicy:ASIFallbackToCacheIfLoadFailsCachePolicy | ASIAskServerIfModifiedWhenStaleCachePolicy];
		[activeRequest setCacheStoragePolicy:ASICachePermanentlyCacheStoragePolicy];
		[activeRequest startAsynchronous];
	}
}


- (void)bounceTargetView:(UIView *)targetView {
	targetView.transform = CGAffineTransformMakeScale(0.9, 0.9);
	[UIView animateWithDuration:0.5 delay:0.0 usingSpringWithDamping:0.3 initialSpringVelocity:5 options:UIViewAnimationOptionCurveEaseInOut animations: ^{
	    targetView.transform = CGAffineTransformIdentity;
	} completion:nil];
}

#pragma mark -对数据进行过滤 --如
- (void)showActiveWhatWithActiveType:(NSInteger)activeType {
	switch (activeType) {
		case ShowActiveType_All: {
			[_activeArr removeAllObjects];  //这里不能移到外面去，否则hide 的活动就不能显示咯
			for (ActiveEventMode *eventMode in _tmpActiveArr) {//显示create的活动
				[_activeArr addObject:eventMode];
			}
		} break;

		case ShowActiveType_upcoming: {
			[_activeArr removeAllObjects];
			for (ActiveEventMode *eventMode in _tmpActiveArr) {//显示upcoming和（voting）的活动
				if ([eventMode.status integerValue] == ActiveStatus_upcoming) {
					[_activeArr addObject:eventMode];
				}
			}
		} break;

		case ShowActiveType_toBeConfirm: {
			[_activeArr removeAllObjects];
			for (ActiveEventMode *eventMode in _tmpActiveArr) {//显示toBeConfirm的活动
				if ([eventMode.status integerValue] == ActiveStatus_toBeConfirm) {
					[_activeArr addObject:eventMode];
				}
			}
		} break;

		case ShowActiveType_confirmed: {
			[_activeArr removeAllObjects];
			for (ActiveEventMode *eventMode in _tmpActiveArr) {//显示confirmed的活动
				if ([eventMode.status integerValue] == ActiveStatus_confirmed) {
					[_activeArr addObject:eventMode];
				}
			}
		} break;

		case ShowActiveType_past: {
			[_activeArr removeAllObjects];
			for (ActiveEventMode *eventMode in _tmpActiveArr) {//显示confirmed的活动
				if ([eventMode.status integerValue] == ShowActiveType_past) {
					[_activeArr addObject:eventMode];
				}
			}
		} break;

		case ShowActiveType_refusedNot: {
			[_activeArr removeAllObjects];
			for (ActiveEventMode *eventMode in _tmpActiveArr) {//显示confirmed的活动
				if (!eventMode.isNotification) {
					[_activeArr addObject:eventMode];
				}
			}
		} break;

		default:
			break;
	}
}

- (void)requestFinished:(ASIHTTPRequest *)request {
	switch (request.tag) {
		case anyTime_GetEventBasicInfo_tag: {
			NSError *error = [request error];
			if (error) {
				[MBProgressHUD showError:@"error"];
			}
			NSString *requestStr =  [request responseString];
			NSDictionary *dic = [requestStr objectFromJSONString];
			NSString *statusCode = [dic objectForKey:@"statusCode"];
			if ([@"1" isEqualToString:statusCode]) {
				id dataObj = [dic objectForKey:@"data"];
				if ([dataObj isKindOfClass:[NSArray class]]) {
					NSArray *activeArr = (NSArray *)dataObj;
					for (int i = 0; i < activeArr.count; i++) {
						ActiveBaseInfoMode *activeEvent = [[ActiveBaseInfoMode alloc] init];
						[activeEvent parseDictionary:activeArr[i]];
						if (activeEvent.member) {
							NSDictionary *memberDataDic = [activeEvent.member firstObject];  //在活动基本信息接口中member只有当前用户
							NSInteger notNum =  [[memberDataDic objectForKey:@"notification"] integerValue];
							activeEvent.isNotification = notNum == 1 ? YES : NO;
						}
						[_tmpActiveArr addObject:activeEvent];
					}
				}
				[self fefreshTableView ];
			}else {
				//[MBProgressHUD showError:@"Request Fail"];
			}
			[MBProgressHUD hideHUDForView:self.view animated:YES];
		} break;
		default:
			break;
	}
}

- (void)requestFailed:(ASIHTTPRequest *)request {
	NSError *error = [request error];
	if (error) {
		[MBProgressHUD hideHUDForView:self.view];
		[MBProgressHUD showError:@"Network error"];
	}
}

- (void)cancelActivedetailsViewController:(ActivedetailsViewController *)activeDetailsViewVontroller {
	[self loadActiveData:nil];//刷新数据
    [activeDetailsViewVontroller.navigationController popToViewController:self animated:YES];
    
}


/**
 *点击搜索执行的方法
 *
 */
- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar{
    if (searchBar.text) {
        self.isSearch = YES ;
        [searchBar resignFirstResponder];
        
        NSString *searchStr = [NSString stringWithFormat:@"*%@*",searchBar.text];
        NSPredicate *filterPre= [NSPredicate predicateWithFormat:@"title LIKE %@",searchStr];
        NSArray * filterArr = [_activeArr filteredArrayUsingPredicate:filterPre];
        resultDataArr = [NSMutableArray arrayWithArray:filterArr];
        [self.tableView reloadData];
    }
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText{
    if (searchBar.text && ![@"" isEqualToString:searchBar.text]) {
        self.isSearch = YES ;
        NSString *searchStr = [NSString stringWithFormat:@"*%@*",searchBar.text];
        NSPredicate *filterPre= [NSPredicate predicateWithFormat:@"title LIKE %@",searchStr];
        NSArray * filterArr = [_activeArr filteredArrayUsingPredicate:filterPre];
        resultDataArr = [NSMutableArray arrayWithArray:filterArr];
       
    }else{
        self.isSearch = NO ;
        [searchBar resignFirstResponder];
        [resultDataArr removeAllObjects];
        
    }
    [self fefreshTableView ];
}



//刷新表格
-(void)fefreshTableView{
     [self.tableView reloadData];
}

-(void)scrollViewDidScroll:(UIScrollView *)scrollView{
//    if ([self.mySearchBar becomeFirstResponder]) {
//        [self.mySearchBar resignFirstResponder];
//    }
//    if (scrollView.contentOffset.y < 44) {
//        self.tableView.contentInset = UIEdgeInsetsZero;
//    } else {
//        self.tableView.contentInset = UIEdgeInsetsMake(-CGRectGetHeight(self.mySearchBar.bounds), 0, 0, 0);
//    }
}

/**
 *
 *删除事件时发出的通知处理
 */
-(void)refreshEventData:(NSNotification *) notification{
    NSString * eventId =  [notification.userInfo objectForKey:DELETEEVENTNOTI_INFO];
    NSPredicate * pre = [NSPredicate predicateWithFormat:@"Id == %@",eventId];
    ActiveBaseInfoMode * activeBaseInfo =  [[_tmpActiveArr filteredArrayUsingPredicate:pre] lastObject];
    [_tmpActiveArr removeObject:activeBaseInfo];
    [self fefreshTableView ];
}


- (NSString *)monthStringWithInteger:(NSUInteger)month {
	NSString *monthStr;
	switch (month) {
		case 1:
			monthStr = @"JAN";
			break;

		case 2:
			monthStr = @"FEB";
			break;

		case 3:
			monthStr = @"MAR";
			break;

		case 4:
			monthStr = @"APR";
			break;

		case 5:
			monthStr = @"MAY";
			break;

		case 6:
			monthStr = @"JUN";
			break;

		case 7:
			monthStr = @"JUL";
			break;

		case 8:
			monthStr = @"AUG";
			break;

		case 9:
			monthStr = @"SEP";
			break;

		case 10:
			monthStr = @"OCT";
			break;

		case 11:
			monthStr = @"NOV";
			break;

		case 12:
			monthStr = @"DEC";
			break;

		default:
			break;
	}
	return monthStr;
}

-(void)dealloc{
    
    [[NSNotificationCenter defaultCenter] removeObserver:DELETEEVENTNOTI];
}

@end
