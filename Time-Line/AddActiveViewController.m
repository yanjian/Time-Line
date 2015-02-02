//
//  AddActiveViewController.m
//  Time-Line
//
//  Created by IF on 14/12/15.
//  Copyright (c) 2014年 zhilifang. All rights reserved.
//

NS_ENUM (NSInteger, voteAndFixDateType) {
	FIXDATETYPE = 1,//固定时间
	VOTEDATETYPE = 2 //可投票时间
};


#import "AddActiveViewController.h"
#import "PublicMethodsViewController.h"
#import "ViewController.h"
#import "voteDateTableViewCell.h"
#import "UIViewController+MJPopupViewController.h"
#import "UIImageView+WebCache.h"
#import "FriendInformationView.h"
#import "SetFriendViewController.h"
#import "Friend.h"
#import "NewVoteActionViewController.h"
#import "LocationViewController.h"
#import "RMDateSelectionViewController.h"
#import "ActiveEventMode.h"
#import "JsonFromObject.h"
#import "camera.h"
#import "utilities.h"
#import "PECropViewController.h"
#import "UIImageView+WebCache.h"
#import "MemberListViewController.h"


#define SPACING  0
#define voteTableViewCellHight  55
#define footerCellHeight  135
#define voteAndFixHeight 32

#define voteActiveTableCellHight  55


@interface AddActiveViewController () <ASIHTTPRequestDelegate, UITableViewDataSource, UITableViewDelegate, settimeDay, SetFriendViewControllerDelegate, NewVoteActionViewControllerDelegate, getlocationDelegate, RMDateSelectionViewControllerDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIActionSheetDelegate, PECropViewControllerDelegate>
{
	UITableView *_tableView;
	UIImageView *_activeImgView; //活动图
	UILabel *_activeLab;     //活动标题 @“Event Title”；
	UITextField *_activeEventTitle; //活动标题内容
	//投票时间
	UIButton *_intervalbtn;
	UIViewController *_voteDateView;      //投票时间
	UIViewController *_fixDateView;      //固定时间没有投票
	NSArray *_voteAndFixArr;
	NSUInteger _selectedBtnIndex;
	NSArray *_voteAndFixViewArr;

	UILabel *fixStartTimeLab;
	UILabel *fixEndTimeLab;
	UITableView *voteTableView;
	UIScrollView *_inviteeScollView;

	int voteDateOfSections;
	NSMutableArray *inviteeFriendArr;
	UITextField *deadlineTextField;

	NSMutableArray *voteDateArr; //存放投票的时间

	int voteAndFixTimeType; //1.表示固定时间， 2表示投票时间
	NSString *deadlineTime;
	NSMutableArray *inviteeArr;  //要求人员id
	NSMutableArray *newVoteArr; //活动内容选择数据
	UIActionSheet *action;
	NSMutableArray *fixDateArr;
	NSInteger allowAddTime;

	//投票内容
	UIView *voteActiveView;
	UITableView *_newVoteTable;
	int voteActiveSections;

	//地理位置
	UITextField *localfiled;
	UILabel *_locallable;
	UIButton *_localtionBtn;//地图点击事件
	UIImageView *addressIcon;

	UITextField *notefiled;	//备注
	UILabel *notelabel;

	NSMutableArray *deleteVoteArr;
	NSMutableArray *addVoteArr;
	NSMutableArray *updateVoteArr;

	NSMutableArray *deleteVoteTimeArr;
	NSMutableArray *addvoteTimeArr;
}

@property (strong, nonatomic) IBOutlet UITableViewCell *inviteeCell;

@property (weak, nonatomic) IBOutlet UILabel *inviteeLab;
@property (weak, nonatomic) IBOutlet UIView *outsideView;
@property (weak, nonatomic) IBOutlet UIScrollView *innsertScorllView;

//添加按钮
@property (weak, nonatomic) IBOutlet UIButton *addFriendBtn;

@property (nonatomic) UIPopoverController *popover;
@property (weak, nonatomic) IBOutlet UIButton *moreBtn;

//生成一个临时的唯一id
- (NSString *)generateUniqueOptonId;
//向voteDateArr中添加一个时间
- (void)addVoteDateWithEventStartTime:(NSString *)start endTime:(NSString *)end;
@end

@implementation AddActiveViewController
@synthesize  isEdit, activeEventMode;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
	self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
	if (self) {
	}
	return self;
}

- (void)viewDidLoad {
	[super viewDidLoad];

	//  self.navigationController.navigationBarHidden=NO;
	// self.navigationController.navigationBar.barTintColor =blueColor;

	voteDateArr = [NSMutableArray arrayWithCapacity:0];
	fixDateArr = [NSMutableArray arrayWithCapacity:0];

	newVoteArr = [NSMutableArray arrayWithCapacity:0];

	if (isEdit) {//编辑数据时添加的人员初始化
		deleteVoteArr = [NSMutableArray arrayWithCapacity:0];
		addVoteArr  = [NSMutableArray arrayWithCapacity:0];
		updateVoteArr  = [NSMutableArray arrayWithCapacity:0];

		deleteVoteTimeArr =  [NSMutableArray arrayWithCapacity:0];
		addvoteTimeArr =  [NSMutableArray arrayWithCapacity:0];

		inviteeFriendArr = [NSMutableArray arrayWithCapacity:0];//活动参加的人员
		deadlineTime = activeEventMode.voteEndTime;

		for (NSDictionary *dic in activeEventMode.member) {
			Friend *friend = [[Friend alloc] init];
			friend.fid = [dic objectForKey:@"uid"];
			friend.imgBig =  [dic objectForKey:@"imgBig"];
			friend.imgSmall = [dic objectForKey:@"imgSmall"];
			friend.nickname = [dic objectForKey:@"nickname"];
			friend.username = [dic objectForKey:@"username"];
			[inviteeFriendArr addObject:friend];
		}
		if (activeEventMode.evList) {//要投票的选项内容
			NSMutableArray *arrTmp = [NSMutableArray arrayWithCapacity:0];
			for (NSDictionary *dic  in activeEventMode.evList) {//转换为可变的字典好再后面操作
				[arrTmp addObject:[NSMutableDictionary dictionaryWithDictionary:dic]];
			}
			newVoteArr = arrTmp;
		}
		if (activeEventMode.member)
			inviteeArr = [NSMutableArray arrayWithArray:activeEventMode.member];
	}
	else {
		inviteeFriendArr = [NSMutableArray arrayWithObjects:[UserInfo currUserInfo], nil];
		inviteeArr = [NSMutableArray arrayWithObjects:@{ @"uid":[UserInfo currUserInfo].Id }, nil];
	}

	[self createNavWithView];
	[self createCellOfTableWithActiveImage];
	[self createCellWithEventTitle];
	[self createCellOfTableWithSelectCard];
	[self createVoteView];
	[self createLoctionView];
	[self createCellOfNoteView];



	_tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, kScreen_Width, kScreen_Height - naviHigth) style:UITableViewStylePlain];
	_tableView.delegate = self;
	_tableView.dataSource = self;
	[self.view addSubview:_tableView];
}

#pragma mark -初始化导航视图
- (void)createNavWithView {
	self.view.frame = CGRectMake(0, 0, kScreen_Width, kScreen_Height);
	UIButton *leftBtn = [UIButton buttonWithType:UIButtonTypeCustom];
	[leftBtn setBackgroundImage:[UIImage imageNamed:@"Icon_Cross.png"] forState:UIControlStateNormal];
	[leftBtn setFrame:CGRectMake(0, 2, 25, 25)];
	[leftBtn addTarget:self action:@selector(onClickCancel) forControlEvents:UIControlEventTouchUpInside];
	self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]initWithCustomView:leftBtn];


	UIButton *rightBtn_arrow = [UIButton buttonWithType:UIButtonTypeCustom];
	[rightBtn_arrow setBackgroundImage:[UIImage imageNamed:@"Icon_Tick.png"] forState:UIControlStateNormal];
	[rightBtn_arrow setFrame:CGRectMake(0, 2, 30, 25)];
	[rightBtn_arrow addTarget:self action:@selector(onClickAddActiveEvent) forControlEvents:UIControlEventTouchUpInside];
	self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithCustomView:rightBtn_arrow];


	UIView *rightView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 200, 40)];
	UILabel *titlelabel = [[UILabel alloc]initWithFrame:rightView.frame];
	titlelabel.textAlignment = NSTextAlignmentCenter;
	titlelabel.font = [UIFont fontWithName:@"Helvetica Neue" size:20.0];
	titlelabel.textColor = [UIColor whiteColor];
	[rightView addSubview:titlelabel];
	self.navigationItem.titleView = rightView;
	titlelabel.text = @"New Event";
	if (isEdit) {//编辑
		titlelabel.text = @"Edit Event";
	}
}

