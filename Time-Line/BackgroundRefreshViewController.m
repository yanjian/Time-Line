//
//  BackgroundRefreshViewController.m
//  Time-Line
//
//  Created by IF on 14-10-12.
//  Copyright (c) 2014年 zhilifang. All rights reserved.
//

#import "BackgroundRefreshViewController.h"
#import "AT_Account.h"
#import "Calendar.h"
@interface BackgroundRefreshViewController () <UITableViewDataSource, UITableViewDelegate>
@property (nonatomic, retain) UITableView *tableView;
@property (nonatomic, retain) NSMutableArray *selectIndexPathArr;
@property (nonatomic, assign) BOOL isSelect;
@property (nonatomic, retain) NSArray *refreshArr;
@property (nonatomic, strong) NSIndexPath *lastIndexPath;
@end

@implementation BackgroundRefreshViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
	self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
	if (self) {
		// Custom initialization
	}
	return self;
}

- (void)viewDidLoad {
	[super viewDidLoad];
	[self.navigationItem setHidesBackButton:YES animated:YES];
	self.refreshArr = [NSArray arrayWithObjects:@"15 minutes", @"30 minutes", @"1 hour", @"2 hour", @"never", nil];
	if (![USER_DEFAULT objectForKey:RefTime]) {
		[USER_DEFAULT setObject:@"15 minutes"  forKey:RefTime];
		[USER_DEFAULT synchronize];
	}
	self.selectIndexPathArr = [NSMutableArray arrayWithCapacity:0];

	self.tableView = [[UITableView alloc] initWithFrame:[[UIScreen mainScreen] bounds] style:UITableViewStyleGrouped];
	self.tableView.dataSource = self;
	self.tableView.delegate = self;
	[self.view addSubview:self.tableView];

	UIView *titleView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 200, 40)];
	UILabel *titlelabel = [[UILabel alloc]initWithFrame:titleView.frame];
	titlelabel.textAlignment = NSTextAlignmentCenter;
	titlelabel.font = [UIFont fontWithName:@"Helvetica Neue" size:20.0];
	titlelabel.text = @"Background Refresh";
	titlelabel.textColor = [UIColor whiteColor];
	[titleView addSubview:titlelabel];
	self.navigationItem.titleView = titleView;

	self.navigationItem.hidesBackButton = YES;
	UIButton *leftBtn = [UIButton buttonWithType:UIButtonTypeCustom];
	[leftBtn setBackgroundImage:[UIImage imageNamed:@"Icon_BackArrow"] forState:UIControlStateNormal];
	leftBtn.frame = CGRectMake(0, 2, 21, 25);
	[leftBtn addTarget:self action:@selector(visibleCaTobackSetingView) forControlEvents:UIControlEventTouchUpInside];
	self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:leftBtn];
}

- (void)didReceiveMemoryWarning {
	[super didReceiveMemoryWarning];
}

- (void)viewDidDisappear:(BOOL)animated {
	[super viewDidDisappear:animated];
	[USER_DEFAULT removeObjectForKey:RefTime];
	NSString *strTime = [self.refreshArr objectAtIndex:self.lastIndexPath.row];
	[USER_DEFAULT setObject:strTime forKey:RefTime];
	[USER_DEFAULT synchronize];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return self.refreshArr.count;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
	return @"REFRESH EVERY";
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

	NSString *refTime = [self.refreshArr objectAtIndex:indexPath.row];
	NSString *timeStr = [USER_DEFAULT objectForKey:RefTime];
	if (!self.isSelect) {
		if ([refTime isEqualToString:timeStr]) {
			cell.accessoryType = UITableViewCellAccessoryCheckmark;
			self.lastIndexPath = indexPath;
			self.isSelect = YES;
		}
	}
	cell.textLabel.text = refTime;
	return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
	int newRow = [indexPath row];
	int oldRow = (self.lastIndexPath != nil) ? [self.lastIndexPath row] : -1;
	if (newRow != oldRow) {
		UITableViewCell *newCell = [tableView cellForRowAtIndexPath:indexPath];
		newCell.accessoryType = UITableViewCellAccessoryCheckmark;
		UITableViewCell *oldCell = [tableView cellForRowAtIndexPath:self.lastIndexPath];
		oldCell.accessoryType = UITableViewCellAccessoryNone;
		self.lastIndexPath = [indexPath copy];
	}
}

- (void)visibleCaTobackSetingView {
	[self.navigationController popViewControllerAnimated:YES];
}

@end
