//
//  AlertViewController.m
//  Go2
//
//  Created by connor on 14-4-9.
//  Copyright (c) 2014年 connor. All rights reserved.
//

#import "AlertViewController.h"

@interface AlertViewController () {
	NSArray *timeArray;
	NSMutableArray *seleArray;
}

@end

@implementation AlertViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
	self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
	if (self) {
	}
	return self;
}

- (void)viewDidLoad {
	[super viewDidLoad];
	self.title = @"Alert";
	timeArray = [[NSArray alloc]initWithObjects:@"At time of event", @"5 mionutes before", @"15 mionutes before", @"30 mionutes before", @"1 hour before", @"2 hour beore", @"1 day before", @"2 day before", nil];
	seleArray = [[NSMutableArray alloc]initWithCapacity:0];
	if ([[NSUserDefaults standardUserDefaults] objectForKey:@"alert"]) {
		seleArray = [NSMutableArray arrayWithArray:[[NSUserDefaults standardUserDefaults] objectForKey:@"alert"]];
	}

	UIButton *leftBtn = [UIButton buttonWithType:UIButtonTypeCustom];
	[leftBtn setBackgroundImage:[UIImage imageNamed:@"Icon_BackArrow.png"] forState:UIControlStateNormal];
	[leftBtn setFrame:CGRectMake(0, 2, 15, 20)];
	[leftBtn addTarget:self action:@selector(disviewcontroller) forControlEvents:UIControlEventTouchUpInside];
	UIControl *titleView = [[UIControl alloc]initWithFrame:CGRectMake(0, 0, 140, 40)];
	UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 140, 40)];
	titleLabel.textAlignment = NSTextAlignmentCenter;
	titleLabel.font = [UIFont boldSystemFontOfSize:22];
	titleLabel.textColor = [UIColor whiteColor];
	titleLabel.text = @"Alert";
	[titleView addSubview:titleLabel];
	self.navigationItem.titleView = titleView;
	self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]initWithCustomView:leftBtn];
	UIButton *rightBtn_arrow = [UIButton buttonWithType:UIButtonTypeCustom];
	[rightBtn_arrow setBackgroundImage:[UIImage imageNamed:@"Icon_Tick.png"] forState:UIControlStateNormal];
	[rightBtn_arrow setFrame:CGRectMake(0, 2, 25, 20)];
	[rightBtn_arrow addTarget:self action:@selector(onClickAdd) forControlEvents:UIControlEventTouchUpInside];
	self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithCustomView:rightBtn_arrow];

//    if ([[NSUserDefaults standardUserDefaults] objectForKey:@"alert"]) {
//        seleArray=[NSMutableArray arrayWithArray:[[NSUserDefaults standardUserDefaults] objectForKey:@"alert"]];
//    }
	// Do any additional setup after loading the view from its nib.
}

- (void)disviewcontroller {
	[self.navigationController popViewControllerAnimated:YES];
}

- (void)onClickAdd {
//    [[NSUserDefaults standardUserDefaults] setObject:seleArray forKey:@"alert"];
//
//    NSLog(@"%@",[[NSUserDefaults standardUserDefaults] objectForKey:@"alert"]);



	[self.navigationController popViewControllerAnimated:YES];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	static NSString *cellId = @"alert";
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
	if (cell == nil) {
		cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellId];
	}
	UIImageView *imageview = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 42 / 2, 31 / 2)];
	imageview.image = [UIImage imageNamed:@"Icon_TickBlack.png"];
	cell.accessoryView = nil;
	for (NSString *str in seleArray) {
		if ([str isEqualToString:[timeArray objectAtIndex:indexPath.row]]) {
			cell.accessoryView = imageview;
		}
	}

	cell.textLabel.text = [timeArray objectAtIndex:indexPath.row];
	if ([seleArray count] == 0) {
		cell.accessoryView = nil;
	}
	return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return 8;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	NSLog(@"%@", seleArray);
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
	if ([seleArray count] == 0) {
		[seleArray addObject:[timeArray objectAtIndex:indexPath.row]];
		[tableView reloadData];
		return;
	}
	for (NSString *str in seleArray) {
		if ([str isEqualToString:[timeArray objectAtIndex:indexPath.row]]) {
			[seleArray removeObject:str];
			[tableView reloadData];
			return;
		}
	}
	[seleArray addObject:[timeArray objectAtIndex:indexPath.row]];

	[tableView reloadData];
}

- (void)didReceiveMemoryWarning {
	[super didReceiveMemoryWarning];
	// Dispose of any resources that can be recreated.
}

@end
