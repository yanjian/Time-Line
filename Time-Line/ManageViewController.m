//
//  ManageViewController.m
//  Time-Line
//
//  Created by IF on 14/12/5.
//  Copyright (c) 2014年 zhilifang. All rights reserved.
//

#import "ManageViewController.h"
#import "MJRefresh.h"
#import "ActiveEventMode.h"
#import "ActiveTableViewCell.h"
#import "UIImageView+WebCache.h"
#import "CalendarDateUtil.h"
#import "ActivedetailsViewController.h"
#import "JCMSegmentPageController.h"
#import "DXPopover.h"

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
                                    UIScrollViewDelegate, ASIHTTPRequestDelegate, ActivedetailsViewControllerDelegate>
{
	NSMutableArray *_activeArr;  //用于显示活动的数组
	NSMutableArray *_tmpActiveArr;   //抓取到的数据都放在这个里面的（除隐藏的活动，直接放到_activeArr中的）
	ShowActiveType _showActiveType;
	NSMutableArray *_selectActiveBtnArr;
	NSArray *_configs;
}
@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) IBOutlet UITableView *popTableView;
@property (nonatomic, strong) DXPopover *popover;

@end

@implementation ManageViewController

- (void)viewDidLoad {
	[super viewDidLoad];
	CGRect frame = CGRectMake(0, 0, kScreen_Width, kScreen_Height);
	self.view.frame = frame;


	_activeArr = [NSMutableArray array]; //创建一个数组

	_showActiveType = ShowActiveType_All; //默认查询所有的活动

	_selectActiveBtnArr = [NSMutableArray array];

	UIView *selectView = [[UIView alloc] initWithFrame:CGRectMake(0, 1, frame.size.width, 25)];
	for (int i = 0; i < 3; i++) {
		UIButton *allBtn = [[UIButton alloc] initWithFrame:CGRectMake(selectView.frame.size.width / 3 * i, 0, selectView.frame.size.width / 3, 25)];
		[allBtn setBackgroundImage:[UIImage imageNamed:@"TIme_Start"] forState:UIControlStateSelected];
		allBtn.titleLabel.font = [UIFont systemFontOfSize:12.f];
		if (i == 0) {
			[allBtn setSelected:YES];
			allBtn.tag = ShowActiveType_All;
			[allBtn setTitle:@"ALL" forState:UIControlStateNormal];
		}
		else if (i == 1) {
			allBtn.tag = ShowActiveType_upcoming;
			[allBtn setTitle:@"UpComing" forState:UIControlStateNormal];
		}
		else if (i == 2) {
			allBtn.tag = 2;
			[allBtn setTitle:@"More" forState:UIControlStateNormal];
		}

		[allBtn addTarget:self action:@selector(clickTouchUpInside:) forControlEvents:UIControlEventTouchUpInside];
		[selectView addSubview:allBtn];
		[_selectActiveBtnArr addObject:allBtn];
	}
	[selectView setBackgroundColor:blueColor];
	[self.view addSubview:selectView];

	self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0,
	                                                               selectView.frame.size.height,
	                                                               frame.size.width,
	                                                               frame.size.height - (selectView.frame.size.height + selectView.frame.origin.y + naviHigth))
	                                              style:UITableViewStyleGrouped];
	self.tableView.delegate = self;
	self.tableView.dataSource = self;
	[self.view addSubview:self.tableView];

	[self setupRefresh];


	_configs = @[@"To be confirm", @"Confirm", @"Past", @"Hide", @"Refused notification"];

	self.popTableView = [[UITableView alloc] initWithFrame:CGRectMake(0,
	                                                                  0,
	                                                                  200,
	                                                                  220)
	                                                 style:UITableViewStylePlain];
	self.popTableView.delegate   = self;
	self.popTableView.dataSource = self;

	self.popover = [DXPopover new];
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
	[self.tableView addFooterWithTarget:self action:@selector(footerRereshing)];
}

#pragma mark 开始进入刷新状态
- (void)headerRereshing {
	[self loadActiveData:nil]; //刷新数据
	[self.tableView headerEndRefreshing];
}

