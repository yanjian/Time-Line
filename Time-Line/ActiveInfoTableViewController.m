//
//  ActiveInfoTableViewController.m
//  Go2
//
//  Created by IF on 15/4/2.
//  Copyright (c) 2015年 zhilifang. All rights reserved.
//

#import "ActiveInfoTableViewController.h"
#import "NavigationViewController.h"
#import "UIImageView+WebCache.h"
#import "UserInfo.h"

static NSString * EventInvitedId   = @"EventInvitedId";
static NSString * EventDescId      = @"EventDescId";
static NSString * EventLocationId  = @"EventLocationId";
static NSString * EventTimeId      = @"EventTimeId";



#define EventInvitedTableViewHeightOfCell 55.f 
#import "ActiveVoteTimeModel.h"
#include "MemberDataModel.h"
#import "InviteesJoinOrReplyTableViewController.h"

#import "ActiveVotingViewController.h"
#import "EventDescTableViewCell.h"
#import "EventTimeTableViewCell.h"
#import "EventLocationTableViewCell.h"
#import "EventInteeTableViewCell.h"
#import "FriendInfoTableViewCell.h"
#import "UITableView+FDTemplateLayoutCell.h"
#import "EventConfirmTimeTableViewController.h"

@interface ActiveInfoTableViewController ()<ASIHTTPRequestDelegate,EventInvitedTableViewDataSource,EventInvitedTableViewDelegate,EventTimeTableViewCellDelegate,ActiveVotingViewControllerDelegate,EventConfirmTimeTableViewControllerDelegate>{
    NSString * _userId;
    NSDictionary * _activeCreatorDic;//活动创建者信息
    NSMutableArray * timeArr ;
    ActiveTimeVoteMode * activeTime ;
    
}
@property (nonatomic,strong)  MKMapView    * vMap ;

@end

@implementation ActiveInfoTableViewController
@synthesize activeEvent ;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _userId = [UserInfo currUserInfo].Id;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone ;
    
    [self.tableView registerNib:[UINib nibWithNibName:@"EventInteeTableViewCell" bundle:nil] forCellReuseIdentifier:EventInvitedId];
    
    [self.tableView registerNib:[UINib nibWithNibName:@"EventDescTableViewCell" bundle:nil] forCellReuseIdentifier:EventDescId];
    
    [self.tableView registerNib:[UINib nibWithNibName:@"EventLocationTableViewCell" bundle:nil] forCellReuseIdentifier:EventLocationId];
    
    [self.tableView registerNib:[UINib nibWithNibName:@"EventTimeTableViewCell" bundle:nil] forCellReuseIdentifier:EventTimeId];
//    self.tableView.rowHeight = UITableViewAutomaticDimension;
//    self.tableView.estimatedRowHeight = 170 ;
    
    //从邀请的人员中得到创建者!(因为创建者必须参加)
    [self.activeEvent.invitees enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSString * inviteeId = [[obj objectForKey:@"user"] objectForKey:@"id"];
        if ([self.activeEvent.createId isEqualToString:inviteeId]) {
             _activeCreatorDic = [obj objectForKey:@"user"];
        }
    }];
    
    timeArr = @[].mutableCopy ;
    for (NSDictionary *timeDic in self.activeEvent.proposeTimes) {
        ActiveTimeVoteMode * activeTimeVoet = [ActiveTimeVoteMode modelWithDictionary:timeDic]  ;
        [timeArr addObject:activeTimeVoet];
        if ([activeTimeVoet.status intValue] == 1 ) { //1.创建者已经确定时间了！
            activeTime = activeTimeVoet ;
        }
    }
    
}

- (NSString *)segmentTitle{
    return @"INFO" ;
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
   
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 4;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
     return 1;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if ( indexPath.section == 2 && indexPath.row == 0 ) {
        NSInteger intiedCount = activeEvent.invitees.count>3?3:activeEvent.invitees.count ;//默认只显示3个参加的人
        return  115.f + intiedCount * EventInvitedTableViewHeightOfCell;
    }else if(indexPath.section == 3 && indexPath.row == 0 ){
        return  245.f ;
    }
    return  175.f;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
     return 10.f ;
}

-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 0.01f;
}



- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0 && indexPath.row == 0) {
        EventDescTableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:@"EventDescId"];
        cell.eventTitle.text = activeEvent.title ;
        cell.eventDesc.text  = activeEvent.enventDesc ;
        
        NSString *_urlStr = [[NSString stringWithFormat:@"%@%@", BaseGo2Url_IP, [_activeCreatorDic objectForKey:@"thumbnail"]] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        NSURL *url = [NSURL URLWithString:_urlStr];

        cell.eventCreatName.text = [NSString stringWithFormat:@"By %@",[_activeCreatorDic objectForKey:@"username"]];
        [cell.eventCreatorImg sd_setImageWithURL:url placeholderImage:[UIImage imageNamed:@"smile_1"]];
        
        return cell;
    }else if(indexPath.section == 2 && indexPath.row == 0 ){
        EventInteeTableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:@"EventInvitedId"];
        if ( !cell.dataSource ) {
             cell.dataSource = self ;
        }
        if ( !cell.delegate ) {
            cell.delegate = self ;
        }
        
        cell.eventInvitedCount.text = [NSString stringWithFormat:@"%lu invited",(unsigned long)activeEvent.invitees.count];
       
        return cell;

    }else if ( indexPath.section == 3 && indexPath.row == 0 ) {
        EventLocationTableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:@"EventLocationId"];
        NSDictionary * locationDic = (NSDictionary *)[activeEvent.location objectFromJSONString];
        cell.eventLocationName.text = [locationDic objectForKey:@"location"];
        
        [cell.locationShowMapView.subviews enumerateObjectsUsingBlock:^(__kindof UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            [obj removeFromSuperview] ;
        }];
        
        CGRect mapRect =  cell.locationShowMapView.frame ;
        self.vMap.frame = mapRect ;
        self.vMap.centerCoordinate = CLLocationCoordinate2DMake([[locationDic objectForKey:@"latitude"] doubleValue], [[locationDic objectForKey:@"longitude"] doubleValue]);
        MKPointAnnotation *annotation = [[MKPointAnnotation alloc] init];
        annotation.coordinate = self.vMap.centerCoordinate;
        annotation.title = [locationDic objectForKey:@"location"];
        
        [self.vMap addAnnotation:annotation];
        [cell.locationShowMapView addSubview:self.vMap]  ;
        
        [self.vMap mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(cell.locationShowMapView).with.offset(0);
            make.left.equalTo(cell.locationShowMapView).with.offset(0);
            make.bottom.equalTo(cell.locationShowMapView).with.offset(-0);
            make.right.equalTo(cell.locationShowMapView).with.offset(-0);
        }];
        return cell;
    }else{
        EventTimeTableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:@"EventTimeId"];
        if ( !cell.delegate ) {
            cell.delegate = self ;
        }
        cell.createHost = [[UserInfo currUserInfo].Id isEqualToString:activeEvent.createId] ? YES : NO ;
        
        if ([activeTime.status intValue] == 1) {//创建者确定了时间
             cell.activeVoteTime = activeTime;//不要同下面的顺序颠倒
             cell.timeConfirmed = YES ;
        }else{
            [activeEvent.voteRecords enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                NSDictionary * voteRecordsDic =  (NSDictionary *)obj;
                NSString * uidStr = [voteRecordsDic objectForKey:@"uid"];
                if ( uidStr != nil &&  [uidStr isEqualToString:[UserInfo currUserInfo].Id] ) {
                    cell.timeConfirmed = NO ;//用户对时间已经投票（但创建者还没有确定时间）
                    * stop = YES ;
                }
            }];
        }
        return cell;
    }
}


- (NSInteger)eventInvitedTableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return activeEvent.invitees.count;
}

-(CGFloat)eventInvitedTableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return EventInvitedTableViewHeightOfCell ;
}

- (UITableViewCell *)eventInvitedTableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    FriendInfoTableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:@"EventInvitedIds"];
    if (!cell) {
         cell = (FriendInfoTableViewCell *)[[[UINib nibWithNibName:@"FriendInfoTableViewCell" bundle:nil] instantiateWithOwner:nil options:nil] firstObject];
        cell.addFriendBtn.hidden = YES ;
    }
    NSDictionary * tmpDic = [activeEvent.invitees[indexPath.row] objectForKey:@"user"];
    NSString *imgSmall = [tmpDic objectForKey:@"thumbnail"];
    NSString *_urlStr = [[NSString stringWithFormat:@"%@%@", BaseGo2Url_IP, imgSmall] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        NSURL *url = [NSURL URLWithString:_urlStr];
        [cell.userHead sd_setImageWithURL:url placeholderImage:[UIImage imageNamed:@"smile_1"] completed:nil];
    cell.nickName.text =[tmpDic objectForKey:@"username"];
    cell.userNote.text =[tmpDic objectForKey:@"nickname"];
    return cell ;
}

#pragma mark - 关闭投票（创建者 confirmed 时间）
-(void)closePoll:(EventTimeTableViewCell *)cell{
    
   NSMutableArray * etArr = @[].mutableCopy ;
    for (NSDictionary *etDic in self.activeEvent.voteRecords) {
        ActiveVoteTimeModel *activeVote = [[ActiveVoteTimeModel alloc] init];
        [activeVote parseDictionary:etDic];
        [etArr addObject:activeVote];
    }

    EventConfirmTimeTableViewController *eventConfirmVc = [[EventConfirmTimeTableViewController alloc] init];
    eventConfirmVc.timeArr = timeArr ;
    eventConfirmVc.etArr   = etArr ;
    eventConfirmVc.eid     = self.activeEvent.Id ;
    eventConfirmVc.delegate = self ;
    [self.navigationController pushViewController:eventConfirmVc animated:YES];
}

#pragma mark - 重新启动投票
-(void)reopenPoll:(EventTimeTableViewCell *)cell {
    
}