#pragma mark -创建EventTitle事件标题
- (void)createCellWithEventTitle {
	_activeLab = [[UILabel alloc] initWithFrame:CGRectMake(SPACING, 5, self.view.frame.size.width - 2 * SPACING, 20)];
	_activeLab.text = @"Event Title";
	_activeLab.textAlignment = NSTextAlignmentCenter;

	_activeEventTitle = [[UITextField alloc]initWithFrame:CGRectMake(SPACING, 22, self.view.frame.size.width - 2 * SPACING, 60)];
	_activeEventTitle.font = [UIFont boldSystemFontOfSize:15.0f];
	_activeEventTitle.textAlignment = NSTextAlignmentCenter;
	[_activeEventTitle setBorderStyle:UITextBorderStyleNone];
	if (isEdit) {
		_activeEventTitle.text = activeEventMode.title;
		return;
	}
	_activeEventTitle.placeholder = @"EVENT TITLE";
}

#pragma mark -创建表格中的活动图片
- (void)createCellOfTableWithActiveImage {
	_activeImgView =  [[UIImageView alloc] initWithFrame:CGRectMake(SPACING, 1, self.view.frame.size.width - 2 * SPACING, 160)];
	_activeImgView.contentMode =  UIViewContentModeScaleToFill;
	if (isEdit) {
		NSString *_urlStr = [[NSString stringWithFormat:@"%@/%@", BASEURL_IP, self.activeEventMode.imgUrl] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
		NSLog(@"%@", _urlStr);
		NSURL *url = [NSURL URLWithString:_urlStr];
		[_activeImgView sd_setImageWithURL:url placeholderImage:[UIImage imageNamed:@"018.jpg"] completed:nil];
		return;
	}
	_activeImgView.image = [UIImage imageNamed:@"018.jpg"];
}

#pragma mark -创建表格中的选项卡
- (void)createCellOfTableWithSelectCard {
	UIButton *_voteBtn = [[UIButton alloc] init];
	[_voteBtn.layer setMasksToBounds:YES];
	[_voteBtn setTitle:@"Vote a Date" forState:UIControlStateNormal];

	[_voteBtn setBackgroundImage:[UIImage imageNamed:@"TIme_Start"] forState:UIControlStateSelected];
	[_voteBtn setBackgroundImage:[UIImage imageNamed:@"Time_End"] forState:UIControlStateNormal];
	_voteBtn.frame = CGRectMake(SPACING, 0, 160 - SPACING, voteAndFixHeight);
	[_voteBtn addTarget:self action:@selector(touchUpInsideAction:) forControlEvents:UIControlEventTouchUpInside];

	UIButton *_fixBtn = [[UIButton alloc] init];
	[_fixBtn.layer setMasksToBounds:YES];
	[_fixBtn setTitle:@"Fix a Date" forState:UIControlStateNormal];
	[_fixBtn setBackgroundImage:[UIImage imageNamed:@"TIme_Start"] forState:UIControlStateSelected];
	[_fixBtn setBackgroundImage:[UIImage imageNamed:@"Time_End"] forState:UIControlStateNormal];
	_fixBtn.frame = CGRectMake(160, 0, 160 - SPACING, voteAndFixHeight);
	[_fixBtn addTarget:self action:@selector(touchUpInsideAction:) forControlEvents:UIControlEventTouchUpInside];
	_voteAndFixArr = [NSArray arrayWithObjects:_voteBtn, _fixBtn, nil];

	if (isEdit) {//编辑数据页面
		NSString *type = [NSString stringWithFormat:@"%@", activeEventMode.type];

		if ([@"1" isEqualToString:type]) {
			_fixBtn.selected = YES;
			_selectedBtnIndex = 1;
			voteDateOfSections = 2; //如果时间是固定的--》用户点击了要投票的的事件： 就  默认显示2个表格cell
			voteDateArr = [NSMutableArray array];
			for (NSInteger i = 0; i < voteDateOfSections; i++) {
				NSString *start = [[PublicMethodsViewController getPublicMethods] getcurrentTime:@"YYYY年 M月d日 HH:mm" interval:i + 1];
				NSString *end = [[PublicMethodsViewController getPublicMethods] getcurrentTime:@"YYYY年 M月d日 HH:mm" interval:(i + 1) * 12];
				[self addVoteDateWithEventStartTime:start endTime:end isAllDay:NO];
			}
		}
		else if ([@"2" isEqualToString:type]) {//可以投票时间
			voteDateArr = [NSMutableArray arrayWithArray:activeEventMode.time];//编辑时赋值给newVoteArr ；
			_voteBtn.selected = YES;
			_selectedBtnIndex = 0;
			voteDateOfSections = voteDateArr.count;
		}
	}
	else {
		_selectedBtnIndex = 0;//默认设置选择的是voteBtn；
		[_voteBtn setSelected:YES];
		voteDateOfSections = 2; //默认显示2个表格cell ；
		for (NSInteger i = 0; i < voteDateOfSections; i++) {
			NSString *start = [[PublicMethodsViewController getPublicMethods] getcurrentTime:@"YYYY年 M月d日 HH:mm" interval:i + 1];
			NSString *end = [[PublicMethodsViewController getPublicMethods] getcurrentTime:@"YYYY年 M月d日 HH:mm" interval:(i + 1) * 12];
			[self addVoteDateWithEventStartTime:start endTime:end isAllDay:NO];//---------------------------------------
		}
	}


	UIView *voteView = [[UIView alloc] initWithFrame:CGRectMake(0, _fixBtn.frame.size.height, kScreen_Width, voteDateOfSections * voteTableViewCellHight + footerCellHeight)];

	voteTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, voteView.frame.size.width, voteView.frame.size.height) style:UITableViewStylePlain];
	voteTableView.bounces = NO;
	voteTableView.delegate = self;
	voteTableView.dataSource = self;
	[voteView addSubview:voteTableView];

	//voteTableView 的底部视图
	UIView *footerView = [[UIView alloc] initWithFrame:CGRectMake(0, _fixBtn.frame.size.height, kScreen_Width
	                                                              , footerCellHeight)];
	UIButton *addTimeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
	addTimeBtn.frame = CGRectMake(20, 10, footerView.frame.size.width - 2 * 20, 44);
	[addTimeBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
	addTimeBtn.layer.borderWidth = 0.5f;
	addTimeBtn.layer.borderColor = [UIColor lightGrayColor].CGColor;
	[addTimeBtn setTitle:@"➕    Add a date..." forState:UIControlStateNormal];
	[addTimeBtn addTarget:self action:@selector(addMutableDateVote) forControlEvents:UIControlEventTouchUpInside];

	UIButton *allowBtn = [UIButton buttonWithType:UIButtonTypeCustom];
	[allowBtn setBackgroundImage:[UIImage imageNamed:@"selecte_friend_cycle"] forState:UIControlStateNormal];
	[allowBtn setBackgroundImage:[UIImage imageNamed:@"selecte_friend_tick"] forState:UIControlStateSelected];
	allowBtn.frame = CGRectMake(30, 60, 30, 30);
	[allowBtn addTarget:self action:@selector(allowAnyoneAddOptions:) forControlEvents:UIControlEventTouchUpInside];

	UILabel *allowLab = [[UILabel alloc] initWithFrame:CGRectMake(70, 60, kScreen_Width - 2 * 50, 32)];
	allowLab.text = @"Allow anyone to add options";
	UILabel *deadLineLab = [[UILabel alloc] initWithFrame:CGRectMake(10, 93, 70, 32)];
	deadLineLab.text = @"Deadline ";
	deadlineTextField = [[UITextField alloc] initWithFrame:CGRectMake(80, 93, 230, 32)];
	deadlineTextField.delegate = self;
	deadlineTextField.layer.borderWidth = 0.5;
	deadlineTextField.layer.borderColor = [UIColor grayColor].CGColor;
	deadlineTextField.tag = 10; //标示该文本输入框 后面确定
	[footerView addSubview:addTimeBtn];
	[footerView addSubview:allowLab];
	[footerView addSubview:deadLineLab];
	[footerView addSubview:allowBtn];
	[footerView addSubview:deadlineTextField];
	voteTableView.tableFooterView = footerView;

	if (isEdit) {
		NSString *addTime = [NSString stringWithFormat:@"%@", activeEventMode.addTime];
		if ([@"1" isEqualToString:addTime]) { //1表示允许成员增加时间
			allowBtn.selected = YES;
			allowAddTime = 1; //no
		}
		else {
			allowBtn.selected = NO;
			allowAddTime = 0;  //no
		}
		deadlineTextField.text = activeEventMode.voteEndTime;
	}


	//固定时间不支持投票
	UIView *fixView = [[UIView alloc] initWithFrame:CGRectMake(0, _fixBtn.frame.size.height, kScreen_Width
	                                                           , 180 - _fixBtn.frame.size.height)];
	_intervalbtn = [UIButton buttonWithType:UIButtonTypeCustom];
	_intervalbtn.frame = CGRectMake(20, 26, 40, 40);
	[_intervalbtn setBackgroundImage:[UIImage imageNamed:@"Event_time_red"] forState:UIControlStateNormal];
	[_intervalbtn setTitle:@"1 h" forState:UIControlStateNormal];
	_intervalbtn.titleLabel.font = [UIFont systemFontOfSize:12.f];

	fixStartTimeLab = [[UILabel alloc] initWithFrame:CGRectMake(50, 26, 230, 20)];
	fixStartTimeLab.textAlignment = NSTextAlignmentCenter;
	fixStartTimeLab.backgroundColor = [UIColor clearColor];

	fixEndTimeLab = [[UILabel alloc] initWithFrame:CGRectMake(50, 46, 230, 20)];
	fixEndTimeLab.textAlignment = NSTextAlignmentCenter;
	fixEndTimeLab.backgroundColor = [UIColor clearColor];

	[fixView addSubview:_intervalbtn];
	[fixView addSubview:fixStartTimeLab];
	[fixView addSubview:fixEndTimeLab];

	_voteAndFixViewArr = @[voteView, fixView];
}

