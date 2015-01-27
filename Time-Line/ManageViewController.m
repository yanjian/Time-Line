//
//  ManageViewController.m
//  Time-Line
//
//  Created by IF on 14/12/5.
//  Copyright (c) 2014年 zhilifang. All rights reserved.
//

#import "ManageViewController.h"
#import "MJRefresh.h"
#import "ActiveEventMode.h"
#import "ActiveTableViewCell.h"
#import "UIImageView+WebCache.h"
#import "CalendarDateUtil.h"
#import "ActivedetailsViewController.h"
#import "JCMSegmentPageController.h"

typedef NS_ENUM(NSInteger, ShowActiveType){
    ShowActiveType_All    = 0 ,
    ShowActiveType_Create = 1 ,
    ShowActiveType_Join   = 2 ,
    ShowActiveType_Hide   = 3
    
} ;


typedef NS_ENUM(NSInteger, ActiveStatus){
    ActiveStatus_upcoming       = 0 ,
    ActiveStatus_toBeConfirm    = 1 ,
    ActiveStatus_confirmed      = 2 ,
    ActiveStatus_past           = 3
} ;



@interface ManageViewController ()<UITableViewDelegate, UITableViewDataSource,
UIScrollViewDelegate,ASIHTTPRequestDelegate,ActivedetailsViewControllerDelegate>
{
    NSMutableArray * _activeArr; //暂时没有用
    NSMutableArray * _tmpActiveArr ;
    
    NSString       * currId ;
    
    ShowActiveType   _showActiveType ;
    NSMutableArray * _selectActiveBtnArr ;

}
@property (strong, nonatomic) IBOutlet UITableView *tableView;
@end

@implementation ManageViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    CGRect frame = CGRectMake(0, 0, kScreen_Width, kScreen_Height);
    self.view.frame=frame;
    
    currId = [UserInfo currUserInfo].Id;
    
    _showActiveType = ShowActiveType_All ;
    
    _selectActiveBtnArr = [NSMutableArray array];
    
    UIView *selectView = [[UIView alloc] initWithFrame:CGRectMake(0, 1, frame.size.width, 25)];
    for (int i=0; i<4; i++) {
        UIButton *allBtn = [[UIButton alloc] initWithFrame:CGRectMake(frame.size.width/4*i, 0, frame.size.width/4, 25)];
        [allBtn setBackgroundImage:[UIImage imageNamed:@"TIme_Start"] forState:UIControlStateSelected];
         allBtn.titleLabel.font = [UIFont systemFontOfSize:12.f];
        if ( i == 0 ) {
            [allBtn setSelected:YES];
            _showActiveType = ShowActiveType_All ;
            [allBtn setTitle:@"ALL" forState:UIControlStateNormal];
        }else if(i == 1){
            [allBtn setTitle:@"Create" forState:UIControlStateNormal];
        }else if( i == 2){
            [allBtn setTitle:@"Join" forState:UIControlStateNormal];
        }else if( i==3 ){
            [allBtn setTitle:@"Hide" forState:UIControlStateNormal];
        }
        allBtn.tag = i ;
        [allBtn addTarget:self action:@selector(clickTouchUpInside:) forControlEvents:UIControlEventTouchUpInside];
        [selectView addSubview:allBtn];
        [_selectActiveBtnArr addObject:allBtn];
    }
    
    [selectView setBackgroundColor:blueColor];
    [self.view addSubview:selectView];
    
    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0,
                                                                   selectView.frame.size.height,
                                                                   frame.size.width,
                                                                   frame.size.height-(selectView.frame.size.height+selectView.frame.origin.y+naviHigth))
                                                  style:UITableViewStyleGrouped];
    self.tableView.delegate=self;
    self.tableView.dataSource=self;
    [self.view  addSubview:self.tableView];
    
    [self setupRefresh];
}


/**
 *  集成刷新控件
 */
- (void)setupRefresh
{
    // 1.下拉刷新(进入刷新状态就会调用self的headerRereshing)
    // dateKey用于存储刷新时间，可以保证不同界面拥有不同的刷新时间
    [self.tableView addHeaderWithTarget:self action:@selector(headerRereshing) dateKey:@"mamageV"];
    
    [self.tableView headerBeginRefreshing];
    
    // 2.上拉加载更多(进入刷新状态就会调用self的footerRereshing)
    [self.tableView addFooterWithTarget:self action:@selector(footerRereshing)];
    
}

#pragma mark 开始进入刷新状态
- (void)headerRereshing
{
     [self loadActiveData:nil];//刷新数据
     [self.tableView headerEndRefreshing];
}

- (void)footerRereshing
{
  [self.tableView footerEndRefreshing];
}



