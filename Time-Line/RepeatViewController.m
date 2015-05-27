//
//  RepeatViewController.m
//  Go2
//
//  Created by IF on 14/11/12.
//  Copyright (c) 2014年 zhilifang. All rights reserved.
//

#import "RepeatViewController.h"
#import "RepeatCalViewController.h"
#import "RepearIntervalViewController.h"
#import "RepearOnDaysViewController.h"
#import "RepeatUntilViewController.h"

@interface RepeatViewController () <UITableViewDataSource, UITableViewDelegate, RepeatCalViewControllerDelegate, RepearIntervalViewControllerDelegate, RepearOnDaysViewControllerDelegate, RepeatUntilViewControllerDelegate> {
	UILabel *repeatLab;
	UILabel *intervalLab;
	UILabel *onDaysLab;
	UILabel *untilLab;

	NSString *intervalValue;

	NSString *onDaysValue;
	NSString *untilValue;
	CLDay *clDay;
	NSMutableArray *tmpArr;
}
@property (nonatomic, strong) UITableView *tableView;
@end

@implementation RepeatViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
	self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
	if (self) {
		// Custom initialization
	}
	return self;
}

- (void)viewDidLoad {
	[super viewDidLoad];
	tmpArr = [NSMutableArray array];
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

	repeatLab = [[UILabel alloc] initWithFrame:CGRectMake(170, 0, 120, 44)];
	repeatLab.textAlignment = NSTextAlignmentRight;

	intervalLab = [[UILabel alloc] initWithFrame:CGRectMake(170, 0, 120, 44)];
	intervalLab.textAlignment = NSTextAlignmentRight;

	onDaysLab = [[UILabel alloc] initWithFrame:CGRectMake(100, 0, 190, 44)];
	onDaysLab.textAlignment = NSTextAlignmentRight;

	untilLab = [[UILabel alloc] initWithFrame:CGRectMake(170, 0, 120, 44)];
	untilLab.textAlignment = NSTextAlignmentRight;
	if (self.recurrObj) {
		intervalValue = [self.recurrObj showIntervalWithRepat];
		self.onDays = [self.recurrObj stringWithIntFromWeek];
		[tmpArr addObject:self.onDays];
		onDaysValue = [self.recurrObj showWeekFromInt];
		untilValue = [self.recurrObj showUtil];
		clDay = [self.recurrObj showUtilClday];
	}
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	[self.tableView reloadData];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	if ([dayly isEqualToString:self.repeatParam] || [monthly isEqualToString:self.repeatParam] || [yearly isEqualToString:self.repeatParam]) {
		return 3;
	}
	else if ([weekly isEqualToString:self.repeatParam]) {
		return 4;
	}
	return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	static NSString *cellID = @"repeatId";
	UITableViewCell *repeartCell = [tableView dequeueReusableCellWithIdentifier:cellID];
	if (!repeartCell) {
		repeartCell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID];
	}
	for (UIView *view in[repeartCell.contentView subviews]) {
		[view removeFromSuperview];
	}
	repeartCell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
	if (indexPath.row == 0) {
		repeartCell.textLabel.text = @"Repeat";
		repeatLab.text = self.repeatParam;
		[repeartCell.contentView addSubview:repeatLab];
	}
	else if (indexPath.row == 1) {
		repeartCell.textLabel.text = @"Interval";
		intervalLab.text = intervalValue;
		[repeartCell.contentView addSubview:intervalLab];
	}
	else if (indexPath.row == 2) {
		if ([weekly isEqualToString:self.repeatParam]) {
			onDaysLab.text = onDaysValue;
			repeartCell.textLabel.text = @"On Days";
			[repeartCell.contentView addSubview:onDaysLab];
		}
		else {
			untilLab.text = untilValue;
			repeartCell.textLabel.text = @"Until";
			[repeartCell.contentView addSubview:untilLab];
		}
	}
	else if (indexPath.row == 3) {
		untilLab.text = untilValue;
		repeartCell.textLabel.text = @"Until";
		[repeartCell.contentView addSubview:untilLab];
	}
	return repeartCell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
	if (indexPath.row == 0) {
		RepeatCalViewController *rcVc = [[RepeatCalViewController alloc] init];
		rcVc.delegate = self;
		[self.navigationController pushViewController:rcVc animated:YES];
	}
	else if (indexPath.row == 1) {
		RepearIntervalViewController *riVc = [[RepearIntervalViewController alloc] init];
		riVc.delegate = self;
		riVc.repeatParam = self.repeatParam;
		[self.navigationController pushViewController:riVc animated:YES];
	}
	else if (indexPath.row == 2) {
		if ([weekly isEqualToString:self.repeatParam]) {
			RepearOnDaysViewController *rodVc = [[RepearOnDaysViewController alloc] init];
			rodVc.onDayStr = self.onDays;
			rodVc.delegate = self;
			[self.navigationController pushViewController:rodVc animated:YES];
		}
		else {
			RepeatUntilViewController *ruVc = [[RepeatUntilViewController alloc] init];
			ruVc.delegate = self;
			[self.navigationController pushViewController:ruVc animated:YES];
		}
	}
	else if (indexPath.row == 3) {
		RepeatUntilViewController *ruVc = [[RepeatUntilViewController alloc] init];
		ruVc.delegate = self;
		[self.navigationController pushViewController:ruVc animated:YES];
	}
}