#pragma mark -建立活动内容投票视图
- (void)createVoteView {
	voteActiveSections = newVoteArr.count;
	voteActiveView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreen_Width, voteActiveTableCellHight + voteActiveSections * voteActiveTableCellHight)];

	_newVoteTable = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, voteActiveView.frame.size.width, voteActiveView.frame.size.height) style:UITableViewStylePlain];

	_newVoteTable.bounces = NO;
	_newVoteTable.delegate = self;
	_newVoteTable.dataSource = self;
	[voteActiveView addSubview:_newVoteTable];
	UIView *voteFooterView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreen_Width
	                                                                  , voteActiveTableCellHight)];

	UIButton *addVoteBtn = [UIButton buttonWithType:UIButtonTypeCustom];
	addVoteBtn.frame = CGRectMake(20, 4, voteFooterView.frame.size.width - 2 * 20, voteActiveTableCellHight - 11);
	[addVoteBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
	addVoteBtn.layer.borderWidth = 0.5f;
	addVoteBtn.layer.borderColor = [UIColor lightGrayColor].CGColor;
	[addVoteBtn setTitle:@"➕    New Vote..." forState:UIControlStateNormal];
	[addVoteBtn addTarget:self action:@selector(addMutableNewVote) forControlEvents:UIControlEventTouchUpInside];

	[voteFooterView addSubview:addVoteBtn];
	_newVoteTable.tableFooterView = voteFooterView;
}

#pragma mark -创建位置标签
- (void)createLoctionView {
	_locallable = [[UILabel alloc] initWithFrame:CGRectMake(0, 5, self.view.frame.size.width, 20)];
	_locallable.text = @"Location";
	_locallable.textAlignment = NSTextAlignmentCenter;

	localfiled = [[UITextField alloc]initWithFrame:CGRectMake(0, 20, self.view.frame.size.width, 64)];
	localfiled.textAlignment = NSTextAlignmentCenter;
	localfiled.font = [UIFont boldSystemFontOfSize:15.0f];
	localfiled.enabled = NO;
	localfiled.tag = 1;
	localfiled.delegate = self;
	if (isEdit) {
		localfiled.text = activeEventMode.location;
		return;
	}
	localfiled.placeholder = @"LOCATION";
}

#pragma mark - 创建Note标签
- (void)createCellOfNoteView {
	notelabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 5, self.view.frame.size.width, 20)];
	notelabel.text = @"Note";
	notelabel.textAlignment = NSTextAlignmentCenter;
	notefiled = [[UITextField alloc]initWithFrame:CGRectMake(0, 20, self.view.frame.size.width, 64)];
	notefiled.tag = 2;
	notefiled.delegate = self;
	notefiled.textAlignment = NSTextAlignmentCenter;
	notefiled.font = [UIFont boldSystemFontOfSize:15.0f];
	notefiled.textColor = [UIColor blackColor];
	if (isEdit) {
		notefiled.text = activeEventMode.note;
		return;
	}
	notefiled.placeholder = @"NOTE";
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
}

#pragma mark -_voteBtn 和 _fixBtn 的点击事件
- (void)touchUpInsideAction:(UIButton *)sender {
	NSLog(@"sender  touchUpInsideAction");
	NSInteger index = [_voteAndFixArr indexOfObject:sender];
	if (isEdit) {
		if (_selectedBtnIndex != index)
			[MBProgressHUD showError:@"Do not modify"];
		return;
	}
	for (UIButton *button in _voteAndFixArr) {
		button.selected = NO;
	}
	sender.selected = YES;

	if (_selectedBtnIndex != index) {
		_selectedBtnIndex = index;
		if (index == 1) {//为fix生成一个时间
			NSDate *startDate = [[NSDate date] dateByAddingTimeInterval:5 * 60];
			NSDate *endDate = [startDate dateByAddingTimeInterval:1 * 60 * 60];
			NSMutableDictionary *fixDateDic = [NSMutableDictionary dictionary];
			NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
			[formatter setDateStyle:NSDateFormatterMediumStyle];
			[formatter setTimeStyle:NSDateFormatterShortStyle];
			[formatter setDateFormat:@"YYYY-MM-dd HH:mm"];
			NSTimeZone *timeZone = [NSTimeZone defaultTimeZone];
			[formatter setTimeZone:timeZone];
			[fixDateDic setObject:[formatter stringFromDate:startDate] forKey:@"startTime"];
			[fixDateDic setObject:[formatter stringFromDate:endDate] forKey:@"endTime"];
			[fixDateDic setObject:@(0) forKey:@"allDay"];
			[fixDateArr addObject:fixDateDic];
		}

		[_tableView reloadData];//重新刷新表格
	}
}

- (void)didReceiveMemoryWarning {
	[super didReceiveMemoryWarning];
	// Dispose of any resources that can be recreated.
}

