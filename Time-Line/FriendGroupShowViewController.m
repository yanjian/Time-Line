//
//  FriendGroupShowViewController.m
//  Go2
//
//  Created by IF on 15/1/26.
//  Copyright (c) 2015年 zhilifang. All rights reserved.
//

#import "FriendGroupShowViewController.h"


@interface FriendGroupShowViewController () <UITableViewDelegate, UITableViewDataSource, ASIHTTPRequestDelegate> {
	NSMutableArray *_groupArr;
}
@property (strong, nonatomic)  UITableView *tableView;
@end

@implementation FriendGroupShowViewController

- (void)viewDidLoad {
	[super viewDidLoad];
	CGRect frame = CGRectMake(10, 25, kScreen_Width - 20, kScreen_Height - 50);
	self.view.frame = frame;

	UIView *rview = [[UIView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, 44)];
	rview.backgroundColor = blueColor;

	[self loadData];

//    //   导航： 右边的按钮
//    UIButton * rightBtn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
//    rightBtn.frame = CGRectMake(frame.size.width-40,20, 30, 25);
//    [rightBtn setBackgroundImage:[UIImage imageNamed:@"Icon_Tick.png"] forState:UIControlStateNormal];
//    [rightBtn addTarget:self action:@selector(touchUpInside) forControlEvents:UIControlEventTouchUpInside];
//    [rview addSubview:rightBtn];

	UILabel *titlelabel = [[UILabel alloc]initWithFrame:CGRectMake(60, 12, 180, 21)];
	titlelabel.textAlignment = NSTextAlignmentCenter;
	titlelabel.text = [NSString stringWithFormat:@"select friend group"];
	titlelabel.font = [UIFont fontWithName:@"Helvetica Neue" size:17.0];
	titlelabel.textColor = [UIColor whiteColor];
	[rview addSubview:titlelabel];

	self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 44, frame.size.width, frame.size.height - 44) style:UITableViewStyleGrouped];
	self.tableView.dataSource = self;
	self.tableView.delegate = self;
	[self.view addSubview:self.tableView];
	[self.view addSubview:rview];

	// Do any additional setup after loading the view from its nib.
}

#pragma mark 加载数据
- (void)loadData {
	ASIHTTPRequest *_friendGroups = [t_Network httpGet:nil Url:anyTime_GetFTlist Delegate:self Tag:anyTime_GetFTlist_tag];
	[_friendGroups startAsynchronous];
}

- (void)didReceiveMemoryWarning {
	[super didReceiveMemoryWarning];
	// Dispose of any resources that can be recreated.
}

#pragma mark - asihttprequest 的代理
- (void)requestFinished:(ASIHTTPRequest *)request {
	NSString *responeStr = [request responseString];
	NSLog(@"%@", [request responseString]);
	id groupObj = [responeStr objectFromJSONString];
	switch (request.tag) {
		case anyTime_GetFTlist_tag: {
			NSMutableArray *fgArray = [NSMutableArray array];
			if ([groupObj isKindOfClass:[NSDictionary class]]) {
				NSString *statusCode = [groupObj objectForKey:@"statusCode"];
				if ([statusCode isEqualToString:@"1"]) {
					NSArray *groupArr = [groupObj objectForKey:@"data"];
					for (NSDictionary *dic in groupArr) {
						FriendGroup *friendGroup = [FriendGroup friendGroupWithDict:dic];
						[fgArray addObject:friendGroup];
					}
					_groupArr = fgArray;
					[_tableView reloadData];
				}
			}
		}
		break;

		default:
			break;
	}
}

- (void)requestFailed:(ASIHTTPRequest *)request {
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return _groupArr.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
	return 0.5f;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
	return 0.5f;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	return 44.f;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	static NSString *cellIdentifier = @"FriendGroupcell";
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
	if (!cell) {
		cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
	}
	FriendGroup *friendGroup = _groupArr[indexPath.row];
	cell.textLabel.text = friendGroup.name;
	return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
	if (self.fBlock) {
		FriendGroup *friendGroup = _groupArr[indexPath.row];
		self.fBlock(self, friendGroup);
	}
}

@end