- (void)repeatCalViewController:(UIViewController *)controle selectData:(NSString *)dateString {
	self.repeatParam = dateString;
	[tmpArr removeAllObjects];
	if ([dayly isEqualToString:dateString]) {
		intervalValue = @"1 day";
	}
	else if ([weekly isEqualToString:dateString]) {
		intervalValue = @"1 week";
		onDaysValue = @"Default";
		self.onDays = [NSString stringWithFormat:@"%i", [CalendarDateUtil getWeekDayWithDate:[NSDate new]] - 1];
		[tmpArr addObject:self.onDays];
	}
	else if ([monthly isEqualToString:dateString]) {
		intervalValue = @"1 month";
	}
	else if ([yearly isEqualToString:dateString]) {
		intervalValue = @"1 year";
	}
	else {
		intervalValue = nil;
	}
	untilValue = @"Forever";
}

- (void)selectValueWithInterval:(NSString *)interval {
	intervalValue = interval;
}

- (void)selectRepeatWtihDay:(NSString *)dayString {
	NSArray *tArr = [dayString componentsSeparatedByString:@","];

	NSComparator cmptr = ^(id obj1, id obj2) {
		if ([obj1 integerValue] > [obj2 integerValue]) {
			return (NSComparisonResult)NSOrderedDescending;
		}

		if ([obj1 integerValue] < [obj2 integerValue]) {
			return (NSComparisonResult)NSOrderedAscending;
		}
		return (NSComparisonResult)NSOrderedSame;
	};
	[tmpArr removeAllObjects];
	tmpArr = [tArr sortedArrayUsingComparator:cmptr].mutableCopy;

	self.onDays = dayString;
	if (tmpArr && tmpArr.count > 0) {
		if (tmpArr.count == 1) {
			NSInteger currWeekInt = [CalendarDateUtil getWeekDayWithDate:[NSDate new]] - 1;
			if (currWeekInt == [tmpArr[0] integerValue]) {
				onDaysValue = @"Default";
			}
			else {
				onDaysValue = [self repeatDateWithInteger:[tmpArr[0] integerValue]];
			}
		}
		else if (tmpArr.count == 2) {
			NSMutableArray *mutArr = [NSMutableArray array];
			for (int i = 0; i < tmpArr.count; i++) {
				[mutArr addObject:[self repeatDateWithInteger:[tmpArr[i] integerValue]]];
			}
			onDaysValue = [mutArr componentsJoinedByString:@","];
		}
		else {
			NSMutableArray *mutArr = [NSMutableArray array];
			for (int i = 0; i < tmpArr.count; i++) {
				[mutArr addObject:[self abbRepeatDateWithInteger:[tmpArr[i] integerValue]]];
			}
			onDaysValue = [mutArr componentsJoinedByString:@","];
		}
	}
	//onDaysValue=dayString;
}

- (void)selectedDidDate:(CLDay *)selectDate {
	if (selectDate) {
		clDay = selectDate;
		untilValue = [selectDate abbreviationWeekDayMotch];
	}
	else {
		untilValue = @"Forever";
	}
}