//取消返回
- (void)onClickCancel {
	[self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)addFriendToActive:(UIButton *)sender {
	SetFriendViewController *setFirVc = [[SetFriendViewController alloc] init];
	setFirVc.delegate = self;
	[self presentPopupViewController:setFirVc animationType:MJPopupViewAnimationFade];
}

#pragma mark - SetFriendViewController的代理方法？用于存储选择的用户
- (void)saveButtonClicked:(SetFriendViewController *)secondSetFriendViewController didSelectFriend:(NSArray *)friendArr {
	if (friendArr.count > 0) {
		inviteeFriendArr = [NSMutableArray arrayWithArray:friendArr];
		[inviteeFriendArr insertObject:[UserInfo currUserInfo] atIndex:0];

		for (NSUInteger i = 0; i < inviteeFriendArr.count; i++) {
			NSMutableDictionary *inviteeDic = [NSMutableDictionary dictionary];

			id tmpObj = inviteeFriendArr[i];
//        if ([tmpObj isKindOfClass:[UserInfo class]]) {
//            UserInfo * currUse = (UserInfo *) tmpObj;
//            [inviteeDic setObject:currUse.Id forKey:@"uid"];
//        }else
			if ([tmpObj isKindOfClass:[Friend class]]) {
				Friend *currUse = (Friend *)tmpObj;
				[inviteeDic setObject:currUse.fid forKey:@"uid"];
				[inviteeArr addObject:inviteeDic];
			}
		}
		[_tableView reloadData];
	}
	[self dismissPopupViewControllerWithanimationType:MJPopupViewAnimationFade];
}

- (void)dissViewcontroller {
	//if ([state isEqualToString:@"edit"]) {
	[self.navigationController popViewControllerAnimated:YES];
	// }else{
	//   [self dismissViewControllerAnimated:YES completion:nil];
	// }
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
	if (textField.tag == 10) {
		RMDateSelectionViewController *dateSelectionVC = [RMDateSelectionViewController dateSelectionController];
		dateSelectionVC.delegate = self;

		[dateSelectionVC show];
		return NO;
	}
	else {
		return YES;
	}
}

- (void)allowAnyoneAddOptions:(UIButton *)sender {
	if (sender.selected) {
		sender.selected = NO;
		allowAddTime = 0; //no
	}
	else {
		sender.selected = YES;
		allowAddTime = 1;//表示允许成员添加时间
	}
	[_tableView reloadData];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
	[_activeEventTitle resignFirstResponder];
	[notefiled resignFirstResponder];
	return YES;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
	[_activeEventTitle resignFirstResponder];
	[notefiled resignFirstResponder];
	_tableView.frame = CGRectMake(0, 0, _tableView.frame.size.width, _tableView.frame.size.height);
}

- (void)textFieldDidBeginEditing:(UITextField *)textField {
	if (2 == textField.tag) {
		[UIView beginAnimations:nil context:nil];
		[UIView setAnimationDuration:0.3];
		_tableView.frame = CGRectMake(0, -250, _tableView.frame.size.width, _tableView.frame.size.height);
		[UIView commitAnimations];
	}
}

#pragma mark - tableview

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	if (voteTableView == tableView) {
		return voteDateOfSections;
	}
	else if (_newVoteTable == tableView) {
		return voteActiveSections;
	}

	return 7;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	if (voteTableView == tableView) {
		return voteTableViewCellHight;
	}
	if (_newVoteTable == tableView) {
		return voteActiveTableCellHight;
	}

	if (indexPath.section == 0) {
		if (indexPath.row == 0) {
			return 162;
		}
	}
	if (indexPath.section == 2) {
		if (indexPath.row == 0) {
			if (_selectedBtnIndex == 1) {
				return 120;
			}
			else {
				return voteDateOfSections * voteTableViewCellHight + voteAndFixHeight + footerCellHeight;
			}
		}
	}
	if (indexPath.section == 3) {
		if (indexPath.row == 0) {
			return 110;
		}
	}
	if (indexPath.section == 4) {
		if (indexPath.row == 0) {
			return voteActiveTableCellHight + voteActiveTableCellHight * voteActiveSections;
		}
	}
	return 84;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	if (voteTableView == tableView) {
		static NSString *cellId = @"addVoteTimeIdentifier";
		voteDateTableViewCell *voteCell = [tableView dequeueReusableCellWithIdentifier:cellId];
		if (voteCell == nil) {
			NSArray *viewCells = [[NSBundle mainBundle] loadNibNamed:@"voteDateTableViewCell" owner:self options:nil];
			for (UITableViewCell *cell in viewCells) {
				if (cell.tag == 10) {
					voteCell = (voteDateTableViewCell *)cell;
				}
			}
		}
		NSDictionary *timeDic = [voteDateArr objectAtIndex:indexPath.section];
		NSInteger isAllDay = [[timeDic objectForKey:@"allDay"] integerValue];//是否全天时间

		NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
		[formatter setDateStyle:NSDateFormatterMediumStyle];
		[formatter setTimeStyle:NSDateFormatterShortStyle];
		[formatter setDateFormat:@"YYYY-MM-dd HH:mm"];
		NSTimeZone *timeZone = [NSTimeZone defaultTimeZone];
		[formatter setTimeZone:timeZone];
		NSDate *startDate = [formatter dateFromString:[timeDic objectForKey:@"startTime"]];
		NSDate *endDate = [formatter dateFromString:[timeDic objectForKey:@"endTime"]];
		NSString *instr = [[PublicMethodsViewController getPublicMethods] timeDifference:[timeDic objectForKey:@"endTime"] getStrart:[timeDic objectForKey:@"startTime"] formmtterStyle:@"yyyy-MM-dd HH:mm"];
		if (isAllDay == 1) {  //表示是全天
			CLDay *startday = [[CLDay alloc] initWithDate:startDate];
			CLDay *endday = [[CLDay alloc] initWithDate:endDate];

			voteCell.intervalTime.text = instr;
			if (![[startday description] isEqualToString:[endday description]] && ![@"1d" isEqualToString:instr]) {
				voteCell.allDayLab.text = [NSString stringWithFormat:@"%@ → %@", [startday abbreviationWeekDayMotch], [endday abbreviationWeekDayMotch]];
			}
			else {
				voteCell.allDayLab.text = [NSString stringWithFormat:@"%@ (ALL DAY)", [startday abbreviationWeekDayMotch]];
			}
		}
		else {
			NSString *fixStartTime = [[PublicMethodsViewController getPublicMethods] stringformatWithDate:startDate];
			NSString *startTime = [[PublicMethodsViewController getPublicMethods] formaterStringfromDate:@"HH:mm" dateString:fixStartTime];
			CLDay *now = [[CLDay alloc] initWithDate:startDate];

			NSString *fixEndTime = [[PublicMethodsViewController getPublicMethods] stringformatWithDate:endDate];
			NSString *endTime = [[PublicMethodsViewController getPublicMethods] formaterStringfromDate:@"HH:mm" dateString:fixEndTime];
			voteCell.intervalTime.text = instr;
			voteCell.showDateLab.text = [now weekDayMotch];
			voteCell.showTimeLab.text = [NSString stringWithFormat:@"%@ → %@", startTime, endTime];
		}
		return voteCell;
	}
	else if (_newVoteTable == tableView) {
		static NSString *cellId = @"newVoteActiveIdentifier";
		UITableViewCell *newVoteCell = [tableView dequeueReusableCellWithIdentifier:cellId];
		if (newVoteCell == nil) {
			NSArray *viewCells = [[NSBundle mainBundle] loadNibNamed:@"voteDateTableViewCell" owner:self options:nil];
			for (UITableViewCell *cell in viewCells) {
				if (cell.tag == 20) {
					newVoteCell = cell;
					newVoteCell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
				}
			}
		}
		NSArray *subviews = [[NSArray alloc]initWithArray:newVoteCell.contentView.subviews];
		for (UIView *subview in subviews) {
			[subview removeFromSuperview];
		}

		if (newVoteArr.count > 0) {
			newVoteCell.textLabel.text = [newVoteArr[indexPath.section] objectForKey:@"title"];
			newVoteCell.textLabel.textAlignment = NSTextAlignmentCenter;
		}
		return newVoteCell;
	}
	else {
		static NSString *cellId = @"addActiveIdentifier";
		UITableViewCell *activeCell = [tableView dequeueReusableCellWithIdentifier:cellId];
		if (activeCell == nil) {
			activeCell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellId];
		}
		//取消选中行的样式
		activeCell.selectionStyle = UITableViewCellSelectionStyleNone;
		//清除contentView中的所有视图
		NSArray *subviews = [[NSArray alloc]initWithArray:activeCell.contentView.subviews];
		for (UIView *subview in subviews) {
			[subview removeFromSuperview];
		}
		if (indexPath.section == 0) {
			if (indexPath.row == 0) {
				[activeCell.contentView addSubview:_activeImgView];
			}
		}
		if (indexPath.section == 1) {
			if (indexPath.row == 0) {
				[activeCell.contentView addSubview:_activeLab];
				[activeCell.contentView addSubview:_activeEventTitle];
			}
		}
		if (indexPath.section == 2) {
			if (indexPath.row == 0) {
				for (UIButton *btn in _voteAndFixArr) {
					[activeCell.contentView addSubview:btn];
				}
				UIView *view = [_voteAndFixViewArr objectAtIndex:_selectedBtnIndex];
				if (_selectedBtnIndex == 0) {//表示可投票时间
					voteAndFixTimeType = VOTEDATETYPE;
				}
				else if (_selectedBtnIndex == 1) {
					voteAndFixTimeType = FIXDATETYPE;
					//开始时间
					NSDictionary *timeDic = [fixDateArr objectAtIndex:0];
					NSInteger isAllDay = [[timeDic objectForKey:@"allDay"] integerValue];//是否全天时间

					NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
					[formatter setDateStyle:NSDateFormatterMediumStyle];
					[formatter setTimeStyle:NSDateFormatterShortStyle];
					[formatter setDateFormat:@"YYYY-MM-dd HH:mm"];
					NSTimeZone *timeZone = [NSTimeZone defaultTimeZone];
					[formatter setTimeZone:timeZone];

					NSDate *startDate = [formatter dateFromString:[timeDic objectForKey:@"startTime"]];
					NSDate *endDate = [formatter dateFromString:[timeDic objectForKey:@"endTime"]];

					NSString *fixStartTime = [[PublicMethodsViewController getPublicMethods] stringformatWithDate:startDate];
					NSString *startTime = [[PublicMethodsViewController getPublicMethods] formaterStringfromDate:@"HH:mm" dateString:fixStartTime];

					//结束时间
					NSString *fixEndTime = [[PublicMethodsViewController getPublicMethods] stringformatWithDate:endDate];
					NSString *endTime = [[PublicMethodsViewController getPublicMethods] formaterStringfromDate:@"HH:mm" dateString:fixEndTime];

					CLDay *startday = [[CLDay alloc] initWithDate:startDate];
					CLDay *endday = [[CLDay alloc] initWithDate:endDate];

					NSString *instr = [[PublicMethodsViewController getPublicMethods] timeDifference:fixEndTime getStrart:fixStartTime formmtterStyle:@"YYYY年 M月d日HH:mm"];
					if (isAllDay == 1) {   //表示是全天
						[_intervalbtn setTitle:instr forState:UIControlStateNormal];
						if (![[startday description] isEqualToString:[endday description]] && ![@"1d" isEqualToString:instr]) {
							fixStartTimeLab.text = [NSString stringWithFormat:@"%@ → %@", [startday abbreviationWeekDayMotch], [endday abbreviationWeekDayMotch]];
						}
						else {
							fixStartTimeLab.text = [NSString stringWithFormat:@"%@ (ALL DAY)", [startday abbreviationWeekDayMotch]];
						}
					}
					else {
						fixStartTimeLab.text = [startday weekDayMotch];
						fixEndTimeLab.text = [NSString stringWithFormat:@"%@ → %@", startTime, endTime];
						[_intervalbtn setTitle:instr forState:UIControlStateNormal];
					}
				}
				[activeCell.contentView addSubview:view];
			}
		}
		if (indexPath.section == 3) {
			if (indexPath.row == 0) {
				for (UIView *view in self.innsertScorllView.subviews) {
					if ([view isKindOfClass:[FriendInformationView class]]) {
						[view  removeFromSuperview];
					}
				}
				NSInteger showCount = 0;  //要显示多少人数
				self.inviteeLab.text = [NSString stringWithFormat:@"%d Invitee", inviteeFriendArr.count];
				if (inviteeFriendArr.count > 5) {
					[self.moreBtn setHidden:NO];
					showCount = 5;
				}
				else {
					[self.moreBtn setHidden:YES];
					showCount = inviteeFriendArr.count;
				}
				for (int i = 0; i < showCount; i++) {
					FriendInformationView *fiv =  [FriendInformationView initFriendInfoView];
					fiv.frame = CGRectMake(52 * i, 10, 50, 80);
					id personInfo = inviteeFriendArr[i];
					if ([personInfo isKindOfClass:[UserInfo class]]) {
						UserInfo *currUse = (UserInfo *)personInfo;
						if (currUse.nickname && ![currUse.nickname isEqualToString:@""]) {
							fiv.friendNameLab.text = currUse.nickname;
						}
						else {
							fiv.friendNameLab.text = currUse.username;
						}

						NSString *_urlStr = [[NSString stringWithFormat:@"%@/%@", BASEURL_IP, currUse.imgUrl] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
						NSURL *url = [NSURL URLWithString:_urlStr];
						[fiv.friendHeadimg sd_setImageWithURL:url placeholderImage:[UIImage imageNamed:@"smile_1"] completed:nil];
					}
					else if ([personInfo isKindOfClass:[Friend class]]) {
						Friend *friend = (Friend *)personInfo;
						NSString *_urlStr = [[NSString stringWithFormat:@"%@/%@", BASEURL_IP, friend.imgBig] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
						NSURL *url = [NSURL URLWithString:_urlStr];
						[fiv.friendHeadimg sd_setImageWithURL:url placeholderImage:[UIImage imageNamed:@"smile_1"] completed:nil];
						if (friend.nickname && ![@"" isEqualToString:friend.nickname]) {
							fiv.friendNameLab.text = friend.nickname;
						}
						else {
							fiv.friendNameLab.text = friend.username;
						}
					}
					[self.innsertScorllView addSubview:fiv];
				}
				return _inviteeCell;
			}
		}
		if (indexPath.section == 4) {
			if (indexPath.row == 0) {
				[activeCell.contentView addSubview:voteActiveView];
			}
		}
		if (indexPath.section == 5) {
			if (indexPath.row == 0) {
				[activeCell.contentView addSubview:_locallable];
				[activeCell.contentView addSubview:localfiled];
				if (localfiled.text.length > 0) {//地图文本不为空
					NSString *str = localfiled.text;
					//计算文本的宽度
					NSDictionary *attribute = @{ NSFontAttributeName: [UIFont systemFontOfSize:15] };
					CGSize size = [str boundingRectWithSize:CGSizeMake(320, 0) options:NSStringDrawingTruncatesLastVisibleLine | NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading attributes:attribute context:nil].size;
					addressIcon.frame = CGRectMake((self.view.bounds.size.width / 2 - size.width / 2) - 17, 25, 10, 15);
					[localfiled addSubview:addressIcon];
				}
			}
		}
		if (indexPath.section == 6) {
			if (indexPath.row == 0) {
				[activeCell.contentView addSubview:notelabel];
				[activeCell.contentView addSubview:notefiled];
			}
		}
		return activeCell;
	}
}

#pragma mark - Table view delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	if (tableView == voteTableView) {
		NSDictionary *timeDic = [voteDateArr objectAtIndex:indexPath.section];
		NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
		[formatter setDateStyle:NSDateFormatterMediumStyle];
		[formatter setTimeStyle:NSDateFormatterShortStyle];
		[formatter setDateFormat:@"YYYY-MM-dd HH:mm"];
		NSTimeZone *timeZone = [NSTimeZone defaultTimeZone];
		[formatter setTimeZone:timeZone];
		NSDate *startDate = [formatter dateFromString:[timeDic objectForKey:@"startTime"]];
		NSDate *endDate = [formatter dateFromString:[timeDic objectForKey:@"endTime"]];

		ViewController *controler = [[ViewController alloc]initWithNibName:@"ViewController" bundle:nil];
		AnyEvent *eventData = [AnyEvent MR_createEntity];
		if (_activeEventTitle.text && ![_activeEventTitle.text isEqualToString:@""]) {
			eventData.eventTitle = _activeEventTitle.text;
		}
		eventData.startDate  =  [[PublicMethodsViewController getPublicMethods] stringformatWithDate:startDate];
		eventData.endDate    = [[PublicMethodsViewController getPublicMethods] stringformatWithDate:endDate];
		eventData.isAllDay = @([[timeDic objectForKey:@"allDay"] integerValue]);//全天事件 标记
		[controler addEventViewControler:self anyEvent:eventData];
		controler.detelegate = self;
		[self.navigationController pushViewController:controler animated:YES];
	}
	else if (_newVoteTable == tableView) {
		if (newVoteArr.count > 0) {
			NSDictionary *newVoteDic = [newVoteArr objectAtIndex:indexPath.section];
			NewVoteActionViewController *newVoteVc = [[NewVoteActionViewController alloc] init];
			newVoteVc.voteOptionDic = newVoteDic;
			newVoteVc.delegate = self;
			newVoteVc.isEdit = YES;  //只要用数据点击进去都是编辑
			[self.navigationController pushViewController:newVoteVc animated:YES];
		}
	}
	else {
		if (indexPath.section == 0) {
			UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil
			                                                         delegate:self
			                                                cancelButtonTitle:nil
			                                           destructiveButtonTitle:nil
			                                                otherButtonTitles:@"Photo Album", nil];
			if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
				[actionSheet addButtonWithTitle:@"Camera"];
			}

			[actionSheet addButtonWithTitle:@"Cancel"];
			actionSheet.cancelButtonIndex = actionSheet.numberOfButtons - 1;

			[actionSheet showInView:self.view];
		}
		if (indexPath.section == 1) {
		}
		else if (indexPath.section == 2) {
			if (_selectedBtnIndex == 1) {// Fix a Date 按钮
				NSDictionary *timeDic = [fixDateArr objectAtIndex:0]; //固定取零
				NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
				[formatter setDateStyle:NSDateFormatterMediumStyle];
				[formatter setTimeStyle:NSDateFormatterShortStyle];
				[formatter setDateFormat:@"YYYY-MM-dd HH:mm"];
				NSTimeZone *timeZone = [NSTimeZone defaultTimeZone];
				[formatter setTimeZone:timeZone];
				NSDate *startDate = [formatter dateFromString:[timeDic objectForKey:@"startTime"]];
				NSDate *endDate = [formatter dateFromString:[timeDic objectForKey:@"endTime"]];

				ViewController *controler = [[ViewController alloc]initWithNibName:@"ViewController" bundle:nil];
				AnyEvent *eventData = [AnyEvent MR_createEntity];
				if (_activeEventTitle.text && ![_activeEventTitle.text isEqualToString:@""]) {
					eventData.eventTitle = _activeEventTitle.text;
				}
				eventData.startDate  =  [[PublicMethodsViewController getPublicMethods] stringformatWithDate:startDate];
				eventData.endDate    = [[PublicMethodsViewController getPublicMethods] stringformatWithDate:endDate];
				eventData.isAllDay = @([[timeDic objectForKey:@"allDay"] integerValue]);//全天事件 标记
				[controler addEventViewControler:self anyEvent:eventData];
				controler.detelegate = self;
				[self.navigationController pushViewController:controler animated:YES];
			}
		}
		else if (indexPath.section == 3) {
		}
		else if (indexPath.section == 4) {
		}
		else if (indexPath.section == 5) {
			LocationViewController *locationView = [[LocationViewController alloc] initWithNibName:@"LocationViewController" bundle:nil];
			locationView.detelegate = self;
			[self.navigationController pushViewController:locationView animated:YES];
		}
	}
}