#pragma mark - 用户选择投票时间 button  EventTimeTableViewCell  的 代理
-(void)chooseYourAvailability:(EventTimeTableViewCell *)cell {
    ActiveVotingViewController *activeVotingVC = [[ActiveVotingViewController alloc] init];
    activeVotingVC.activeEvent = self.activeEvent ;
    activeVotingVC.delegate    = self ;
    NavigationViewController *navC= [[NavigationViewController alloc] initWithRootViewController:activeVotingVC];
    navC.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName:[UIColor whiteColor]};
    [navC.navigationBar setBarTintColor: RGB(39, 135, 237)];
    [self presentViewController:navC animated:YES completion:nil];
}

#pragma mark -  显示活动的所有成员 -- EventInteeTableViewCell 的 代理
-(void)showAllInviteesMemberWithEventCell:(EventInteeTableViewCell *)eventInteeCell{
    InviteesJoinOrReplyTableViewController * inviteesJoinOrReplyVC = [[InviteesJoinOrReplyTableViewController alloc] init];
    
    NSMutableArray * memberArr = @[].mutableCopy ;
    for (NSDictionary *memDic in self.activeEvent.invitees) {
        MemberDataModel * member = [MemberDataModel modelWithDictionary:memDic];
        [memberArr addObject:member];
    }
    inviteesJoinOrReplyVC.isOpenModel = YES ;
    inviteesJoinOrReplyVC.memberArr   = memberArr ;
    NavigationViewController *navC= [[NavigationViewController alloc] initWithRootViewController:inviteesJoinOrReplyVC];
    navC.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName:[UIColor whiteColor]};
    [navC.navigationBar setBarTintColor: RGB(39, 135, 237)];
    [self presentViewController:navC animated:YES completion:nil];
}


#pragma mark - 创建者确定时间后用于回调的方法 --（刷新数据）  EventConfirmTimeTableViewController的代理
-(void)eventConfirmTimeTableViewControllerDelegate:(EventConfirmTimeTableViewController *) eventConfirmVC setTimeId:(NSString *)tid{
    for (ActiveTimeVoteMode *tmpATime in timeArr) {
        if ([ tmpATime.Id isEqualToString: tid ]   ) {
            [tmpATime setValue:@(1) forKey:@"status"] ; //修改status的值为1 表示用户已经确定时间
            activeTime = tmpATime ;
            [self.tableView reloadData];
            break ;
        }
    }
}

#pragma mark -用户对时间投票后 -- 刷新该活动数据      ActiveVotingViewController的代理
-(void)refreshDataWithCloseController:(ActiveVotingViewController *) vc isRefresh:(BOOL)refresh {
    
    [vc dismissViewControllerAnimated:YES completion:^{
        if (refresh) {
             [self refreshActiveEventData:self.activeEvent.Id] ;
        }
        
    }];
}


#pragma mark - 重新刷新数据：网络 --- eventId 活动id
-(void)refreshActiveEventData:(NSString *)eventId{
    ASIHTTPRequest * aEventRequest = [t_Network httpPostValue:@{@"method":@"getAllSocials",@"eid":eventId }.mutableCopy
                                                          Url:Go2_socials
                                                     Delegate:self
                                                          Tag:Go2_getOneSocials_Tag];
    [aEventRequest startSynchronous];
}



#pragma mark - 网络请求代理
- (void)requestFinished:(ASIHTTPRequest *)request {
    NSString *responseStr = [request responseString];
    NSDictionary *tmpDic = [responseStr objectFromJSONString];
    switch (request.tag) {
        case Go2_JoinEvent_tag:
        {
            int statusCode = [[tmpDic objectForKey:@"statusCode"] intValue];
            if ( statusCode  == 1 ) {
                [MBProgressHUD showSuccess:@"Success！"];
                [self refreshActiveEventData:self.activeEvent.Id] ;
            }
        }
            break;
        case Go2_getOneSocials_Tag:{
            int statusCode = [[tmpDic objectForKey:@"statusCode"] intValue];
            if ( statusCode == 1 ) {
                NSDictionary * dataDic = [[tmpDic objectForKey:@"datas"] lastObject];
                activeEvent = [ActiveEventModel modelWithDictionary:dataDic];
                [self.tableView reloadData];
            }
        }break;
        default:
            break;
    }
}



#pragma mark - 格式化时间Date
- (NSDate *)StringToDate:(NSString *)format formaterDate:(NSString *) dateStr {
    NSDateFormatter *formatter =  [[NSDateFormatter alloc] init];
    [formatter setDateFormat:format];
    NSTimeZone *timeZone = [NSTimeZone timeZoneWithName:SYS_DEFAULT_TIMEZONE];
    [formatter setTimeZone:timeZone];
    NSDate *loctime = [formatter dateFromString:dateStr];
    NSLog(@"%@", loctime);
    return loctime;
}





-(MKMapView *)vMap{
    if (!_vMap) {
        _vMap = [[MKMapView alloc] initWithFrame:CGRectZero];
        _vMap.delegate = self;
        _vMap.camera.altitude = 20;
        _vMap.showsBuildings = YES;
        _vMap.zoomEnabled = NO ;
        _vMap.scrollEnabled = NO ;
        
    }
    return _vMap;
}
@end
