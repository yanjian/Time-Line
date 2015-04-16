//
//  AllDayEventsViewController.m
//  Time-Line
//
//  Created by IF on 14-10-15.
//  Copyright (c) 2014年 zhilifang. All rights reserved.
//

#import "AllDayEventsViewController.h"

@interface AllDayEventsViewController () <UITableViewDelegate, UITableViewDataSource>
@property (nonatomic, retain) UITableView *tableView;
@property (nonatomic, retain) NSArray *allDayEventArr;
@end

@implementation AllDayEventsViewController


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
	self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
	if (self) {
		// Custom initialization
	}
	return self;
}

- (void)viewDidLoad {
	[super viewDidLoad];
    self.title = @"Events" ;
    UIButton *leftBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [leftBtn setFrame:CGRectMake(0, 2, 22, 14)];
    [leftBtn setBackgroundImage:[UIImage imageNamed:@"Arrow_Left_Blue.png"] forState:UIControlStateNormal] ;
    [leftBtn addTarget:self action:@selector(visibleCaTobackSetingView) forControlEvents:UIControlEventTouchUpInside] ;
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:leftBtn] ;
    self.navigationController.interactivePopGestureRecognizer.delegate = (id)self;
    
	self.allDayEventArr = [NSArray arrayWithObjects:@"never", @"5:00", @"7:00", @"8:00", @"9:00", @"10:00", nil];

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
	return self.allDayEventArr.count;
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
	cell.textLabel.text = self.allDayEventArr[indexPath.row];
	return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
	UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
	[self.delegate getAllDayEvent:cell.textLabel.text];
	[self visibleCaTobackSetingView];
}

- (void)visibleCaTobackSetingView {
	[self.navigationController popViewControllerAnimated:YES];
}

@end