#pragma mark -该方法是UIActionsheet的回调
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
	NSString *buttonTitle = [actionSheet buttonTitleAtIndex:buttonIndex];
	if ([buttonTitle isEqualToString:NSLocalizedString(@"Photo Album", nil)]) {
		[self openPhotoAlbum];
	}
	else if ([buttonTitle isEqualToString:NSLocalizedString(@"Camera", nil)]) {
		[self showCamera];
	}
}

- (void)openPhotoAlbum {
	UIImagePickerController *controller = [[UIImagePickerController alloc] init];
	controller.delegate = self;
	controller.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;

	if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
		if (self.popover.isPopoverVisible) {
			[self.popover dismissPopoverAnimated:NO];
		}

		self.popover = [[UIPopoverController alloc] initWithContentViewController:controller];
		[self.popover presentPopoverFromRect:self.view.frame inView:self.view
		            permittedArrowDirections:UIPopoverArrowDirectionAny
		                            animated:YES];
	}
	else {
		[self presentViewController:controller animated:YES completion:NULL];
	}
}

#pragma mark - Private methods

- (void)showCamera {
	UIImagePickerController *controller = [[UIImagePickerController alloc] init];
	controller.delegate = self;
	controller.sourceType = UIImagePickerControllerSourceTypeCamera;

	if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
		if (self.popover.isPopoverVisible) {
			[self.popover dismissPopoverAnimated:NO];
		}

		self.popover = [[UIPopoverController alloc] initWithContentViewController:controller];
		[self.popover presentPopoverFromRect:self.view.frame inView:self.view
		            permittedArrowDirections:UIPopoverArrowDirectionAny
		                            animated:YES];
	}
	else {
		[self presentViewController:controller animated:YES completion:NULL];
	}
}

