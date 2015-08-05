//
//  EventAlertsViewController.m
//  Go2
//
//  Created by IF on 14-10-15.
//  Copyright (c) 2014年 zhilifang. All rights reserved.
//

#import "EventAlertsViewController.h"

@interface EventAlertsViewController () <UITableViewDataSource, UITableViewDelegate>
@property (nonatomic, retain) UITableView *tableView;
@property (nonatomic, assign) EventsAlertTime eventsAlertTime;
@end

@implementation EventAlertsViewController


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
	self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
	if (self) {
	}
	return self;
}

- (void)viewDidLoad {
	[super viewDidLoad];
     self.title = @"Events" ;
     UIButton *leftBtn = [UIButton buttonWithType:UIButtonTypeCustom];
     [leftBtn setFrame:CGRectMake(0, 2, 22, 14)];
     [leftBtn setBackgroundImage:[UIImage imageNamed:@"go2_arrow_left"] forState:UIControlStateNormal] ;
     [leftBtn addTarget:self action:@selector(visibleCaTobackSetingView) forControlEvents:UIControlEventTouchUpInside] ;
     
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:leftBtn] ;
    self.navigationController.interactivePopGestureRecognizer.delegate = (id)self;
    
    self.eventsAlertTime = [[USER_DEFAULT objectForKey:@"eventTime"] integerValue];
    
	self.tableView = [[UITableView alloc] initWithFrame:[[UIScreen mainScreen] bounds] style:UITableViewStyleGrouped];
	self.tableView.dataSource = self;
	self.tableView.delegate = self;
	[self.view addSubview:self.tableView];
}

- (void)didReceiveMemoryWarning {
	[super didReceiveMemoryWarning];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return self.eventAlertsArr.count;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
	return @"Alert";
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
	return 35.f;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	NSString *cellIdentifier = @"cellEventsAlert";
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
	if (cell == nil) {
		cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
	}
    NSString * alertStr    = self.eventAlertsArr[indexPath.row];
    NSString * alertTmpStr = self.eventAlertsArr[self.eventsAlertTime];
    if ([alertStr isEqualToString:alertTmpStr]) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark ;
    }
    
	cell.textLabel.text = alertStr ;
	return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
	UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    if (self.delegate && [self.delegate respondsToSelector:@selector(eventsAlertTimeString:atIndex:)]) {
        [self.delegate eventsAlertTimeString:cell.textLabel.text atIndex:indexPath.row];
    }
	[self visibleCaTobackSetingView];
}

- (void)visibleCaTobackSetingView {
	[self.navigationController popViewControllerAnimated:YES];
}

@end