- (void)footerRereshing {
	[self.tableView footerEndRefreshing];
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView; {
	if (self.popTableView == tableView) {
		return 1;
	}
	else {
		[self showActiveWhatWithActiveType:_showActiveType];
		return _activeArr.count;
	}
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	if (self.popTableView == tableView) {
		return _configs.count;
	}
	else {
		return 1;
	}
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	if (tableView == self.popTableView) {
		return 44.f;
	}
	else
		return 150.f;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
	return 2.f;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
	return 0.1f;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	if (self.popTableView == tableView) {
		static NSString *configId = @"configID";
		UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:configId];
		if (!cell) {
			cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:configId];
		}

		cell.textLabel.text = [_configs objectAtIndex:indexPath.row];

		return cell;
	}
	else {
		static NSString *activeId = @"activeManagerCellId";
		ActiveTableViewCell *activeCell = [tableView dequeueReusableCellWithIdentifier:activeId];
		if (!activeCell) {
			activeCell = (ActiveTableViewCell *)[[[NSBundle mainBundle] loadNibNamed:@"ActiveTableViewCell" owner:self options:nil] firstObject];
		}
		if (_activeArr.count > 0) {
			ActiveBaseInfoMode *activeEvent = _activeArr[indexPath.section];

			activeCell.activeEvent = activeEvent;

			if ([activeEvent.status integerValue] == ActiveStatus_upcoming) {
				if ([activeEvent.type integerValue] == 2) {
					activeCell.activeStateLab.text = @"UpComing(Voting)";
				}
				else {
					activeCell.activeStateLab.text = @"UpComing";
				}
			}
			else if ([activeEvent.status integerValue] == ActiveStatus_toBeConfirm) {
				activeCell.activeStateLab.text = @"To be Confirm";
			}
			else if ([activeEvent.status integerValue] == ActiveStatus_confirmed) {
				activeCell.activeStateLab.text = @"Confirmed";
			}
			else if ([activeEvent.status integerValue] == ActiveStatus_past) {
				activeCell.activeStateLab.text = @"Past";
			}
			NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
			[formatter setDateStyle:NSDateFormatterMediumStyle];
			[formatter setTimeStyle:NSDateFormatterShortStyle];
			[formatter setDateFormat:@"YYYY-MM-dd HH:mm"];
			NSTimeZone *timeZone = [NSTimeZone defaultTimeZone];
			[formatter setTimeZone:timeZone];

			NSDate *createTime = [formatter dateFromString:activeEvent.createTime];
			NSInteger currMonth = [CalendarDateUtil getMonthWithDate:createTime];
			NSInteger currDay = [CalendarDateUtil getDayWithDate:createTime];
			activeCell.monthLab.text = [self monthStringWithInteger:currMonth];
			activeCell.dayCountLab.text = [NSString stringWithFormat:@"%ld", (long)currDay];
			NSString *_urlStr = [[NSString stringWithFormat:@"%@/%@", BASEURL_IP, activeEvent.imgUrl] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
			NSLog(@"%@", _urlStr);
			NSURL *url = [NSURL URLWithString:_urlStr];
			[activeCell.activeImg sd_setImageWithURL:url placeholderImage:[UIImage imageNamed:@"018.jpg"]];
			activeCell.activeNameLab.text = activeEvent.title;
		}

		return activeCell;
	}
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	if (tableView == self.popTableView) {
		if (indexPath.row == 0) { //
			_showActiveType = ShowActiveType_toBeConfirm;
			[self.tableView reloadData];
		}
		else if (indexPath.row == 1) {
			_showActiveType = ShowActiveType_confirmed;
			[self.tableView reloadData];
		}
		else if (indexPath.row == 2) {
			_showActiveType = ShowActiveType_past;
			[self.tableView reloadData];
		}
		else if (indexPath.row == 3) {
			_showActiveType = ShowActiveType_hide;
			[self featchHideActivity];
		}
		else if (indexPath.row == 4) {
			_showActiveType = ShowActiveType_refusedNot;
			[self.tableView reloadData];
		}
		return;
	}
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
	ActivedetailsViewController *activeDetailVC = [[ActivedetailsViewController alloc] init];
	ActiveBaseInfoMode *activeEvent = _activeArr[indexPath.section];
	activeDetailVC.delegate = self;
	activeDetailVC.activeEventInfo = activeEvent;
	[self.navigationController pushViewController:activeDetailVC animated:YES];
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
	    [self.tableView reloadData];
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
	}
	else {
		_tmpActiveArr = [NSMutableArray arrayWithCapacity:0];
		ASIHTTPRequest *activeRequest = [t_Network httpGet:nil Url:anyTime_GetEventBasicInfo Delegate:self Tag:anyTime_GetEventBasicInfo_tag];
		[activeRequest setDownloadCache:g_AppDelegate.anyTimeCache];
		[activeRequest setCachePolicy:ASIFallbackToCacheIfLoadFailsCachePolicy | ASIAskServerIfModifiedWhenStaleCachePolicy];
		[activeRequest setCacheStoragePolicy:ASICachePermanentlyCacheStoragePolicy];
		[activeRequest startAsynchronous];
	}
}

- (void)clickTouchUpInside:(UIButton *)sender {
	for (UIButton *button in _selectActiveBtnArr) {
		button.selected = NO;
	}
	sender.selected = YES;
	if (sender.tag == 2) { //more 按钮
		CGPoint startPoint = CGPointMake(CGRectGetMidX(sender.frame), CGRectGetMaxY(sender.frame) + 20);

		[self.popover showAtPoint:startPoint popoverPostion:DXPopoverPositionDown withContentView:self.popTableView inView:self.view];
		__weak typeof(self) weakSelf = self;

		self.popover.didDismissHandler = ^{
			[weakSelf bounceTargetView:sender];
		};
	}
	else {
		if (_showActiveType != sender.tag) {//这里tag 的值 要与 _showActiveType的值一致 好处理
			[self bounceTargetView:sender];
			_showActiveType = sender.tag;
			[_tableView reloadData];
		}
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
				[self.tableView reloadData];
			}
			else {
				[MBProgressHUD showError:@"Request Fail"];
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

	for (UIViewController *viewController in activeDetailsViewVontroller.navigationController.viewControllers) {
		if ([viewController isKindOfClass:[JCMSegmentPageController class]]) {
			[activeDetailsViewVontroller.navigationController popToViewController:viewController animated:YES];
		}
	}
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

@end
