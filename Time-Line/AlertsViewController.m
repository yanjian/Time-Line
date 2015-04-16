//
//  AlertsViewController.m
//  Time-Line
//
//  Created by IF on 14-10-12.
//  Copyright (c) 2014年 zhilifang. All rights reserved.
//

#import "AlertsViewController.h"
#import "EventAlertsViewController.h"
#import "AllDayEventsViewController.h"

@interface AlertsViewController () <UITableViewDelegate, UITableViewDataSource, EventAlertsDelegate, AllDayEventsDelegate>
@property (nonatomic, retain) UITableView *tableView;
@property (nonatomic, retain) NSMutableArray *selectIndexPathArr;
@property (nonatomic, assign) BOOL isSelect;
@property (nonatomic, retain) NSArray *alertsArr;
@property (nonatomic, strong) NSString *eventStr;
@property (nonatomic, strong) NSString *allDayEventStr;
@end

@implementation AlertsViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
	self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
	if (self) {
		// Custom initialization
	}
	return self;
}

- (void)viewDidLoad {
	[super viewDidLoad];
    self.title = @"Alerts" ;
    UIButton *leftBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [leftBtn setFrame:CGRectMake(0, 2, 22, 14)];
    [leftBtn setBackgroundImage:[UIImage imageNamed:@"Arrow_Left_Blue.png"] forState:UIControlStateNormal] ;
    [leftBtn addTarget:self action:@selector(visibleCaTobackSetingView) forControlEvents:UIControlEventTouchUpInside] ;
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:leftBtn] ;
    self.navigationController.interactivePopGestureRecognizer.delegate = (id)self;
    
	self.alertsArr = [NSArray arrayWithObjects:@"Events", @"All Day Events", nil];
	self.allDayEventStr = [USER_DEFAULT objectForKey:@"allDay"];
	self.eventStr = [USER_DEFAULT objectForKey:@"eventTime"];
	self.selectIndexPathArr = [NSMutableArray arrayWithCapacity:0];

	self.tableView = [[UITableView alloc] initWithFrame:[[UIScreen mainScreen] bounds] style:UITableViewStyleGrouped];
	self.tableView.dataSource = self;
	self.tableView.delegate = self;
	[self.view addSubview:self.tableView];
}

- (void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];
}

- (void)didReceiveMemoryWarning {
	[super didReceiveMemoryWarning];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return self.alertsArr.count;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
	return @"ALERT TIMES";
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
	return 35.f;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	NSString *cellIdentifier = @"cellVisible";
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
	if (cell == nil) {
		cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
	}
	cell.tag = indexPath.row;
	cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;

	UILabel *lab = [[UILabel alloc] initWithFrame:CGRectMake(140, 2, 150, 40)];
	NSArray *viewArr = [cell.contentView subviews];
	for (UIView *view in viewArr) {
		if (view.tag == indexPath.row) {
			[view removeFromSuperview];
		}
	}

	[lab setTag:indexPath.row];
	[lab setTextAlignment:NSTextAlignmentRight];
	[lab setBackgroundColor:[UIColor clearColor]];
	if (indexPath.row == 0) {
		[lab setText:self.eventStr];
	}
	else if (indexPath.row == 1) {
		[lab setText:self.allDayEventStr];
	}
	[cell.contentView addSubview:lab];

	cell.textLabel.text = self.alertsArr[indexPath.row];
	return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
	if (indexPath.row == 0) {//events
		EventAlertsViewController *eventAlerts = [[EventAlertsViewController alloc] init];
		eventAlerts.delegate = self;
		[self.navigationController pushViewController:eventAlerts animated:YES];
	}
	else if (indexPath.row == 1) {//all day
		AllDayEventsViewController *allDayEvents = [[AllDayEventsViewController alloc] init];
		allDayEvents.delegate = self;
		[self.navigationController pushViewController:allDayEvents animated:YES];
	}
}

- (void)viewDidDisappear:(BOOL)animated {
	[super viewDidDisappear:animated];
	[USER_DEFAULT setObject:self.allDayEventStr forKey:@"allDay"];
	[USER_DEFAULT setObject:self.eventStr forKey:@"eventTime"];
	[USER_DEFAULT synchronize];
}

- (void)eventsAlertTimeString:(NSString *)alertStr {
	self.eventStr =  alertStr;
	[self.tableView reloadData];
}

- (void)getAllDayEvent:(NSString *)timestr {
	self.allDayEventStr = timestr;
	[self.tableView reloadData];
}

- (void)visibleCaTobackSetingView {
	[self.navigationController popViewControllerAnimated:YES];
}

@end
