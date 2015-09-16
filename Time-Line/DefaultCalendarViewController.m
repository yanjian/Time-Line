//
//  DefaultCalendarViewController.m
//  Go2
//
//  Created by IF on 14-10-12.
//  Copyright (c) 2014年 zhilifang. All rights reserved.
//

#import "DefaultCalendarViewController.h"
#import "AT_Account.h"
#import "Calendar.h"
#import "CircleDrawView.h"
@interface DefaultCalendarViewController () <UITableViewDataSource, UITableViewDelegate>
@property (nonatomic, retain) UITableView *tableView;
@property (nonatomic, assign) BOOL isSelect;
@property (nonatomic, retain) NSMutableArray *calendarLs;
@property (nonatomic, retain) NSMutableArray *calendarArray;
@property (nonatomic, strong)  NSIndexPath *lastIndexPath;
@end

@implementation DefaultCalendarViewController


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
	self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
	if (self) {
		// Custom initialization
	}
	return self;
}

- (void)viewDidLoad {
	[super viewDidLoad];
    self.title = @"Default Calendars" ;
    UIButton *leftBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [leftBtn setFrame:CGRectMake(0, 2, 22, 14)];
    [leftBtn setBackgroundImage:[UIImage imageNamed:@"go2_arrow_left"] forState:UIControlStateNormal] ;
    [leftBtn addTarget:self action:@selector(visibleCaTobackSetingView) forControlEvents:UIControlEventTouchUpInside] ;
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:leftBtn] ;
    self.navigationController.interactivePopGestureRecognizer.delegate = (id)self;

	self.calendarArray = [NSMutableArray arrayWithCapacity:0];

	self.tableView = [[UITableView alloc] initWithFrame:[[UIScreen mainScreen] bounds] style:UITableViewStyleGrouped];
	self.tableView.dataSource = self;
	self.tableView.delegate = self;
	[self.view addSubview:self.tableView];

//	UIView *titleView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 200, 40)];
//	UILabel *titlelabel = [[UILabel alloc]initWithFrame:titleView.frame];
//	titlelabel.textAlignment = NSTextAlignmentCenter;
//	titlelabel.font = [UIFont fontWithName:@"Helvetica Neue" size:20.0];
//	titlelabel.text = @"Default Calendars";
//	titlelabel.textColor = [UIColor whiteColor];
//	[titleView addSubview:titlelabel];
//	self.navigationItem.titleView = titleView;
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	[self.calendarArray removeAllObjects];

    
    self.calendarLs = [[Calendar MR_findAll] mutableCopy];
    NSMutableArray * localArr = [NSMutableArray array];
    NSMutableArray * googleArr = [NSMutableArray array];
    [self.calendarLs enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        if ([obj isKindOfClass:[Calendar class]]) {
            Calendar * ca = (Calendar *) obj ;
            if ([ca.type intValue] == AccountTypeLocal ) {
                [localArr addObject:ca] ;
            }else if ([ca.type intValue] == AccountTypeGoogle ){
                [googleArr addObject:ca];
            }
        }
    }];
    [self.calendarArray addObject:localArr];
    [self.calendarArray addObject:googleArr];
}

- (void)didReceiveMemoryWarning {
	[super didReceiveMemoryWarning];
}

- (void)viewDidDisappear:(BOOL)animated {
	[super viewDidDisappear:animated];
	for (Calendar *calendar in self.calendarLs) {
		calendar.isDefault = @(0);
		Calendar *ca = [[self.calendarArray objectAtIndex:self.lastIndexPath.section] objectAtIndex:self.lastIndexPath.row];
		if ([calendar.cid isEqualToString:ca.cid]) {
			calendar.isDefault = @(1);
		}
		[[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreAndWait];
	}
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return self.calendarArray.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	NSArray *arr = self.calendarArray[section];
	return arr.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
	return 40.f;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
	NSArray *calendarListArr = self.calendarArray[section];
    NSString *returnStr = @"";
    if (calendarListArr.count > 0 ) {
        Calendar *caObj = calendarListArr[0];
        if ([caObj.type intValue] == AccountTypeLocal) {
            returnStr = [NSString stringWithFormat:@" IF(%@)", caObj.account];
        } else if ([caObj.type intValue] == AccountTypeGoogle) {
            returnStr = [NSString stringWithFormat:@" GOOGLE(%@)", caObj.account];
        }
    }
	UILabel *label = [[UILabel alloc] init];
	label.frame = CGRectMake(2, 20, 300, 22);
	label.backgroundColor = [UIColor clearColor];
	label.textColor = [UIColor grayColor];
	label.text = returnStr;

	UIView *sectionView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.bounds.size.width, 22)];
	[sectionView setBackgroundColor:[UIColor clearColor]];
	[sectionView addSubview:label];
	return sectionView;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	NSString *cellIdentifier = @"cellDefaultCa";
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
	if (cell == nil) {
		cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
	}
	NSArray *viewarr = [cell.contentView subviews];
	for (UIView *view in viewarr) {
		[view removeFromSuperview];
	}

	NSArray *calendarListArr = [self.calendarArray objectAtIndex:indexPath.section];
	Calendar *caObj = [calendarListArr objectAtIndex:indexPath.row];
	if (!self.isSelect) {
		if ([caObj.isDefault intValue] == 1) {
			cell.accessoryType = UITableViewCellAccessoryCheckmark;
			self.lastIndexPath = indexPath;
			self.isSelect = YES;
		}
	}


	CircleDrawView *cd = [[CircleDrawView alloc] initWithFrame:CGRectMake(0, 2, 40, 40)];
	cd.hexString = caObj.backgroundColor;
	[cell.contentView addSubview:cd];

	UILabel *contextLab = [[UILabel alloc] initWithFrame:CGRectMake(cd.frame.size.width, 2, 215, 40)];
	contextLab.lineBreakMode = NSLineBreakByTruncatingMiddle;
	[contextLab setBackgroundColor:[UIColor clearColor]];
	[contextLab setText:caObj.summary];
	[cell.contentView addSubview:contextLab];
	return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	[tableView deselectRowAtIndexPath:indexPath animated:YES];



	int newRow = [indexPath row];
	int oldRow = (self.lastIndexPath != nil) ? [self.lastIndexPath row] : -1;

	int newSection = [indexPath section];
	int oldSection = (self.lastIndexPath != nil) ? [self.lastIndexPath section] : -1;

	newRow = [[NSString stringWithFormat:@"%d%d", newSection, newRow] intValue];
	oldRow = [[NSString stringWithFormat:@"%d%d", oldSection, oldRow] intValue];
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
