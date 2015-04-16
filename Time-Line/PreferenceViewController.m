//
//  PreferenceViewController.m
//  Time-Line
//
//  Created by IF on 14-10-11.
//  Copyright (c) 2014年 zhilifang. All rights reserved.
//

#import "PreferenceViewController.h"
#import "BackgroundRefreshViewController.h"
#import "DefaultCalendarViewController.h"
#import "AlertsViewController.h"
#import "DirectionsViewController.h"
#import "WeekStartViewController.h"

@interface PreferenceViewController () <UITableViewDelegate, UITableViewDataSource>
@property (nonatomic, retain) NSMutableArray *itemDataArr;
@property (nonatomic, retain) UITableView *tableView;
@end

@implementation PreferenceViewController


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
	self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
	if (self) {
		// Custom initialization
	}
	return self;
}

- (void)viewDidLoad {
	[super viewDidLoad];
    
    self.title = @"Preference" ;
    UIButton *leftBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [leftBtn setFrame:CGRectMake(0, 2, 22, 14)];
    [leftBtn setBackgroundImage:[UIImage imageNamed:@"Arrow_Left_Blue.png"] forState:UIControlStateNormal] ;
    [leftBtn addTarget:self action:@selector(preferenceTobackSetingView) forControlEvents:UIControlEventTouchUpInside] ;
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:leftBtn] ;
    self.navigationController.interactivePopGestureRecognizer.delegate = (id)self;
    

	self.itemDataArr = [NSMutableArray arrayWithObjects:@"Background Refresh", @"Default Calendar", @"Alerts", /*@"Directions",@"Week Start", */ nil];

	self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, kScreen_Width, kScreen_Height) style:UITableViewStyleGrouped];
	self.tableView.dataSource = self;
	self.tableView.delegate = self;
	[self.view addSubview:self.tableView];

//	UIView *titleView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 200, 40)];
//	UILabel *titlelabel = [[UILabel alloc]initWithFrame:titleView.frame];
//	titlelabel.textAlignment = NSTextAlignmentCenter;
//	titlelabel.font = [UIFont fontWithName:@"Helvetica Neue" size:20.0];
//	titlelabel.text = @"Preference";
//	titlelabel.textColor = [UIColor whiteColor];
//	[titleView addSubview:titlelabel];
//	self.navigationItem.titleView = titleView;
}

- (void)didReceiveMemoryWarning {
	[super didReceiveMemoryWarning];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return self.itemDataArr.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	NSString *cellIdentifier = @"cellPrefence";
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
	if (cell == nil) {
		cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
	}
	cell.tag = indexPath.row;
	cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
	cell.textLabel.text = [self.itemDataArr objectAtIndex:indexPath.row];
	return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	[tableView deselectRowAtIndexPath:indexPath animated:YES];

	if (indexPath.row == 0) {
		BackgroundRefreshViewController *brVC = [[BackgroundRefreshViewController alloc] init];
		[self.navigationController pushViewController:brVC animated:YES];
	}
	else if (indexPath.row == 1) {
		DefaultCalendarViewController *defaultCalendar = [[DefaultCalendarViewController alloc] init];
		[self.navigationController pushViewController:defaultCalendar animated:YES];
	}
	else if (indexPath.row == 2) {
		AlertsViewController *alertVC = [[AlertsViewController alloc] init];
		[self.navigationController pushViewController:alertVC animated:YES];
	}
	else if (indexPath.row == 3) {
		DirectionsViewController *directionsVC = [[DirectionsViewController alloc] init];
		[self.navigationController pushViewController:directionsVC animated:YES];
	}
	else if (indexPath.row == 4) {
		WeekStartViewController *weekStart = [[WeekStartViewController alloc] init];
		[self.navigationController pushViewController:weekStart animated:YES];
	}
}

- (void)preferenceTobackSetingView {
	[self.navigationController popViewControllerAnimated:YES];
}

@end