#pragma mark - UIImagePickerControllerDelegate methods
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
	UIImage *image = info[UIImagePickerControllerOriginalImage];
	image = ResizeImage(image, kScreen_Width, kScreen_Width / 2);
	if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
		if (self.popover.isPopoverVisible) {
			[self.popover dismissPopoverAnimated:NO];
			[self openEditor:image];
		}
	}
	else {
		[picker dismissViewControllerAnimated:YES completion: ^{
		    [self openEditor:image];
		}];
	}
}

- (void)openEditor:(UIImage *)image {
	PECropViewController *controller = [[PECropViewController alloc] init];
	controller.delegate = self;
	controller.image = image;
	CGFloat width = image.size.width;
	CGFloat height = image.size.height;
	CGFloat length = MIN(width, height);
	controller.imageCropRect = CGRectMake(0, length / 4, width, width / 2);

	UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:controller];
	navigationController.navigationBar.translucent = NO;
	navigationController.navigationBar.barTintColor = blueColor;

	if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
		navigationController.modalPresentationStyle = UIModalPresentationFormSheet;
	}

	[self presentViewController:navigationController animated:YES completion:NULL];
}

- (void)cropViewController:(PECropViewController *)controller didFinishCroppingImage:(UIImage *)croppedImage;
{
	[controller dismissViewControllerAnimated:YES completion:NULL];
	_activeImgView.image = croppedImage;
}

- (void)cropViewControllerDidCancel:(PECropViewController *)controller {
	[controller dismissViewControllerAnimated:YES completion:NULL];
}

//-(UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    return UITableViewCellEditingStyleInsert;
//}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
	if (tableView == voteTableView) {//时间投票的操作
		return UITableViewCellEditingStyleDelete;
	}
	else if (_newVoteTable == tableView) {//活动内容投票
		return UITableViewCellEditingStyleDelete;
	}
	return UITableViewCellEditingStyleNone;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath  {
	if (editingStyle == UITableViewCellEditingStyleDelete) {
		if (tableView == _newVoteTable) {//内容投票操作
			if (isEdit) {
				NSDictionary *deleteDic = [newVoteArr objectAtIndex:indexPath.section];
				NSString *idStr = [NSString stringWithFormat:@"%@", [deleteDic objectForKey:@"id"]];
				if (![idStr hasPrefix:@"option"]) {
					[deleteVoteArr addObject:idStr];
				}
				else {
					[addVoteArr removeObject:deleteDic];
				}
				[updateVoteArr removeObject:deleteDic];
			}
			voteActiveSections -= 1;
			[newVoteArr removeObjectAtIndex:indexPath.section];
			[tableView deleteSections:[NSIndexSet indexSetWithIndex:indexPath.section] withRowAnimation:UITableViewRowAnimationAutomatic];
			[_newVoteTable reloadData];
		}
		else if (voteTableView == tableView) {//时间投票操作
			voteDateOfSections -= 1;
			if (isEdit) { //是修改数据才才进行操作
				NSMutableDictionary *deleteDic = [voteDateArr objectAtIndex:indexPath.section];
				NSString *idStr = [NSString stringWithFormat:@"%@", [deleteDic objectForKey:@"id"]];
				if (idStr && ![idStr isEqual:@""]) {
					[deleteVoteTimeArr addObject:idStr];
				}
				else {
					[addvoteTimeArr removeObject:deleteDic];
				}
			}
			[voteDateArr removeObjectAtIndex:indexPath.section];
			[tableView deleteSections:[NSIndexSet indexSetWithIndex:indexPath.section] withRowAnimation:UITableViewRowAnimationAutomatic];
		}
		[_tableView    reloadData];
	}
	if (editingStyle == UITableViewCellEditingStyleInsert) {
//        i=i+1;
//        NSInteger row = [indexPath row];
//        NSArray *insertIndexPath = [NSArray arrayWithObjects:indexPath, nil];
//        NSString *mes = [NSString stringWithFormat:@"添加的第%d行",i];
//        //        添加单元行的设置的标题
//        [self.listData insertObject:mes atIndex:row];
//        [tableView insertRowsAtIndexPaths:insertIndexPath withRowAnimation:UITableViewRowAnimationRight];
		voteDateOfSections = voteDateOfSections + 1;
		[voteTableView reloadData];
		[_tableView    reloadData];
	}
	UIView *voteView = (UIView *)_voteAndFixViewArr[0];
	[voteTableView setFrame:CGRectMake(0, 0, kScreen_Width, voteDateOfSections * voteTableViewCellHight + footerCellHeight)];
	[voteView setFrame:CGRectMake(0, voteAndFixHeight, kScreen_Width, voteDateOfSections * voteTableViewCellHight + footerCellHeight)];
}

