//
//  DirectionsViewController.m
//  Time-Line
//
//  Created by IF on 14-10-12.
//  Copyright (c) 2014年 zhilifang. All rights reserved.
//

#import "DirectionsViewController.h"

@interface DirectionsViewController () <UITableViewDataSource, UITableViewDelegate>
@property (nonatomic, retain) UITableView *tableView;
@property (nonatomic, retain) NSMutableArray *selectIndexPathArr;
@property (nonatomic, assign) BOOL isSelect;
@property (nonatomic, retain) NSArray *directionsArr;
@end

@implementation DirectionsViewController

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
	self.directionsArr = [NSArray arrayWithObjects:@"Apple Maps", @"Google Maps", nil];

	self.selectIndexPathArr = [NSMutableArray arrayWithCapacity:0];

	self.tableView = [[UITableView alloc] initWithFrame:[[UIScreen mainScreen] bounds] style:UITableViewStyleGrouped];
	self.tableView.dataSource = self;
	self.tableView.delegate = self;
	[self.view addSubview:self.tableView];

	UIView *titleView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 200, 40)];
	UILabel *titlelabel = [[UILabel alloc]initWithFrame:titleView.frame];
	titlelabel.textAlignment = NSTextAlignmentCenter;
	titlelabel.font = [UIFont fontWithName:@"Helvetica Neue" size:20.0];
	titlelabel.text = @"Directions";
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

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return self.directionsArr.count;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
	return @"OPEN DIRECTIONS WITH";
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
	cell.textLabel.text = self.directionsArr[indexPath.row];
	return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (void)visibleCaTobackSetingView {
	[self.navigationController popViewControllerAnimated:YES];
}

@end
