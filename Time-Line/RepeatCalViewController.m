//
//  RepeatCalViewController.m
//  Go2
//
//  Created by IF on 14/11/12.
//  Copyright (c) 2014年 zhilifang. All rights reserved.
//

#import "RepeatCalViewController.h"

@interface RepeatCalViewController () <UITableViewDataSource, UITableViewDelegate> {
	NSArray *dateDataArr;
}
@property (nonatomic, strong) UITableView *tableView;
@end

@implementation RepeatCalViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
	self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
	if (self) {
		// Custom initialization
	}
	return self;
}

- (void)viewDidLoad {
	[super viewDidLoad];
	dateDataArr = [NSArray arrayWithObjects:none, dayly, weekly, monthly, yearly, nil];

	UIView *titleView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 200, 40)];
	UILabel *titlelabel = [[UILabel alloc]initWithFrame:titleView.frame];
	titlelabel.textAlignment = NSTextAlignmentCenter;
	titlelabel.font = [UIFont fontWithName:@"Helvetica Neue" size:20.0];
	titlelabel.textColor = [UIColor whiteColor];
	[titleView addSubview:titlelabel];
	self.navigationItem.titleView = titleView;
	titlelabel.text = @"Repeat";

    UIButton *leftBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [leftBtn setFrame:CGRectMake(0, 0, 22, 14)];
    [leftBtn setTag:1];
    [leftBtn setBackgroundImage:[UIImage imageNamed:@"go2_arrow_left"] forState:UIControlStateNormal] ;
	[leftBtn addTarget:self action:@selector(disviewcontroller) forControlEvents:UIControlEventTouchUpInside];
	self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]initWithCustomView:leftBtn];

	self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, kScreen_Width, kScreen_Height - naviHigth) style:UITableViewStyleGrouped];
	self.tableView.delegate = self;
	self.tableView.dataSource = self;
	[self.view addSubview:self.tableView];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return dateDataArr.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	static NSString *cellID = @"repeatSelectID";
	UITableViewCell *repeartCell = [tableView dequeueReusableCellWithIdentifier:cellID];
	if (!repeartCell) {
		repeartCell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID];
	}
	repeartCell.textLabel.text = dateDataArr[indexPath.row];
	return repeartCell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
	[self.delegate repeatCalViewController:self selectData:dateDataArr[indexPath.row]];
	[self disviewcontroller];
}

- (void)didReceiveMemoryWarning {
	[super didReceiveMemoryWarning];
}

- (void)disviewcontroller {
	[self.navigationController popViewControllerAnimated:YES];
}

@end