#pragma mark -添加投票的代理方法：返回数据
- (void)newVoteActionViewController:(NewVoteActionViewController *)newVoteViewVc mainQuestion:(NSString *)question allowAddQuestion:(NSInteger)allow childQuestion:(NSArray *)childArr optionId:(NSString *)oId isEdit:(BOOL)isModify {
	if (isModify) {//是对选项进行修改
		NSString *opId = [NSString stringWithFormat:@"%@", oId];
		for (NSMutableDictionary *optionDic in newVoteArr) {
			NSString *optionId = [NSString stringWithFormat:@"%@", [optionDic objectForKey:@"id"]];
			if ([opId isEqualToString:optionId]) {
				[optionDic removeObjectForKey:@"title"];
				[optionDic setObject:question forKey:@"title"];
				[optionDic removeObjectForKey:@"optionList"];//删除原来的值
				[optionDic setObject:childArr forKey:@"optionList"];
				if (isEdit) {
					[updateVoteArr addObject:optionDic];//记录修改的数据 ；
				}
			}
		}
	}
	else {
		voteActiveSections++;
		NSMutableDictionary *tmp = [NSMutableDictionary dictionary];
		[tmp setObject:[self generateUniqueOptonId] forKey:@"id"];//生成一个临时id
		[tmp setObject:question forKey:@"title"];
		[tmp setObject:@(allow) forKey:@"enableAdd"];
		if (childArr.count > 0) {
			[tmp setObject:childArr forKey:@"optionList"];
		}
		if (isEdit) {
			[addVoteArr addObject:tmp];//记录新增的数据 ；
		}
		[newVoteArr addObject:tmp];
	}
	voteActiveView.frame = CGRectMake(0, 0, kScreen_Width, voteActiveTableCellHight + voteActiveSections * voteActiveTableCellHight);
	_newVoteTable.frame = CGRectMake(0, 0, kScreen_Width, voteActiveTableCellHight + voteActiveSections * voteActiveTableCellHight);
	[_newVoteTable reloadData];
	[_tableView    reloadData];

	[self.navigationController popToViewController:self animated:YES];
}

#pragma mark -添加投票的时间
- (void)addMutableDateVote {
	ViewController *controler = [[ViewController alloc]initWithNibName:@"ViewController" bundle:nil];
	AnyEvent *eventData = [AnyEvent MR_createEntity];
	NSDate *startDate = [[NSDate date] dateByAddingTimeInterval:5 * 60];
	eventData.startDate = [[PublicMethodsViewController getPublicMethods] stringformatWithDate:startDate];
	NSDate *endDate = [startDate dateByAddingTimeInterval:1 * 60 * 60];
	eventData.endDate = [[PublicMethodsViewController getPublicMethods] stringformatWithDate:endDate];
	eventData.isAllDay = @(0);//全天事件 标记
	[controler addEventViewControler:self anyEvent:eventData];
	controler.detelegate = self;
	[self.navigationController pushViewController:controler animated:YES];
}

#pragma mark -添加投票的具体内容
- (void)addMutableNewVote {
	NewVoteActionViewController *newVoteVc = [[NewVoteActionViewController alloc] init];
	newVoteVc.delegate = self;
	newVoteVc.isEdit = NO;
	[self.navigationController pushViewController:newVoteVc animated:YES];
}

#pragma mark - RMDateSelectionViewController Delegates
- (void)dateSelectionViewController:(RMDateSelectionViewController *)vc didSelectDate:(NSDate *)aDate {
	//Do something
	NSLog(@"%@", aDate);

	NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
	[formatter setDateStyle:NSDateFormatterMediumStyle];
	[formatter setTimeStyle:NSDateFormatterShortStyle];
	[formatter setDateFormat:@"YYYY-MM-dd HH:mm"];
	NSTimeZone *timeZone = [NSTimeZone defaultTimeZone];
	[formatter setTimeZone:timeZone];
	deadlineTime = [formatter stringFromDate:aDate];
	deadlineTextField.text = [[PublicMethodsViewController getPublicMethods] datewithstringEnglist:aDate];
}

- (void)dateSelectionViewControllerDidCancel:(RMDateSelectionViewController *)vc {
	//Do something else
}

- (IBAction)showMoreMember:(UIButton *)sender {
	MemberListViewController *memberListVc = [[MemberListViewController alloc] init];
	memberListVc.isMemberObj = YES;  //表示数组中专递的是封装的对象 不是字典
	memberListVc.memberArr = inviteeFriendArr;
	[self presentViewController:memberListVc animated:YES completion:nil];
}

- (void)onClickAddActiveEvent {
	if (!_activeEventTitle.text || [@"" isEqualToString:_activeEventTitle.text]) {
		[MBProgressHUD showError:@"Must fill in the Event Title"];
		return;
	}

	NSMutableDictionary *activeDic =  [NSMutableDictionary dictionaryWithCapacity:0];

	[activeDic setObject:_activeEventTitle.text forKey:@"title"];
	if (newVoteArr.count <= 0) {
		[MBProgressHUD showError:@"Must fill in the New vote"];
		return;
	}
	if (localfiled.text) {
		[activeDic setObject:localfiled.text forKey:@"location"];
	}
	if (notefiled.text) {
		[activeDic setObject:notefiled.text forKey:@"note"];
	}

	[activeDic setObject:@(voteAndFixTimeType) forKey:@"type"];
	[activeDic setObject:@(allowAddTime) forKey:@"addTime"];

	if (isEdit) {
		if (voteAndFixTimeType == 2) {
			if (voteDateArr.count < 2) {
				[MBProgressHUD showError:@"Must fill in vote date"];
				return;
			}
			if (!deadlineTextField.text || [@"" isEqualToString:deadlineTextField.text]) {
				[MBProgressHUD showError:@"Must fill in the deadline"];
				return;
			}
			[activeDic setObject:deadlineTime forKey:@"voteEndTime"];
		}
		else {
			if (fixDateArr.count <= 0) {
				return;
			}
			[activeDic setObject:[fixDateArr JSONString] forKey:@"time"];
		}
		if (updateVoteArr && updateVoteArr.count > 0) {
			[activeDic setObject:updateVoteArr forKey:@"evListUpdate"];
		}

		[activeDic setObject:self.activeEventMode.Id forKey:@"id"];
		if (deleteVoteTimeArr && deleteVoteTimeArr.count > 0) {
			[activeDic setObject:deleteVoteTimeArr forKey:@"timeDel"];
		}

		if (addvoteTimeArr && addvoteTimeArr.count > 0) {
			[activeDic setObject:addvoteTimeArr forKey:@"timeAdd"];
		}

		if (addVoteArr.count > 0) {
			for (NSMutableDictionary *tmpDic in addVoteArr) {
				NSString *tmpId = [NSString stringWithFormat:@"%@", [tmpDic objectForKey:@"id"]];
				if ([tmpId hasPrefix:@"option"]) {
					[tmpDic removeObjectForKey:@"id"];
				}
			}
			[activeDic setObject:addVoteArr forKey:@"evListAdd"];
		}
		if (deleteVoteArr.count > 0) {
			[activeDic setObject:deleteVoteArr forKey:@"evListdel"];
		}

		NSString *activeDicJson = [activeDic JSONString];


		ASIHTTPRequest *addActiveRequest = [t_Network httpPostValue:@{ @"event":activeDicJson }.mutableCopy Url:anyTime_UpdateEvents Delegate:self Tag:anyTime_UpdateEvents_tag];
		[addActiveRequest startAsynchronous];

		return;
	}


	if (voteAndFixTimeType == 2) {
		if (voteDateArr.count < 2) {
			[MBProgressHUD showError:@"Must fill in vote date"];
			return;
		}
		if (!deadlineTextField.text || [@"" isEqualToString:deadlineTextField.text]) {
			[MBProgressHUD showError:@"Must fill in the deadline"];
			return;
		}
		[activeDic setObject:deadlineTime forKey:@"veTime"];
		[activeDic setObject:[voteDateArr JSONString] forKey:@"time"];
	}
	else {
		if (fixDateArr.count <= 0) {
			return;
		}
		[activeDic setObject:[fixDateArr JSONString] forKey:@"time"];
	}

	if (newVoteArr && newVoteArr.count > 0) {//新增数据时去掉id
		for (NSMutableDictionary *dic  in newVoteArr) {
			[dic removeObjectForKey:@"id"];
		}
	}

	[activeDic setObject:[newVoteArr JSONString] forKey:@"eventVote"];
	[activeDic setObject:[inviteeArr JSONString] forKey:@"member"];
	NSLog(@"%@", activeDic);
	ASIHTTPRequest *addActiveRequest = [t_Network httpPostValue:activeDic Url:anyTime_AddEvents Delegate:self Tag:anyTime_AddEvents_tag];
	[addActiveRequest startAsynchronous];
}