-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
   
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView;{
    return _tmpActiveArr.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
   return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 215.f;
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 2.f;
}
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 0.1f;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *activeId=@"activeManagerCellId";
    ActiveTableViewCell *activeCell=[tableView dequeueReusableCellWithIdentifier:activeId];
    if (!activeCell) {
        activeCell = (ActiveTableViewCell*)[[[NSBundle mainBundle] loadNibNamed:@"ActiveTableViewCell" owner:self options:nil] firstObject];
    }
    if (_tmpActiveArr.count>0) {
        ActiveBaseInfoMode *activeEvent = _tmpActiveArr[indexPath.section];
        
//        for (NSDictionary * member in activeEvent.member) {
//            if ([currId isEqualToString:[[member objectForKey:@"uid"] stringValue]]) {
//                NSInteger view = [[member objectForKey:@"view"] integerValue];
//                NSInteger not = [[member objectForKey:@"notification"] integerValue];
//                if ( view == 1 ) {//1 表示显示活动
//                    activeCell.isView = YES;
//                }else{
//                    activeCell.isView = NO;
//                }
//                if (not == 1) {
//                     activeCell.isNotification = YES;
//                }else{
//                    activeCell.isNotification = NO;
//                }
//            }
//        }

        activeCell.activeEvent = activeEvent ;
        
        if([activeEvent.status integerValue] == ActiveStatus_upcoming ){
            if ([activeEvent.type integerValue]== 2) {
                activeCell.activeStateLab.text = @"UpComing(Voting)" ;
            }else{
                activeCell.activeStateLab.text = @"UpComing" ;
            }
        }else if  ([activeEvent.status integerValue] == ActiveStatus_toBeConfirm ){
            activeCell.activeStateLab.text = @"To be Confirm" ;
        }else if  ([activeEvent.status integerValue] == ActiveStatus_confirmed ){
            activeCell.activeStateLab.text = @"Confirmed" ;
        }else if  ([activeEvent.status integerValue] == ActiveStatus_past ){
            activeCell.activeStateLab.text = @"Past" ;
        }
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setDateStyle:NSDateFormatterMediumStyle];
        [formatter setTimeStyle:NSDateFormatterShortStyle];
        [formatter setDateFormat:@"YYYY-MM-dd HH:mm"];
        NSTimeZone* timeZone = [NSTimeZone defaultTimeZone];
        [formatter setTimeZone:timeZone];
        
        NSDate * createTime = [formatter dateFromString:activeEvent.createTime];
        NSInteger currMonth = [CalendarDateUtil getMonthWithDate:createTime];
        NSInteger currDay = [CalendarDateUtil getDayWithDate:createTime];
        activeCell.monthLab.text = [self monthStringWithInteger:currMonth];
        activeCell.dayCountLab.text =[NSString stringWithFormat:@"%ld",(long)currDay];
        NSString *_urlStr=[[NSString stringWithFormat:@"%@/%@",BASEURL_IP,activeEvent.imgUrl] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        NSLog(@"%@",_urlStr);
        NSURL *url=[NSURL URLWithString:_urlStr];
        [activeCell.activeImg sd_setImageWithURL:url placeholderImage:[UIImage imageNamed:@"018"]];
        activeCell.activeNameLab.text = activeEvent.title;
    }
    
    return activeCell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
     [tableView deselectRowAtIndexPath:indexPath animated:YES];
     ActivedetailsViewController *activeDetailVC = [[ActivedetailsViewController alloc] init];
     ActiveBaseInfoMode * activeEvent = _tmpActiveArr[indexPath.section];
     activeDetailVC.delegate = self;
     activeDetailVC.activeEventInfo = activeEvent;
    [self.navigationController pushViewController:activeDetailVC animated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

-(void) loadActiveData:(void(^)())AddHUD{
     _tmpActiveArr= [NSMutableArray arrayWithCapacity:0];
    if (AddHUD) {
        AddHUD();
    }
    ASIHTTPRequest * activeRequest = [t_Network httpGet:nil Url:anyTime_GetEventBasicInfo Delegate:self Tag:anyTime_GetEventBasicInfo_tag];
    [activeRequest setDownloadCache:g_AppDelegate.anyTimeCache] ;
    [activeRequest setCachePolicy:ASIFallbackToCacheIfLoadFailsCachePolicy|ASIAskServerIfModifiedWhenStaleCachePolicy];
    [activeRequest setCacheStoragePolicy:ASICachePermanentlyCacheStoragePolicy] ;
    [activeRequest startAsynchronous];
}

-(void)clickTouchUpInside:(UIButton *) sender {
    for (UIButton *button in _selectActiveBtnArr) {
        button.selected = NO;
    }
    sender.selected = YES;
    if (_showActiveType != sender.tag) {//这里tag 的值 要与 _showActiveType的值一致 好处理
        [self showActiveWhatWithActiveType:sender.tag];
        [_tableView reloadData];
    }
}

#pragma mark -对数据进行过滤 --如
-(void)showActiveWhatWithActiveType:(NSInteger) activeType{
     [_activeArr removeAllObjects];
    switch (activeType) {
        case 0:{
            _showActiveType = ShowActiveType_All ;
            for (ActiveEventMode *eventMode in _tmpActiveArr) {//显示create的活动
                [_activeArr addObject:eventMode];
            }
        }break;
        case 1:{
            _showActiveType = ShowActiveType_Create ;
            for (ActiveEventMode *eventMode in _tmpActiveArr) {//显示create的活动
                NSString * create =[NSString stringWithFormat:@"%@",eventMode.create ] ;
                if ([create isEqualToString:currId]) {
                    [_activeArr addObject:eventMode];
                }
            }
        }break;
        case 2:{
            _showActiveType = ShowActiveType_Join ;
            for (ActiveEventMode *eventMode in _tmpActiveArr) {//显示join的活动===这里显示的时别人邀请我参加的活动
                NSString *create = [NSString stringWithFormat:@"%@",eventMode.create];
                if (![currId isEqualToString:create]) {//创建活动的用户不是当前用户就是别人邀请的
                     [_activeArr addObject:eventMode];
                 }
//                for (NSDictionary * member in eventMode.member) {
//                    NSString * join = [[member objectForKey:@"join"] stringValue];
//                    if ([@"1" isEqualToString:join]) {
//                        [_activeArr addObject:eventMode];
//                    }
//                }
            }
        }break;
        case 3:{
            _showActiveType = ShowActiveType_Hide ;
            for (ActiveEventMode *eventMode in _tmpActiveArr) {//显示hide的活动
                for (NSDictionary * member in eventMode.member) {
                    if ([currId isEqualToString:[[member objectForKey:@"uid"] stringValue]]) {
                        NSString * view = [[member objectForKey:@"view"] stringValue];
                        if ([@"2" isEqualToString:view]) {
                            [_activeArr addObject:eventMode];
                        }
                 }
               }
            }
        }break;
        default:
            break;
    }
}

- (void)requestFinished:(ASIHTTPRequest *)request{
    NSError *error = [request error];
    if (error) {
        [MBProgressHUD showError:@"error"];
    }
    NSString * requestStr =  [request responseString];
    NSDictionary * dic = [requestStr objectFromJSONString];
    NSString * statusCode = [dic objectForKey:@"statusCode"];
    if ([@"1" isEqualToString:statusCode]) {
        id dataObj = [dic objectForKey:@"data"];
        if ([dataObj isKindOfClass:[NSArray class]]) {
            NSArray * activeArr = (NSArray *) dataObj ;
            for (int i = 0; i<activeArr.count; i++) {
                ActiveBaseInfoMode * activeEvent = [[ActiveBaseInfoMode alloc ] init];
                [activeEvent parseDictionary:activeArr[i]];
                [_tmpActiveArr addObject:activeEvent];
            }
        }
        [self.tableView reloadData];
    }else{
        [MBProgressHUD showError:@"Request Fail"];
    }
     [MBProgressHUD hideHUDForView:self.view animated:YES];
}

- (void)requestFailed:(ASIHTTPRequest *)request{
    NSError * error = [request error];
    if (error) {
        [MBProgressHUD hideHUDForView:self.view];
        [MBProgressHUD showError:@"Network error"];
    }
}


-(void)cancelActivedetailsViewController:(ActivedetailsViewController *)activeDetailsViewVontroller{
    [self loadActiveData:nil];//刷新数据
    
    for (UIViewController *viewController in activeDetailsViewVontroller.navigationController.viewControllers) {
        if ([viewController isKindOfClass:[JCMSegmentPageController class]]) {
             [activeDetailsViewVontroller.navigationController popToViewController:viewController animated:YES];
        }
    }
}


-(NSString *)monthStringWithInteger:(NSUInteger)month{
    NSString *monthStr;
    switch (month) {
        case 1:
            monthStr = @"JAN";
            break;
        case 2:
            monthStr = @"FEB";
            break;
        case 3:
            monthStr = @"MAR";
            break;
        case 4:
            monthStr = @"APR";
            break;
        case 5:
            monthStr = @"MAY";
            break;
        case 6:
            monthStr = @"JUN";
            break;
        case 7:
            monthStr = @"JUL";
            break;
        case 8:
            monthStr = @"AUG";
            break;
        case 9:
            monthStr = @"SEP";
            break;
        case 10:
            monthStr = @"OCT";
            break;
        case 11:
            monthStr = @"NOV";
            break;
        case 12:
            monthStr = @"DEC";
            break;
            
        default:
            break;
    }
    return monthStr;
}

@end