- (void)didReceiveMemoryWarning {
	[super didReceiveMemoryWarning];
}

- (void)disviewcontroller {
	NSString *tmp = [self groupStringJoinParam];
	self.recurrObj = [[RecurrenceModel alloc] initRecrrenceModel:tmp];
	[self.delegate selectValueWithDateString:repeatLab.text repeatRecurrence:self.recurrObj];
	[self.navigationController popViewControllerAnimated:YES];
}

- (NSString *)groupStringJoinParam {
	if (![none isEqualToString:self.repeatParam]) {
		NSMutableArray *mutArr = [NSMutableArray arrayWithCapacity:0];

		NSString *joinStr = @"RRULE:";
		if (repeatLab.text) {
			NSString *repeatStr = [joinStr stringByAppendingString:[NSString stringWithFormat:@"FREQ=%@", [self.repeatParam uppercaseString]]];
			[mutArr addObject:repeatStr];
		}
		if (intervalLab.text) {
			NSArray *intervalArr = [intervalValue componentsSeparatedByString:@" "];
			NSString *intervalStr = [NSString stringWithFormat:@"INTERVAL=%@", intervalArr[0]];
			[mutArr addObject:intervalStr];
		}

		if ([weekly isEqualToString:self.repeatParam]) {
			NSMutableArray *mutArrstr = [NSMutableArray arrayWithCapacity:0];
			if (onDaysLab.text) {
				for (int i = 0; i < tmpArr.count; i++) {
					[mutArrstr addObject:[self abbUPcaseRepeatDateWithInteger:[tmpArr[i] integerValue]]];
				}
				NSString *onDaysStr = [NSString stringWithFormat:@"BYDAY=%@", [mutArrstr componentsJoinedByString:@","]];
				[mutArr addObject:onDaysStr];
			}
		}
		if (untilLab.text) {
			if (![@"Forever" isEqualToString:untilValue]) {
				NSString *untilStr = [NSString stringWithFormat:@"UNTIL=%@", [NSString stringWithFormat:@"%lu%@%@", (unsigned long)clDay.year, [self stringJoinZuro:clDay.month], [self stringJoinZuro:clDay.day]]];
				[mutArr addObject:untilStr];
			}
		}
		NSString *tmpStr = [mutArr componentsJoinedByString:@";"];
		NSLog(@"<++++++++++++++++++++>   %@", tmpStr);
		return tmpStr;
	}
	return nil;
}

- (NSString *)stringJoinZuro:(NSUInteger *)param {
	NSString *tmp = @"";
	if (param < 10) {
		tmp = [NSString stringWithFormat:@"0%lu", param];
	}
	else {
		tmp = [NSString stringWithFormat:@"%lu", param];
	}
	return tmp;
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

- (NSString *)abbRepeatDateWithInteger:(NSUInteger)dayCount {
	NSString *weakStr = @"";
	switch (dayCount) {
		case 0:
			weakStr = @"S";
			break;

		case 1:
			weakStr = @"M";
			break;

		case 2:
			weakStr = @"T";
			break;

		case 3:
			weakStr = @"W";
			break;

		case 4:
			weakStr = @"T";
			break;

		case 5:
			weakStr = @"F";
			break;

		case 6:
			weakStr = @"S";
			break;

		default:
			break;
	}
	return weakStr;
}

- (NSString *)abbUPcaseRepeatDateWithInteger:(NSUInteger)dayCount {
	NSString *weakStr = @"";
	switch (dayCount) {
		case 0:
			weakStr = @"SU";
			break;

		case 1:
			weakStr = @"MO";
			break;

		case 2:
			weakStr = @"TU";
			break;

		case 3:
			weakStr = @"WE";
			break;

		case 4:
			weakStr = @"TH";
			break;

		case 5:
			weakStr = @"FR";
			break;

		case 6:
			weakStr = @"SA";
			break;

		default:
			break;
	}
	return weakStr;
}

/*
   #pragma mark - Navigation

   // In a storyboard-based application, you will often want to do a little preparation before navigation
   - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
   {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
   }
 */

@end
