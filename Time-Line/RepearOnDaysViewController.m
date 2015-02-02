//
//  RepearOnDaysViewController.m
//  Time-Line
//
//  Created by IF on 14/11/12.
//  Copyright (c) 2014年 zhilifang. All rights reserved.
//

#import "RepearOnDaysViewController.h"
#import "CalendarDateUtil.h"
@interface RepearOnDaysViewController () <UITableViewDataSource, UITableViewDelegate> {
	NSArray *dateDataArr;
	NSMutableArray *selectData;
}
@property (nonatomic, assign) BOOL isSelect;
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, retain) NSMutableArray *selectIndexPathArr;
@end

@implementation RepearOnDaysViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
	self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
	if (self) {
	}
	return self;
}

- (void)viewDidLoad {
	[super viewDidLoad];

	self.selectIndexPathArr = [NSMutableArray arrayWithCapacity:0];
	dateDataArr = [NSArray arrayWithObjects:@0, @1, @2, @3, @4, @5, @6, nil];
	selectData = [NSMutableArray array];

	UIView *titleView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 200, 40)];
	UILabel *titlelabel = [[UILabel alloc]initWithFrame:titleView.frame];
	titlelabel.textAlignment = NSTextAlignmentCenter;
	titlelabel.font = [UIFont fontWithName:@"Helvetica Neue" size:20.0];
	titlelabel.textColor = [UIColor whiteColor];
	[titleView addSubview:titlelabel];
	self.navigationItem.titleView = titleView;
	titlelabel.text = @"Repeat";

	UIButton *leftBtn = [UIButton buttonWithType:UIButtonTypeCustom];
	[leftBtn setBackgroundImage:[UIImage imageNamed:@"Icon_BackArrow.png"] forState:UIControlStateNormal];

	[leftBtn setFrame:CGRectMake(0, 2, 21, 25)];
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
	static NSString *cellID = @"repeatOnDaysID";
	UITableViewCell *repeartCell = [tableView dequeueReusableCellWithIdentifier:cellID];
	if (!repeartCell) {
		repeartCell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID];
	}
	if (!self.isSelect) {
		NSInteger weekInt = [dateDataArr[indexPath.row] integerValue];
		if (self.onDayStr) {
			NSArray *tmpArr = [self.onDayStr componentsSeparatedByString:@","];
			for (int i = 0; i < tmpArr.count; i++) {
				if ([tmpArr[i] integerValue] == weekInt) {
					repeartCell.accessoryType = UITableViewCellAccessoryCheckmark;
					[self.selectIndexPathArr addObject:indexPath];
					break;
				}
			}
			if (tmpArr.count == self.selectIndexPathArr.count) {
				self.isSelect = YES;
			}
		}
		else {
			NSInteger currWeekInt = [CalendarDateUtil getWeekDayWithDate:[NSDate new]] - 1;
			if (currWeekInt == weekInt) {
				repeartCell.accessoryType = UITableViewCellAccessoryCheckmark;
				[self.selectIndexPathArr addObject:indexPath];
				self.isSelect = YES;
			}
		}
	}
	repeartCell.textLabel.text = [self repeatDateWithInteger:[dateDataArr[indexPath.row] integerValue]];
	return repeartCell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
	UITableViewCell *cell = (UITableViewCell *)[tableView cellForRowAtIndexPath:indexPath];
	if (cell.accessoryType == UITableViewCellAccessoryCheckmark) {
		cell.accessoryType = UITableViewCellAccessoryNone;
		[self.selectIndexPathArr removeObject:indexPath];
	}
	else {
		cell.accessoryType = UITableViewCellAccessoryCheckmark;
		[self.selectIndexPathArr addObject:indexPath];
	}
}

- (void)didReceiveMemoryWarning {
	[super didReceiveMemoryWarning];
	// Dispose of any resources that can be recreated.
}

- (void)disviewcontroller {
	NSMutableArray *tmpArr = [NSMutableArray array];
	if (self.selectIndexPathArr.count > 0) {
		for (NSIndexPath *indexPath in self.selectIndexPathArr) {
			[tmpArr addObject:dateDataArr[indexPath.row]];
		}
	}
	NSLog(@"===========>  %@", [tmpArr componentsJoinedByString:@","]);
	[self.delegate selectRepeatWtihDay:[tmpArr componentsJoinedByString:@","]];
	[self.navigationController popViewControllerAnimated:YES];
}

- (NSString *)repeatDateWithInteger:(NSUInteger)dayCount {
	NSString *weakStr = @"";
	switch (dayCount) {
		case 0:
			weakStr = @"Sunday";
			break;

		case 1:
			weakStr = @"Monday";
			break;

		case 2:
			weakStr = @"Tuesday";
			break;

		case 3:
			weakStr = @"Wednesday";
			break;

		case 4:
			weakStr = @"Thursday";
			break;

		case 5:
			weakStr = @"Friday";
			break;

		case 6:
			weakStr = @"Saturday";
			break;

		default:
			break;
	}
	return weakStr;
}

@end
