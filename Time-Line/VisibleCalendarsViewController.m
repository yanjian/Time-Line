//
//  VisibleCalendarsTableViewController.m
//  Go2
//
//  Created by IF on 14-10-11.
//  Copyright (c) 2014年 zhilifang. All rights reserved.
//

#import "VisibleCalendarsViewController.h"
#import "GoogleCalendarData.h"
#import "LocalCalendarData.h"
#import "CircleDrawView.h"
#import "Calendar.h"
#import "AT_Account.h"
@interface VisibleCalendarsViewController () <UITableViewDataSource, UITableViewDelegate, ASIHTTPRequestDelegate, UIGestureRecognizerDelegate>
@property (nonatomic, retain) UITableView *tableView;
@property (nonatomic, retain) NSMutableArray *selectIndexPathArr;
@property (nonatomic, assign) BOOL isSelect;
@property (nonatomic, retain) NSMutableArray *calendarLs;
@end

@implementation VisibleCalendarsViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
	self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
	if (self) {
		
	}
	return self;
}

- (void)viewDidLoad {
	[super viewDidLoad];
    self.title = @"Visible Calendars" ;
    UIButton *leftBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [leftBtn setFrame:CGRectMake(0, 2, 22, 14)];
    [leftBtn setBackgroundImage:[UIImage imageNamed:@"go2_arrow_left"] forState:UIControlStateNormal] ;
    [leftBtn addTarget:self action:@selector(backToSettingsView) forControlEvents:UIControlEventTouchUpInside] ;
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:leftBtn] ;
    self.navigationController.interactivePopGestureRecognizer.delegate = (id)self;
    
	self.selectIndexPathArr = [NSMutableArray arrayWithCapacity:0];
	self.calendarArray = [NSMutableArray arrayWithCapacity:0];

	self.tableView = [[UITableView alloc] initWithFrame:[[UIScreen mainScreen] bounds] style:UITableViewStyleGrouped];
	self.tableView.dataSource = self;
	self.tableView.delegate = self;
	[self.view addSubview:self.tableView];
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
		calendar.isVisible = @(0);
		for (NSIndexPath *indexPath in self.selectIndexPathArr) {
			Calendar *ca = [[self.calendarArray objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
			if ([calendar.cid isEqualToString:ca.cid]) {
				calendar.isVisible = @(1);
			}
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
    if (calendarListArr.count > 0 ){
        Calendar *caObj = calendarListArr[0];
       

        if ([caObj.type intValue] == AccountTypeLocal) {
            returnStr = [NSString stringWithFormat:@" IF(%@)", caObj.account];
        }
        else if ([caObj.type intValue] == AccountTypeGoogle) {
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
	NSString *cellIdentifier = @"cellVisible";
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
	if (cell == nil) {
		cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
	}

	NSArray *viewarr = [cell.contentView subviews];
	for (UIView *view in viewarr) {
		[view removeFromSuperview];
	}

	NSArray *calendarListArr = [self.calendarArray objectAtIndex:indexPath.section];
	if (!self.isSelect) {
		Calendar *caObj = [calendarListArr objectAtIndex:indexPath.row];
		if ([caObj.isVisible intValue] == 1) {
			cell.accessoryType = UITableViewCellAccessoryCheckmark;
			[self.selectIndexPathArr addObject:indexPath];
			if (indexPath.section == self.calendarArray.count - 1) {
				if (indexPath.row == calendarListArr.count - 1) {
					self.isSelect = YES;
				}
			}
		}
	}
	Calendar *caObj = [calendarListArr objectAtIndex:indexPath.row];

	CircleDrawView *cd = [[CircleDrawView alloc] initWithFrame:CGRectMake(0, 2, 40, 40)];
	cd.hexString = caObj.backgroundColor;
	[cell.contentView addSubview:cd];

	UILabel *contextLab = [[UILabel alloc] initWithFrame:CGRectMake(cd.frame.size.width, 2, 215, 40)];
	[contextLab setBackgroundColor:[UIColor clearColor]];
	contextLab.lineBreakMode = NSLineBreakByTruncatingMiddle;
	[contextLab setText:caObj.summary];
	[cell.contentView addSubview:contextLab];
	return cell;
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

- (void)backToSettingsView {
	[self.navigationController popViewControllerAnimated:YES];
}

@end