- (void)requestFinished:(ASIHTTPRequest *)request {
	NSString *requestStr =  [request responseString];
	NSDictionary *dic = [requestStr objectFromJSONString];

	switch (request.tag) {
		case anyTime_AddEvents_tag:
		{
			NSString *statusCode = [dic objectForKey:@"statusCode"];
			NSError *error = [request error];
			if (error) {
				[MBProgressHUD showError:@"save fail"];
				return;
			}
			if ([statusCode isEqualToString:@"1"]) {
				id tmpData = [dic objectForKey:@"data"];
				if ([tmpData isKindOfClass:[NSDictionary class]]) {
					[MBProgressHUD showSuccess:@"Save Success"];

					NSDictionary *tmpDic = (NSDictionary *)tmpData;
					NSString *activeId = [tmpDic objectForKey:@"id"];
					//上传活动图片
					NSURL *url = [NSURL URLWithString:[anyTime_EventAddPhoto stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
					ASIFormDataRequest *uploadImageRequest = [ASIFormDataRequest requestWithURL:url];
					[uploadImageRequest setRequestMethod:@"POST"];
					[uploadImageRequest setPostValue:activeId forKey:@"eid"];
					NSData *data = UIImagePNGRepresentation(_activeImgView.image);
					NSMutableData *imageData = [NSMutableData dataWithData:data];
					[uploadImageRequest setStringEncoding:NSUTF8StringEncoding];
					[uploadImageRequest setPostFormat:ASIMultipartFormDataPostFormat];
					//[uploadImageRequest setPostValue:photoDescribe forKey:@"photoContent"];
					NSString *tmpDate = [[PublicMethodsViewController getPublicMethods] getcurrentTime:@"yyyyMMddss"];

					[uploadImageRequest addData:imageData withFileName:[NSString stringWithFormat:@"%@.jpg", tmpDate]  andContentType:@"image/jpeg" forKey:@"f1"];
					[uploadImageRequest setTag:anyTime_EventAddPhoto_tag];
					__block ASIFormDataRequest *uploadRequest = uploadImageRequest;
					[uploadImageRequest setCompletionBlock: ^{
					    NSString *responseStr = [uploadRequest responseString];
					    NSLog(@"数据更新成功：%@", responseStr);
					    id obj = [responseStr objectFromJSONString];
					    if ([obj isKindOfClass:[NSDictionary class]]) {
					        NSDictionary *tmpDic = (NSDictionary *)obj;
					        int statusCode = [[tmpDic objectForKey:@"statusCode"] integerValue];
					        if (statusCode == 1) {
					            [self.navigationController popViewControllerAnimated:YES];
							}
						}
					}];

					[uploadImageRequest setFailedBlock: ^{
					    NSLog(@"请求失败：%@", [uploadRequest responseString]);
					    [MBProgressHUD showError:@"Please connect to the Internet"];
					}];
					[uploadImageRequest startAsynchronous];
				}
			}
			else {
				[MBProgressHUD showError:[dic objectForKey:@"message"]];
			}
		}
		break;

		case anyTime_UpdateEvents_tag: {
			NSString *statusCode = [dic objectForKey:@"statusCode"];
		}
		break;

		default:
			break;
	}
}

- (void)requestFailed:(ASIHTTPRequest *)request {
}

#pragma mark - 时间选择viewController的代理方法 settimedelegate
- (void)getstarttime:(NSString *)start getendtime:(NSString *)end isAllDay:(BOOL)isAll {
	if (start && end) {
		[self addVoteDateWithEventStartTime:start endTime:end isAllDay:isAll];
		if (_selectedBtnIndex == 1) {// Fix a Date
			[_tableView    reloadData];
			return;
		}
		voteDateOfSections = voteDateOfSections + 1;
		UIView *voteView = (UIView *)_voteAndFixViewArr[0];
		[voteTableView setFrame:CGRectMake(0, 0, kScreen_Width, voteDateOfSections * voteTableViewCellHight + footerCellHeight)];
		[voteView setFrame:CGRectMake(0, voteAndFixHeight, kScreen_Width, voteDateOfSections * voteTableViewCellHight + footerCellHeight)];
		[voteTableView reloadData];
		[_tableView    reloadData];
	}
}

- (void)addVoteDateWithEventStartTime:(NSString *)start endTime:(NSString *)end isAllDay:(BOOL)isAll {
	NSMutableDictionary *voteDateDic = [NSMutableDictionary dictionary];
	//开始时间
	NSDate *startDate = [[PublicMethodsViewController getPublicMethods] formatWithStringDate:start];
	//结束时间
	NSDate *endDate = [[PublicMethodsViewController getPublicMethods] formatWithStringDate:end];


	NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
	[formatter setDateStyle:NSDateFormatterMediumStyle];
	[formatter setTimeStyle:NSDateFormatterShortStyle];
	[formatter setDateFormat:@"YYYY-MM-dd HH:mm"];
	NSTimeZone *timeZone = [NSTimeZone defaultTimeZone];
	[formatter setTimeZone:timeZone];

	[voteDateDic setObject:[formatter stringFromDate:startDate] forKey:@"startTime"];
	[voteDateDic setObject:[formatter stringFromDate:endDate] forKey:@"endTime"];
	[voteDateDic setObject:isAll ? @(1) : @(0) forKey:@"allDay"];
	if (_selectedBtnIndex == 1) {// Fix a Date
		[fixDateArr removeAllObjects];
		[fixDateArr addObject:voteDateDic];
	}
	else {
		[voteDateArr addObject:voteDateDic];
	}
	if (isEdit) {//是修改数据才记录新增的数据    \\可能有问题
		[voteDateArr addObject:voteDateDic];
		[addvoteTimeArr addObject:voteDateDic];
	}
}

#pragma mark -代理方法 -- getlocation:coordinate:
- (void)getlocation:(NSString *)name coordinate:(NSDictionary *)coordinatesDic {
	localfiled.text = name;
}

//生成唯一个eventId
- (NSString *)generateUniqueOptonId {
	NSString *prefix = @"option";
	NSDate *newDate = [NSDate date];
	NSDateFormatter *df = [[NSDateFormatter alloc] init];
	[df setDateFormat:@"YYYYMdHHmmss"];
	NSString *dateStr = [df stringFromDate:newDate];
	NSInteger random = arc4random() % 10000 + 1;
	return [NSString stringWithFormat:@"%@%@%d", prefix, dateStr, random];
}

@end
